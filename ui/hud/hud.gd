class_name Hud
extends CanvasLayer
## HUD cơ bản: ngày/mùa/giờ (trái trên), tiền (phải trên), gợi ý tương tác (giữa dưới).
##
## Chỉ nghe EventBus; không biết Player hay các hệ thống khác.

var _time_label: Label
var _money_label: Label
var _prompt_label: Label


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

	_time_label = _make_label(root, 20)
	_money_label = _make_label(root, 20)
	_money_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_money_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_prompt_label = _make_label(root, 22)
	_prompt_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_prompt_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_prompt_label.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_prompt_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))

	EventBus.time_ticked.connect(func(_h: int, _m: int) -> void: _update_time())
	EventBus.day_changed.connect(func(_d: int) -> void: _update_time())
	EventBus.money_changed.connect(func(_amount: int, _delta: int) -> void: _update_money())
	EventBus.interaction_prompt_changed.connect(func(text: String) -> void: _prompt_label.text = text)
	# Ẩn gợi ý khi đang mua bán để không chồng lên cửa hàng.
	EventBus.shop_opened.connect(func(_vendor: Resource) -> void: _prompt_label.hide())
	EventBus.shop_closed.connect(func(_vendor: Resource) -> void: _prompt_label.show())
	_update_time()
	_update_money()


func _make_label(parent: Node, font_size: int) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 5)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label


func _update_time() -> void:
	_time_label.text = "Ngày %d (%s, ngày %d/%d)  %s" % [
		TimeManager.day,
		TimeManager.get_season_name(),
		TimeManager.get_day_of_season(),
		TimeManager.days_per_season,
		TimeManager.get_time_string(),
	]


func _update_money() -> void:
	_money_label.text = "Tiền: %d đ" % EconomyManager.money
