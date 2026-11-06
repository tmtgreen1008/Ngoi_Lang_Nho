class_name PauseMenu
extends CanvasLayer
## Menu tạm dừng (Esc): Tiếp tục, Lưu game, Tải game. Dừng toàn bộ game khi mở
## (get_tree().paused), nên đồng hồ và Player đứng yên.
##
## Không mở khi cửa hàng đang mở (Esc lúc đó dành cho ShopUI) hoặc khi đang chuyển map.

var _panel: PanelContainer
var _info_label: Label
var _message_label: Label
var _load_button: Button
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

	_message_label = Label.new()
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	box.add_child(_message_label)

	EventBus.shop_opened.connect(func(_vendor: Resource) -> void: _shop_open = true)
	EventBus.shop_closed.connect(func(_vendor: Resource) -> void: _shop_open = false)
	# Mini-game có nút Thoát riêng, Esc không mở menu tạm dừng lúc đó.
	EventBus.minigame_started.connect(func(_id: StringName) -> void: _minigame_open = true)
	EventBus.minigame_finished.connect(func(_id: StringName, _result: Dictionary) -> void: _minigame_open = false)
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if visible:
		close()
	elif not _shop_open and not _minigame_open and not SceneManager.is_transitioning:
		open()
	else:
		return
	get_viewport().set_input_as_handled()


func open() -> void:
	_message_label.text = ""
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
	_message_label.text = error if not error.is_empty() else "Đã lưu game."
	_refresh_info()


func _on_load_pressed() -> void:
	# Bỏ dừng trước khi nạp: hiệu ứng chuyển map cần game chạy.
	close()
	var error: String = await SaveManager.load_game()
	if not error.is_empty():
		open()
		_message_label.text = error


func _add_button(parent: Node, text: String, on_pressed: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.pressed.connect(on_pressed)
	parent.add_child(button)
	return button
