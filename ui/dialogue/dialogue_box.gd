class_name DialogueBox
extends CanvasLayer
## Hộp thoại với NPC: hiện tên, lời thoại, độ thân thiết và các lựa chọn (Mua bán / Trò chuyện / Tạm biệt).
##
## Nghe EventBus.npc_talk_requested (VendorNPC phát) và tự mở; không ai gọi trực tiếp. Phát dialogue_opened/
## dialogue_closed để Player khoá di chuyển. Bấm E chọn lựa chọn đầu tiên (Mua bán), nên E-E mở cửa hàng
## nhanh như trước; Esc đóng hộp thoại.
##
## "Trò chuyện" tăng độ thân thiết (mỗi ngày một lần, xem RelationshipManager) và có thể nhận quà.

var _panel: PanelContainer
var _name_label: Label
var _status_label: Label
var _text_label: Label
var _options: HBoxContainer
var _shop_button: Button
var _talk_button: Button
var _upgrade_button: Button
var _bye_button: Button

var _npc: Node = null
var _data: DialogueData = null
var _player: Node = null
var _salt: int = 0


func _ready() -> void:
	layer = 22
	var anchor := Control.new()
	anchor.set_anchors_preset(Control.PRESET_FULL_RECT)
	anchor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(anchor)
	_panel = PanelContainer.new()
	_panel.theme = UiTheme.get_theme()
	_panel.custom_minimum_size = Vector2(760, 0)
	_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_panel.position.y -= 100.0
	anchor.add_child(_panel)
	var margin := MarginContainer.new()
	for side: String in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	_panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	var header := HBoxContainer.new()
	box.add_child(header)
	_name_label = Label.new()
	_name_label.add_theme_font_size_override("font_size", 24)
	_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_name_label)
	_status_label = Label.new()
	_status_label.add_theme_font_size_override("font_size", 15)
	_status_label.add_theme_color_override("font_color", UiTheme.INK_SOFT)
	header.add_child(_status_label)

	_text_label = Label.new()
	_text_label.custom_minimum_size = Vector2(0, 72)
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.add_theme_font_size_override("font_size", 19)
	box.add_child(_text_label)

	_options = HBoxContainer.new()
	_options.add_theme_constant_override("separation", 10)
	box.add_child(_options)
	_shop_button = _add_option("Mua bán", _on_shop_pressed)
	_talk_button = _add_option("Trò chuyện", _on_talk_pressed)
	_upgrade_button = _add_option("Nhờ làm giúp", _on_upgrade_pressed)
	_bye_button = _add_option("Tạm biệt", _on_bye_pressed)

	EventBus.npc_talk_requested.connect(_on_npc_talk_requested)
	hide()


func is_open() -> bool:
	return visible


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
	elif event.is_action_pressed("interact"):
		# E chọn lựa chọn đầu tiên đang có (Mua bán, hoặc Trò chuyện nếu NPC không bán hàng).
		for button: Button in [_shop_button, _talk_button]:
			if button.visible:
				button.pressed.emit()
				break
	else:
		return
	get_viewport().set_input_as_handled()


## Mở hộp thoại với [param npc] (cần thuộc tính dialogue, và vendor nếu có bán hàng; VendorNPC hoặc
## VillagerNPC), người chơi là [param interactor].
func open(npc: Node, interactor: Node) -> void:
	if visible or npc == null:
		return
	var dialogue: DialogueData = npc.get("dialogue") as DialogueData
	if dialogue == null:
		return
	_npc = npc
	_player = interactor
	_data = dialogue
	_salt = TimeManager.day * 13
	_name_label.text = _data.display_name
	var greeting: String
	if RelationshipManager.has_met(_data.speaker_id):
		greeting = _data.pick_greeting(_salt)
	else:
		greeting = _data.pick_first_meeting()
	_text_label.text = greeting
	_shop_button.visible = npc.get("vendor") != null
	_upgrade_button.visible = npc.get("offers_upgrades") == true  # VendorNPC không có thuộc tính này (null)
	_refresh_status()
	show()
	EventBus.dialogue_opened.emit(_data.speaker_id)


func close() -> void:
	if not visible:
		return
	var speaker: StringName = _data.speaker_id
	hide()
	_npc = null
	_player = null
	EventBus.dialogue_closed.emit(speaker)


func _add_option(text: String, on_pressed: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(on_pressed)
	_options.add_child(button)
	return button


func _refresh_status() -> void:
	var id: StringName = _data.speaker_id
	var text: String = "%s · %d điểm" % [RelationshipManager.get_level_name(id), RelationshipManager.get_points(id)]
	if RelationshipManager.has_talked_today(id):
		text += " · hôm nay đã trò chuyện"
	elif RelationshipManager.is_wearing_clean():
		text += " · áo quần sạch (x2 điểm)"
	_status_label.text = text


func _on_npc_talk_requested(npc: Node, interactor: Node) -> void:
	open(npc, interactor)


func _on_shop_pressed() -> void:
	var vendor: Node = _npc.get("vendor")
	var buyer: Node = _player.get("inventory") if _player != null else null
	close()
	if vendor != null and buyer != null:
		EventBus.shop_open_requested.emit(vendor, buyer)


## "Nhờ làm giúp": đóng hộp thoại và mở bảng nâng cấp (UpgradeUI nghe EventBus).
func _on_upgrade_pressed() -> void:
	close()
	EventBus.upgrade_menu_requested.emit()


func _on_talk_pressed() -> void:
	var id: StringName = _data.speaker_id
	var result: Dictionary = RelationshipManager.talk(id)
	_salt += 1
	_text_label.text = _data.pick_line(TimeManager.season, int(result["level"]), _salt)
	if bool(result["leveled_up"]):
		EventBus.notice_requested.emit("Bạn và %s đã trở nên \"%s\"." % [_data.display_name, RelationshipManager.LEVEL_NAMES[int(result["level"])]], &"success")
	_try_give_gift()
	_refresh_status()


## Đủ điểm thân thiết thì NPC tặng quà (một lần). Túi đầy thì để lần sau.
func _try_give_gift() -> void:
	var id: StringName = _data.speaker_id
	if _data.gift_item_id == &"" or not RelationshipManager.is_gift_ready(id, _data.gift_points):
		return
	var item: ItemData = ItemDatabase.get_item(_data.gift_item_id)
	var inventory: InventoryComponent = _player.get("inventory") as InventoryComponent if _player != null else null
	if item == null or inventory == null:
		return
	if not inventory.can_add(item, _data.gift_amount):
		EventBus.notice_requested.emit("%s muốn tặng quà nhưng túi đồ của bạn đã đầy." % _data.display_name, &"error")
		return
	RelationshipManager.claim_gift(id)
	inventory.add_item(item, _data.gift_amount)
	EventBus.item_picked.emit(item, _data.gift_amount)
	_text_label.text = _data.gift_text
	EventBus.notice_requested.emit("%s tặng bạn %d %s." % [_data.display_name, _data.gift_amount, item.display_name], &"success")


func _on_bye_pressed() -> void:
	EventBus.notice_requested.emit("%s: %s" % [_data.display_name, _data.pick_farewell(_salt)], &"info")
	close()
