extends "res://tests/test_base.gd"
## Ô ăn quan: luật chơi (rải quân, bốc tiếp, dừng ở ô quan, ăn và ăn liên tiếp, rải lại khi hết quân, kết thúc ván),
## máy chọn nước ăn nhiều nhất, tổng điểm luôn bảo toàn qua các ván ngẫu nhiên, giao diện mini-game và trạm chơi.

const BOARD_PATH: String = "res://minigames/o_an_quan/o_an_quan_board.gd"


## Bàn trống (chỉ còn hai quan) với các ô trong [param stones] (ô -> số dân).
func _board(stones: Dictionary, current: int = 0) -> Variant:
	var board: Variant = load(BOARD_PATH).new()
	for i: int in 12:
		board.stones[i] = int(stones.get(i, 0))
	board.current = current
	return board


func run() -> void:
	var bus: Node = root.get_node("EventBus")
	var am: Node = root.get_node("AudioManager")
	var sm: Node = root.get_node("SceneManager")
	var tm: Node = root.get_node("TimeManager")
	tm.pause()
	var board_script: GDScript = load(BOARD_PATH)

	# --- thế cờ ban đầu ---
	var start: Variant = board_script.new()
	var start_ok: bool = start.has_quan(0) and start.has_quan(6) and start.stones[0] == 0 and start.stones[6] == 0
	for square: int in [1, 2, 3, 4, 5, 7, 8, 9, 10, 11]:
		start_ok = start_ok and start.stones[square] == 5
	check("ban đầu: mỗi ô dân 5 quân, mỗi ô quan 1 quan, tổng 70 điểm", start_ok and start.total_points() == 70 and start.value_of(0) == 10)
	check("người chơi đi trước, có 10 nước (5 ô x 2 chiều)", start.current == 0 and start.legal_moves(0).size() == 10 and start.legal_moves(1).size() == 10)
	check("hàng dưới là ô 1-5, hàng trên là ô 7-11", board_script.row_of(0) == [1, 2, 3, 4, 5] and board_script.row_of(1) == [7, 8, 9, 10, 11])

	# --- rải và bốc tiếp ---
	var a: Variant = _board({1: 1, 3: 4})
	var ra: Dictionary = a.play(1, 1)
	check("rải 1 quân, gặp ô có quân thì bốc rải tiếp, dừng khi gặp hai ô trống", ra["ok"] and ra["captured"] == 0 and ra["sown"] == 5 and ra["last"] == 7 and a.stones[1] == 0 and a.stones[2] == 1 and a.stones[3] == 0 and a.stones[4] == 1 and a.stones[5] == 1 and a.stones[6] == 1 and a.stones[7] == 1)
	check("đi xong thì đổi lượt", a.current == 1 and a.turns == 1 and not a.over)

	# --- ăn và ăn liên tiếp (cả quan) ---
	var b: Variant = _board({1: 1, 4: 3})
	var rb: Dictionary = b.play(1, 1)
	check("gặp ô trống thì ăn ô kế sau; lại gặp ô trống thì ăn tiếp cả quan: 3 + 10 = 13", rb["captured"] == 13 and b.scores[0] == 13 and b.stones[4] == 0 and not b.has_quan(6) and b.has_quan(0) and b.stones[2] == 1)

	# --- dừng ở ô quan ---
	var c: Variant = _board({4: 1, 7: 5})
	var rc: Dictionary = c.play(4, 1)
	check("rải xong mà ô kế tiếp là ô quan còn quân thì hết lượt, không ăn", rc["captured"] == 0 and c.stones[5] == 1 and c.stones[7] == 5 and c.has_quan(6))

	# --- đi chiều ngược lại ---
	var d: Variant = _board({2: 1})
	check("rải sang trái rồi gặp ô quan: hết lượt", d.play(2, -1)["captured"] == 0 and d.stones[1] == 1 and d.stones[2] == 0)
	var e: Variant = _board({3: 1})
	var re: Dictionary = e.play(3, -1)
	check("rải sang trái, gặp ô trống thì ăn quan bên trái (10 điểm)", re["captured"] == 10 and not e.has_quan(0) and e.stones[2] == 1 and e.scores[0] == 10)

	# --- nước đi không hợp lệ ---
	var f: Variant = board_script.new()
	check("không được bốc ô của đối thủ, ô trống, hay chiều lạ", not f.play(7, 1)["ok"] and not f.play(1, 2)["ok"] and not _board({1: 0, 2: 3}).play(1, 1)["ok"] and f.total_points() == 70 and f.current == 0 and f.turns == 0)

	# --- kết thúc ván ---
	var g: Variant = _board({3: 1, 8: 2})
	g.quan[0] = false
	var rg: Dictionary = g.play(3, 1)
	check("ăn nốt quan cuối: ván kết thúc, dân còn lại về hàng của mình", rg["captured"] == 12 and g.over and g.scores[0] == 13 and g.scores[1] == 0 and g.winner() == 0 and g.legal_moves(1).is_empty())
	check("ván đã kết thúc thì không đi được nữa", not g.play(4, 1)["ok"])
	var tie: Variant = board_script.new()
	tie.scores[0] = 35
	tie.scores[1] = 35
	check("bằng điểm là hoà", tie.winner() == -1)

	# --- rải lại khi hàng mình hết quân ---
	var h: Variant = _board({8: 3})
	h.scores[0] = 7
	check("hàng mình trống, đủ điểm: lấy 5 điểm rải mỗi ô một quân", h.refill_if_needed() and h.scores[0] == 2 and h.stones[1] == 1 and h.stones[5] == 1 and h.legal_moves(0).size() == 10)
	check("hàng còn quân thì không rải lại", not h.refill_if_needed() and h.scores[0] == 2)
	var broke: Variant = _board({8: 3})
	broke.scores[0] = 3
	check("hàng trống mà không đủ 5 điểm: ván kết thúc", not broke.refill_if_needed() and broke.over)

	# --- máy chọn nước ăn nhiều nhất ---
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var ai: Variant = _board({7: 1, 10: 3}, 1)
	check("máy chọn nước ăn được 13 điểm (ô 7 chiều +1)", ai.choose_move(rng) == [7, 1])
	ai.play(7, 1)
	check("máy ăn xong: 13 điểm, quan trái mất", ai.scores[1] == 13 and not ai.has_quan(0))
	check("không có nước nào thì trả về mảng rỗng", _board({}, 1).choose_move(rng).is_empty())
	var copy: Variant = start.clone()
	copy.play(1, 1)
	check("clone độc lập với bàn gốc", start.stones[1] == 5 and start.turns == 0 and copy.turns == 1)

	# --- ván ngẫu nhiên: tổng điểm bảo toàn, ván nào cũng kết thúc ---
	var conserved: bool = true
	var all_end: bool = true
	var results: Dictionary = {}
	for game_seed: int in 30:
		rng.seed = game_seed * 97 + 3
		var sim: Variant = board_script.new()
		var guard: int = 0
		while not sim.over and guard < 400:
			guard += 1
			sim.refill_if_needed()
			if sim.over:
				break
			var moves: Array = sim.legal_moves(sim.current)
			var move: Array = moves[rng.randi_range(0, moves.size() - 1)] if game_seed % 2 == 0 else sim.choose_move(rng)
			sim.play(int(move[0]), int(move[1]))
			conserved = conserved and sim.total_points() == 70
		all_end = all_end and sim.over and sim.scores[0] + sim.scores[1] == 70
		results[sim.winner()] = true
	check("30 ván ngẫu nhiên: sau mọi nước tổng điểm vẫn là 70", conserved)
	check("ván nào cũng kết thúc và chia hết 70 điểm", all_end)
	check("kết quả có cả thắng lẫn thua", results.size() >= 2)

	# --- giao diện mini-game ---
	var game: Variant = load("res://minigames/o_an_quan/o_an_quan_game.tscn").instantiate()
	root.add_child(game)
	await wait(0.2)
	game.ai_delay = 0.0
	game.rng.seed = 7
	var targets: Dictionary = load("res://tools/economy_report.gd").TARGETS
	var hourly: float = float(game.win_payout - game.entry_fee) * 60.0 / game.minutes_cost
	check("phí 10 đ, 60 phút, thắng 30 đ: lãi %.0f đ/giờ nằm trong mục tiêu mini-game" % hourly, game.entry_fee == 10 and game.minutes_cost == 60 and hourly >= targets["min_minigame_hourly"] and hourly <= targets["max_minigame_hourly"])
	check("có 10 nút chọn chiều, chưa bắt đầu thì khoá hết", game._move_buttons.size() == 10 and game._move_buttons[[1, 1]].disabled and not game.is_playing)
	check("chưa bắt đầu thì không đi được", not game.play_player_move(1, 1))
	var centers_ok: bool = true
	var size: Vector2 = game._board_view.custom_minimum_size
	for square: int in 12:
		var center: Vector2 = game.square_center(square)
		centers_ok = centers_ok and center.x > 0.0 and center.x < size.x and center.y > 0.0 and center.y < size.y
	check("tâm 12 ô nằm trong bàn; hàng dưới ở dưới hàng trên; ô 7 thẳng cột với ô 5", centers_ok and game.square_center(1).y > game.square_center(11).y and is_equal_approx(game.square_center(7).x, game.square_center(5).x) and game.square_center(0).x < game.square_center(1).x)
	game._start_button.pressed.emit()
	check("bấm Bắt đầu: vào ván, nút của ô có quân mở", game.is_playing and game.played and not game._move_buttons[[1, 1]].disabled and game._start_button.disabled)
	await shot("o_an_quan_start.png")
	var stone_before: int = int(am.play_counts.get(&"stone", 0))
	game._move_buttons[[3, 1]].pressed.emit()
	check("bấm nút rải: người chơi đi, máy đáp ngay, lại tới lượt người chơi (hoặc hết ván)", game.board.turns >= 2 and (game.board.current == 0 or game.board.over) and game.board.total_points() == 70)
	check("có tiếng đặt quân", int(am.play_counts.get(&"stone", 0)) > stone_before)
	check("bảng điểm cập nhật", game._score_label.text == "Bạn: %d điểm   |   Máy: %d điểm" % [game.board.scores[0], game.board.scores[1]])
	await shot("o_an_quan_playing.png")
	var guard_ui: int = 0
	while not game.board.over and guard_ui < 300:
		guard_ui += 1
		var moves_ui: Array = game.board.legal_moves(0)
		if moves_ui.is_empty():
			break
		game.play_player_move(int(moves_ui[0][0]), int(moves_ui[0][1]))
		await process_frame
	check("chơi tới hết ván", game.board.over and not game.is_playing and game.board.scores[0] + game.board.scores[1] == 70)
	var expected: int = 0
	if game.board.winner() == 0:
		expected = game.win_payout
	elif game.board.winner() == -1:
		expected = game.entry_fee
	check("tiền thưởng theo kết quả (thắng 30, hoà hoàn 10, thua 0)", game.get_payout() == expected)
	check("hết ván: báo kết quả, nút đổi thành Nhận kết quả, các nút rải bị khoá", game._status_label.text.begins_with("Hết quan, tàn dân!") and game._start_button.text == "Nhận kết quả" and not game._start_button.disabled and game._move_buttons[[1, 1]].disabled)
	var finished: Array = []
	bus.minigame_finished.connect(func(id: StringName, result: Dictionary) -> void: finished.append([id, result]))
	game._start_button.pressed.emit()
	check("bấm Nhận kết quả: trả kết quả về thế giới chính", finished.size() == 1 and finished[0][0] == &"o_an_quan" and int(finished[0][1]["money"]) == expected and int(finished[0][1]["minutes"]) == 60 and int(finished[0][1]["player"]) == game.board.scores[0])
	game.queue_free()

	# Thoát trước khi chơi thì hoàn phí.
	var fresh: Variant = load("res://minigames/o_an_quan/o_an_quan_game.tscn").instantiate()
	root.add_child(fresh)
	await wait(0.1)
	finished.clear()
	fresh.quit()
	check("thoát khi chưa bắt đầu: hoàn phí, không mất thời gian", finished.size() == 1 and int(finished[0][1]["money"]) == 10 and int(finished[0][1]["minutes"]) == 0)
	fresh.queue_free()

	# --- trạm chơi ở Khu Giải trí ---
	var main: Node = await start_game()
	tm.pause()
	travel("entertainment")
	await wait(1.0)
	var stations: Array = []
	for child: Node in sm.current_map.get_children():
		var script: Script = child.get_script()
		if script != null and script.get_global_name() == &"ArcadeStation":
			stations.append(child)
	var mat: Node = null
	for station: Node in stations:
		if station.station_name == "Chiếu Ô ăn quan":
			mat = station
	check("Khu Giải trí có 3 trạm chơi, trong đó có Chiếu Ô ăn quan", stations.size() == 3 and mat != null and mat.minigame_scene.resource_path.ends_with("o_an_quan_game.tscn"))
	check("lời nhắc ghi đúng phí", mat != null and mat.interactable.prompt_text == "Chơi Chiếu Ô ăn quan (phí 10 đ)")
	await shot("o_an_quan_station.png")
