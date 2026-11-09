extends MapBase
## Khu nhà: sân nhỏ gọn quanh ngôi nhà, mảnh vườn, con đường dẫn ra làng.
##
## Bố cục (toạ độ thế giới, ô lưới 48px, vùng chơi 1008x528 viền bằng rặng cây):
## - Nhà ở góc trên phải; bước vào cửa nhà thì sang map trong nhà (nơi có giường để ngủ).
## - Con đường đất đi từ cửa nhà xuống ngã ba, rẽ trái thành lối mòn tới mảnh vườn,
##   rẽ phải ra cổng phía đông; ở ngã ba có biển chỉ đường tới Tiệm Tạp Hóa, Khu Giải trí, Chợ.
## - Cây trồng thành cụm (rặng chuối, bụi tre, hàng bụi hoa) thay vì rải lẻ tẻ.
##
## Vườn (FarmField) thuộc nhóm world_persistent nên được WorldStateManager nhớ khi người chơi
## đi vắng; quay về cây vẫn còn và đã lớn thêm đúng số ngày vắng mặt.
## Điều khiển vườn: chuột trái dùng công cụ; phím 1/2/3 đổi Cuốc / Gieo hạt / Thu hoạch.

const GROCERY_MAP: String = "res://maps/grocery_store/grocery_store.tscn"
const MARKET_MAP: String = "res://maps/morning_market/morning_market.tscn"
const ENTERTAINMENT_MAP: String = "res://maps/entertainment/entertainment.tscn"
const INTERIOR_MAP: String = "res://maps/house_interior/house_interior.tscn"

## Chân ngôi nhà (giữa đáy ảnh), nhà phóng 2 lần.
const HOUSE_FEET := Vector2(936, 232)
## Cửa nhà: khe hở giữa hai dải chặn thân nhà.
const DOOR_LEFT: float = 928.0
const DOOR_RIGHT: float = 972.0
## Ô lưới góc trên trái của mảnh vườn.
const FARM_CELL := Vector2i(4, 5)
## Cột ô lưới của đường từ cửa nhà (x ~ 950 là cột 19), cột đường dọc ở cổng (x ~ 1080 là cột 22).
const YARD_PATH_COLUMN: int = 19
const TRUNK_COLUMN: int = 22
const MAIN_ROAD_ROW: int = 8
## Các hàng ô lưới của ba lối ra phía đông (Tạp hóa, Khu giải trí, Chợ).
const GATE_ROWS: Array[int] = [5, 8, 11]

var field: FarmField
var view: FarmView
var controller: FarmToolController
var coop: LivestockHouse
var barn: LivestockHouse
var ong_bay: VillagerNPC
var be_ti: VillagerNPC

var _tool_buttons: Dictionary = {}  # FarmToolController.Tool -> Button
var _feedback_panel: PanelContainer
var _feedback_label: Label


func _init() -> void:
	playable_rect = Rect2(144, 96, 1008, 528)
	border_style = BorderStyle.TREES
	ground_variation = true


func _build() -> void:
	var cell_size: float = TerrainTiles.TILE_SIZE
	var door_x: float = (DOOR_LEFT + DOOR_RIGHT) / 2.0
	add_spawn(&"default", Vector2(door_x, 330))
	add_spawn(&"from_house", Vector2(door_x, 296))
	# Điểm xuất hiện khi từ các nơi khác về: ngay trong cổng phía đông.
	var gate_x: float = playable_rect.end.x - cell_size
	add_spawn(&"from_grocery", Vector2(gate_x, (GATE_ROWS[0] + 0.5) * cell_size))
	add_spawn(&"from_entertainment", Vector2(gate_x, (GATE_ROWS[1] + 0.5) * cell_size))
	add_spawn(&"from_market", Vector2(gate_x, (GATE_ROWS[2] + 0.5) * cell_size))

	var edge_x: float = playable_rect.end.x - 6.0
	add_exit(Vector2(edge_x, (GATE_ROWS[0] + 0.5) * cell_size), Vector2(24, 70), GROCERY_MAP, &"from_home", "")
	add_exit(Vector2(edge_x, (GATE_ROWS[1] + 0.5) * cell_size), Vector2(24, 70), ENTERTAINMENT_MAP, &"from_home", "")
	add_exit(Vector2(edge_x, (GATE_ROWS[2] + 0.5) * cell_size), Vector2(24, 70), MARKET_MAP, &"from_home", "")
	# Bước vào cửa nhà (khe hở giữa hai dải chặn) thì vào trong nhà.
	add_exit(Vector2(door_x, HOUSE_FEET.y + 24.0), Vector2(DOOR_RIGHT - DOOR_LEFT, 28), INTERIOR_MAP, &"from_home", "")

	_build_garden()
	_build_livestock()
	_build_villagers()
	_build_house()
	_build_scenery()
	_build_hud()


## Mảnh vườn và công cụ làm vườn (chuột trái, phím 1/2/3).
func _build_garden() -> void:
	field = FarmField.new()
	field.name = "FarmField"
	add_child(field)
	view = FarmView.new()
	# Căn theo lưới ô 48px, không phóng to để pixel không méo.
	view.position = Vector2(FARM_CELL * TerrainTiles.TILE_SIZE)
	add_child(view)
	view.setup(field)

	controller = FarmToolController.new()
	controller.field = field
	add_child(controller)
	var player: Node = get_tree().get_first_node_in_group("player")
	if player != null:
		controller.inventory = player.get("inventory")
	controller.tool_changed.connect(func(_t: FarmToolController.Tool) -> void: _update_status())
	controller.feedback.connect(_show_feedback)

	# Hàng rào tre phía nam mảnh vườn, mỗi đoạn rộng một ô.
	var fence_y: float = (FARM_CELL.y + field.field_area.size.y) * TerrainTiles.TILE_SIZE + 24.0
	for i: int in int(field.field_area.size.x):
		add_decor(Decor.FENCE, Vector2(FARM_CELL.x * TerrainTiles.TILE_SIZE + 24.0 + i * TerrainTiles.TILE_SIZE, fence_y), 38.0)


## Chuồng gà và chuồng lợn ở bãi trống phía nam đường mòn, cạnh mảnh vườn.
func _build_livestock() -> void:
	coop = _add_livestock_house(Vector2(736, 560), LivestockHouse.Structure.COOP, "res://data/animals/ga.tres", &"coop")
	barn = _add_livestock_house(Vector2(890, 572), LivestockHouse.Structure.BARN, "res://data/animals/lon.tres", &"barn")


func _add_livestock_house(feet: Vector2, structure: LivestockHouse.Structure, species_path: String, key: StringName) -> LivestockHouse:
	var house := LivestockHouse.new()
	house.position = feet
	house.structure = structure
	house.species = load(species_path)
	house.persistent_key = key
	add_child(house)
	return house


## Dân làng ở sân nhà: ông Bảy đứng cạnh lối mòn, bé Tí chạy chơi trên bãi cỏ phía bắc đường mòn.
func _build_villagers() -> void:
	ong_bay = add_villager("res://data/dialogues/ong_bay.tres", 1, Vector2(860, 330))
	be_ti = add_villager("res://data/dialogues/be_ti.tres", 5, Vector2(760, 330), Rect2(700, 290, 160, 80))


## Ngôi nhà: hai dải chặn hai bên cửa, chừa khe hở cho Player bước vào.
func _build_house() -> void:
	var house: Sprite2D = add_prop("res://assets/art/props/house.png", HOUSE_FEET, 2)
	var half_width: float = house.texture.get_width() * house.scale.x / 2.0
	var left_edge: float = HOUSE_FEET.x - half_width
	var right_edge: float = HOUSE_FEET.x + half_width
	_add_blocker_span(left_edge, DOOR_LEFT, HOUSE_FEET.y, 16.0)
	_add_blocker_span(DOOR_RIGHT, right_edge, HOUSE_FEET.y, 16.0)


## Cây cối thành cụm, bụi hoa thành hàng, chum đặt cạnh nhà.
func _build_scenery() -> void:
	add_decor(Decor.JAR, Vector2(866, 238))
	# Rặng chuối cạnh nhà phía đông và góc dưới phải.
	add_cluster(Decor.BANANA, Vector2(1080, 210), 3, 28.0, 11)
	add_cluster(Decor.BANANA, Vector2(1000, 560), 3, 30.0, 12)
	# Bụi tre trên góc trái và dưới trái.
	add_cluster(Decor.BAMBOO, Vector2(232, 150), 5, 40.0, 13)
	add_cluster(Decor.BAMBOO, Vector2(210, 585), 3, 26.0, 14)
	# Hàng bụi hoa ngăn sân nhà và bãi trống phía bắc vườn.
	for i: int in 6:
		add_decor(Decor.BUSH, Vector2(540 + i * 34, 150 + (i % 2) * 6))
	# Hai bụi hoa hai bên bậc thềm.
	add_decor(Decor.BUSH, Vector2(880, 252))
	add_decor(Decor.BUSH, Vector2(1002, 252))
	# Biển chỉ đường ở ngã ba: ba tấm ván chỉ ra làng.
	add_signpost(Vector2(1010, 376), ["Tiệm Tạp Hóa", "Khu Giải trí", "Chợ Quê"], true)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_show_feedback("")
		controller.use_tool_at(view.world_to_cell(view.get_global_mouse_position()))
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				controller.set_tool(FarmToolController.Tool.HOE)
			KEY_2:
				controller.set_tool(FarmToolController.Tool.SEED)
			KEY_3:
				controller.set_tool(FarmToolController.Tool.HARVEST)


## Nền khu nhà: cỏ rải hoa, cùng con đường đất nối cửa nhà, vườn và cổng phía đông.
func _tile_for_cell(cell: Vector2i) -> TerrainTiles.Tile:
	if _is_path_cell(cell):
		return TerrainTiles.Tile.PATH
	# Hoa mọc rải rác, vị trí cố định theo ô (không ngẫu nhiên mỗi lần vẽ).
	if (cell.x * 7 + cell.y * 13) % 11 == 0:
		return TerrainTiles.Tile.GRASS_FLOWERS
	return TerrainTiles.Tile.GRASS


func _is_path_cell(cell: Vector2i) -> bool:
	var farm_right: int = FARM_CELL.x + 10  # cột đầu tiên sau mảnh vườn
	var yard: bool = cell.x == YARD_PATH_COLUMN and cell.y >= 5 and cell.y <= MAIN_ROAD_ROW  # từ cửa nhà xuống
	var main_road: bool = cell.y == MAIN_ROAD_ROW and cell.x >= farm_right and cell.x <= TRUNK_COLUMN  # lối mòn tới vườn
	var trunk: bool = cell.x == TRUNK_COLUMN and cell.y >= GATE_ROWS[0] and cell.y <= GATE_ROWS[2]  # đường dọc ở cổng
	var branches: bool = cell.x >= TRUNK_COLUMN and cell.x <= TRUNK_COLUMN + 1 and cell.y in GATE_ROWS  # ba nhánh ra cổng (dừng ở mép vùng chơi)
	return yard or main_road or trunk or branches


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	# Thanh công cụ góc dưới trái: ba nút bật/tắt, nút đang chọn lõm xuống.
	var bar := PanelContainer.new()
	bar.theme = UiTheme.get_theme()
	bar.add_theme_stylebox_override("panel", UiTheme.hud_panel_style())
	bar.position = Vector2(20, 640)
	layer.add_child(bar)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	bar.add_child(row)
	var group := ButtonGroup.new()
	for tool: int in FarmToolController.TOOL_NAMES:
		var button := Button.new()
		button.toggle_mode = true
		button.button_group = group
		button.focus_mode = Control.FOCUS_NONE
		button.text = "%d  %s" % [tool + 1, FarmToolController.TOOL_NAMES[tool]]
		button.pressed.connect(controller.set_tool.bind(tool))
		_tool_buttons[tool] = button
		row.add_child(button)
	var hint := Label.new()
	hint.text = "Chuột trái để dùng"
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", UiTheme.INK_SOFT)
	hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(hint)

	# Phản hồi (lỗi/kết quả) hiện thành tờ giấy nhỏ phía trên thanh công cụ, rỗng thì ẩn.
	_feedback_panel = PanelContainer.new()
	_feedback_panel.theme = UiTheme.get_theme()
	_feedback_panel.add_theme_stylebox_override("panel", UiTheme.hud_panel_style())
	_feedback_panel.position = Vector2(20, 590)
	_feedback_panel.hide()
	layer.add_child(_feedback_panel)
	_feedback_label = Label.new()
	_feedback_label.add_theme_color_override("font_color", UiTheme.ACCENT_RED)
	_feedback_panel.add_child(_feedback_label)
	_update_status()


func _show_feedback(text: String) -> void:
	_feedback_label.text = text
	_feedback_panel.visible = not text.is_empty()
	_feedback_panel.reset_size()


func _update_status() -> void:
	for tool: int in _tool_buttons:
		(_tool_buttons[tool] as Button).set_pressed_no_signal(tool == controller.current_tool)
