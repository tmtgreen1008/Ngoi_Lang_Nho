extends "res://tests/test_base.gd"
## Mini-game: MinigameHost thu phí/dừng đồng hồ/áp kết quả; Quán Net (bắn mục tiêu);
## Quán Bida (canh lực); thoát sớm, thoát giữa chừng, hết tiền, yêu cầu trùng.


func _minutes(tm: Node) -> int:
	return tm.hour * 60 + tm.minute


func run() -> void:
	var tm: Node = root.get_node("TimeManager")
	var sm: Node = root.get_node("SceneManager")
	var economy: Node = root.get_node("EconomyManager")
	var bus: Node = root.get_node("EventBus")

	var main: Node = await start_game()
	var player: Node = main.player
	var host: Node = find_by_class(main, &"MinigameHost")
	var hud: Node = find_by_class(main, &"Hud")
	var menu: Node = find_by_class(main, &"PauseMenu")
	check("có MinigameHost", host != null)
	var results: Array = []
	bus.minigame_finished.connect(func(id: StringName, r: Dictionary) -> void: results.append([id, r]))
	tm.start()  # đồng hồ đang chạy để kiểm tra việc dừng/bật lại

	player.position = Vector2(1250, 370)
	await wait(1.0)
	check("Nhà có lối ra Khu Giải trí", sm.current_scene_path.ends_with("entertainment.tscn"))
	check("Player ở spawn của Khu Giải trí", player.position.distance_to(Vector2(160, 360)) < 5)
	await shot("minigames_map.png")

	# --- Quán Net ---
	player.position = Vector2(480, 380)
	await wait(0.3)
	check("lời nhắc có phí", player.get_target() != null and player.get_target().prompt_text == "Chơi Quán Net (phí 5 đ)")
	var money0: int = economy.money
	var time0: int = _minutes(tm)
	await press_action("interact")
	var game: Node = host._active
	check("bắt đầu mini-game, host bận", host.is_active() and game.get_script().get_global_name() == &"AimGame")
	check("thu phí 5 đ", economy.money == money0 - 5)
	check("đồng hồ dừng trong lúc chơi", not tm.is_running())
	await press_action("ui_cancel")
	check("Esc không mở menu tạm dừng khi đang chơi", not paused and not menu.visible and host.is_active())
	var x_before: float = player.position.x
	Input.action_press("move_right")
	await wait(0.3)
	Input.action_release("move_right")
	check("Player đứng yên khi đang chơi", is_equal_approx(player.position.x, x_before))
	bus.minigame_requested.emit("res://minigames/billiards/billiards_game.tscn")
	check("yêu cầu thứ hai bị bỏ qua, không thu phí thêm", host._active == game and economy.money == money0 - 5)

	game.rng.seed = 7
	game.start_round()
	check("vòng chơi bắt đầu với 1 mục tiêu", game.is_playing and game.get_active_targets().size() == 1 and game.played)
	for i: int in 4:
		game.spawn_target()
	await shot("minigames_aim.png")
	var targets: Array = game.get_active_targets()
	check("5 mục tiêu trên màn hình", targets.size() == 5)
	targets[0].pressed.emit()
	targets[1].pressed.emit()
	targets[2].pressed.emit()
	check("3 lần trúng = 6 đ", game.hits == 3 and game.get_payout() == 6)
	game.end_round()
	await wait(0.3)
	check("kết quả: 6 đ, 60 phút, 3 trúng", results.size() == 1 and results[0][0] == &"net_cafe_aim" and int(results[0][1]["money"]) == 6 and int(results[0][1]["minutes"]) == 60 and int(results[0][1]["hits"]) == 3)
	check("tiền: -5 phí +6 thưởng", economy.money == money0 - 5 + 6)
	var elapsed: int = _minutes(tm) - time0
	check("thời gian trôi khoảng 60 phút", elapsed >= 60 and elapsed <= 70)
	check("đồng hồ chạy lại", tm.is_running())
	check("game đã giải phóng, host rảnh", not host.is_active() and not is_instance_valid(game))
	check("toast tóm tắt kết quả", hud._toast_label.visible and hud._toast_label.text.contains("Quán Net") and hud._toast_label.text.contains("+1 đ"))
	await shot("minigames_toast.png")
	Input.action_press("move_right")
	await wait(0.3)
	Input.action_release("move_right")
	check("Player đi lại được sau khi chơi", player.position.x > x_before)

	# --- hết tiền ---
	economy.spend(economy.money - 3)
	player.position = Vector2(480, 380)
	await wait(0.3)
	await press_action("interact")
	check("hết tiền: không vào được, giữ nguyên tiền", not host.is_active() and economy.money == 3)
	check("hết tiền: có thông báo lý do", hud._toast_label.text == "Không đủ tiền: cần 5 đ.")
	economy.earn(100)

	# --- Quán Bida ---
	player.position = Vector2(900, 380)
	await wait(0.3)
	check("lời nhắc Quán Bida", player.get_target() != null and player.get_target().prompt_text == "Chơi Quán Bida (phí 15 đ)")
	var money1: int = economy.money
	await press_action("interact")
	var billiards: Node = host._active
	check("vào Quán Bida, thu phí 15 đ", host.is_active() and billiards.get_script().get_global_name() == &"BilliardsGame" and economy.money == money1 - 15)
	check("đánh trước khi bắt đầu không có tác dụng", not billiards.shoot() and billiards.shots_taken == 0)
	billiards.start_round()
	billiards._power = 0.75
	check("cú 1 trúng vùng xanh", billiards.shoot())
	billiards._power = 0.2
	check("cú 2 trượt", not billiards.shoot())
	billiards._power = 0.80
	check("cú 3 trúng (sát mép vùng)", billiards.shoot())
	billiards._power = 0.95
	check("cú 4 trượt (ngoài vùng)", not billiards.shoot())
	check("4 cú, 2 bi vào lỗ, vẫn đang chơi", billiards.shots_taken == 4 and billiards.pocketed == 2 and billiards.is_playing)
	await shot("minigames_billiards.png")
	billiards._power = 0.70
	check("cú 5 trúng", billiards.shoot())
	await wait(0.3)
	check("vòng tự kết thúc sau 5 cú", not host.is_active())
	check("kết quả Bida: 36 đ, 45 phút, 3 bi", int(results[-1][1]["money"]) == 36 and int(results[-1][1]["minutes"]) == 45 and int(results[-1][1]["pocketed"]) == 3)
	check("tiền: -15 phí +36 thưởng", economy.money == money1 - 15 + 36)

	# --- thoát trước khi chơi: hoàn phí ---
	var money2: int = economy.money
	var time2: int = _minutes(tm)
	player.position = Vector2(480, 380)
	await wait(0.3)
	await press_action("interact")
	check("lần mới lại bị thu phí", economy.money == money2 - 5)
	host._active.quit()
	await wait(0.3)
	check("thoát trước khi chơi: hoàn phí, 0 phút", economy.money == money2 and int(results[-1][1]["minutes"]) == 0 and _minutes(tm) - time2 < 15)

	# --- thoát giữa chừng: mất thưởng ---
	player.position = Vector2(480, 380)
	await wait(0.3)
	await press_action("interact")
	var quitter: Node = host._active
	quitter.start_round()
	quitter.spawn_target()
	quitter.get_active_targets()[0].pressed.emit()
	quitter.quit()
	await wait(0.3)
	check("thoát giữa chừng: không có thưởng, vẫn mất thời gian", economy.money == money2 - 5 and int(results[-1][1]["money"]) == 0 and int(results[-1][1]["minutes"]) == 60)

	# --- finish chỉ tính một lần ---
	var count: int = results.size()
	player.position = Vector2(480, 380)
	await wait(0.3)
	await press_action("interact")
	var once: Node = host._active
	once.start_round()
	once.end_round()
	once.finish(999)
	once.end_round()
	await wait(0.3)
	check("finish chỉ phát kết quả một lần", results.size() == count + 1)
	tm.pause()
