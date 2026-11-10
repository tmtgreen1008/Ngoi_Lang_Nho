class_name UpgradeUI
extends CanvasLayer
## Bảng nâng cấp ("Nhờ ông Bảy làm giúp"): mỗi nâng cấp một dòng gồm tên, mô tả, cấp hiện tại, hiệu lực hiện tại
## và kế tiếp, nút mua kèm giá. Dữ liệu và việc mua do UpgradeManager lo; bảng chỉ hiển thị.
##
## Mở khi EventBus.upgrade_menu_requested (DialogueBox phát). Mở bảng thì phát dialogue_opened(&"upgrades") để
## Player đứng yên và menu tạm dừng nhường Esc, giống hộp thoại. Esc hoặc nút Đóng để thoát.

const SPEAKER_ID: StringName = &"upgrades"

var _panel: PanelContainer
var _money_label: Label
var _list: VBoxContainer
var _message_label: Label
var _open: bool = false


func _ready() -> void:
	layer = 23
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	_panel = PanelContainer.new()
	_panel.theme = UiTheme.get_theme()
	_panel.custom_minimum_size = Vector2(780, 0)
	center.add_child(_panel)
	var margin := MarginContainer.new()
	for side: String in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	_panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	var header := HBoxContainer.new()
	box.add_child(header)
	var title := Label.new()
	title.text = "Nhờ ông Bảy làm giúp"
	title.add_theme_font_size_override("font_size", 24)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	_money_label = Label.new()
	_money_label.add_theme_font_size_override("font_size", 20)
	header.add_child(_money_label)

	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 6)
	box.add_child(_list)

	_message_label = Label.new()
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.add_theme_color_override("font_color", UiTheme.ACCENT_RED)
	box.add_child(_message_label)
	var close_button := Button.new()
	close_button.text = "Đóng"
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.pressed.connect(close)
	box.add_child(close_button)

	EventBus.upgrade_menu_requested.connect(open)
	EventBus.money_changed.connect(func(_amount: int, _delta: int) -> void: _refresh())
	EventBus.upgrade_purchased.connect(func(_id: StringName, _level: int) -> void: _refresh())
	EventBus.upgrades_reloaded.connect(_refresh)
	hide()


func is_open() -> bool:
	return _open


func _unhandled_input(event: InputEvent) -> void:
	if _open and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func open() -> void:
	if _open:
		return
	_open = true
	_message_label.text = ""
	_refresh()
	show()
	EventBus.dialogue_opened.emit(SPEAKER_ID)


func close() -> void:
	if not _open:
		return
	_open = false
	hide()
	EventBus.dialogue_closed.emit(SPEAKER_ID)


## Dựng lại danh sách theo cấp và tiền hiện tại.
func _refresh() -> void:
	if not _open:
		return
	_money_label.text = "%d đ" % EconomyManager.money
	for child: Node in _list.get_children():
		child.queue_free()
	for data: UpgradeData in UpgradeManager.get_all():
		_list.add_child(_make_row(data))


func _make_row(data: UpgradeData) -> Control:
	var level: int = UpgradeManager.get_level(data.id)
	var maxed: bool = UpgradeManager.is_maxed(data.id)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text_box)
	var name_label := Label.new()
	name_label.text = "%s  (cấp %d/%d)" % [data.display_name, level, data.max_level()]
	name_label.add_theme_font_size_override("font_size", 18)
	text_box.add_child(name_label)
	var description := Label.new()
	description.text = data.description
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.custom_minimum_size = Vector2(440, 0)
	description.add_theme_font_size_override("font_size", 14)
	description.add_theme_color_override("font_color", UiTheme.INK_SOFT)
	text_box.add_child(description)

	var effect := Label.new()
	effect.custom_minimum_size = Vector2(150, 0)
	effect.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	effect.text = data.format_value(level) if maxed else "%s → %s" % [data.format_value(level), data.format_value(level + 1)]
	row.add_child(effect)

	var button := Button.new()
	button.custom_minimum_size = Vector2(140, 0)
	button.focus_mode = Control.FOCUS_NONE
	if maxed:
		button.text = "Tối đa"
		button.disabled = true
	else:
		var cost: int = UpgradeManager.get_next_cost(data.id)
		button.text = "Nâng cấp %d đ" % cost
		button.disabled = not EconomyManager.can_afford(cost)
		button.pressed.connect(_on_buy_pressed.bind(data.id))
	row.add_child(button)
	return row


func _on_buy_pressed(id: StringName) -> void:
	var data: UpgradeData = UpgradeManager.get_data(id)
	var error: String = UpgradeManager.buy(id)
	if error.is_empty():
		_message_label.text = ""
		EventBus.notice_requested.emit("Đã nâng cấp: %s (%s)." % [data.display_name, data.format_value(UpgradeManager.get_level(id))], &"success")
	else:
		_message_label.text = error
