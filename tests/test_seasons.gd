extends "res://tests/test_base.gd"
## Nền đất theo mùa: bốn sheet cùng bố cục, ô trong nhà giữ nguyên, ô ngoài trời đổi theo mùa; map và
## vườn đổi ảnh khi sang mùa mới, và vào map đúng mùa đang chơi. Kiểm tra bằng ảnh chụp thật (cần cửa sổ).

const SEASON_NAMES: Array[String] = ["Xuân", "Hạ", "Thu", "Đông"]


## Số pixel khác nhau giữa hai ảnh trong vùng [param rect].
func _diff(a: Image, b: Image, rect: Rect2i) -> int:
	var count: int = 0
	for y: int in range(rect.position.y, rect.end.y):
		for x: int in range(rect.position.x, rect.end.x):
			if a.get_pixel(x, y) != b.get_pixel(x, y):
				count += 1
	return count


func run() -> void:
	var tm: Node = root.get_node("TimeManager")
	var bus: Node = root.get_node("EventBus")
	var sm: Node = root.get_node("SceneManager")
	var tiles: GDScript = load("res://core/terrain_tiles.gd")

	# --- sheet các mùa ---
	var sheets: Array[Image] = []
	var layout_ok: bool = tiles.SEASON_SHEETS.size() == 4
	for path: String in tiles.SEASON_SHEETS:
		var image: Image = Image.load_from_file(path)
		layout_ok = layout_ok and image != null and image.get_size() == Vector2i(192, 96)
		sheets.append(image)
	check("4 sheet nền (Xuân, Hạ, Thu, Đông) đều 192x96 (8 ô 48x48)", layout_ok)
	var indoor_same: bool = true
	var outdoor_differs: bool = true
	for season: int in range(1, 4):
		for tile: int in [4, 5, 6]:  # sàn gỗ, nền chợ, sàn quán: trong nhà, không đổi theo mùa
			var rect := Rect2i((tile % 4) * 48, (tile / 4) * 48, 48, 48)
			indoor_same = indoor_same and _diff(sheets[0], sheets[season], rect) == 0
		for tile: int in [0, 1, 2, 3, 7]:  # cỏ, cỏ điểm hoa, đường, đất cuốc, nước
			var rect := Rect2i((tile % 4) * 48, (tile / 4) * 48, 48, 48)
			outdoor_differs = outdoor_differs and _diff(sheets[0], sheets[season], rect) > 500
	check("ô trong nhà (sàn gỗ, nền chợ, sàn quán) giống hệt ở mọi mùa", indoor_same)
	check("ô ngoài trời (cỏ, đường, đất, nước) khác hẳn Xuân ở Hạ, Thu, Đông", outdoor_differs)

	# --- API mùa ---
	check("set_season trả về true khi đổi, false khi giữ nguyên", tiles.set_season(2) and not tiles.set_season(2) and tiles.get_season() == 2)
	check("get_texture theo mùa hiện tại", tiles.get_texture().resource_path.ends_with("terrain_autumn.png"))
	check("mùa ngoài phạm vi được kẹp lại", tiles.set_season(99) and tiles.get_season() == 3 and tiles.set_season(-5) and tiles.get_season() == 0)

	# --- trong game: vào map đúng mùa, đổi mùa thì vẽ lại ---
	var main: Node = await start_game()
	tm.pause()
	var home: Node = sm.current_map
	var shots: Array[Image] = []
	var ground_ok: bool = true
	var atlas_ok: bool = true
	for season: int in 4:
		tm.season = season
		bus.season_changed.emit(season, 1)
		shots.append(await _capture_home(main))
		ground_ok = ground_ok and tiles.get_season() == season
		atlas_ok = atlas_ok and (home.view._ground.tile_set.get_source(0) as TileSetAtlasSource).texture.resource_path == tiles.SEASON_SHEETS[season]
	check("đổi mùa: nền và tileset vườn dùng đúng sheet của mùa", ground_ok and atlas_ok)
	var grass := Rect2i(300, 120, 200, 80)  # bãi cỏ phía bắc vườn
	var all_distinct: bool = true
	for a: int in 4:
		for b: int in range(a + 1, 4):
			all_distinct = all_distinct and _diff(shots[a], shots[b], grass) > 2000
	check("bốn mùa cho bốn nền cỏ khác nhau trên màn hình", all_distinct)
	var garden := Rect2i(200, 250, 300, 200)
	check("vườn đổi theo mùa (Xuân khác Thu)", _diff(shots[0], shots[2], garden) > 2000)
	for season: int in 4:
		shots[season].save_png("user://test_shots/season_%d.png" % season)

	# Sang mùa mới qua đồng hồ thật (không phát tay): 28 ngày mỗi mùa.
	tm.season = 0
	bus.season_changed.emit(0, 1)
	tm.day = 28
	tm.sleep_until_morning()
	check("ngủ qua ngày cuối mùa Xuân thì sang Hạ và nền đổi theo", tm.season == 1 and tiles.get_season() == 1)

	# Vào map mới khi đang mùa Đông: nền đúng mùa ngay từ đầu.
	tm.season = 3
	player_to_grocery(main, sm)
	await wait(1.0)
	check("vào Tiệm Tạp Hóa lúc mùa Đông: nền lấy sheet mùa Đông", sm.current_scene_path.ends_with("grocery_store.tscn") and tiles.get_season() == 3)


func _capture_home(_main: Node) -> Image:
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	await wait(0.3)
	return root.get_texture().get_image()


func player_to_grocery(main: Node, sm: Node) -> void:
	main.player.position = sm.current_map.get_exit_position("grocery_store.tscn")
