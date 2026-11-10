extends "res://tests/test_base.gd"
## Cài đặt: âm lượng hiệu ứng / nhạc nền / tắt tiếng được lưu và nạp lại; menu tạm dừng có thanh trượt,
## công tắc tắt tiếng và nút "Về màn hình chính" (hỏi xác nhận, ván mới chơi lại được).


func run() -> void:
	var am: Node = root.get_node("AudioManager")
	var tm: Node = root.get_node("TimeManager")
	var sm: Node = root.get_node("SceneManager")
	check("khi chạy test cài đặt ghi vào file riêng, không đụng file thật", am.settings_path == "user://settings_test.cfg")
	DirAccess.remove_absolute(am.settings_path)
	var sfx_bus: int = AudioServer.get_bus_index(&"SFX")
	var music_bus: int = AudioServer.get_bus_index(&"Music")

	# --- âm lượng và lưu/nạp ---
	check("mặc định: 100% cả hai, không tắt tiếng", am.sfx_volume == 1.0 and am.music_volume == 1.0 and not am.muted)
	am.set_sfx_volume(0.4)
	am.set_music_volume(0.7)
	check("bus hiệu ứng theo dB: mức gốc + log(0,4)", is_equal_approx(AudioServer.get_bus_volume_db(sfx_bus), am.SFX_BASE_DB + linear_to_db(0.4)))
	check("bus nhạc theo dB: mức gốc + log(0,7)", is_equal_approx(AudioServer.get_bus_volume_db(music_bus), am.MUSIC_BASE_DB + linear_to_db(0.7)))
	am.set_sfx_volume(0.0)
	check("âm lượng 0 thì bus gần như câm (-80 dB)", AudioServer.get_bus_volume_db(sfx_bus) <= am.SFX_BASE_DB - 70.0)
	am.set_sfx_volume(5.0)
	check("âm lượng ngoài khoảng được kẹp về 1", am.sfx_volume == 1.0)
	am.set_sfx_volume(0.4)
	am.set_muted(true)
	check("file cài đặt đã được ghi", FileAccess.file_exists(am.settings_path))
	am.sfx_volume = 1.0
	am.music_volume = 1.0
	am.muted = false
	check("nạp lại từ file thành công", am.load_settings())
	check("nạp lại đúng âm lượng và trạng thái tắt tiếng", is_equal_approx(am.sfx_volume, 0.4) and is_equal_approx(am.music_volume, 0.7) and am.muted)
	DirAccess.remove_absolute(am.settings_path)
	am.sfx_volume = 0.9
	check("không có file thì giữ nguyên, không lỗi", not am.load_settings() and am.sfx_volume == 0.9)
	var broken := FileAccess.open(am.settings_path, FileAccess.WRITE)
	broken.store_string("[audio\nsfx = = oops")
	broken.close()
	check("file hỏng thì giữ nguyên, không lỗi", not am.load_settings() and am.sfx_volume == 0.9)
	am.set_muted(false)
	am.set_sfx_volume(1.0)
	am.set_music_volume(1.0)

	# --- menu tạm dừng ---
	var main: Node = await start_game()
	tm.pause()
	var pause: Node = main.pause_menu
	check("đang chơi: menu tạm dừng cho phép mở", not pause.in_main_menu)
	await press_action("ui_cancel")
	check("Esc mở menu tạm dừng và dừng game", pause.visible and paused)
	await shot("settings_pause.png")
	check("thanh trượt phản ánh âm lượng hiện tại (100)", pause._sfx_slider.value == 100.0 and pause._music_slider.value == 100.0 and not pause._mute_check.button_pressed)
	pause._sfx_slider.value = 50.0
	pause._music_slider.value = 25.0
	check("kéo thanh trượt đổi âm lượng thật", is_equal_approx(am.sfx_volume, 0.5) and is_equal_approx(am.music_volume, 0.25))
	pause._mute_check.button_pressed = true
	check("công tắc Tắt tiếng bật tiếng tắt", am.muted)
	var muted_icon: AtlasTexture = pause._mute_check.icon
	check("đang tắt tiếng: icon loa gạch chéo (ô 10 của hud_icons_2.png)", muted_icon != null and muted_icon.atlas.resource_path.ends_with("hud_icons_2.png") and muted_icon.region == Rect2(64, 64, 32, 32))
	pause._mute_check.button_pressed = false
	check("tắt công tắc thì bật lại tiếng", not am.muted)
	check("đang bật tiếng: icon loa có sóng (ô 9)", (pause._mute_check.icon as AtlasTexture).region == Rect2(32, 64, 32, 32))
	am.set_muted(true)
	await press_action("ui_cancel")
	await press_action("ui_cancel")
	check("mở lại menu: công tắc và thanh trượt đồng bộ với cài đặt (kể cả đổi bằng phím M)", pause._mute_check.button_pressed and pause._sfx_slider.value == 50.0)
	am.set_muted(false)

	# --- Về màn hình chính ---
	var button: Button = pause._menu_button
	check("nút Về màn hình chính có chữ gốc", button.text == "Về màn hình chính")
	button.pressed.emit()
	check("bấm lần đầu chỉ hỏi xác nhận, chưa thoát", button.text != "Về màn hình chính" and pause.visible and not main.start_menu.visible)
	await press_action("ui_cancel")
	await press_action("ui_cancel")
	check("đóng rồi mở lại menu: hết trạng thái chờ xác nhận", pause.visible and pause._menu_button.text == "Về màn hình chính")
	button.pressed.emit()
	button.pressed.emit()
	check("bấm lần hai: về màn hình chính", main.start_menu.visible and not pause.visible and not paused)
	check("về màn hình chính: đồng hồ dừng, Player khoá, HUD ẩn", not tm.is_running() and main.player.movement_locked and not main.hud.visible)
	check("đang ở màn hình chính: Esc không mở menu tạm dừng", pause.in_main_menu)
	await press_action("ui_cancel")
	check("Esc ở màn hình chính không làm gì", not pause.visible and main.start_menu.visible)

	# Chơi lại từ màn hình chính.
	main.start_menu.new_game_requested.emit()
	await wait(1.0)
	check("Ván mới sau khi quay về: vào map, HUD hiện, Player cử động được", sm.current_map != null and main.hud.visible and not main.player.movement_locked and not main.start_menu.visible)
	check("đồ khởi đầu được cấp lại", main.player.inventory.count_of(root.get_node("ItemDatabase").get_item(&"hat_giong_lua")) == 10)
	await press_action("ui_cancel")
	check("đang chơi lại: Esc mở được menu tạm dừng", pause.visible and not pause.in_main_menu)
	await press_action("ui_cancel")
	DirAccess.remove_absolute(am.settings_path)
