extends "res://tests/test_base.gd"
## Làng: map lớn có camera cuộn, đi bộ thật qua cổng nhà ra làng và ngược lại, vào / ra Tiệm Tạp Hóa và Khu Giải trí
## qua cửa nhà, thân nhà và hàng rào chặn đường, cổng chợ đi qua được, ba sạp trong sân chợ, dân làng theo lịch.


## Giữ phím [param action] trong [param seconds] giây.
func _hold(action: String, seconds: float) -> void:
	Input.action_press(action)
	await wait(seconds)
	Input.action_release(action)
	await wait(0.1)


func _labels(map: Node) -> Array:
	var texts: Array = []
	for child: Node in map.get_children():
		if child is Label:
			texts.append((child as Label).text)
	return texts


func run() -> void:
	var tm: Node = root.get_node("TimeManager")
	var sm: Node = root.get_node("SceneManager")
	tm.pause()
	tm.load_save_data({})
	var main: Node = await start_game()
	tm.pause()
	var player: Node = main.player
	var home: Node = sm.current_map

	# --- sân nhà: camera đứng yên, cả ba cổng đều ra làng ---
	check("sân nhà vừa một màn hình: camera bị giới hạn 1280x720", player.camera.limit_right == 1280 and player.camera.limit_bottom == 720 and player.camera.limit_left == 0)
	var exits_to_village: int = 0
	for child: Node in home.get_children():
		if child.get_script() != null and child.get_script().get_global_name() == &"SceneExit" and String(child.target_scene).ends_with("village.tscn"):
			exits_to_village += 1
	check("ba cổng phía đông của sân nhà đều dẫn ra làng", exits_to_village == 3)

	# --- đi bộ thật ra làng ---
	player.position = home.get_spawn_position(&"from_village")
	await _hold("move_right", 0.35)
	await wait(0.8)
	var village: Node = sm.current_map
	check("đi qua cổng đông thì ra làng", sm.current_scene_path.ends_with("village.tscn"))
	check("xuất hiện ở cổng tây của làng, trên đường làng", player.position.distance_to(village.get_spawn_position(&"from_home")) < 30.0 and village._tile_for_cell(Vector2i(player.position / 48.0)) == load("res://core/terrain_tiles.gd").Tile.PATH)
	check("làng rộng 2304x1296, vùng chơi nằm gọn trong map", village.world_size == Vector2(2304, 1296) and Rect2(Vector2.ZERO, village.world_size).encloses(village.playable_rect))
	check("camera được nới theo cỡ làng", player.camera.limit_right == 2304 and player.camera.limit_bottom == 1296)
	check("ở mép tây camera dừng ở mép map (không lộ ngoài map)", is_equal_approx(player.camera.get_screen_center_position().x, 640.0))
	check("map làng có tên khoá 'village' và báo tên 'Làng'", village.map_key() == "village" and village.map_title == "Làng")

	# --- camera cuộn theo Player ---
	player.position = Vector2(1600, 420)
	await wait(0.3)
	var center: Vector2 = player.camera.get_screen_center_position()
	check("giữa làng: camera lấy Player làm tâm", center.distance_to(player.position) < 2.0)
	check("Player hiện giữa màn hình (toạ độ màn hình khoảng 640, 360)", (player.get_global_transform_with_canvas().origin).distance_to(Vector2(640, 360)) < 2.0)
	await shot("village_market.png")

	# --- chợ: ba sạp trong sân chợ, cô Lan đi chợ buổi sáng ---
	var market_rect := Rect2(Vector2(village.MARKET_CELLS.position) * 48.0, Vector2(village.MARKET_CELLS.size) * 48.0)
	var inside: bool = village.vendors.size() == 3
	for id: StringName in village.vendors:
		inside = inside and market_rect.has_point(village.vendors[id].position)
	check("ba sạp (chú Năm, cô Ba, cô Út) đứng trong sân chợ", inside and village.vendors.has(&"thuong_lai_rau") and village.vendors.has(&"quan_co_ba") and village.vendors.has(&"hang_co_ut"))
	check("6 giờ sáng cô Lan có mặt trong sân chợ", village.get_villager(&"co_lan") != null and market_rect.has_point(village.get_villager(&"co_lan").position))
	var labels: Array = _labels(village)
	check("biển hiệu do game vẽ: Tiệm Tạp Hóa, Quán Net, Quán Bida, Chợ Quê", labels.has("Tiệm Tạp Hóa") and labels.has("Quán Net") and labels.has("Quán Bida") and labels.has("Chợ Quê"))

	# Cổng chợ đi qua được, hàng rào hai bên thì chặn.
	var gate_x: float = (village.MARKET_GATE_COLUMNS[0] + 1) * 48.0
	player.position = Vector2(gate_x, 660)
	await _hold("move_up", 1.2)
	check("từ đường làng đi lên qua cổng chợ vào được sân chợ", market_rect.has_point(player.position))
	player.position = Vector2(1400, 660)
	await _hold("move_up", 1.2)
	check("hàng rào chợ chặn đường (không vào sân chợ được ở chỗ có rào)", not market_rect.has_point(player.position) and player.position.y > 590.0)

	# --- Tiệm Tạp Hóa: thân nhà chặn, cửa thì vào được ---
	var grocery_door: Vector2 = village.doors["grocery"]
	player.position = grocery_door + Vector2(-70, 6)
	await _hold("move_up", 0.8)
	check("đi vào tường tiệm (lệch cửa) thì bị chặn, vẫn ở làng", sm.current_scene_path.ends_with("village.tscn") and player.position.y > grocery_door.y - 30.0)
	player.position = grocery_door
	await wait(0.2)
	await shot("village_grocery_door.png")
	await _hold("move_up", 0.4)
	await wait(0.8)
	var shop: Node = sm.current_map
	check("bước vào cửa tiệm thì vào trong Tiệm Tạp Hóa", sm.current_scene_path.ends_with("grocery_store.tscn"))
	check("trong tiệm là một căn phòng (ngoài phòng tối), camera đứng yên", shop.playable_rect == shop.room and shop.border_style == shop.BorderStyle.VOID and player.camera.limit_right == 1280)
	check("Player đứng ngay trong cửa, bà Tư ở sau quầy trong phòng", shop.room.has_point(player.position) and find_by_class(shop, &"VendorNPC") != null and shop.room.has_point(find_by_class(shop, &"VendorNPC").position))
	check("6 giờ sáng chị Hạnh đang ở trong tiệm", shop.get_villager(&"chi_hanh") != null and shop.room.has_point(shop.get_villager(&"chi_hanh").position))
	await shot("village_grocery_inside.png")
	player.position = shop.get_spawn_position(&"default")
	await _hold("move_down", 0.45)
	await wait(0.8)
	check("đi ra thảm cửa thì về lại làng, ngay trước cửa tiệm", sm.current_scene_path.ends_with("village.tscn") and player.position.distance_to(sm.current_map.doors["grocery"]) < 30.0)

	# --- Khu Giải trí: hai cửa (Quán Net, Quán Bida) vào chung một gian ---
	village = sm.current_map
	for door: String in ["net", "bida"]:
		player.position = village.doors[door]
		await wait(0.2)
		await _hold("move_up", 0.4)
		await wait(0.8)
		check("cửa %s dẫn vào Khu Giải trí" % door, sm.current_scene_path.ends_with("entertainment.tscn"))
		var hall: Node = sm.current_map
		if door == "net":
			var stations: int = 0
			for child: Node in hall.get_children():
				if child.get_script() != null and child.get_script().get_global_name() == &"ArcadeStation":
					stations += 1
					check("trạm chơi '%s' nằm trong gian" % child.station_name, hall.room.has_point(child.position))
			check("trong gian có 3 trạm chơi và anh Hai", stations == 3 and hall.get_villager(&"anh_hai") != null)
			await shot("village_leisure_inside.png")
		player.position = hall.get_spawn_position(&"default")
		await _hold("move_down", 0.45)
		await wait(0.8)
		village = sm.current_map
		check("ra khỏi Khu Giải trí (vào từ cửa %s): về làng trước cửa Quán Net" % door, sm.current_scene_path.ends_with("village.tscn") and player.position.distance_to(village.doors["net"]) < 30.0)
	player.position = Vector2(1500, 1000)
	await wait(0.3)
	await shot("village_south_lane.png")

	# --- ao làng chặn đường ---
	player.position = Vector2(480, 1100)
	await _hold("move_up", 1.0)
	check("ao làng chặn đường (không đi xuyên qua ao)", player.position.y > 1015.0)

	# --- về nhà bằng cổng tây ---
	player.position = village.get_spawn_position(&"from_home")
	await _hold("move_left", 0.5)
	await wait(0.8)
	check("đi qua cổng tây thì về sân nhà, đứng trong cổng đông", sm.current_scene_path.ends_with("home.tscn") and player.position.distance_to(sm.current_map.get_spawn_position(&"from_village")) < 30.0)
	check("về sân nhà: camera lại bị giới hạn một màn hình", player.camera.limit_right == 1280 and is_equal_approx(player.camera.get_screen_center_position().x, 640.0))

	# --- lưu ở làng rồi nạp lại ---
	await travel("village", &"from_home")
	player.position = Vector2(1700, 700)
	var save: Node = root.get_node("SaveManager")
	check("lưu game khi đang ở làng", save.save_game(&"test_village") == "")
	await travel("home", &"from_village")
	check("nạp game", await save.load_game(&"test_village") == "")
	await wait(0.6)
	check("nạp lại: đúng map làng, đúng vị trí, camera theo cỡ làng", sm.current_scene_path.ends_with("village.tscn") and player.position.distance_to(Vector2(1700, 700)) < 2.0 and player.camera.limit_right == 2304)
	DirAccess.remove_absolute(save.get_slot_path(&"test_village"))
