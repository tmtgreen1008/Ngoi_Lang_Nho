class_name StartMenu
extends CanvasLayer
## Màn hình chính: Ván mới, Tiếp tục (bản lưu mới nhất), Thoát.
##
## Chỉ phát signal; Main quyết định cách bắt đầu ván. Nút Tiếp tục bị khoá khi chưa có
## bản lưu hợp lệ.

## Người chơi chọn ván mới.
signal new_game_requested
## Người chơi chọn tiếp tục từ [param slot].
signal continue_requested(slot: StringName)

var _continue_button: Button
var _info_label: Label
var _message_label: Label
var _slot: StringName = &""


func _ready() -> void:
	layer = 60
	var background := ColorRect.new()
	background.color = Color(0.16, 0.3, 0.2, 1.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(360, 0)
	box.add_theme_constant_override("separation", 12)
	center.add_child(box)

	var title := Label.new()
	title.text = "Hương Quê"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 54)
	box.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Rustic Roots"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.modulate = Color(1, 1, 1, 0.7)
	box.add_child(subtitle)
	box.add_child(Control.new())  # khoảng đệm

	_add_button(box, "Ván mới", func() -> void: new_game_requested.emit())
	_continue_button = _add_button(box, "Tiếp tục", func() -> void: continue_requested.emit(_slot))
	_add_button(box, "Thoát", func() -> void: get_tree().quit())

	_info_label = Label.new()
	_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_info_label.modulate = Color(1, 1, 1, 0.8)
	box.add_child(_info_label)
	_message_label = Label.new()
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	box.add_child(_message_label)
	refresh()


## Hiện lại menu (vd: sau khi nạp game thất bại), kèm thông báo [param message].
func open(message: String = "") -> void:
	_message_label.text = message
	refresh()
	show()


## Cập nhật nút Tiếp tục và thông tin bản lưu theo các file hiện có.
func refresh() -> void:
	_slot = SaveManager.get_latest_slot()
	_continue_button.disabled = _slot == &""
	if _slot == &"":
		_info_label.text = "Chưa có bản lưu."
		return
	var info: Dictionary = SaveManager.get_slot_info(_slot)
	_info_label.text = "Bản lưu %s: Ngày %d (%s) %s, %d đ" % [
		"tự động" if _slot == SaveManager.AUTOSAVE_SLOT else "thủ công",
		int(info.get("day", 0)),
		TimeManager.SEASON_NAMES.get(int(info.get("season", 0)), "?"),
		info.get("time", ""),
		int(info.get("money", 0)),
	]


func _add_button(parent: Node, text: String, on_pressed: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 42)
	button.pressed.connect(on_pressed)
	parent.add_child(button)
	return button
