extends MapBase
## Khu nhà: mảnh vườn (cuốc, gieo, thu hoạch), giường để ngủ, lối ra Tiệm Tạp Hóa và Chợ.
##
## Vườn (FarmField) thuộc nhóm world_persistent nên được WorldStateManager nhớ khi
## người chơi đi chợ; quay về cây vẫn còn và đã lớn thêm đúng số ngày vắng mặt.
## Điều khiển vườn: chuột trái dùng công cụ; phím 1/2/3 đổi Cuốc / Gieo hạt / Thu hoạch.

const GROCERY_MAP: String = "res://maps/grocery_store/grocery_store.tscn"
const MARKET_MAP: String = "res://maps/morning_market/morning_market.tscn"

var field: FarmField
var view: FarmView
var controller: FarmToolController

var _status_label: Label
var _feedback_label: Label


func _build() -> void:
	add_spawn(&"default", Vector2(900, 400))
	add_spawn(&"from_grocery", Vector2(1150, 220))
	add_spawn(&"from_market", Vector2(1150, 520))
	add_exit(Vector2(1250, 220), Vector2(40, 120), GROCERY_MAP, &"from_home", "Tiệm Tạp Hóa")
	add_exit(Vector2(1250, 520), Vector2(40, 120), MARKET_MAP, &"from_home", "Chợ Quê")

	field = FarmField.new()
	field.name = "FarmField"
	add_child(field)
	view = FarmView.new()
	view.position = Vector2(60, 130)
	view.scale = Vector2(2, 2)
	add_child(view)
	view.setup(field)

	controller = FarmToolController.new()
	controller.field = field
	add_child(controller)
	var player: Node = get_tree().get_first_node_in_group("player")
	if player != null:
		controller.inventory = player.get("inventory")

	_build_bed()
	_build_hud()
	controller.tool_changed.connect(func(_t: FarmToolController.Tool) -> void: _update_status())
	controller.feedback.connect(func(text: String) -> void: _feedback_label.text = text)
	_update_status()


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
	var bed := InteractableComponent.new()
	bed.position = Vector2(900, 150)
	bed.prompt_text = "Đi ngủ"
	bed.interact_radius = 50.0
	bed.interacted.connect(func(_who: Node) -> void: TimeManager.sleep_until_morning())
	add_child(bed)
	var label := Label.new()
	label.text = "Giường"
	label.position = Vector2(868, 176)
	add_child(label)


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


func _draw() -> void:
	super._draw()
	# Ngôi nhà tạm: một khối nâu phía trên giường.
	draw_rect(Rect2(780, 90, 240, 40), Color(0.55, 0.38, 0.25))
