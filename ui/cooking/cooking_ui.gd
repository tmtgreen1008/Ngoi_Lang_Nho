class_name CookingUI
extends CanvasLayer
## Bảng nấu ăn (bếp trong nhà): mỗi công thức một dòng gồm icon và tên món, nguyên liệu (kèm số đang có), thời gian
## nấu và nút "Nấu". Dữ liệu là RecipeData (data/recipes/); nấu thì trừ nguyên liệu, thêm món, đồng hồ trôi
## [member RecipeData.cook_minutes] phút và có tiếng xèo xèo.
##
## Mở khi EventBus.cooking_requested (bếp phát, kèm người nấu). Giống bảng nâng cấp: phát dialogue_opened/closed để
## Player đứng yên và menu tạm dừng nhường Esc.

const SPEAKER_ID: StringName = &"cooking"

var _list: VBoxContainer
var _message_label: Label
var _inventory: InventoryComponent
var _recipes: Array[RecipeData] = []
var _open: bool = false


func _ready() -> void:
	layer = 23
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.theme = UiTheme.get_theme()
	panel.custom_minimum_size = Vector2(760, 0)
	center.add_child(panel)
	var margin := MarginContainer.new()
	for side: String in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)
	var title := Label.new()
	title.text = "Bếp nhà: nấu ăn"
	title.add_theme_font_size_override("font_size", 24)
	box.add_child(title)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 420)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 6)
	scroll.add_child(_list)
	_message_label = Label.new()
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_message_label)
	var close_button := Button.new()
	close_button.text = "Đóng"
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.pressed.connect(close)
	box.add_child(close_button)

	_recipes = RecipeData.load_all()
	EventBus.cooking_requested.connect(open)
	EventBus.inventory_changed.connect(func(_owner: StringName) -> void: _refresh())
	hide()


func is_open() -> bool:
	return _open


func get_recipes() -> Array[RecipeData]:
	return _recipes


func _unhandled_input(event: InputEvent) -> void:
	if _open and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


## Mở bảng cho người nấu [param cook] (cần thuộc tính inventory).
func open(cook: Node) -> void:
	if _open or cook == null:
		return
	_inventory = cook.get("inventory") as InventoryComponent
	if _inventory == null:
		return
	_open = true
	_set_message("", &"info")
	show()
	_refresh()
	EventBus.dialogue_opened.emit(SPEAKER_ID)


func close() -> void:
	if not _open:
		return
	_open = false
	hide()
	EventBus.dialogue_closed.emit(SPEAKER_ID)


## Nấu công thức [param recipe] một lần. Trả về true nếu nấu được.
func cook(recipe: RecipeData) -> bool:
	var error: String = recipe.cook(_inventory)
	if not error.is_empty():
		_set_message(error, &"error")
		return false
	var dish: ItemData = recipe.get_output()
	if recipe.cook_minutes > 0:
		TimeManager.advance_minutes(recipe.cook_minutes)
	EventBus.sfx_requested.emit(&"sizzle")
	EventBus.item_picked.emit(dish, recipe.output_amount)
	_set_message("Đã nấu xong %d %s (mất %d phút)." % [recipe.output_amount, dish.display_name.to_lower(), recipe.cook_minutes], &"success")
	_refresh()
	return true


func _set_message(text: String, kind: StringName) -> void:
	_message_label.text = text
	_message_label.add_theme_color_override("font_color", UiTheme.notice_color(kind))


func _refresh() -> void:
	if not _open:
		return
	for child: Node in _list.get_children():
		child.queue_free()
	for recipe: RecipeData in _recipes:
		_list.add_child(_make_row(recipe))


func _make_row(recipe: RecipeData) -> Control:
	var dish: ItemData = recipe.get_output()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var icon := TextureRect.new()
	icon.texture = dish.icon
	icon.custom_minimum_size = Vector2(48, 48)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	row.add_child(icon)
	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text_box)
	var name_label := Label.new()
	name_label.text = "%s  (%d phút)" % [dish.display_name, recipe.cook_minutes]
	name_label.add_theme_font_size_override("font_size", 18)
	text_box.add_child(name_label)
	var missing: String = recipe.get_missing(_inventory)
	var detail := Label.new()
	detail.text = recipe.describe_ingredients() if missing.is_empty() else "%s  ·  thiếu %s" % [recipe.describe_ingredients(), missing]
	detail.add_theme_font_size_override("font_size", 14)
	detail.add_theme_color_override("font_color", UiTheme.INK_SOFT if missing.is_empty() else UiTheme.ACCENT_RED)
	text_box.add_child(detail)
	var button := Button.new()
	button.text = "Nấu"
	button.custom_minimum_size = Vector2(110, 0)
	button.focus_mode = Control.FOCUS_NONE
	button.disabled = not recipe.get_block_reason(_inventory).is_empty()
	button.pressed.connect(cook.bind(recipe))
	row.add_child(button)
	return row
