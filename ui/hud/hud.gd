class_name Hud
extends CanvasLayer
## HUD: ngày/mùa/giờ kèm icon mùa (trái trên), tiền kèm icon đồng xu (phải trên),
## gợi ý tương tác kèm phím E (giữa dưới), thông báo nhanh (giữa trên).
##
## Chỉ nghe EventBus; không biết Player hay các hệ thống khác. Mỗi nhóm thông tin nằm trong
## một bảng giấy (UiTheme) nên đọc rõ trên mọi nền map.

const TOAST_SECONDS: float = 4.0

var _time_label: Label
var _money_label: Label
var _prompt_label: Label
var _toast_label: Label
var _season_icon: TextureRect
var _toast_panel: PanelContainer
var _prompt_panel: PanelContainer
var _toast_timer: Timer
var _shop_open: bool = false


func _ready() -> void:
	layer = 10
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side: String in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	add_child(margin)

	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(root)

	# Trái trên: icon mùa + ngày giờ.
	var left := _make_panel(root)
	var left_row := _make_row(left)
	_season_icon = _make_icon(left_row, UiTheme.HudIcon.SPRING)
	_time_label = _make_label(left_row, 18)

	# Phải trên: tiền + đồng xu.
	var right := _make_panel(root)
	right.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	right.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	var right_row := _make_row(right)
	_money_label = _make_label(right_row, 20)
	_make_icon(right_row, UiTheme.HudIcon.COIN)

	# Giữa dưới: phím E + lời nhắc.
	_prompt_panel = _make_panel(root)
	_prompt_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_prompt_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_prompt_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var prompt_row := _make_row(_prompt_panel)
	_make_icon(prompt_row, UiTheme.HudIcon.KEY_E)
	_prompt_label = _make_label(prompt_row, 20)
	_prompt_panel.hide()

	_toast_panel = _make_panel(root)
	_toast_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_toast_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_toast_panel.position.y = 64.0
	_toast_label = _make_label(_toast_panel, 20)
	_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_label.add_theme_color_override("font_color", UiTheme.INK)
	_toast_panel.hide()
	_toast_label.hide()
	_toast_timer = Timer.new()
	_toast_timer.one_shot = true
	_toast_timer.timeout.connect(_hide_toast)
	add_child(_toast_timer)
	EventBus.toast_requested.connect(func(text: String) -> void: show_toast(text, &"info"))
	EventBus.notice_requested.connect(show_toast)

	EventBus.time_ticked.connect(func(_h: int, _m: int) -> void: _update_time())
	EventBus.day_changed.connect(func(_d: int) -> void: _update_time())
	EventBus.season_changed.connect(func(_s: int, _y: int) -> void: _update_time())
	EventBus.money_changed.connect(func(_amount: int, _delta: int) -> void: _update_money())
	EventBus.interaction_prompt_changed.connect(_on_prompt_changed)
	# Ẩn gợi ý khi đang mua bán để không chồng lên cửa hàng.
	EventBus.shop_opened.connect(func(_vendor: Resource) -> void: _set_shop_open(true))
	EventBus.shop_closed.connect(func(_vendor: Resource) -> void: _set_shop_open(false))
	_update_time()
	_update_money()


## Hiện thông báo nhanh [param text] giữa màn hình vài giây (thông báo mới thay thông báo cũ).
func show_toast(text: String, kind: StringName = &"info") -> void:
	_toast_label.text = text
	_toast_label.add_theme_color_override("font_color", UiTheme.notice_color(kind))
	_toast_label.show()
	_toast_panel.show()
	# Panel co lại theo chữ mới (thông báo trước dài hơn thì không để lại khoảng thừa).
	_toast_panel.reset_size()
	_toast_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE)
	_toast_panel.position.y = 64.0
	_toast_timer.start(TOAST_SECONDS)


func _hide_toast() -> void:
	_toast_label.hide()
	_toast_panel.hide()


func _on_prompt_changed(text: String) -> void:
	_prompt_label.text = text
	_refresh_prompt_visibility()


func _set_shop_open(is_open: bool) -> void:
	_shop_open = is_open
	_refresh_prompt_visibility()


func _refresh_prompt_visibility() -> void:
	_prompt_panel.visible = not _prompt_label.text.is_empty() and not _shop_open


## Bảng giấy nhỏ gọn cho một nhóm thông tin; chữ bên trong tự thành nâu đậm nhờ UiTheme.
func _make_panel(parent: Node) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.theme = UiTheme.get_theme()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", UiTheme.hud_panel_style())
	parent.add_child(panel)
	return panel


func _make_row(panel: PanelContainer) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(row)
	return row


func _make_label(parent: Node, font_size: int) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label


func _make_icon(parent: Node, icon: UiTheme.HudIcon) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = UiTheme.hud_icon(icon)
	rect.custom_minimum_size = Vector2(UiTheme.HUD_ICON_CELL, UiTheme.HUD_ICON_CELL)
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)
	return rect


func _update_time() -> void:
	_season_icon.texture = UiTheme.season_icon(TimeManager.season)
	_time_label.text = "Ngày %d (%s, ngày %d/%d)  %s" % [
		TimeManager.day,
		TimeManager.get_season_name(),
		TimeManager.get_day_of_season(),
		TimeManager.days_per_season,
		TimeManager.get_time_string(),
	]


func _update_money() -> void:
	_money_label.text = "%d đ" % EconomyManager.money
