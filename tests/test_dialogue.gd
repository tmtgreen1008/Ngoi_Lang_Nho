extends "res://tests/test_base.gd"
## Thoại NPC: dữ liệu lời thoại, độ thân thiết (RelationshipManager: điểm mỗi ngày, cấp, quà, lưu/nạp) và
## hộp thoại trong game (E mở, Mua bán / Trò chuyện / Tạm biệt, Esc, quà tặng, túi đầy).


func _in_pool(line: String, pools: Array) -> bool:
	for pool: PackedStringArray in pools:
		if pool.has(line):
			return true
	return false


func run() -> void:
	var tm: Node = root.get_node("TimeManager")
	var rm: Node = root.get_node("RelationshipManager")
	var bus: Node = root.get_node("EventBus")
	var db: Node = root.get_node("ItemDatabase")
	var sm: Node = root.get_node("SceneManager")
	tm.pause()
	tm.load_save_data({})
	rm.clear()

	# --- dữ liệu lời thoại ---
	var ba_tu: DialogueData = load("res://data/dialogues/ba_tu.tres")
	var chu_nam: DialogueData = load("res://data/dialogues/chu_nam.tres")
	check("lời thoại bà Tư và chú Năm hợp lệ", ba_tu.is_valid() and chu_nam.is_valid() and ba_tu.speaker_id == &"tap_hoa" and chu_nam.speaker_id == &"thuong_lai_rau")
	check("mỗi người có chào, tạm biệt, câu theo bốn mùa, câu người quen và quà", not ba_tu.first_meeting.is_empty() and not ba_tu.greetings.is_empty() and not ba_tu.farewells.is_empty() and not ba_tu.lines_spring.is_empty() and not ba_tu.lines_winter.is_empty() and not ba_tu.friend_lines.is_empty() and not ba_tu.close_lines.is_empty() and db.has_item(ba_tu.gift_item_id) and db.has_item(chu_nam.gift_item_id))
	var vendors: Array = [load("res://data/vendors/tap_hoa.tres"), load("res://data/vendors/thuong_lai_rau.tres")]
	check("lời thoại đã gắn vào dữ liệu người bán", vendors[0].dialogue == ba_tu and vendors[1].dialogue == chu_nam and vendors[0].id == ba_tu.speaker_id)
	var stranger_ok: bool = true
	var friend_seen: bool = false
	var summer_seen: bool = false
	for salt: int in 100:
		var line0: String = ba_tu.pick_line(1, 0, salt)
		stranger_ok = stranger_ok and _in_pool(line0, [ba_tu.lines_general, ba_tu.lines_summer])
		if _in_pool(ba_tu.pick_line(1, 1, salt), [ba_tu.friend_lines]):
			friend_seen = true
		if _in_pool(line0, [ba_tu.lines_summer]):
			summer_seen = true
	check("người lạ chỉ nghe câu chung và câu của mùa hiện tại", stranger_ok and summer_seen)
	check("quen biết rồi thì nghe thêm câu người quen", friend_seen)
	var close_seen: bool = false
	for salt: int in 100:
		close_seen = close_seen or _in_pool(ba_tu.pick_line(0, 3, salt), [ba_tu.close_lines])
	check("thân thiết thì nghe cả câu thân thiết", close_seen)
	check("cùng salt thì cùng câu (xác định), salt âm không lỗi", ba_tu.pick_line(2, 1, 7) == ba_tu.pick_line(2, 1, 7) and not ba_tu.pick_line(2, 1, -3).is_empty())

	# --- độ thân thiết ---
	check("chưa gặp: 0 điểm, Người lạ", not rm.has_met(&"tap_hoa") and rm.get_points(&"tap_hoa") == 0 and rm.get_level_name(&"tap_hoa") == "Người lạ")
	var levels: Array = []
	bus.relationship_changed.connect(func(id: StringName, level: int) -> void: levels.append([id, level]))
	var first: Dictionary = rm.talk(&"tap_hoa")
	check("lần đầu trò chuyện: +1 điểm, đã gặp", first["gained"] and rm.get_points(&"tap_hoa") == 1 and rm.has_met(&"tap_hoa") and not first["leveled_up"])
	var again: Dictionary = rm.talk(&"tap_hoa")
	check("trò chuyện lần hai cùng ngày không cộng điểm", not again["gained"] and rm.get_points(&"tap_hoa") == 1 and rm.has_talked_today(&"tap_hoa"))
	tm.sleep_until_morning()
	check("sang ngày mới: hết 'đã nói chuyện hôm nay'", not rm.has_talked_today(&"tap_hoa"))
	var second: Dictionary = rm.talk(&"tap_hoa")
	check("ngày hôm sau +1 điểm, lên cấp Quen biết (2 điểm)", second["gained"] and second["leveled_up"] and second["level"] == 1 and levels == [[&"tap_hoa", 1]])
	check("hai NPC tính riêng", rm.get_points(&"thuong_lai_rau") == 0)
	check("cấp theo điểm: 0-1 lạ, 2-4 quen, 5-9 thân, 10+ thân thiết", rm.level_for_points(1) == 0 and rm.level_for_points(2) == 1 and rm.level_for_points(5) == 2 and rm.level_for_points(10) == 3 and rm.level_for_points(99) == 3)
	check("quà chưa đủ điểm thì chưa sẵn sàng", not rm.is_gift_ready(&"tap_hoa", 3))
	tm.sleep_until_morning()
	rm.talk(&"tap_hoa")
	check("đủ 3 điểm: quà sẵn sàng", rm.is_gift_ready(&"tap_hoa", 3))
	rm.claim_gift(&"tap_hoa")
	check("nhận quà rồi thì không nhận lại", not rm.is_gift_ready(&"tap_hoa", 3) and rm.has_claimed_gift(&"tap_hoa"))
	var saved: Dictionary = JSON.parse_string(JSON.stringify(rm.get_save_data()))
	rm.clear()
	check("clear xoá hết", rm.get_points(&"tap_hoa") == 0 and not rm.has_met(&"tap_hoa"))
	rm.load_save_data(saved)
	check("lưu/nạp qua JSON giữ điểm, ngày, quà", rm.get_points(&"tap_hoa") == 3 and rm.has_met(&"tap_hoa") and rm.has_claimed_gift(&"tap_hoa") and rm.has_talked_today(&"tap_hoa"))
	rm.load_save_data({"x": "rác", "y": {"points": -5}})
	check("dữ liệu lạ bị bỏ qua, điểm âm kẹp về 0", rm.get_points(&"x") == 0 and rm.get_points(&"y") == 0)
	rm.load_save_data({})
	check("bản lưu cũ (không có mục này) nạp được, rỗng", rm.get_points(&"tap_hoa") == 0)
	rm.clear()

	# --- hộp thoại trong game ---
	tm.load_save_data({})
	var main: Node = await start_game()
	tm.pause()
	var player: Node = main.player
	var box: Node = main.dialogue_box
	rm.clear()
	var lua: ItemData = db.get_item(&"lua")
	var seed_item: ItemData = db.get_item(ba_tu.gift_item_id)
	player.position = sm.current_map.get_exit_position("grocery_store.tscn")
	await wait(1.0)
	check("sang Tiệm Tạp Hóa", sm.current_scene_path.ends_with("grocery_store.tscn"))
	player.position = Vector2(640, 345)
	await wait(0.3)
	var opened: Array = []
	bus.dialogue_opened.connect(func(id: StringName) -> void: opened.append(id))
	var closed: Array = []
	bus.dialogue_closed.connect(func(id: StringName) -> void: closed.append(id))
	await press_action("interact")
	check("E mở hộp thoại bà Tư, chưa mở cửa hàng", box.visible and box._name_label.text == "Bà Tư" and not main.shop_ui.visible and opened == [&"tap_hoa"])
	check("lần đầu gặp: câu chào làm quen", ba_tu.first_meeting.has(box._text_label.text))
	check("có đủ 3 lựa chọn", box._shop_button.visible and box._talk_button.visible and box._bye_button.visible)
	check("Player bị khoá di chuyển khi đang nói chuyện", player.movement_locked)
	await shot("dialogue_box.png")
	await press_action("ui_cancel")
	check("Esc đóng hộp thoại (không mở menu tạm dừng)", not box.visible and not main.pause_menu.visible and closed == [&"tap_hoa"] and not player.movement_locked)

	await press_action("interact")
	box._talk_button.pressed.emit()
	check("Trò chuyện: có câu thoại, +1 điểm, hiện cấp", rm.get_points(&"tap_hoa") == 1 and ba_tu.pick_line(0, 0, 0) != "" and _in_pool(box._text_label.text, [ba_tu.lines_general, ba_tu.lines_spring]) and box._status_label.text.begins_with("Người lạ · 1 điểm"))
	box._talk_button.pressed.emit()
	check("trò chuyện tiếp cùng ngày không thêm điểm", rm.get_points(&"tap_hoa") == 1 and "hôm nay đã trò chuyện" in box._status_label.text)
	var notices: Array = []
	bus.notice_requested.connect(func(text: String, kind: StringName) -> void: notices.append([text, kind]))
	box._bye_button.pressed.emit()
	check("Tạm biệt: đóng hộp thoại, báo câu tạm biệt", not box.visible and notices.size() == 1 and notices[0][0].begins_with("Bà Tư: "))

	# Ngày 2: lên cấp "Quen biết". Ngày 3: nhận quà.
	tm.sleep_until_morning()
	await press_action("interact")
	check("lần sau: câu chào thường (không phải câu làm quen)", ba_tu.greetings.has(box._text_label.text))
	notices.clear()
	box._talk_button.pressed.emit()
	check("ngày 2: lên cấp Quen biết, có thông báo", rm.get_points(&"tap_hoa") == 2 and notices.any(func(n: Array) -> bool: return "Quen biết" in n[0] and n[1] == &"success"))
	box.close()

	# Túi đầy: quà chưa nhận, báo lỗi, không mất.
	var inv: Node = player.inventory
	inv.remove_item(seed_item, inv.count_of(seed_item))  # còn hạt giống trong túi thì quà cộng dồn được vào ô cũ
	inv.add_item(lua, 16 * 99)
	check("túi đã đầy (không nhận thêm hạt giống)", not inv.can_add(seed_item, ba_tu.gift_amount))
	tm.sleep_until_morning()
	await press_action("interact")
	notices.clear()
	box._talk_button.pressed.emit()
	check("túi đầy: quà chưa nhận, có báo lỗi", rm.get_points(&"tap_hoa") == 3 and not rm.has_claimed_gift(&"tap_hoa") and notices.any(func(n: Array) -> bool: return n[1] == &"error" and "túi" in n[0]))
	box.close()
	inv.remove_item(lua, inv.count_of(lua))  # (túi còn đồ khởi đầu nên không nhét đủ 16 x 99)
	var seeds_before: int = inv.count_of(seed_item)
	tm.sleep_until_morning()
	await press_action("interact")
	notices.clear()
	box._talk_button.pressed.emit()
	check("có chỗ trống: nhận quà 5 hạt giống lúa, lời tặng quà hiện ra", inv.count_of(seed_item) == seeds_before + ba_tu.gift_amount and rm.has_claimed_gift(&"tap_hoa") and box._text_label.text == ba_tu.gift_text and notices.any(func(n: Array) -> bool: return "tặng" in n[0]))
	box.close()
	tm.sleep_until_morning()
	await press_action("interact")
	box._talk_button.pressed.emit()
	check("quà chỉ tặng một lần", inv.count_of(seed_item) == seeds_before + ba_tu.gift_amount)
	box.close()

	# E-E: mở hộp thoại rồi chọn Mua bán -> cửa hàng.
	await press_action("interact")
	await press_action("interact")
	check("E rồi E: hộp thoại đóng, cửa hàng mở", not box.visible and main.shop_ui.visible and main.shop_ui._title_label.text == "Tiệm Tạp Hóa bà Tư" and player.movement_locked)
	await press_action("ui_cancel")
	check("Esc đóng cửa hàng", not main.shop_ui.visible and not player.movement_locked)

	# Lưu game giữ độ thân thiết.
	var save: Node = root.get_node("SaveManager")
	var points: int = rm.get_points(&"tap_hoa")
	check("lưu game", save.save_game(&"test_dialogue") == "")
	rm.clear()
	check("sau khi xoá: về 0", rm.get_points(&"tap_hoa") == 0)
	check("nạp game", await save.load_game(&"test_dialogue") == "")
	check("nạp game khôi phục độ thân thiết và quà đã nhận", rm.get_points(&"tap_hoa") == points and rm.has_claimed_gift(&"tap_hoa"))
	DirAccess.remove_absolute(save.get_slot_path(&"test_dialogue"))

	# Ván mới xoá độ thân thiết.
	main.start_new_game()
	await wait(0.5)
	check("ván mới: độ thân thiết về 0", rm.get_points(&"tap_hoa") == 0)
