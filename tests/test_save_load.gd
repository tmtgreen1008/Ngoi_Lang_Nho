extends "res://tests/test_base.gd"
## SaveManager + PauseMenu: lưu/nạp trạng thái, ghi đè an toàn, file hỏng/thiếu/sai phiên bản
## không làm đổi trạng thái, tự lưu khi sang ngày, menu Esc.
## Dùng các slot "test" và "bad"; test tự xoá các file lưu nó tạo ra khi xong.


func _write_file(path: String, text: String) -> void:
	DirAccess.make_dir_recursive_absolute("user://saves")
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _remove_test_files(sv: Node) -> void:
	for slot: String in ["test", "bad", "autosave", "slot1"]:
		var path: String = sv.get_slot_path(StringName(slot))
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


func run() -> void:
	var tm: Node = root.get_node("TimeManager")
	var sm: Node = root.get_node("SceneManager")
	var economy: Node = root.get_node("EconomyManager")
	var db: Node = root.get_node("ItemDatabase")
	var sv: Node = root.get_node("SaveManager")
	_remove_test_files(sv)

	var main: Node = await start_game()
	tm.pause()
	var player: Node = main.player
	var seed_item: ItemData = db.get_item(&"hat_giong_lua")
	var lua: ItemData = db.get_item(&"lua")
	var egg: ItemData = db.get_item(&"trung_ga")

	check("chưa có bản lưu", not sv.has_save(&"test") and sv.get_slot_info(&"test").is_empty())
	check("nạp slot không tồn tại báo lỗi", await sv.load_game(&"nope") == "Chưa có bản lưu.")

	# --- dựng trạng thái: gieo ở nhà ngày 1, lưu ở Chợ ngày 3 ---
	var controller: Node = sm.current_map.controller
	controller.set_tool(0)
	controller.use_tool_at(Vector2i(1, 1))
	controller.set_tool(1)
	controller.use_tool_at(Vector2i(1, 1))
	economy.spend(20)
	for i: int in 2:
		tm.sleep_until_morning()
	await wait(0.2)
	check("tự lưu khi sang ngày mới", sv.has_save(&"autosave") and int(sv.get_slot_info(&"autosave").get("day", 0)) == 3)
	player.position = Vector2(1250, 520)
	await wait(1.0)
	player.position = Vector2(700, 420)
	await wait(0.2)
	var expected_position: Vector2 = player.global_position
	check("đang ở Chợ", sm.current_scene_path.ends_with("morning_market.tscn"))
	check("lưu thành công", sv.save_game(&"test") == "" and sv.has_save(&"test"))
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(sv.get_slot_path(&"test")))
	check("file JSON hợp lệ, version 1, đủ các phần", parsed is Dictionary and int(parsed["version"]) == 1 and parsed.has("time") and parsed.has("economy") and parsed.has("world") and parsed.has("player"))
	check("không còn file .tmp", not FileAccess.file_exists(sv.get_slot_path(&"test") + ".tmp"))
	check("lưu đè lần hai thành công", sv.save_game(&"test") == "")
	var info: Dictionary = sv.get_slot_info(&"test")
	check("thông tin slot: ngày 3, 80 đ", int(info.get("day", 0)) == 3 and int(info.get("money", 0)) == 80)

	# --- thay đổi mọi thứ rồi nạp lại ---
	economy.spend(30)
	player.inventory.add_item(lua, 7)
	for i: int in 3:
		tm.sleep_until_morning()
	player.position = Vector2(30, 360)
	await wait(1.0)
	var home: Node = sm.current_map
	home.controller.set_tool(0)
	home.controller.use_tool_at(Vector2i(2, 2))
	player.position = Vector2(1250, 220)
	await wait(1.0)
	check("trước khi nạp: đang ở Tạp hóa, ngày 6", sm.current_scene_path.ends_with("grocery_store.tscn") and tm.day == 6)

	var error: String = await sv.load_game(&"test")
	await wait(0.6)
	check("nạp thành công", error == "")
	check("khôi phục map Chợ", sm.current_scene_path.ends_with("morning_market.tscn"))
	check("khôi phục vị trí Player", player.global_position.distance_to(expected_position) < 5)
	check("khôi phục tiền 80 đ", economy.money == 80)
	check("khôi phục ngày 3, 06:00", tm.day == 3 and tm.get_time_string() == "06:00")
	check("khôi phục kho đồ", player.inventory.count_of(seed_item) == 9 and player.inventory.count_of(egg) == 4 and player.inventory.count_of(lua) == 0)
	check("không kẹt trạng thái chuyển cảnh", not sm.is_transitioning)
	player.position = Vector2(30, 360)
	await wait(1.0)
	var field: Node = sm.current_map.field
	var plot: Variant = field.get_plot(Vector2i(1, 1))
	check("vườn nhà khôi phục: cây lớn 2 ngày", plot != null and plot.is_planted() and plot.days_grown == 2)
	check("thay đổi sau lúc lưu bị bỏ: ô (2,2) chưa cuốc", field.get_plot(Vector2i(2, 2)) == null)

	# --- file xấu: trạng thái phải giữ nguyên ---
	var money: int = economy.money
	var day: int = tm.day
	_write_file(sv.get_slot_path(&"bad"), "không phải json {{")
	check("file hỏng báo lỗi", await sv.load_game(&"bad") == "Bản lưu bị hỏng.")
	_write_file(sv.get_slot_path(&"bad"), '{"version": 99}')
	check("phiên bản quá mới báo lỗi", (await sv.load_game(&"bad")).begins_with("Bản lưu có phiên bản không hỗ trợ"))
	_write_file(sv.get_slot_path(&"bad"), '{"version": 1, "map": "res://khong_co.tscn", "economy": {"money": 9999}}')
	check("trỏ tới map không tồn tại báo lỗi", await sv.load_game(&"bad") == "Bản lưu hỏng: không tìm thấy map.")
	check("các lần nạp lỗi không đổi trạng thái", economy.money == money and tm.day == day)

	# --- bản lưu mới nhất ---
	check("get_latest_slot chọn bản lưu có thời điểm mới nhất", sv.get_latest_slot() in [&"autosave", &"slot1"])

	# --- menu tạm dừng ---
	var menu: Node = find_by_class(main, &"PauseMenu")
	check("menu tạm dừng tồn tại và ẩn", menu != null and not menu.visible)
	await press_action("ui_cancel")
	check("Esc mở menu và dừng game", menu.visible and paused)
	await shot("pause_menu.png")
	var buttons: Dictionary = {}
	for button in find_buttons(menu):
		buttons[button.text] = button
	check("đủ 3 nút", buttons.has("Tiếp tục") and buttons.has("Lưu game") and buttons.has("Tải game"))
	buttons["Lưu game"].pressed.emit()
	check("lưu qua menu tạo slot1 và báo thành công", sv.has_save(&"slot1") and menu._message_label.text == "Đã lưu game.")
	check("nút Tải bật sau khi có bản lưu", not buttons["Tải game"].disabled)
	var saved_money: int = economy.money
	await press_action("ui_cancel")
	check("Esc đóng menu và tiếp tục game", not menu.visible and not paused)
	economy.spend(25)
	await press_action("ui_cancel")
	buttons["Tải game"].pressed.emit()
	await wait(1.2)
	check("tải qua menu khôi phục tiền", economy.money == saved_money)
	check("sau khi tải menu đóng, game chạy", not menu.visible and not paused and not sm.is_transitioning)

	_remove_test_files(sv)
