extends MapBase
## Khu nhà: mảnh vườn (cuốc, gieo, thu hoạch), giường để ngủ, lối ra Tiệm Tạp Hóa và Chợ.
##
## Vườn (FarmField) thuộc nhóm world_persistent nên được WorldStateManager nhớ khi
## người chơi đi chợ; quay về cây vẫn còn và đã lớn thêm đúng số ngày vắng mặt.
## Điều khiển vườn: chuột trái dùng công cụ; phím 1/2/3 đổi Cuốc / Gieo hạt / Thu hoạch.

const GROCERY_MAP: String = "res://maps/grocery_store/grocery_store.tscn"
const MARKET_MAP: String = "res://maps/morning_market/morning_market.tscn"
const ENTERTAINMENT_MAP: String = "res://maps/entertainment/entertainment.tscn"

var field: FarmField
var view: FarmView
var controller: FarmToolController

var _status_label: Label
var _feedback_label: Label


func _build() -> void:
	add_spawn(&"default", Vector2(900, 400))
	add_spawn(&"from_grocery", Vector2(1150, 220))
	add_spawn(&"from_market", Vector2(1150, 520))
	add_spawn(&"from_entertainment", Vector2(1150, 370))
	add_exit(Vector2(1250, 220), Vector2(40, 120), GROCERY_MAP, &"from_home", "Tiệm Tạp Hóa")
	add_exit(Vector2(1250, 520), Vector2(40, 120), MARKET_MAP, &"from_home", "Chợ Quê")
	add_exit(Vector2(1250, 370), Vector2(40, 100), ENTERTAINMENT_MAP, &"from_home", "Khu Giải trí")

	field = FarmField.new()
	field.name = "FarmField"
	add_child(field)
	view = FarmView.new()
	# Căn theo lưới ô 48px (cột 2, hàng 3) để các ô vườn khớp với ô nền, không phóng to để pixel không méo.
	view.position = Vector2(2, 3) * TerrainTiles.TILE_SIZE
	add_child(view)
	view.setup(field)

	controller = FarmToolController.new()
	controller.field = field
	add_child(controller)
	var player: Node = get_tree().get_first_node_in_group("player")
	if player != null:
		controller.inventory = player.get("inventory")

	_build_scenery()
	_build_bed()
	_build_hud()
	controller.tool_changed.connect(func(_t: FarmToolController.Tool) -> void: _update_status())
	controller.feedback.connect(func(text: String) -> void: _feedback_label.text = text)
	_update_status()


## Nền khu nhà: cỏ rải hoa, cùng con đường đất nối chỗ xuất hiện với ba lối ra phía đông.
func _tile_for_cell(cell: Vector2i) -> TerrainTiles.Tile:
	if _is_path_cell(cell):
		return TerrainTiles.Tile.PATH
	# Hoa mọc rải rác, vị trí cố định theo ô (không ngẫu nhiên mỗi lần vẽ).
	if (cell.x * 7 + cell.y * 13) % 11 == 0:
		return TerrainTiles.Tile.GRASS_FLOWERS
	return TerrainTiles.Tile.GRASS


func _is_path_cell(cell: Vector2i) -> bool:
	var on_trunk: bool = cell.x == 23 and cell.y >= 3 and cell.y <= 11  # dọc theo cột các lối ra
	var on_branch: bool = cell.x >= 23 and cell.y in [4, 7, 10]  # ba nhánh ra mép phải
	var on_main: bool = cell.y == 8 and cell.x >= 12 and cell.x <= 23  # từ vườn tới ngã ba
	return on_trunk or on_branch or on_main


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_feedback_label.text = ""
		controller.use_tool_at(view.world_to_cell(view.get_global_mouse_position()))
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				controller.set_tool(FarmToolController.Tool.HOE)
			KEY_2:
				controller.set_tool(FarmToolController.Tool.SEED)
			KEY_3:
				controller.set_tool(FarmToolController.Tool.HARVEST)


## Giường: tương tác để ngủ qua đêm (sang ngày mới, cây lớn thêm một ngày).
func _build_bed() -> void:
	# Giường (phản có màn) đặt ngoài hiên cạnh nhà; chân giường ở (770, 225).
	var bed_feet := Vector2(770, 225)
	add_prop("res://assets/art/props/bed.png", bed_feet, 1, 14.0)
	var bed := InteractableComponent.new()
	bed.position = bed_feet + Vector2(0, -30)
	bed.prompt_text = "Đi ngủ"
	bed.interact_radius = 50.0
	bed.interacted.connect(func(_who: Node) -> void: TimeManager.sleep_until_morning())
	add_child(bed)


## Ngôi nhà, cây cối, hàng rào và chum quanh khu nhà. Nhà phóng to 2 lần (cửa cao hơn Player).
func _build_scenery() -> void:
	add_prop("res://assets/art/props/house.png", Vector2(930, 200), 2, 16.0)
	add_decor(Decor.JAR, Vector2(850, 206))
	add_decor(Decor.BANANA, Vector2(1050, 190))
	add_decor(Decor.BANANA, Vector2(70, 100))
	add_decor(Decor.BAMBOO, Vector2(1060, 110))
	add_decor(Decor.BAMBOO, Vector2(640, 120))
	add_decor(Decor.BUSH, Vector2(700, 110))
	add_decor(Decor.BUSH, Vector2(640, 600))
	add_decor(Decor.BUSH, Vector2(900, 590))
	add_decor(Decor.BAMBOO, Vector2(80, 620))
	# Hàng rào tre phía nam mảnh vườn, mỗi đoạn rộng một ô.
	for i: int in 10:
		add_decor(Decor.FENCE, Vector2(120 + i * TerrainTiles.TILE_SIZE, 528), 38.0)


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_status_label = Label.new()
	_status_label.position = Vector2(60, 640)
	_status_label.add_theme_font_size_override("font_size", 18)
	layer.add_child(_status_label)
	_feedback_label = Label.new()
	_feedback_label.position = Vector2(60, 672)
	_feedback_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	layer.add_child(_feedback_label)


func _update_status() -> void:
	_status_label.text = "Công cụ: %s   (1: Cuốc   2: Gieo hạt   3: Thu hoạch; chuột trái để dùng)" % controller.get_tool_name()
