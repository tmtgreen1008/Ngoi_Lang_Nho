extends "res://tests/test_base.gd"
## Nền đất thật: sheet ô 48x48, tileset của vườn, lát nền bốn map, đổi toạ độ chuột sang ô vườn.
## Có chụp ảnh từng map để xem bằng mắt.


func run() -> void:
	var sm: Node = root.get_node("SceneManager")
	var tm: Node = root.get_node("TimeManager")

	# --- sheet và quy ước ô ---
	var texture: Texture2D = load("res://assets/art/tiles/terrain_tiles.png")
	check("sheet nền đất là 192x96 (lưới 4x2, ô 48)", texture != null and texture.get_size() == Vector2(192, 96))
	var terrain: GDScript = load("res://core/terrain_tiles.gd")
	check("cạnh ô là 48", terrain.TILE_SIZE == 48)
	check("thứ tự ô: cỏ ở (0,0), nước ở (3,1)", terrain.atlas_coords(terrain.Tile.GRASS) == Vector2i(0, 0) and terrain.atlas_coords(terrain.Tile.WATER) == Vector2i(3, 1))
	check("vùng nguồn của sàn gỗ", terrain.source_rect(terrain.Tile.WOOD_FLOOR) == Rect2(0, 48, 48, 48))
	var source: TileSetAtlasSource = terrain.create_atlas_source()
	check("atlas có đủ 8 ô", source.get_tiles_count() == 8)

	# --- vào game, kiểm tra từng map ---
	var main: Node = await start_game()
	tm.pause()
	var player: Node = main.player
	var home: Node = sm.current_map
	check("map nhà lát cỏ (floor_tile = GRASS)", home.floor_tile == terrain.Tile.GRASS)
	check("nhà: ô xa đường là cỏ, có ô cỏ hoa", home._tile_for_cell(Vector2i(1, 0)) == terrain.Tile.GRASS and home._tile_for_cell(Vector2i(0, 0)) == terrain.Tile.GRASS_FLOWERS)
	check("nhà: đường đất nối spawn (18,8) với lối ra phía đông", home._tile_for_cell(Vector2i(18, 8)) == terrain.Tile.PATH and home._tile_for_cell(Vector2i(25, 4)) == terrain.Tile.PATH and home._tile_for_cell(Vector2i(25, 10)) == terrain.Tile.PATH)
	check("nhà: hoa ở vị trí cố định (gọi hai lần cho cùng kết quả)", home._tile_for_cell(Vector2i(3, 5)) == home._tile_for_cell(Vector2i(3, 5)))

	# toạ độ chuột -> ô vườn: vườn đặt tại ô (2,3) = pixel (96,144), không phóng to
	var view: Node = home.view
	check("vườn không bị phóng to (scale 1)", view.scale == Vector2.ONE)
	check("vườn căn theo lưới ô: (96,144)", view.position == Vector2(96, 144))
	check("chuột ở góc ô vườn (0,0)", view.world_to_cell(Vector2(96 + 5, 144 + 5)) == Vector2i(0, 0))
	check("chuột ở ô vườn (3,2)", view.world_to_cell(Vector2(96 + 48 * 3 + 5, 144 + 48 * 2 + 5)) == Vector2i(3, 2))
	check("chuột ở ô vườn (9,6) (ô cuối)", view.world_to_cell(Vector2(96 + 48 * 9 + 47, 144 + 48 * 6 + 47)) == Vector2i(9, 6))

	home.controller.set_tool(0)
	home.controller.use_tool_at(Vector2i(2, 2))
	home.controller.use_tool_at(Vector2i(3, 2))
	home.controller.set_tool(1)
	home.controller.use_tool_at(Vector2i(2, 2))
	await wait(0.3)
	var ground: TileMapLayer = view._ground
	check("ô đã cuốc vẽ ô SOIL (3,0), ô chưa cuốc vẽ ô GRASS", ground.get_cell_atlas_coords(Vector2i(2, 2)) == terrain.atlas_coords(terrain.Tile.SOIL) and ground.get_cell_atlas_coords(Vector2i(5, 5)) == terrain.atlas_coords(terrain.Tile.GRASS))
	check("ô đã gieo có lớp cây", view._crops.get_cell_source_id(Vector2i(2, 2)) == view.CROP_SOURCE and view._crops.get_cell_source_id(Vector2i(3, 2)) == -1)
	await shot("terrain_home.png")

	player.position = Vector2(1250, 220)
	await wait(1.0)
	check("Tạp hóa lát sàn gỗ", sm.current_map.floor_tile == terrain.Tile.WOOD_FLOOR)
	await shot("terrain_grocery.png")

	player.position = Vector2(30, 360)
	await wait(1.0)
	player.position = Vector2(1250, 520)
	await wait(1.0)
	check("Chợ lát nền đất chợ", sm.current_map.floor_tile == terrain.Tile.MARKET_GROUND)
	await shot("terrain_market.png")

	player.position = Vector2(30, 360)
	await wait(1.0)
	player.position = Vector2(1250, 370)
	await wait(1.0)
	check("Khu giải trí lát sàn ca-rô", sm.current_map.floor_tile == terrain.Tile.CAFE_FLOOR)
	await shot("terrain_entertainment.png")
