extends "res://tests/test_base.gd"
## Âm thanh: bộ tổng hợp (mọi âm hợp lệ, không méo), AudioManager (nối EventBus, tắt tiếng, chống phát dồn,
## nút bấm có tiếng click) và tiếng bước chân của Player. Khi chạy test, AudioManager không phát ra loa.


func _count(am: Node, id: StringName) -> int:
	return int(am.play_counts.get(id, 0))


func run() -> void:
	var synth: GDScript = load("res://core/audio/sfx_synth.gd")
	var am: Node = root.get_node("AudioManager")
	var bus: Node = root.get_node("EventBus")
	var tm: Node = root.get_node("TimeManager")

	# --- bộ tổng hợp ---
	var all_valid: bool = true
	var no_clip: bool = true
	var audible: bool = true
	var short: bool = true
	for id: StringName in synth.SOUND_IDS:
		var buffer: PackedFloat32Array = synth.render(id)
		if buffer.is_empty():
			all_valid = false
			continue
		var peak: float = 0.0
		for sample: float in buffer:
			peak = maxf(peak, absf(sample))
		no_clip = no_clip and peak <= 1.0
		audible = audible and peak >= 0.05
		short = short and buffer.size() < synth.RATE  # dưới 1 giây
	check("29 âm đều có công thức", synth.SOUND_IDS.size() == 29 and all_valid)
	check("không âm nào bị méo (đỉnh <= 1.0)", no_clip)
	check("không âm nào quá nhỏ (đỉnh >= 0.05)", audible)
	check("mọi âm ngắn hơn 1 giây", short)
	var stream: AudioStreamWAV = synth.build(&"harvest")
	check("AudioStreamWAV 16 bit đơn âm 22050 Hz", stream.format == AudioStreamWAV.FORMAT_16_BITS and not stream.stereo and stream.mix_rate == 22050 and stream.data.size() == synth.render(&"harvest").size() * 2)
	check("âm sinh ra luôn giống nhau (xác định)", synth.render(&"step") == synth.render(&"step") and synth.render(&"dig") == synth.render(&"dig"))
	check("id lạ không có âm", synth.build(&"khong_co") == null)

	# --- AudioManager ---
	var has_all: bool = true
	for id: StringName in synth.SOUND_IDS:
		has_all = has_all and am.has_sound(id)
	check("AudioManager nạp đủ âm", has_all)
	check("bus SFX có và đang tắt loa khi chạy test", AudioServer.get_bus_index(&"SFX") != -1 and AudioServer.is_bus_mute(AudioServer.get_bus_index(&"SFX")))

	var before: int = _count(am, &"click")
	check("play trả về true và đếm lượt", am.play(&"click") and _count(am, &"click") == before + 1 and am.last_played == &"click")
	check("phát lặp quá sát bị bỏ qua", not am.play(&"click") and _count(am, &"click") == before + 1)
	check("id lạ không phát", not am.play(&"khong_co"))

	# --- sự kiện game -> âm thanh ---
	await wait(0.1)
	var expectations: Array = [
		[&"pickup", func() -> void: bus.item_picked.emit(null, 1)],
		[&"coin", func() -> void: bus.transaction_completed.emit(null, 1, 10, true)],
		[&"sell", func() -> void: bus.transaction_completed.emit(null, 1, 10, false)],
		[&"dig", func() -> void: bus.tile_tilled.emit(Vector2i.ZERO)],
		[&"plant", func() -> void: bus.crop_planted.emit(Vector2i.ZERO, null)],
		[&"harvest", func() -> void: bus.crop_harvested.emit(Vector2i.ZERO, null)],
		[&"wither", func() -> void: bus.crop_withered.emit(Vector2i.ZERO, null)],
		[&"feed", func() -> void: bus.animal_fed.emit(&"ga")],
		[&"bell", func() -> void: bus.shop_opened.emit(null)],
		[&"shop_close", func() -> void: bus.shop_closed.emit(null)],
		[&"season", func() -> void: bus.season_changed.emit(1, 1)],
		[&"tick", func() -> void: bus.interaction_started.emit(null)],
		[&"whoosh", func() -> void: bus.scene_change_requested.emit("res://maps/home/home.tscn", &"default")],
		[&"minigame_start", func() -> void: bus.minigame_started.emit(&"test")],
		[&"win", func() -> void: bus.minigame_finished.emit(&"test", {"money": 50})],
		[&"lose", func() -> void: bus.minigame_finished.emit(&"test", {"money": 0})],
		[&"save", func() -> void: bus.game_saved.emit()],
		[&"step", func() -> void: bus.player_stepped.emit()],
	]
	for entry: Array in expectations:
		var id: StringName = entry[0]
		var count_before: int = _count(am, id)
		(entry[1] as Callable).call()
		check("sự kiện phát âm '%s'" % id, _count(am, id) == count_before + 1)

	# Sang ngày: chỉ có tiếng khi ngày thật sự tăng (nạp game phát lại cùng ngày thì im).
	var day_before: int = _count(am, &"day")
	bus.day_changed.emit(tm.day)
	check("day_changed cùng ngày: không có tiếng", _count(am, &"day") == day_before)
	bus.day_changed.emit(tm.day + 1)
	check("sang ngày mới: có tiếng", _count(am, &"day") == day_before + 1)
	bus.day_changed.emit(tm.day)  # trả lại để không ảnh hưởng phần sau

	# Thông báo: lỗi/thành công có tiếng khi yên lặng; im nếu việc vừa làm đã có tiếng riêng.
	await wait(0.4)
	var error_before: int = _count(am, &"error")
	bus.notice_requested.emit("Không đủ tiền", &"error")
	check("thông báo lỗi có tiếng", _count(am, &"error") == error_before + 1)
	await wait(0.4)
	var success_before: int = _count(am, &"success")
	bus.item_picked.emit(null, 1)
	bus.notice_requested.emit("Thu được 3 trứng", &"success")
	check("thông báo ngay sau một âm khác thì không chồng tiếng", _count(am, &"success") == success_before)
	await wait(0.4)
	bus.notice_requested.emit("Đã lưu", &"success")
	check("thông báo thành công khi yên lặng có tiếng", _count(am, &"success") == success_before + 1)
	await wait(0.4)
	var info_all: int = 0
	for id: StringName in am.play_counts:
		info_all += _count(am, id)
	bus.notice_requested.emit("Khu nhà", &"info")
	var info_after: int = 0
	for id: StringName in am.play_counts:
		info_after += _count(am, id)
	check("thông báo thông tin (tên map) không có tiếng", info_all == info_after)

	# --- nút bấm tự có tiếng click ---
	await wait(0.1)
	var button := Button.new()
	root.add_child(button)
	var clicks: int = _count(am, &"click")
	button.pressed.emit()
	check("nút mới thêm vào cây tự có tiếng click", _count(am, &"click") == clicks + 1)
	await wait(0.1)
	button.pressed.emit()
	check("nút không bị nối tín hiệu hai lần", _count(am, &"click") == clicks + 2)
	button.queue_free()

	# --- tắt tiếng bằng phím M ---
	await wait(0.1)
	var key := InputEventKey.new()
	key.keycode = KEY_M
	key.pressed = true
	am._unhandled_input(key)
	check("phím M tắt tiếng", am.muted)
	var muted_before: int = _count(am, &"pickup")
	bus.item_picked.emit(null, 1)
	check("đang tắt tiếng: không phát, không đếm", _count(am, &"pickup") == muted_before and not am.play(&"coin"))
	am._unhandled_input(key)
	check("phím M lần hai bật lại tiếng", not am.muted)
	await wait(0.1)
	check("bật lại: phát được", am.play(&"coin"))

	# --- tiếng bước chân trong game ---
	var main: Node = await start_game()
	tm.pause()
	var steps_before: int = _count(am, &"step")
	main.player.position = Vector2(300, 150)
	Input.action_press("move_right")
	await wait(1.2)
	Input.action_release("move_right")
	var steps: int = _count(am, &"step") - steps_before
	check("đi bộ 1,2 giây: có vài tiếng bước chân (không phải mỗi khung hình)", steps >= 3 and steps <= 14)
	var idle_before: int = _count(am, &"step")
	await wait(0.5)
	check("đứng yên: không có tiếng bước", _count(am, &"step") == idle_before)

	# --- tiếng riêng trong mini-game (qua EventBus.sfx_requested) ---
	await wait(0.2)
	var generic: int = _count(am, &"stone")
	bus.sfx_requested.emit(&"stone")
	check("sfx_requested phát âm theo id", _count(am, &"stone") == generic + 1)
	var aim: Variant = load("res://minigames/net_cafe/aim_game.tscn").instantiate()
	root.add_child(aim)
	await wait(0.1)
	aim.start_round()
	var target: Button = aim.spawn_target()
	var hit_before: int = _count(am, &"hit")
	target.pressed.emit()
	check("Quán Net: bắn trúng có tiếng 'hit'", _count(am, &"hit") == hit_before + 1 and aim.hits == 1)
	var miss_before: int = _count(am, &"miss")
	var late: Button = aim.spawn_target()
	aim._on_target_expired(late)
	check("Quán Net: mục tiêu biến mất có tiếng 'miss'", _count(am, &"miss") == miss_before + 1 and aim.misses == 1)
	aim.queue_free()
	var pool: Variant = load("res://minigames/billiards/billiards_game.tscn").instantiate()
	root.add_child(pool)
	await wait(0.1)
	pool.start_round()
	pool._power = pool.sweet_center
	var pocket_before: int = _count(am, &"pocket")
	check("Quán Bida: bi vào lỗ có tiếng 'pocket'", pool.shoot() and _count(am, &"pocket") == pocket_before + 1)
	pool._power = 0.0
	var cue_before: int = _count(am, &"cue")
	check("Quán Bida: đánh trượt có tiếng 'cue'", not pool.shoot() and _count(am, &"cue") == cue_before + 1)
	pool.queue_free()
