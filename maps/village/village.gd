extends MapBase
## Làng: một map lớn (2304x1296, camera cuộn theo Player) gộp Tiệm Tạp Hóa, Chợ Quê và Khu Giải trí.
##
## Bố cục (ô lưới 48 px; nhà quay mặt về phía nam nên đều nằm ở bờ bắc của một con đường):
## - Đường làng chạy ngang giữa map (hàng 13-14), cổng phía tây về khu nhà của người chơi.
## - Bờ bắc đường làng: chòi nghỉ, Tiệm Tạp Hóa (bước vào cửa để vào trong tiệm), một nhà ngói.
## - Chợ Quê ở góc đông bắc: sân chợ lát gạch có rào, cổng chợ mở ra đường làng, ba sạp và một dãy lán.
## - Đường dọc (cột 22-23) nối xuống ngõ phía nam (hàng 22-23): Quán Net, Quán Bida (chung một gian bên trong) và nhà tầng.
## - Góc tây nam: ao làng, nhà tranh, chòi nghỉ.
## Dân làng có mặt theo lịch (data/schedules, map "village").

const HOME_MAP: String = "res://maps/home/home.tscn"
const GROCERY_MAP: String = "res://maps/grocery_store/grocery_store.tscn"
const ENTERTAINMENT_MAP: String = "res://maps/entertainment/entertainment.tscn"
const NPC_SCENE: PackedScene = preload("res://entities/vendor/vendor_npc.tscn")
const HOUSES_SHEET: String = "res://assets/art/props/village_houses.png"

## Các dải ô lưới (cột, hàng).
const MAIN_ROAD_ROWS: Array[int] = [13, 14]
const CROSS_ROAD_COLUMNS: Array[int] = [22, 23]
const SOUTH_LANE_ROWS: Array[int] = [22, 23]
## Sân chợ (ô lưới) và cột của lối từ cổng chợ ra đường làng.
const MARKET_CELLS := Rect2i(27, 4, 16, 8)
const MARKET_GATE_COLUMNS: Array[int] = [33, 34]

var vendors: Dictionary = {}  # id cửa hàng -> VendorNPC
## Điểm đứng trước cửa từng nhà vào được (tên -> toạ độ), để kiểm thử và đặt spawn.
var doors: Dictionary = {}


func _init() -> void:
	world_size = Vector2(2304, 1296)
	playable_rect = Rect2(96, 96, 2112, 1104)
	border_style = BorderStyle.TREES
	ground_variation = true
	variation_seed = 21


func _build() -> void:
	var tile: float = TerrainTiles.TILE_SIZE
	var road_y: float = (MAIN_ROAD_ROWS[0] + 1) * tile  # giữa đường làng
	# Cổng tây về khu nhà.
	add_spawn(&"default", Vector2(playable_rect.position.x + 84.0, road_y))
	add_spawn(&"from_home", Vector2(playable_rect.position.x + 84.0, road_y))
	add_exit(Vector2(playable_rect.position.x + 6.0, road_y), Vector2(24, 96), HOME_MAP, &"from_village", "")
	add_signpost(Vector2(372, 612), ["Tiệm Tạp Hóa", "Chợ Quê", "Khu Giải trí"], true)

	_build_north_side(MAIN_ROAD_ROWS[0] * tile - 8.0)
	_build_market()
	_build_south_lane(SOUTH_LANE_ROWS[0] * tile - 6.0)
	_build_pond_corner()
	_build_greenery()


## Bờ bắc đường làng: chòi nghỉ, Tiệm Tạp Hóa, nhà ngói.
func _build_north_side(feet_y: float) -> void:
	add_prop("res://assets/art/props/rest_shelter.png", Vector2(200, feet_y), 2)
	doors["grocery"] = add_building("res://assets/art/props/facade_grocery.png", Vector2(520, feet_y), 0.63, 44.0, GROCERY_MAP, &"from_village", "Tiệm Tạp Hóa", Vector2(0.44, 0.33))
	add_spawn(&"from_grocery", doors["grocery"])
	add_prop_frame(HOUSES_SHEET, 0, 3, Vector2(840, feet_y), 2, 34.0)
	add_decor(Decor.JAR, Vector2(700, feet_y - 4.0))


## Chợ Quê: sân lát gạch, rào tre phía nam chừa cổng chợ, ba sạp và một dãy lán.
func _build_market() -> void:
	var tile: float = TerrainTiles.TILE_SIZE
	var left: float = MARKET_CELLS.position.x * tile
	var right: float = MARKET_CELLS.end.x * tile
	var south: float = MARKET_CELLS.end.y * tile
	var gate_x: float = (MARKET_GATE_COLUMNS[0] + 1) * tile
	# Cổng chợ: hai trụ gạch chặn đường, lối giữa đi qua được.
	var gate: Sprite2D = add_prop("res://assets/art/props/market_gate.png", Vector2(gate_x, south + 40.0), 2)
	var gate_half: float = gate.texture.get_width()  # nửa bề ngang sau khi phóng 2 lần
	_add_blocker_span(gate_x - gate_half, gate_x - gate_half + 46.0, south + 40.0, 14.0)
	_add_blocker_span(gate_x + gate_half - 46.0, gate_x + gate_half, south + 40.0, 14.0)
	_add_gate_label(gate_x, south + 40.0 - gate.texture.get_height() * 2.0 * 0.5)
	# Rào tre hai bên cổng, dọc mép nam sân chợ.
	add_fence(Vector2(left, south + 30.0), int((gate_x - gate_half - left) / FENCE_STEP))
	var east_start: float = gate_x + gate_half + 6.0
	add_fence(Vector2(east_start, south + 30.0), int((right - east_start) / FENCE_STEP))
	# Ba sạp: người bán đứng bên trái sạp.
	_add_stall("res://data/vendors/hang_co_ut.tres", Vector2(1400, 300), "res://assets/art/props/stall_goods.png", Vector2(1512, 330))
	_add_stall("res://data/vendors/thuong_lai_rau.tres", Vector2(1790, 310), "res://assets/art/props/market_stall.png", Vector2(1900, 334))
	_add_stall("res://data/vendors/quan_co_ba.tres", Vector2(1336, 506), "res://assets/art/props/stall_eggs.png", Vector2(1448, 540))
	# Dãy lán tranh cho người đi chợ nghỉ chân, vài chum hàng.
	add_prop("res://assets/art/props/market_shelter.png", Vector2(1880, 548), 2)
	add_decor(Decor.JAR, Vector2(1330, 250))
	add_decor(Decor.JAR, Vector2(2020, 260))
	add_decor(Decor.JAR, Vector2(1700, 250))


func _add_stall(vendor_path: String, npc_pos: Vector2, stall_texture: String, stall_feet: Vector2) -> void:
	var data: VendorData = load(vendor_path)
	var npc: VendorNPC = NPC_SCENE.instantiate()
	npc.vendor_data = data
	npc.position = npc_pos
	add_child(npc)
	add_prop(stall_texture, stall_feet, 1, 20.0)
	vendors[data.id] = npc


## Chữ "Chợ Quê" trên tấm biển treo ở cổng chợ.
func _add_gate_label(center_x: float, center_y: float) -> void:
	var label := Label.new()
	label.text = "Chợ Quê"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size = Vector2(120, 20)
	label.position = Vector2(center_x - 60.0, center_y - 12.0)
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color("#4E3320"))
	label.z_index = 5
	add_child(label)


## Ngõ phía nam: Quán Net và Quán Bida (hai cửa vào chung một gian), nhà tầng.
func _build_south_lane(feet_y: float) -> void:
	doors["net"] = add_building("res://assets/art/props/facade_net.png", Vector2(1330, feet_y), 0.8, 40.0, ENTERTAINMENT_MAP, &"from_village", "Quán Net", Vector2(0.5, 0.37))
	doors["bida"] = add_building("res://assets/art/props/facade_bida.png", Vector2(1580, feet_y), 0.48, 64.0, ENTERTAINMENT_MAP, &"from_village", "Quán Bida", Vector2(0.5, 0.34))
	add_spawn(&"from_entertainment", doors["net"])
	add_prop_frame(HOUSES_SHEET, 2, 3, Vector2(1840, feet_y), 2, 34.0)


## Góc tây nam: ao làng, nhà tranh, chòi nghỉ.
func _build_pond_corner() -> void:
	var pond_feet := Vector2(480, 1040)
	add_prop("res://assets/art/props/pond_large.png", pond_feet, 2)
	_add_blocker(pond_feet + Vector2(0, -16.0), 236.0, 110.0)
	add_prop_frame(HOUSES_SHEET, 1, 3, Vector2(860, 1000), 2, 34.0)
	add_prop("res://assets/art/props/rest_shelter.png", Vector2(250, 900), 2)


## Cây cối thành cụm ở các khoảng trống, bụi hoa dọc đường.
func _build_greenery() -> void:
	add_cluster(Decor.BAMBOO, Vector2(300, 300), 6, 60.0, 31)
	add_cluster(Decor.BANANA, Vector2(700, 260), 4, 46.0, 32)
	add_cluster(Decor.BAMBOO, Vector2(980, 330), 4, 40.0, 33)
	add_cluster(Decor.BANANA, Vector2(2130, 330), 3, 30.0, 34)
	add_cluster(Decor.BAMBOO, Vector2(2100, 860), 6, 60.0, 35)
	add_cluster(Decor.BANANA, Vector2(1900, 800), 3, 36.0, 36)
	add_cluster(Decor.BAMBOO, Vector2(260, 1140), 5, 50.0, 37)
	add_cluster(Decor.BANANA, Vector2(1000, 1160), 4, 44.0, 38)
	add_cluster(Decor.BANANA, Vector2(730, 830), 3, 30.0, 39)
	add_cluster(Decor.BAMBOO, Vector2(2080, 1150), 4, 40.0, 40)
	# Hàng bụi hoa ngăn sân chợ với đường dọc, và hai dải bụi hoa bên bờ nam đường làng.
	for i: int in 7:
		add_decor(Decor.BUSH, Vector2(1210.0 + (i % 2) * 8.0, 240.0 + i * 52.0))
	for i: int in 6:
		add_decor(Decor.BUSH, Vector2(380.0 + i * 46.0, 762.0 + (i % 2) * 6.0))
	for i: int in 5:
		add_decor(Decor.BUSH, Vector2(1300.0 + i * 46.0, 760.0 + (i % 2) * 6.0))


## Nền làng: đường đất, sân chợ lát gạch, còn lại là cỏ điểm hoa.
func _tile_for_cell(cell: Vector2i) -> TerrainTiles.Tile:
	if _is_road_cell(cell):
		return TerrainTiles.Tile.PATH
	if MARKET_CELLS.has_point(cell):
		return TerrainTiles.Tile.MARKET_GROUND
	if (cell.x * 5 + cell.y * 11) % 13 == 0:
		return TerrainTiles.Tile.GRASS_FLOWERS
	return TerrainTiles.Tile.GRASS


func _is_road_cell(cell: Vector2i) -> bool:
	var main: bool = cell.y in MAIN_ROAD_ROWS and cell.x <= 45
	var cross: bool = cell.x in CROSS_ROAD_COLUMNS and cell.y >= MAIN_ROAD_ROWS[0] and cell.y <= SOUTH_LANE_ROWS[1]
	var lane: bool = cell.y in SOUTH_LANE_ROWS and cell.x >= CROSS_ROAD_COLUMNS[0] and cell.x <= 40
	var gate_link: bool = cell.x in MARKET_GATE_COLUMNS and cell.y == MARKET_CELLS.end.y
	return main or cross or lane or gate_link
