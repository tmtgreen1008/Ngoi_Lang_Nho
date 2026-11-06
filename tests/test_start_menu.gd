extends "res://tests/test_base.gd"
## Màn hình chính. Chạy theo 3 pha, mỗi pha là một tiến trình riêng (mô phỏng mở lại game):
##   godot --path . -s tests/test_start_menu.gd -- phase=A   (chưa có bản lưu, chơi ván mới, lưu)
##   godot --path . -s tests/test_start_menu.gd -- phase=B   (mở lại, Tiếp tục khôi phục đúng)
##   godot --path . -s tests/test_start_menu.gd -- phase=C   (bản lưu hỏng: báo lỗi, quay lại menu)
## tests/run_all.sh chạy đủ ba pha và dọn các file lưu.


func _phase() -> String:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("phase="):
			return arg.trim_prefix("phase=")
	return "A"


func _make_main() -> Node:
	var main: Node = load("res://main.tscn").instantiate()
	root.add_child(main)
	await wait(0.4)
	return main


func run() -> void:
	match _phase():
		"A":
			await _phase_a()
		"B":
			await _phase_b()
		"C":
			await _phase_c()


func _menu_buttons(menu: Node) -> Dictionary:
	var buttons: Dictionary = {}
	for button in find_buttons(menu):
		buttons[button.text] = button
	return buttons


func _phase_a() -> void:
	var tm: Node = root.get_node("TimeManager")
	var sm: Node = root.get_node("SceneManager")
	var economy: Node = root.get_node("EconomyManager")
	var sv: Node = root.get_node("SaveManager")
	var db: Node = root.get_node("ItemDatabase")
	for slot: String in ["slot1", "autosave"]:
		if FileAccess.file_exists(sv.get_slot_path(StringName(slot))):
			DirAccess.remove_absolute(sv.get_slot_path(StringName(slot)))

	var main: Node = await _make_main()
	var menu: Node = main.start_menu
	check("mở game: hiện màn hình chính", menu.visible)
	check("chưa vào map nào, đồng hồ dừng", sm.current_map == null and not tm.is_running())
	check("Player đứng yên, HUD ẩn", main.player.movement_locked and not main.hud.visible)
	var buttons: Dictionary = _menu_buttons(menu)
	check("có nút Ván mới / Tiếp tục / Thoát", buttons.has("Ván mới") and buttons.has("Tiếp tục") and buttons.has("Thoát"))
	check("chưa có bản lưu: Tiếp tục bị khoá", buttons["Tiếp tục"].disabled and menu._info_label.text == "Chưa có bản lưu.")
	await press_action("ui_cancel")
	check("Esc không mở menu tạm dừng ở màn hình chính", not paused)
	await shot("start_menu_no_save.png")

	buttons["Ván mới"].pressed.emit()
	await wait(1.0)
	check("Ván mới: vào map nhà, menu ẩn", sm.current_scene_path.ends_with("home.tscn") and not menu.visible)
	check("Ván mới: HUD hiện, Player cử động được, đồng hồ chạy", main.hud.visible and not main.player.movement_locked and tm.is_running())
	check("Ván mới: ngày 1, 100 đ, 10 hạt giống", tm.day == 1 and economy.money == 100 and main.player.inventory.count_of(db.get_item(&"hat_giong_lua")) == 10)

	# Tạo trạng thái đặc biệt rồi lưu để pha B kiểm tra.
	tm.pause()
	economy.spend(37)
	main.player.inventory.add_item(db.get_item(&"lua"), 6)
	tm.sleep_until_morning()
	tm.sleep_until_morning()
	check("lưu game thành công", sv.save_game(&"slot1") == "")


func _phase_b() -> void:
	var tm: Node = root.get_node("TimeManager")
	var sm: Node = root.get_node("SceneManager")
	var economy: Node = root.get_node("EconomyManager")
	var db: Node = root.get_node("ItemDatabase")

	var main: Node = await _make_main()
	var menu: Node = main.start_menu
	var buttons: Dictionary = _menu_buttons(menu)
	check("mở lại game: Tiếp tục bật", menu.visible and not buttons["Tiếp tục"].disabled)
	check("hiện thông tin bản lưu (ngày 3, 63 đ)", menu._info_label.text.contains("Ngày 3") and menu._info_label.text.contains("63 đ"))
	await shot("start_menu_with_save.png")

	buttons["Tiếp tục"].pressed.emit()
	await wait(1.5)
	check("Tiếp tục: menu ẩn, vào đúng map", not menu.visible and sm.current_scene_path.ends_with("home.tscn"))
	check("khôi phục ngày 3 và 63 đ", tm.day == 3 and economy.money == 63)
	check("khôi phục kho đồ (6 lúa, 10 hạt giống)", main.player.inventory.count_of(db.get_item(&"lua")) == 6 and main.player.inventory.count_of(db.get_item(&"hat_giong_lua")) == 10)
	check("HUD hiện sau khi Tiếp tục", main.hud.visible)
	check("Player cử động được sau khi Tiếp tục", not main.player.movement_locked)
	check("đồng hồ chạy sau khi Tiếp tục", tm.is_running())
	tm.pause()


func _phase_c() -> void:
	var sm: Node = root.get_node("SceneManager")
	var tm: Node = root.get_node("TimeManager")
	var sv: Node = root.get_node("SaveManager")
	DirAccess.make_dir_recursive_absolute("user://saves")
	# Xoá bản tự lưu còn sót từ pha trước, nếu không nó mới hơn và được chọn thay vì file hỏng.
	if FileAccess.file_exists(sv.get_slot_path(&"autosave")):
		DirAccess.remove_absolute(sv.get_slot_path(&"autosave"))
	var file: FileAccess = FileAccess.open(sv.get_slot_path(&"slot1"), FileAccess.WRITE)
	# Có đủ "meta" nên menu coi là bản lưu hợp lệ, nhưng map trỏ tới scene không tồn tại.
	file.store_string('{"version": 1, "map": "res://khong_co.tscn", "meta": {"saved_at": "2026-01-01T00:00:00", "day": 1, "season": 0, "time": "06:00", "money": 1, "map": "res://khong_co.tscn"}}')
	file.close()

	var main: Node = await _make_main()
	var menu: Node = main.start_menu
	var buttons: Dictionary = _menu_buttons(menu)
	check("bản lưu có meta nhưng map hỏng: Tiếp tục vẫn bật", not buttons["Tiếp tục"].disabled)
	buttons["Tiếp tục"].pressed.emit()
	await wait(0.6)
	check("nạp lỗi: quay lại màn hình chính với thông báo", menu.visible and menu._message_label.text == "Bản lưu hỏng: không tìm thấy map.")
	check("nạp lỗi: chưa vào map, đồng hồ vẫn dừng", sm.current_map == null and not tm.is_running())
	check("nạp lỗi: HUD vẫn ẩn, Player vẫn bị khoá", not main.hud.visible and main.player.movement_locked)
	await shot("start_menu_load_error.png")
