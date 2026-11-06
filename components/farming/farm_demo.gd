extends Node2D
## Scene demo vườn: chuột trái dùng công cụ lên ô; phím 1/2/3 đổi công cụ
## (Cuốc / Gieo hạt / Thu hoạch); phím N ngủ qua ngày (để thử cây lớn nhanh).
## Chỉ để thử hệ thống; game thật sẽ đặt FarmField vào map Home.

const INVENTORY_UI_SCENE: PackedScene = preload("res://ui/inventory/inventory_ui.tscn")

var field: FarmField
var view: FarmView
var controller: FarmToolController
var inventory: InventoryComponent

var _status_label: Label
var _feedback_label: Label


func _ready() -> void:
	field = FarmField.new()
	add_child(field)

	inventory = InventoryComponent.new()
	inventory.owner_id = &"player"
	inventory.slot_count = 8
	add_child(inventory)
	inventory.add_item(ItemDatabase.get_item(&"hat_giong_lua"), 10)

	view = FarmView.new()
	view.position = Vector2(60, 130)
	view.scale = Vector2(2, 2)
	add_child(view)
	view.setup(field)

	controller = FarmToolController.new()
	controller.field = field
	controller.inventory = inventory
	add_child(controller)

	_build_hud()
	controller.tool_changed.connect(func(_t: FarmToolController.Tool) -> void: _update_status())
	controller.feedback.connect(func(text: String) -> void: _feedback_label.text = text)
	EventBus.time_ticked.connect(func(_h: int, _m: int) -> void: _update_status())
	EventBus.day_changed.connect(func(_d: int) -> void: _update_status())
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
			KEY_N:
				TimeManager.sleep_until_morning()


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side: String in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	layer.add_child(margin)

	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(root)

	_status_label = Label.new()
	_status_label.add_theme_font_size_override("font_size", 20)
	root.add_child(_status_label)

	var hint := Label.new()
	hint.text = "Chuột trái: dùng công cụ   |   1: Cuốc   2: Gieo hạt   3: Thu hoạch   |   N: ngủ qua ngày"
	hint.position = Vector2(0, 30)
	root.add_child(hint)

	_feedback_label = Label.new()
	_feedback_label.position = Vector2(0, 60)
	_feedback_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	root.add_child(_feedback_label)

	var inventory_ui: InventoryUI = INVENTORY_UI_SCENE.instantiate()
	inventory_ui.columns = 4
	inventory_ui.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	root.add_child(inventory_ui)
	inventory_ui.setup(inventory, "Túi đồ")
	inventory_ui.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)


func _update_status() -> void:
	_status_label.text = "Ngày %d (%s, ngày %d/%d)  %s   |   Công cụ: %s" % [
		TimeManager.day,
		TimeManager.get_season_name(),
		TimeManager.get_day_of_season(),
		TimeManager.days_per_season,
		TimeManager.get_time_string(),
		controller.get_tool_name(),
	]
