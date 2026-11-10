class_name InventorySlotUI
extends PanelContainer
## Một ô kho trên giao diện. Hiển thị icon (hoặc tên nếu chưa có icon) và số lượng,
## hỗ trợ kéo/thả bằng cơ chế drag-and-drop của Godot.
##
## Ô không tự sửa dữ liệu: khi thả, nó gọi InventoryComponent.transfer_slot() rồi
## cập nhật lại khi nhận signal slot_changed của component.

const DRAG_TYPE: String = "inventory_slot"
const SLOT_SIZE: Vector2 = Vector2(72, 72)

## Người chơi bấm chuột trái vào ô (để xem chi tiết vật phẩm).
signal selected(index: int)

## Kho và vị trí ô mà ô giao diện này đại diện.
var inventory: InventoryComponent
var index: int = -1

var _icon: TextureRect
var _name_label: Label
var _amount_label: Label
var _normal_style: StyleBox
var _hover_style: StyleBox


func _init() -> void:
	custom_minimum_size = SLOT_SIZE
	_normal_style = UiTheme.slot_style(0)
	_hover_style = UiTheme.slot_style(1)
	add_theme_stylebox_override("panel", _normal_style)
	# Viền sáng khi trỏ chuột vào ô (hoặc kéo đồ qua ô).
	mouse_entered.connect(_set_highlight.bind(true))
	mouse_exited.connect(_set_highlight.bind(false))

	_icon = TextureRect.new()
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_icon)

	# Khi chưa có icon, hiện tên vật phẩm để vẫn phân biệt được.
	_name_label = Label.new()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_name_label.add_theme_font_size_override("font_size", 12)
	_name_label.add_theme_color_override("font_color", Color.WHITE)
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_name_label)

	# Số lượng nằm góc dưới phải: PanelContainer chỉ căn con theo cờ kích thước.
	_amount_label = Label.new()
	_amount_label.size_flags_horizontal = Control.SIZE_SHRINK_END
	_amount_label.size_flags_vertical = Control.SIZE_SHRINK_END
	_amount_label.add_theme_font_size_override("font_size", 14)
	_amount_label.add_theme_color_override("font_color", Color.WHITE)
	_amount_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_amount_label.add_theme_constant_override("outline_size", 5)
	_amount_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_amount_label)


## Gắn ô giao diện với ô số [param slot_index] của [param inv] rồi vẽ lại.
func setup(inv: InventoryComponent, slot_index: int) -> void:
	inventory = inv
	index = slot_index
	refresh()


## Vẽ lại theo nội dung hiện tại của ô dữ liệu.
func refresh() -> void:
	if inventory == null or index < 0 or index >= inventory.slots.size():
		return
	var slot: InventorySlot = inventory.slots[index]
	if slot.is_empty():
		_icon.texture = null
		_name_label.text = ""
		_amount_label.text = ""
		tooltip_text = ""
		return
	_icon.texture = slot.item.icon
	_name_label.text = "" if slot.item.icon != null else slot.item.display_name
	_amount_label.text = "x%d" % slot.amount if slot.amount > 1 else ""
	tooltip_text = slot.item.display_name
	if not slot.item.description.is_empty():
		tooltip_text += "\n" + slot.item.description


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		selected.emit(index)


func _get_drag_data(_at_position: Vector2) -> Variant:
	if inventory == null or inventory.slots[index].is_empty():
		return null
	var slot: InventorySlot = inventory.slots[index]
	var preview := PanelContainer.new()
	preview.add_theme_stylebox_override("panel", _make_style(Color(0.35, 0.26, 0.16, 0.9), Color(0.85, 0.7, 0.4)))
	preview.custom_minimum_size = SLOT_SIZE * 0.8
	var label := Label.new()
	label.text = "%s\nx%d" % [slot.item.display_name, slot.amount]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 12)
	preview.add_child(label)
	set_drag_preview(preview)
	return {"type": DRAG_TYPE, "inventory": inventory, "index": index}


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return (
		inventory != null
		and data is Dictionary
		and data.get("type") == DRAG_TYPE
		and is_instance_valid(data.get("inventory"))
	)


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var source: InventoryComponent = data["inventory"]
	source.transfer_slot(int(data["index"]), inventory, index)


static func _make_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(4)
	return style


## Bật/tắt viền sáng của ô.
func _set_highlight(on: bool) -> void:
	add_theme_stylebox_override("panel", _hover_style if on else _normal_style)
