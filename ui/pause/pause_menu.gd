class_name PauseMenu
extends CanvasLayer
## Menu tạm dừng (Esc): Tiếp tục, Lưu game, Tải game, cài đặt âm thanh (hiệu ứng, nhạc nền, tắt tiếng)
## và Về màn hình chính (hỏi xác nhận). Dừng toàn bộ game khi mở (get_tree().paused), nên đồng hồ và
## Player đứng yên.
##
## Không mở khi cửa hàng đang mở (Esc lúc đó dành cho ShopUI), khi đang chuyển map, hoặc khi đang ở
## màn hình chính ([member in_main_menu]).

## Người chơi xác nhận về màn hình chính; Main lo phần dừng ván.
signal main_menu_requested

const MENU_BUTTON_TEXT: String = "Về màn hình chính"

var _panel: PanelContainer
var _info_label: Label
var _message_label: Label
var _load_button: Button
var _menu_button: Button
var _sfx_slider: HSlider
var _music_slider: HSlider
var _mute_check: CheckButton
var _confirming_exit: bool = false
## true khi đang ở màn hình chính: Esc không mở menu tạm dừng.
var in_main_menu: bool = false
var _shop_open: bool = false
var _minigame_open: bool = false


func _ready() -> void:
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS  # Vẫn nhận input khi game đang dừng.

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(420, 0)
	_panel.theme = UiTheme.get_theme()
	center.add_child(_panel)
	var margin := MarginContainer.new()
	for side: String in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	_panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	var title := Label.new()
	title.text = "Tạm dừng"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	box.add_child(title)

	_info_label = Label.new()
	_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_info_label)

	_add_button(box, "Tiếp tục", close)
	_add_button(box, "Lưu game", _on_save_pressed)
	_load_button = _add_button(box, "Tải game", _on_load_pressed)

	# Cài đặt âm thanh (lưu lại giữa các lần chơi qua AudioManager).
	_sfx_slider = _add_volume_row(box, "Hiệu ứng", AudioManager.sfx_volume, AudioManager.set_sfx_volume)
	_music_slider = _add_volume_row(box, "Nhạc nền", AudioManager.music_volume, AudioManager.set_music_volume)
	_mute_check = CheckButton.new()
	_mute_check.text = "Tắt tiếng (phím M)"
	_mute_check.button_pressed = AudioManager.muted
	_mute_check.toggled.connect(func(pressed: bool) -> void: AudioManager.set_muted(pressed))
	box.add_child(_mute_check)

	_menu_button = _add_button(box, MENU_BUTTON_TEXT, _on_main_menu_pressed)

	_message_label = Label.new()
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.add_theme_color_override("font_color", UiTheme.ACCENT_RED)
	box.add_child(_message_label)

	EventBus.shop_opened.connect(func(_vendor: Resource) -> void: _shop_open = true)
	EventBus.shop_closed.connect(func(_vendor: Resource) -> void: _shop_open = false)
	# Hộp thoại tự xử lý Esc, nên menu tạm dừng không mở lúc đó.
	EventBus.dialogue_opened.connect(func(_speaker: StringName) -> void: _shop_open = true)
	EventBus.dialogue_closed.connect(func(_speaker: StringName) -> void: _shop_open = false)
	# Mini-game có nút Thoát riêng, Esc không mở menu tạm dừng lúc đó.
	EventBus.minigame_started.connect(func(_id: StringName) -> void: _minigame_open = true)
	EventBus.minigame_finished.connect(func(_id: StringName, _result: Dictionary) -> void: _minigame_open = false)
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if visible:
		close()
	elif SceneManager.current_map != null and not in_main_menu and not _shop_open and not _minigame_open and not SceneManager.is_transitioning:
		open()
	else:
		return
	get_viewport().set_input_as_handled()


func open() -> void:
	_message_label.text = ""
	_confirming_exit = false
	_menu_button.text = MENU_BUTTON_TEXT
	_sfx_slider.set_value_no_signal(AudioManager.sfx_volume * 100.0)
	_music_slider.set_value_no_signal(AudioManager.music_volume * 100.0)
	_mute_check.set_pressed_no_signal(AudioManager.muted)
	_refresh_info()
	show()
	get_tree().paused = true


func close() -> void:
	hide()
	get_tree().paused = false


func _refresh_info() -> void:
	var info: Dictionary = SaveManager.get_slot_info()
	_load_button.disabled = info.is_empty()
	if info.is_empty():
		_info_label.text = "Chưa có bản lưu."
		return
	_info_label.text = "Bản lưu: Ngày %d (%s) %s, %d đ\n%s" % [
		int(info.get("day", 0)),
		TimeManager.SEASON_NAMES.get(int(info.get("season", 0)), "?"),
		info.get("time", ""),
		int(info.get("money", 0)),
		info.get("saved_at", ""),
	]


func _on_save_pressed() -> void:
	var error: String = SaveManager.save_game()
	var failed: bool = not error.is_empty()
	_message_label.text = error if failed else "Đã lưu game."
	_message_label.add_theme_color_override("font_color", UiTheme.notice_color(&"error" if failed else &"success"))
	_refresh_info()


func _on_load_pressed() -> void:
	# Bỏ dừng trước khi nạp: hiệu ứng chuyển map cần game chạy.
	close()
	var error: String = await SaveManager.load_game()
	if not error.is_empty():
		open()
		_message_label.text = error
		_message_label.add_theme_color_override("font_color", UiTheme.notice_color(&"error"))


## Về màn hình chính: bấm lần đầu chỉ hỏi lại (ván chưa lưu sẽ mất), lần hai mới thoát ra.
func _on_main_menu_pressed() -> void:
	if not _confirming_exit:
		_confirming_exit = true
		_menu_button.text = "Bấm lần nữa để xác nhận (chưa lưu sẽ mất)"
		return
	close()
	main_menu_requested.emit()


## Một hàng "tên + thanh trượt 0-100" nối với [param setter] (nhận giá trị 0-1).
func _add_volume_row(parent: Node, label_text: String, value: float, setter: Callable) -> HSlider:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	parent.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(110, 0)
	row.add_child(label)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 5.0
	slider.value = value * 100.0
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.focus_mode = Control.FOCUS_NONE
	slider.value_changed.connect(func(v: float) -> void: setter.call(v / 100.0))
	row.add_child(slider)
	return slider


func _add_button(parent: Node, text: String, on_pressed: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.pressed.connect(on_pressed)
	parent.add_child(button)
	return button
