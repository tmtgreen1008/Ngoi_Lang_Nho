class_name BagScreen
extends CanvasLayer
## Màn hình túi đồ của người chơi: lưới ô kho (kéo/thả để sắp xếp) bên trái, chi tiết vật phẩm đang chọn bên phải,
## nút "Ăn" cho đồ ăn được (hồi thể lực), nút "Sắp xếp" gộp và xếp lại đồ. Mở/đóng bằng phím Tab hoặc I (hành động "inventory"); Esc cũng đóng.
##
## Dùng lại InventoryUI (lưới ô). Khi mở thì phát dialogue_opened(&"bag") để Player đứng yên và menu tạm dừng nhường
## Esc, giống các bảng khác. Không mở được khi đang nói chuyện, mua bán, chơi mini-game, chuyển map hay ở màn hình chính.

const SPEAKER_ID: StringName = &"bag"
const ACTION: StringName = &"inventory"
const INVENTORY_UI_SCENE: PackedScene = preload("res://ui/inventory/inventory_ui.tscn")
const CATEGORY_NAMES: Dictionary = {
	ItemData.Category.SEED: "Hạt giống", ItemData.Category.CROP: "Nông sản", ItemData.Category.FOOD: "Thực phẩm",
	ItemData.Category.TOOL: "Công cụ", ItemData.Category.MATERIAL: "Vật liệu", ItemData.Category.MISC: "Khác",
}

var inventory_ui: InventoryUI
var selected_index: int = -1

var _inventory: InventoryComponent
var _icon: TextureRect
var _name_label: Label
var _info_label: Label
var _description_label: Label
var _eat_button: Button
var _open: bool = false
var _busy: bool = false  # đang có hộp thoại / cửa hàng / mini-game


func _ready() -> void:
	layer = 21
	_register_action()
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	center.add_child(row)

	inventory_ui = INVENTORY_UI_SCENE.instantiate()
	inventory_ui.columns = 8
	row.add_child(inventory_ui)
	inventory_ui.slot_selected.connect(select)

	# Bảng chi tiết bên phải.
	var detail := PanelContainer.new()
	detail.theme = UiTheme.get_theme()
	detail.custom_minimum_size = Vector2(300, 0)
	row.add_child(detail)
	var margin := MarginContainer.new()
	for side: String in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	detail.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)
	_icon = TextureRect.new()
	_icon.custom_minimum_size = Vector2(96, 96)
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	box.add_child(_icon)
	_name_label = Label.new()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", 22)
	box.add_child(_name_label)
	_info_label = Label.new()
	_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_info_label.add_theme_font_size_override("font_size", 14)
	_info_label.add_theme_color_override("font_color", UiTheme.INK_SOFT)
	box.add_child(_info_label)
	_description_label = Label.new()
	_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_description_label.custom_minimum_size = Vector2(268, 90)
	_description_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_description_label)
	_eat_button = Button.new()
	_eat_button.text = "Ăn"
	_eat_button.focus_mode = Control.FOCUS_NONE
	_eat_button.pressed.connect(eat_selected)
	_eat_button.hide()
	box.add_child(_eat_button)
	var sort_button := Button.new()
	sort_button.text = "Sắp xếp"
	sort_button.focus_mode = Control.FOCUS_NONE
	sort_button.pressed.connect(sort_items)
	box.add_child(sort_button)
	var close_button := Button.new()
	close_button.text = "Đóng (Tab)"
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.pressed.connect(close)
	box.add_child(close_button)

	EventBus.dialogue_opened.connect(func(speaker: StringName) -> void: _busy = speaker != SPEAKER_ID or _busy)
	EventBus.dialogue_closed.connect(func(_speaker: StringName) -> void: _busy = false)
	EventBus.shop_opened.connect(func(_vendor: Resource) -> void: _busy = true)
	EventBus.shop_closed.connect(func(_vendor: Resource) -> void: _busy = false)
	EventBus.minigame_started.connect(func(_id: StringName) -> void: _busy = true)
	EventBus.minigame_finished.connect(func(_id: StringName, _result: Dictionary) -> void: _busy = false)
	EventBus.inventory_changed.connect(func(_owner: StringName) -> void: _refresh_detail())
	hide()


func is_open() -> bool:
	return _open


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(ACTION):
		if _open:
			close()
		else:
			open()
		get_viewport().set_input_as_handled()
	elif _open and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


## Mở túi đồ của Player. Trả về false nếu lúc này không mở được.
func open() -> bool:
	if _open or _busy or SceneManager.current_map == null or SceneManager.is_transitioning or get_tree().paused:
		return false
	var player: Node = get_tree().get_first_node_in_group("player")
	if player == null or bool(player.get("movement_locked")):
		return false  # đang ở màn hình chính hoặc bị khoá vì lý do khác
	_inventory = player.get("inventory") as InventoryComponent
	if _inventory == null:
		return false
	_open = true
	selected_index = -1
	_rebuild()
	show()
	EventBus.dialogue_opened.emit(SPEAKER_ID)
	return true


func close() -> void:
	if not _open:
		return
	_open = false
	hide()
	EventBus.dialogue_closed.emit(SPEAKER_ID)


## Chọn ô [param index] để xem chi tiết (ô trống thì bỏ chọn).
func select(index: int) -> void:
	selected_index = index
	_refresh_detail()


## Ăn một cái của vật phẩm đang chọn để hồi thể lực. Trả về true nếu đã ăn.
func eat_selected() -> bool:
	if _inventory == null or selected_index < 0 or selected_index >= _inventory.slots.size():
		return false
	var slot: InventorySlot = _inventory.slots[selected_index]
	if slot.is_empty() or slot.item.energy <= 0:
		return false
	var item: ItemData = slot.item
	if StaminaManager.is_full():
		EventBus.notice_requested.emit("Bạn đang khỏe, chưa cần ăn.", &"info")
		return false
	_inventory.remove_item(item, 1)
	var restored: int = StaminaManager.restore(item.energy)
	EventBus.item_used.emit(item, 1)
	EventBus.sfx_requested.emit(&"pickup")
	EventBus.notice_requested.emit("Bạn ăn %s, hồi %d thể lực." % [item.display_name.to_lower(), restored], &"success")
	_refresh_detail()
	return true


## Gộp các chồng cùng loại và xếp lại theo nhóm rồi theo tên.
func sort_items() -> void:
	if _inventory == null:
		return
	_inventory.sort_slots()
	selected_index = -1
	_refresh_detail()
	EventBus.sfx_requested.emit(&"tick")


## Dựng lại lưới ô (số ô có thể đã đổi do nâng cấp túi) và tiêu đề.
func _rebuild() -> void:
	inventory_ui.setup(_inventory, "")
	_refresh_detail()


func _used_slots() -> int:
	var used: int = 0
	for slot: InventorySlot in _inventory.slots:
		if not slot.is_empty():
			used += 1
	return used


func _refresh_detail() -> void:
	if not _open or _inventory == null:
		return
	inventory_ui.set_title("Túi đồ (%d/%d ô)" % [_used_slots(), _inventory.slots.size()])
	var slot: InventorySlot = _inventory.slots[selected_index] if selected_index >= 0 and selected_index < _inventory.slots.size() else null
	if slot == null or slot.is_empty():
		_icon.texture = null
		_name_label.text = "Chọn một vật phẩm"
		_info_label.text = "Bấm vào ô để xem chi tiết. Kéo thả để đổi chỗ."
		_description_label.text = ""
		_eat_button.hide()
		return
	var item: ItemData = slot.item
	_icon.texture = item.icon
	_name_label.text = item.display_name
	_info_label.text = "%s  ·  đang có %d  ·  giá gốc %d đ" % [CATEGORY_NAMES.get(item.category, "Khác"), _inventory.count_of(item), item.base_price]
	var text: String = item.description
	if item is CropItemData:
		var crop: CropItemData = item as CropItemData
		var seasons: PackedStringArray = []
		for season: int in crop.allowed_seasons:
			seasons.append(String(TimeManager.SEASON_NAMES.get(season, "?")))
		text += "\nGieo vào mùa: %s. Lớn trong %d ngày, thu %d nông sản." % [", ".join(seasons) if not seasons.is_empty() else "mùa nào cũng được", crop.grow_days, crop.harvest_amount]
	if item.energy > 0:
		text += "
Ăn được: hồi %d thể lực." % item.energy
	_description_label.text = text
	_eat_button.visible = item.energy > 0
	_eat_button.text = "Ăn (+%d sức)" % item.energy


## Đăng ký hành động "inventory" (Tab, I) nếu dự án chưa khai báo.
func _register_action() -> void:
	if InputMap.has_action(ACTION):
		return
	InputMap.add_action(ACTION)
	for keycode: int in [KEY_TAB, KEY_I]:
		var event := InputEventKey.new()
		event.physical_keycode = keycode
		InputMap.action_add_event(ACTION, event)
