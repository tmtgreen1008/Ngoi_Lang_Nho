class_name MusicSynth
extends RefCounted
## Nhạc nền sinh bằng mã: mỗi bản là một vòng lặp 8 ô nhịp, gồm giai điệu gảy (ngũ cung, đi bước ngẫu
## nhiên có hạt giống cố định nên luôn giống nhau), bè bass và nền hợp âm kéo dài. Mỗi mùa một giọng và
## nhịp riêng; mini-game nhanh và sáng hơn. Thả file assets/audio/music/<id>.ogg|mp3|wav để thay bằng nhạc thật.
##
## Dùng tần số lấy mẫu thấp ([constant RATE]) cho nhanh: bản nhạc nhẹ, ít nội dung cao tần. MusicManager
## dựng bản nhạc ở luồng nền nên không giật khi vào game.
##
## Vòng lặp liền mạch: phần đuôi của nốt cuối được cộng ngược vào đầu bản nhạc (quấn vòng).

const RATE: int = 11025
const BARS: int = 8
const BEATS_PER_BAR: int = 4
## Đỉnh âm lượng sau khi chuẩn hoá (chừa dư để không méo).
const PEAK: float = 0.6

## Thông số từng bản. root: nốt gốc (số MIDI); scale: các bậc ngũ cung (nửa cung); chords: gốc hợp âm của
## từng ô nhịp (nửa cung so với root, lặp lại); minor: hợp âm thứ (quãng ba 3 thay vì 4); density: xác suất
## có nốt trên mỗi phách nửa.
const TRACKS: Dictionary = {
	&"spring": {"root": 60, "scale": [0, 2, 4, 7, 9], "bpm": 84.0, "chords": [0, 7, 9, 5], "minor": false, "density": 0.55, "seed": 101},
	&"summer": {"root": 55, "scale": [0, 2, 4, 7, 9], "bpm": 100.0, "chords": [0, 5, 7, 5], "minor": false, "density": 0.7, "seed": 202},
	&"autumn": {"root": 57, "scale": [0, 3, 5, 7, 10], "bpm": 72.0, "chords": [0, 8, 5, 7], "minor": true, "density": 0.45, "seed": 303},
	&"winter": {"root": 62, "scale": [0, 3, 5, 7, 10], "bpm": 60.0, "chords": [0, 10, 8, 7], "minor": true, "density": 0.3, "seed": 404},
	&"minigame": {"root": 60, "scale": [0, 2, 4, 7, 9], "bpm": 128.0, "chords": [0, 9, 5, 7], "minor": false, "density": 0.8, "seed": 505},
}


static func track_ids() -> Array:
	return TRACKS.keys()


static func _hz(midi: float) -> float:
	return 440.0 * pow(2.0, (midi - 69.0) / 12.0)


## Cộng một nốt vào [param buffer] từ giây [param start], quấn vòng nếu vượt cuối bộ đệm.
## [param pad] = true: nền kéo dài (vào/ra mềm); false: nốt gảy (tắt theo hàm mũ).
static func _add_note(buffer: PackedFloat32Array, start: float, freq: float, dur: float, volume: float, pad: bool, triangle: bool, harmonic: float = 0.0) -> void:
	var length: int = buffer.size()
	var count: int = int(dur * RATE)
	var index: int = int(start * RATE) % length
	var phase: float = 0.0
	var step: float = freq / RATE
	var env: float = volume
	var decay: float = exp(-5.0 / maxf(count, 1.0))  # còn ~0,7% sau khi hết nốt
	for i: int in count:
		phase += step
		var p: float = phase - floorf(phase)
		var sample: float
		if triangle:
			sample = 4.0 * absf(p - 0.5) - 1.0
		else:
			sample = sin(TAU * p)
		if harmonic > 0.0:
			var p2: float = fmod(phase * 2.0, 1.0)
			sample = (sample + harmonic * sin(TAU * p2)) / (1.0 + harmonic)
		var gain: float
		if pad:
			var x: float = float(i) / count
			gain = minf(minf(x / 0.2, (1.0 - x) / 0.2), 1.0) * volume
		else:
			gain = minf(float(i) / 60.0, 1.0) * env  # 60 mẫu ~ 5 ms vào nhanh
			env *= decay
		buffer[index] += sample * gain
		index += 1
		if index >= length:
			index = 0


## Bộ đệm mẫu của bản nhạc [param id] (rỗng nếu không có).
static func render(id: StringName) -> PackedFloat32Array:
	if not TRACKS.has(id):
		return PackedFloat32Array()
	var config: Dictionary = TRACKS[id]
	var beat: float = 60.0 / float(config["bpm"])
	var bar: float = beat * BEATS_PER_BAR
	var length: int = int(bar * BARS * RATE)
	var buffer := PackedFloat32Array()
	buffer.resize(length)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(config["seed"])
	var scale: Array = config["scale"]
	var chords: Array = config["chords"]
	var root: int = config["root"]
	var third: int = 3 if bool(config["minor"]) else 4
	var density: float = config["density"]
	var scale_index: int = scale.size()  # bắt đầu ở quãng tám trên của bậc đầu

	for b: int in BARS:
		var t0: float = b * bar
		var chord_root: int = root + int(chords[b % chords.size()])
		# Nền hợp âm kéo dài (gốc, quãng ba, quãng năm) hơi dài hơn ô nhịp để nối liền sang ô sau.
		for interval: int in [0, third, 7]:
			_add_note(buffer, t0, _hz(chord_root + interval), bar * 1.15, 0.07, true, false)
		# Bass gảy ở phách 1 và 3.
		for beat_index: int in [0, 2]:
			_add_note(buffer, t0 + beat_index * beat, _hz(chord_root - 12), beat * 1.9, 0.2, false, false, 0.2)
		# Giai điệu: đi bước ngẫu nhiên trên ngũ cung, hai quãng tám.
		for e: int in BEATS_PER_BAR * 2:
			var on_beat: bool = e % 2 == 0
			if rng.randf() > (density + (0.25 if on_beat else -0.1)):
				continue
			scale_index = clampi(scale_index + rng.randi_range(-2, 2), 0, scale.size() * 2 - 1)
			var midi: int = root + 12 + int(scale[scale_index % scale.size()]) + 12 * (scale_index / scale.size())
			var dur: float = beat * 0.5 * rng.randf_range(1.5, 3.5)
			_add_note(buffer, t0 + e * beat * 0.5, _hz(midi), dur, 0.15 if on_beat else 0.11, false, true, 0.3)

	# Chuẩn hoá để đỉnh vừa phải, giữ nguyên tương quan giữa các bè.
	var peak: float = 0.0
	for sample: float in buffer:
		peak = maxf(peak, absf(sample))
	if peak > 0.0:
		var gain: float = PEAK / peak
		for i: int in length:
			buffer[i] *= gain
	return buffer


## Bản nhạc [param id] dạng AudioStreamWAV lặp vô hạn (hoặc null nếu không có).
static func build(id: StringName) -> AudioStreamWAV:
	var buffer: PackedFloat32Array = render(id)
	if buffer.is_empty():
		return null
	var data := PackedByteArray()
	data.resize(buffer.size() * 2)
	for i: int in buffer.size():
		data.encode_s16(i * 2, int(clampf(buffer[i], -1.0, 1.0) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.stereo = false
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = buffer.size()
	return stream
