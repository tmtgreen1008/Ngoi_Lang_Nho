class_name StartMenu
extends CanvasLayer
## Màn hình chính: Ván mới, Tiếp tục (bản lưu mới nhất), Thoát.
##
## Chỉ phát signal; Main quyết định cách bắt đầu ván. Nút Tiếp tục bị khoá khi chưa có
## bản lưu hợp lệ. Nền là tranh làng quê, logo có dải băng để ghi tên game.

## Người chơi chọn ván mới.
signal new_game_requested
## Người chơi chọn tiếp tục từ [param slot].
signal continue_requested(slot: StringName)

const BACKGROUND_PATH: String = "res://assets/art/ui/start_background.png"
const LOGO_PATH: String = "res://assets/art/ui/logo_emblem.png"
## Logo phóng to nguyên lần (pixel không méo).
const LOGO_SCALE: int = 3

var _continue_button: Button
var _info_label: Label
var _message_label: Label
var _slot: StringName = &""


func _ready() -> void:
	layer = 60
	var background := TextureRect.new()
	background.texture = load(BACKGROUND_PATH)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(340, 0)
	box.add_theme_constant_override("separation", 12)
	center.add_child(box)

	box.add_child(_make_logo())

	_add_button(box, "Ván mới", func() -> void: new_game_requested.emit())
	_continue_button = _add_button(box, "Tiếp tục", func() -> void: continue_requested.emit(_slot))
	_add_button(box, "Thoát", func() -> void: get_tree().quit())

	_info_label = _make_outlined_label(box, Color.WHITE)
	_message_label = _make_outlined_label(box, Color(1.0, 0.85, 0.4))
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


## Logo kèm tên game viết lên dải băng trống ở đáy ảnh.
func _make_logo() -> Control:
	var texture: Texture2D = load(LOGO_PATH)
	var holder := Control.new()
	holder.custom_minimum_size = texture.get_size() * LOGO_SCALE
	# Giữ đúng cỡ (không bị VBox kéo rộng ra làm méo logo), căn giữa cột nút.
	holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var image := TextureRect.new()
	image.texture = texture
	image.set_anchors_preset(Control.PRESET_FULL_RECT)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_SCALE
	holder.add_child(image)
	var title := Label.new()
	title.text = "Hương Quê"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", UiTheme.INK)
	holder.add_child(title)
	# Trải hết bề ngang logo, rồi đặt dải cao 36px vào chỗ dải băng (khoảng 72% chiều cao logo).
	title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = holder.custom_minimum_size.y * 0.72
	title.offset_bottom = title.offset_top + 36.0
	return holder


func _make_outlined_label(parent: Node, color: Color) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 5)
	parent.add_child(label)
	return label


func _add_button(parent: Node, text: String, on_pressed: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.theme = UiTheme.get_theme()
	button.custom_minimum_size = Vector2(0, 44)
	button.add_theme_font_size_override("font_size", 20)
	button.pressed.connect(on_pressed)
	parent.add_child(button)
	return button
