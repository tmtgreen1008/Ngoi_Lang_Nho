extends "res://tests/test_base.gd"
## Art đã nối vào game: icon vật phẩm, ảnh cây lúa theo giai đoạn, ảnh người bán, hoạt ảnh
## Player, đồ vật chặn đường, giao diện giấy (UiTheme). Có chụp ảnh các màn hình chính.

const ITEM_IDS: Array[StringName] = [
	&"lua", &"hat_giong_lua", &"mi_tom", &"cam_ga", &"xa_phong",
	&"rau_muong", &"ca_chua", &"bap_cai", &"trung_ga", &"dua_leo",
]


func run() -> void:
	var db: Node = root.get_node("ItemDatabase")
	var sm: Node = root.get_node("SceneManager")
	var tm: Node = root.get_node("TimeManager")

	# --- dữ liệu: icon, ảnh cây, ảnh người bán ---
	var all_have_icons: bool = true
	var sizes_ok: bool = true
	var distinct: Dictionary = {}
	for item_id: StringName in ITEM_IDS:
		var item: ItemData = db.get_item(item_id)
		all_have_icons = all_have_icons and item != null and item.icon != null
		if item != null and item.icon != null:
			sizes_ok = sizes_ok and item.icon.get_size() == Vector2(32, 32)
			distinct[str((item.icon as AtlasTexture).region)] = true
	check("cả 10 vật phẩm đều có icon", all_have_icons)
	check("icon 32x32 và mỗi vật phẩm một ô riêng trong sheet", sizes_ok and distinct.size() == ITEM_IDS.size())

	var crop: CropItemData = db.get_item(&"hat_giong_lua")
	check("hạt giống lúa có ảnh cây 3 khung 48x48", crop.growth_sheet != null and crop.growth_sheet.get_size() == Vector2(144, 48))
	check("khung hình cây: mới gieo 0, nửa đường 1, chín 2", crop.get_growth_frame(0) == 0 and crop.get_growth_frame(1) == 0 and crop.get_growth_frame(2) == 1 and crop.get_growth_frame(3) == 1 and crop.get_growth_frame(4) == 2 and crop.get_growth_frame(9) == 2)
	for vendor_path: String in ["res://data/vendors/tap_hoa.tres", "res://data/vendors/thuong_lai_rau.tres"]:
		var vendor: VendorData = load(vendor_path)
		check("người bán %s có ảnh 2 khung 32x48" % vendor.id, vendor.npc_sheet != null and vendor.npc_sheet.get_size() == Vector2(64, 48))

	# --- giao diện giấy ---
	var ui_theme: GDScript = load("res://core/ui_theme.gd")
	var theme: Theme = ui_theme.get_theme()
	check("khung giấy là StyleBoxTexture 9-slice", theme.get_stylebox("panel", "PanelContainer") is StyleBoxTexture and theme.get_stylebox("panel", "PanelContainer").texture_margin_left == 24)
	check("nút có đủ 3 trạng thái là ảnh khác nhau", theme.get_stylebox("normal", "Button").texture.region != theme.get_stylebox("hover", "Button").texture.region and theme.get_stylebox("hover", "Button").texture.region != theme.get_stylebox("pressed", "Button").texture.region)
	check("chữ trên giấy màu nâu đậm", theme.get_color("font_color", "Label") == ui_theme.INK)
	var season_regions: Dictionary = {}
	for season: int in 4:
		season_regions[str(ui_theme.season_icon(season).region)] = true
	check("bốn mùa có bốn icon khác nhau 32x32", season_regions.size() == 4 and ui_theme.hud_icon(ui_theme.HudIcon.COIN).get_size() == Vector2(32, 32))

	# --- vào game ---
	var main: Node = await start_game()
	tm.pause()
	var player: Node = main.player
	check("Player dùng sheet 3x4 khung, đứng yên nhìn xuống (khung giữa, hàng 0)", player.get_frame_coords() == Vector2i(1, 0))
	await shot("art_home.png")

	# --- hoạt ảnh Player ---
	var seen_frames: Dictionary = {}
	Input.action_press("move_right")
	for i: int in 14:
		await wait(0.05)
		seen_frames[player.get_frame_coords().x] = true
	check("đi sang phải: nhìn phải (hàng 2) và đổi khung chân", player.get_frame_coords().y == 2 and seen_frames.size() >= 2)
	Input.action_release("move_right")
	await wait(0.1)
	check("dừng lại: về khung đứng, giữ hướng nhìn phải", player.get_frame_coords() == Vector2i(1, 2))
	Input.action_press("move_up")
	await wait(0.2)
	check("đi lên: nhìn hướng lưng (hàng 3)", player.get_frame_coords().y == 3)
	Input.action_release("move_up")
	Input.action_press("move_left")
	await wait(0.2)
	check("đi sang trái: hàng 1", player.get_frame_coords().y == 1)
	Input.action_release("move_left")
	Input.action_press("move_down")
	await wait(0.2)
	check("đi xuống: hàng 0", player.get_frame_coords().y == 0)
	Input.action_release("move_down")

	# --- đồ vật chặn đường: nhà (map nhà) ---
	var home: Node = sm.current_map
	player.position = Vector2(890, 330)
	await wait(0.2)
	Input.action_press("move_up")
	await wait(1.5)
	Input.action_release("move_up")
	check("nhà chặn Player: không đi xuyên qua thân nhà (dừng ở y >= 228)", player.position.y >= 228.0 and player.position.y < 330.0)

	# --- Tạp hóa: quầy chặn, NPC dùng ảnh từ dữ liệu ---
	player.position = home.get_exit_position("grocery_store.tscn")
	await wait(1.0)
	check("sang Tạp hóa", sm.current_scene_path.ends_with("grocery_store.tscn"))
	var npc: Node = find_by_class(sm.current_map, &"VendorNPC")
	check("bà Tư lấy ảnh từ VendorData", npc != null and npc._sprite.texture == npc.vendor_data.npc_sheet and npc._sprite.hframes == 2)
	var first_frame: int = npc._sprite.frame
	await wait(0.9)
	check("bà Tư nhún nhẹ: khung đổi theo thời gian", npc._sprite.frame != first_frame or npc._idle_timer.wait_time < 1.0)
	player.position = Vector2(640, 440)
	await wait(0.2)
	Input.action_press("move_up")
	await wait(1.2)
	Input.action_release("move_up")
	check("quầy chặn Player: dừng trước quầy (y từ 378 đến 420)", player.position.y >= 378.0 and player.position.y < 420.0)
	check("đứng trước quầy vẫn nhắm được bà Tư", player.get_target() != null)
	await press_action("interact")
	await shot("art_shop.png")
	check("cửa hàng hiện icon vật phẩm trên dòng hàng", _has_icon_row(main.shop_ui._buy_list))
	await press_action("ui_cancel")

	# --- Khu giải trí: trạm có ảnh, mini-game dùng ảnh ---
	player.position = Vector2(30, 360)
	await wait(1.0)
	player.position = sm.current_map.get_exit_position("entertainment.tscn")
	await wait(1.0)
	check("sang Khu giải trí", sm.current_scene_path.ends_with("entertainment.tscn"))
	var station: Node = find_by_class(sm.current_map, &"ArcadeStation")
	check("trạm chơi hiện ảnh máy tính", station != null and station.texture != null)
	await shot("art_entertainment.png")
	player.position = Vector2(480, 440)
	await wait(0.3)
	await press_action("interact")
	var host: Node = find_by_class(main, &"MinigameHost")
	var game: Node = host._active
	check("mở mini-game Quán Net", game != null)
	game.start_round()
	for i: int in 3:
		game.spawn_target()
	await shot("art_aim.png")
	var target: Button = game.get_active_targets()[0]
	check("mục tiêu dùng ảnh bia bắn, không chữ", target.icon != null and target.text == "" and target.flat)
	game.quit()
	await wait(0.3)

	player.position = Vector2(900, 440)
	await wait(0.3)
	await press_action("interact")
	game = host._active
	check("mở mini-game Quán Bida", game != null and game.get_script().get_global_name() == &"BilliardsGame")
	game.start_round()
	await shot("art_billiards.png")
	game.quit()
	await wait(0.3)

	# --- menu tạm dừng với giao diện giấy ---
	await press_action("ui_cancel")
	await shot("art_pause.png")
	await press_action("ui_cancel")


func _has_icon_row(list: Node) -> bool:
	for row: Node in list.get_children():
		for child: Node in row.get_children():
			if child is TextureRect and child.texture != null:
				return true
	return false
