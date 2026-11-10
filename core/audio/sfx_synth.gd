class_name SfxSynth
extends RefCounted
## Bộ tổng hợp âm thanh: tạo hiệu ứng âm thanh (AudioStreamWAV 16 bit, đơn âm) hoàn toàn bằng mã,
## nên game có tiếng mà không cần file âm thanh ngoài. Muốn thay bằng file thật thì thả file vào
## assets/audio/sfx/<id>.wav (hoặc .ogg); AudioManager ưu tiên file nếu có.
##
## Mỗi âm là một "công thức" ghép từ vài khối: [method tone] (nốt có quét tần số, hình sóng và độ tắt),
## [method noise] (tiếng ồn lọc thấp: bước chân, xúc đất) và [method mix] (xếp nhiều khối theo thời điểm,
## vd. hợp âm rải).

const RATE: int = 22050
enum Wave { SINE, SQUARE, TRIANGLE, SAW }

## Mọi âm có công thức ở [method build].
const SOUND_IDS: Array[StringName] = [
	&"click", &"tick", &"step", &"pickup", &"dig", &"plant", &"harvest", &"feed", &"wither",
	&"coin", &"sell", &"error", &"success", &"day", &"season", &"bell", &"shop_close",
	&"save", &"win", &"lose", &"minigame_start", &"whoosh",
	&"hit", &"miss", &"cue", &"pocket", &"stone", &"splash", &"sizzle",
]


static func _osc(wave: int, phase: float) -> float:
	var p: float = phase - floorf(phase)
	match wave:
		Wave.SQUARE:
			return 1.0 if p < 0.5 else -1.0
		Wave.TRIANGLE:
			return 4.0 * absf(p - 0.5) - 1.0
		Wave.SAW:
			return 2.0 * p - 1.0
	return sin(TAU * p)


## Một nốt dài [param dur] giây, tần số quét từ [param f0] tới [param f1] (Hz), âm lượng [param volume] (0-1).
## [param decay] càng lớn càng tắt nhanh; [param harmonics] thêm bồi âm bậc hai cho tiếng "kim loại".
static func tone(f0: float, f1: float, dur: float, wave: int = Wave.SINE, volume: float = 0.5, attack: float = 0.005, decay: float = 4.0, harmonics: float = 0.0) -> PackedFloat32Array:
	var count: int = int(dur * RATE)
	var out := PackedFloat32Array()
	out.resize(count)
	var phase: float = 0.0
	var fade: int = int(0.004 * RATE)  # tắt dần 4 ms cuối để không bị "tách"
	for i: int in count:
		var t: float = float(i) / RATE
		var freq: float = lerpf(f0, f1, float(i) / maxi(count - 1, 1))
		phase += freq / RATE
		var sample: float = _osc(wave, phase)
		if harmonics > 0.0:
			sample = (sample + harmonics * _osc(wave, phase * 2.0)) / (1.0 + harmonics)
		var env: float = minf(t / maxf(attack, 0.0001), 1.0) * exp(-decay * t / dur)
		if i > count - fade:
			env *= float(count - i) / fade
		out[i] = sample * env * volume
	return out


## Tiếng ồn lọc thấp (một cực). [param lowpass] nhỏ = trầm đục (0.05), lớn = rít (0.9).
## [param seed_value] cố định để âm thanh luôn giống nhau mỗi lần chạy.
static func noise(dur: float, volume: float = 0.5, lowpass: float = 0.2, decay: float = 6.0, seed_value: int = 1, rise: float = 0.0) -> PackedFloat32Array:
	var count: int = int(dur * RATE)
	var out := PackedFloat32Array()
	out.resize(count)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var y: float = 0.0
	var fade: int = int(0.004 * RATE)
	for i: int in count:
		var t: float = float(i) / RATE
		y += lowpass * (rng.randf_range(-1.0, 1.0) - y)
		var env: float = exp(-decay * t / dur)
		if rise > 0.0:  # tiếng vút: mạnh dần rồi tắt (hình tam giác)
			var x: float = float(i) / count
			env = (x / rise) if x < rise else (1.0 - x) / (1.0 - rise)
		if i > count - fade:
			env *= float(count - i) / fade
		out[i] = y * env * volume * 3.0
	return out


## Xếp các khối âm theo thời điểm: [param parts] là mảng [giây bắt đầu, bộ đệm].
static func mix(parts: Array) -> PackedFloat32Array:
	var length: int = 0
	for part: Array in parts:
		length = maxi(length, int(float(part[0]) * RATE) + (part[1] as PackedFloat32Array).size())
	var out := PackedFloat32Array()
	out.resize(length)
	for part: Array in parts:
		var start: int = int(float(part[0]) * RATE)
		var buffer: PackedFloat32Array = part[1]
		for i: int in buffer.size():
			out[start + i] += buffer[i]
	return out


## Bộ đệm -> AudioStreamWAV 16 bit đơn âm (cắt ngưỡng tại ±1).
static func to_stream(buffer: PackedFloat32Array) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(buffer.size() * 2)
	for i: int in buffer.size():
		data.encode_s16(i * 2, int(clampf(buffer[i], -1.0, 1.0) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.stereo = false
	stream.data = data
	return stream


## Bộ đệm mẫu của âm [param id] (rỗng nếu không có công thức).
static func render(id: StringName) -> PackedFloat32Array:
	match id:
		&"click":
			return tone(900.0, 650.0, 0.05, Wave.SQUARE, 0.12, 0.002, 5.0)
		&"tick":
			return tone(1300.0, 1300.0, 0.03, Wave.SINE, 0.08, 0.002, 6.0)
		&"step":
			return mix([[0.0, noise(0.07, 0.22, 0.12, 7.0, 3)], [0.0, tone(110.0, 70.0, 0.07, Wave.SINE, 0.25, 0.002, 6.0)]])
		&"pickup":
			return tone(620.0, 1000.0, 0.13, Wave.TRIANGLE, 0.3, 0.004, 3.5)
		&"dig":
			return mix([[0.0, noise(0.2, 0.5, 0.08, 5.0, 5)], [0.0, tone(95.0, 55.0, 0.18, Wave.SINE, 0.4, 0.003, 5.0)]])
		&"plant":
			return mix([[0.0, tone(340.0, 190.0, 0.11, Wave.SINE, 0.4, 0.003, 5.0)], [0.02, noise(0.06, 0.15, 0.3, 6.0, 9)]])
		&"harvest":
			return mix([[0.0, tone(523.0, 523.0, 0.16, Wave.TRIANGLE, 0.3, 0.004, 4.0, 0.3)], [0.08, tone(659.0, 659.0, 0.16, Wave.TRIANGLE, 0.3, 0.004, 4.0, 0.3)], [0.16, tone(784.0, 784.0, 0.28, Wave.TRIANGLE, 0.32, 0.004, 3.5, 0.3)]])
		&"feed":
			return mix([[0.0, tone(850.0, 1250.0, 0.07, Wave.SINE, 0.3, 0.003, 4.0)], [0.09, tone(900.0, 1350.0, 0.07, Wave.SINE, 0.3, 0.003, 4.0)], [0.2, tone(820.0, 1150.0, 0.08, Wave.SINE, 0.25, 0.003, 4.0)]])
		&"wither":
			return tone(330.0, 140.0, 0.3, Wave.TRIANGLE, 0.3, 0.01, 3.0)
		&"coin":
			return mix([[0.0, tone(1318.0, 1318.0, 0.07, Wave.SINE, 0.3, 0.002, 5.0, 0.5)], [0.065, tone(1760.0, 1760.0, 0.22, Wave.SINE, 0.3, 0.002, 4.5, 0.5)]])
		&"sell":
			return mix([[0.0, tone(880.0, 880.0, 0.07, Wave.SINE, 0.28, 0.002, 5.0, 0.4)], [0.06, tone(1108.0, 1108.0, 0.07, Wave.SINE, 0.28, 0.002, 5.0, 0.4)], [0.12, tone(1318.0, 1318.0, 0.2, Wave.SINE, 0.3, 0.002, 4.5, 0.4)]])
		&"error":
			return tone(170.0, 120.0, 0.2, Wave.SQUARE, 0.16, 0.004, 3.0)
		&"success":
			return mix([[0.0, tone(523.0, 523.0, 0.1, Wave.SINE, 0.22, 0.004, 4.0, 0.2)], [0.09, tone(784.0, 784.0, 0.2, Wave.SINE, 0.24, 0.004, 4.0, 0.2)]])
		&"day":
			return mix([[0.0, tone(392.0, 392.0, 0.14, Wave.TRIANGLE, 0.3, 0.006, 3.5, 0.3)], [0.13, tone(523.0, 523.0, 0.14, Wave.TRIANGLE, 0.3, 0.006, 3.5, 0.3)], [0.26, tone(659.0, 659.0, 0.14, Wave.TRIANGLE, 0.3, 0.006, 3.5, 0.3)], [0.39, tone(784.0, 784.0, 0.4, Wave.TRIANGLE, 0.33, 0.006, 3.0, 0.3)]])
		&"season":
			var parts: Array = []
			var notes: Array[float] = [1046.0, 1318.0, 1568.0, 1760.0, 2093.0]
			for i: int in notes.size():
				parts.append([i * 0.11, tone(notes[i], notes[i], 0.45, Wave.SINE, 0.18, 0.003, 4.0, 0.3)])
			return mix(parts)
		&"bell":
			return mix([[0.0, tone(880.0, 880.0, 0.6, Wave.SINE, 0.3, 0.002, 4.0, 0.6)], [0.0, tone(1760.0, 1760.0, 0.4, Wave.SINE, 0.12, 0.002, 6.0)]])
		&"shop_close":
			return tone(660.0, 660.0, 0.3, Wave.SINE, 0.25, 0.002, 5.0, 0.5)
		&"save":
			return mix([[0.0, tone(523.0, 523.0, 0.09, Wave.SINE, 0.25, 0.004, 4.0, 0.2)], [0.08, tone(659.0, 659.0, 0.09, Wave.SINE, 0.25, 0.004, 4.0, 0.2)], [0.16, tone(1046.0, 1046.0, 0.25, Wave.SINE, 0.27, 0.004, 4.0, 0.2)]])
		&"win":
			return mix([[0.0, tone(523.0, 523.0, 0.12, Wave.TRIANGLE, 0.3, 0.004, 3.0, 0.3)], [0.11, tone(659.0, 659.0, 0.12, Wave.TRIANGLE, 0.3, 0.004, 3.0, 0.3)], [0.22, tone(784.0, 784.0, 0.12, Wave.TRIANGLE, 0.3, 0.004, 3.0, 0.3)], [0.33, tone(1046.0, 1046.0, 0.4, Wave.TRIANGLE, 0.33, 0.004, 3.0, 0.3)]])
		&"lose":
			return mix([[0.0, tone(392.0, 392.0, 0.16, Wave.TRIANGLE, 0.28, 0.006, 3.0)], [0.15, tone(349.0, 349.0, 0.16, Wave.TRIANGLE, 0.28, 0.006, 3.0)], [0.3, tone(294.0, 294.0, 0.35, Wave.TRIANGLE, 0.28, 0.006, 3.0)]])
		&"minigame_start":
			return mix([[0.0, tone(440.0, 440.0, 0.08, Wave.SQUARE, 0.14, 0.003, 4.0)], [0.09, tone(880.0, 880.0, 0.16, Wave.SQUARE, 0.14, 0.003, 4.0)]])
		&"whoosh":
			return noise(0.3, 0.3, 0.35, 3.0, 11, 0.35)
		&"hit":
			return mix([[0.0, tone(1400.0, 900.0, 0.06, Wave.SQUARE, 0.14, 0.002, 5.0)], [0.0, noise(0.05, 0.2, 0.6, 7.0, 21)]])
		&"miss":
			return tone(300.0, 180.0, 0.12, Wave.TRIANGLE, 0.2, 0.004, 4.0)
		&"cue":
			return mix([[0.0, noise(0.03, 0.2, 0.7, 8.0, 23)], [0.0, tone(520.0, 380.0, 0.08, Wave.SINE, 0.35, 0.001, 6.0, 0.4)]])
		&"pocket":
			return mix([[0.0, tone(240.0, 120.0, 0.14, Wave.SINE, 0.4, 0.003, 4.0)], [0.12, tone(660.0, 880.0, 0.18, Wave.TRIANGLE, 0.25, 0.004, 4.0, 0.3)]])
		&"stone":
			return mix([[0.0, noise(0.025, 0.18, 0.8, 8.0, 27)], [0.0, tone(760.0, 620.0, 0.05, Wave.SINE, 0.3, 0.001, 7.0, 0.5)]])
		&"splash":
			return mix([[0.0, noise(0.28, 0.22, 0.5, 4.0, 29, 0.2)], [0.03, tone(500.0, 260.0, 0.12, Wave.SINE, 0.18, 0.004, 5.0)]])
		&"sizzle":
			return noise(0.5, 0.22, 0.85, 2.5, 31, 0.15)
	return PackedFloat32Array()


## Âm thanh [param id] dạng AudioStream, hoặc null nếu không có công thức.
static func build(id: StringName) -> AudioStream:
	var buffer: PackedFloat32Array = render(id)
	if buffer.is_empty():
		return null
	return to_stream(buffer)
