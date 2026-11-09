extends "res://tests/test_base.gd"
## Nhạc nền: bản nhạc sinh bằng mã (hợp lệ, không méo, lặp liền mạch, mỗi mùa một bản), MusicManager
## (theo mùa, mini-game, lưu đệm, tắt tiếng bằng M). Khi chạy test nhạc không ra loa.


func run() -> void:
	var synth: GDScript = load("res://core/audio/music_synth.gd")
	var mm: Node = root.get_node("MusicManager")
	var am: Node = root.get_node("AudioManager")
	var bus: Node = root.get_node("EventBus")
	var tm: Node = root.get_node("TimeManager")

	# --- bộ tổng hợp ---
	var ids: Array = synth.track_ids()
	check("5 bản nhạc: bốn mùa và mini-game", ids.size() == 5 and ids.has(&"spring") and ids.has(&"winter") and ids.has(&"minigame"))
	var renders: Dictionary = {}
	var valid: bool = true
	var no_clip: bool = true
	var long_enough: bool = true
	var seam_ok: bool = true
	for id: StringName in ids:
		var buffer: PackedFloat32Array = synth.render(id)
		renders[id] = buffer
		valid = valid and not buffer.is_empty()
		var peak: float = 0.0
		for sample: float in buffer:
			peak = maxf(peak, absf(sample))
		no_clip = no_clip and peak <= 0.61 and peak >= 0.5
		var seconds: float = float(buffer.size()) / synth.RATE
		long_enough = long_enough and seconds >= 12.0 and seconds <= 40.0
		# Đầu và cuối vòng lặp đều gần 0 hoặc liên tục (không "bụp" ở chỗ nối): bước nhảy giữa mẫu cuối
		# và mẫu đầu không lớn hơn bước nhảy lớn nhất giữa hai mẫu liền kề thông thường.
		var max_step: float = 0.0
		for i: int in range(1, buffer.size()):
			max_step = maxf(max_step, absf(buffer[i] - buffer[i - 1]))
		seam_ok = seam_ok and absf(buffer[0] - buffer[buffer.size() - 1]) <= max_step * 1.5
	check("mọi bản nhạc đều có nội dung", valid)
	check("đỉnh âm lượng đã chuẩn hoá (~0.6, không méo)", no_clip)
	check("mỗi bản dài 12-40 giây", long_enough)
	check("chỗ nối vòng lặp liền mạch (không nhảy đột ngột)", seam_ok)
	check("nhạc sinh ra luôn giống nhau (xác định)", synth.render(&"autumn") == renders[&"autumn"])
	var distinct: bool = true
	for a: int in ids.size():
		for b: int in range(a + 1, ids.size()):
			distinct = distinct and renders[ids[a]] != renders[ids[b]]
	check("mỗi bản một giai điệu khác nhau", distinct)
	var stream: AudioStreamWAV = synth.build(&"spring")
	check("AudioStreamWAV lặp vô hạn từ đầu tới hết", stream.loop_mode == AudioStreamWAV.LOOP_FORWARD and stream.loop_begin == 0 and stream.loop_end == renders[&"spring"].size() and stream.format == AudioStreamWAV.FORMAT_16_BITS)
	check("id lạ không có nhạc", synth.build(&"khong_co") == null and synth.render(&"khong_co").is_empty())

	# --- MusicManager ---
	check("bus Music có, nhỏ hơn mức gốc", AudioServer.get_bus_index(&"Music") != -1 and AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Music")) < 0.0)
	tm.pause()
	tm.load_save_data({})
	bus.season_changed.emit(0, 1)
	check("mùa Xuân: bản spring", mm.current_track == &"spring" and mm.track_for(0) == &"spring")
	check("bản nhạc đang phát", mm.is_playing())
	var switches: int = mm.switch_count
	bus.season_changed.emit(0, 1)
	check("cùng mùa: không đổi bản", mm.switch_count == switches)
	for season: int in range(1, 4):
		bus.season_changed.emit(season, 1)
		check("sang mùa %d: nhạc đổi theo" % season, mm.current_track == mm.track_for(season) and mm.current_track != &"spring")
	check("bốn mùa bốn bản khác nhau", mm.track_for(0) != mm.track_for(1) and mm.track_for(1) != mm.track_for(2) and mm.track_for(2) != mm.track_for(3))
	tm.season = 1
	bus.minigame_started.emit(&"test")
	check("vào mini-game: bản minigame", mm.current_track == &"minigame")
	bus.minigame_finished.emit(&"test", {"money": 0})
	check("hết mini-game: về nhạc của mùa", mm.current_track == &"summer")
	bus.scene_changed.emit("res://maps/home/home.tscn")
	check("đổi map không làm đổi bản đang chạy", mm.current_track == &"summer")
	check("play_track bản không tồn tại bị từ chối", not mm.play_track(&"khong_co") and mm.current_track == &"summer")
	await wait(0.4)
	check("hai bộ phát luân phiên: có đúng một bộ đang phát sau khi mờ dần", mm.is_playing())

	# --- tắt tiếng (M) cũng tắt nhạc ---
	var key := InputEventKey.new()
	key.keycode = KEY_M
	key.pressed = true
	am._unhandled_input(key)
	check("phím M tắt tiếng: bus nhạc cũng tắt", am.muted and AudioServer.is_bus_mute(AudioServer.get_bus_index(&"Music")))
	am._unhandled_input(key)
	check("bật lại tiếng", not am.muted)
	await wait(2.0)
	check("sau khi mờ dần xong vẫn đang phát nhạc", mm.is_playing())
