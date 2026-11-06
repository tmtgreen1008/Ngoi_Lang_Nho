class_name Hud
extends CanvasLayer
## HUD: ngày/mùa/giờ kèm icon mùa (trái trên), tiền kèm icon đồng xu (phải trên),
## gợi ý tương tác kèm phím E (giữa dưới), thông báo nhanh (giữa trên).
##
## Chỉ nghe EventBus; không biết Player hay các hệ thống khác. Chữ trắng viền đen vì nằm
## trên nền game (không dùng UiTheme giấy).

const TOAST_SECONDS: float = 4.0

var _time_label: Label
var _money_label: Label
var _prompt_label: Label
var _toast_label: Label
var _season_icon: TextureRect
var _prompt_box: HBoxContainer
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
	var left := HBoxContainer.new()
	left.add_theme_constant_override("separation", 8)
	root.add_child(left)
	_season_icon = _make_icon(left, UiTheme.HudIcon.SPRING)
	_time_label = _make_label(left, 20)

	# Phải trên: tiền + đồng xu.
	var right := HBoxContainer.new()
	right.add_theme_constant_override("separation", 8)
	root.add_child(right)
	right.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	right.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_money_label = _make_label(right, 20)
	_make_icon(right, UiTheme.HudIcon.COIN)

	# Giữa dưới: phím E + lời nhắc.
	_prompt_box = HBoxContainer.new()
	_prompt_box.add_theme_constant_override("separation", 8)
	root.add_child(_prompt_box)
	_prompt_box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_prompt_box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_prompt_box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_make_icon(_prompt_box, UiTheme.HudIcon.KEY_E)
	_prompt_label = _make_label(_prompt_box, 22)
	_prompt_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	_prompt_box.hide()

	_toast_label = _make_label(root, 20)
	_toast_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_toast_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_toast_label.position.y = 90.0
	_toast_label.add_theme_color_override("font_color", Color(0.6, 1.0, 0.7))
	_toast_label.hide()
	_toast_timer = Timer.new()
	_toast_timer.one_shot = true
	_toast_timer.timeout.connect(_toast_label.hide)
	add_child(_toast_timer)
	EventBus.toast_requested.connect(show_toast)

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
func show_toast(text: String) -> void:
	_toast_label.text = text
	_toast_label.show()
	_toast_timer.start(TOAST_SECONDS)


func _on_prompt_changed(text: String) -> void:
	_prompt_label.text = text
	_refresh_prompt_visibility()


func _set_shop_open(is_open: bool) -> void:
	_shop_open = is_open
	_refresh_prompt_visibility()


func _refresh_prompt_visibility() -> void:
	_prompt_box.visible = not _prompt_label.text.is_empty() and not _shop_open


func _make_label(parent: Node, font_size: int) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 5)
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
