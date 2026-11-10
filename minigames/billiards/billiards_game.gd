class_name BilliardsGame
extends MinigameBase
## Quán Bida: canh lực. Thanh lực chạy qua lại; bấm "Đánh!" (hoặc Space) để dừng.
## Dừng trong vùng xanh thì bi vào lỗ. Mỗi vòng [member shots_per_round] cú,
## mỗi bi vào lỗ được [member pay_per_ball] đồng.

@export_range(1, 15, 1) var shots_per_round: int = 5
## Tâm và nửa bề rộng của vùng xanh trên thanh lực (0..1).
@export_range(0.0, 1.0, 0.01) var sweet_center: float = 0.75
@export_range(0.01, 0.5, 0.01) var sweet_half_width: float = 0.12
@export_range(0, 100, 1) var pay_per_ball: int = 9
## Số lần thanh lực chạy đi-về mỗi giây.
@export_range(0.2, 5.0, 0.1) var meter_speed: float = 0.8

const BALLS_TEXTURE: Texture2D = preload("res://assets/art/minigames/billiard_balls.png")
## Mỗi ô bi trong sheet rộng 23 px; vẽ gấp đôi trên bàn.
const BALL_CELL: int = 23
const BALL_DRAW_SIZE: float = 46.0

var shots_taken: int = 0
var pocketed: int = 0
var is_playing: bool = false

var _power: float = 0.0
var _phase: float = 0.0
var _table: Control
var _meter: Control
var _status_label: Label
var _feedback_label: Label
var _start_button: Button
var _shoot_button: Button


func _init() -> void:
	minigame_id = &"billiards"
	title = "Quán Bida: Canh lực"
	entry_fee = 15
	minutes_cost = 45


func _setup() -> void:
	_status_label = Label.new()
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.add_theme_font_size_override("font_size", 18)
	content.add_child(_status_label)

	_table = Control.new()
	_table.custom_minimum_size = Vector2(820, 280)
	_table.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_table.draw.connect(_draw_table)
	content.add_child(_table)

	_meter = Control.new()
	_meter.custom_minimum_size = Vector2(820, 34)
	_meter.draw.connect(_draw_meter)
	content.add_child(_meter)

	_feedback_label = Label.new()
	_feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_feedback_label.add_theme_color_override("font_color", UiTheme.ACCENT_RED)
	content.add_child(_feedback_label)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	content.add_child(row)
	_start_button = Button.new()
	_start_button.text = "Bắt đầu"
	_start_button.pressed.connect(start_round)
	row.add_child(_start_button)
	_shoot_button = Button.new()
	_shoot_button.text = "Đánh!"
	_shoot_button.disabled = true
	_shoot_button.pressed.connect(shoot)
	row.add_child(_shoot_button)
	_update_status()


func _process(delta: float) -> void:
	if not is_playing:
		return
	_phase += delta * meter_speed
	# Sóng tam giác 0 -> 1 -> 0 (đều tay, dễ canh hơn sóng sin).
	_power = 1.0 - absf(fposmod(_phase, 1.0) * 2.0 - 1.0)
	_meter.queue_redraw()


func _unhandled_key_input(event: InputEvent) -> void:
	if is_playing and event.is_pressed() and not event.is_echo() and (event as InputEventKey).keycode == KEY_SPACE:
		shoot()
		get_viewport().set_input_as_handled()


## Bắt đầu vòng chơi mới.
func start_round() -> void:
	if is_playing:
		return
	shots_taken = 0
	pocketed = 0
	_phase = 0.0
	is_playing = true
	mark_played()
	_start_button.disabled = true
	_shoot_button.disabled = false
	_feedback_label.text = ""
	_update_status()
	_table.queue_redraw()


## Đánh một cú với lực hiện tại. Trả về true nếu bi vào lỗ.
func shoot() -> bool:
	if not is_playing:
		return false
	shots_taken += 1
	var is_pocketed: bool = is_in_sweet_zone(_power)
	EventBus.sfx_requested.emit(&"pocket" if is_pocketed else &"cue")
	if is_pocketed:
		pocketed += 1
	_feedback_label.text = "Vào lỗ!" if is_pocketed else "Trượt rồi (lực %d%%)." % int(_power * 100.0)
	_update_status()
	_table.queue_redraw()
	if shots_taken >= shots_per_round:
		end_round()
	return is_pocketed


## Lực [param power] (0..1) có nằm trong vùng xanh không.
func is_in_sweet_zone(power: float) -> bool:
	return absf(power - sweet_center) <= sweet_half_width


func end_round() -> void:
	if not is_playing:
		return
	is_playing = false
	_shoot_button.disabled = true
	_update_status()
	finish(get_payout(), {"pocketed": pocketed, "shots": shots_taken})


func get_payout() -> int:
	return pocketed * pay_per_ball


func quit() -> void:
	is_playing = false
	super.quit()


func _update_status() -> void:
	if _status_label == null:
		return
	if is_playing:
		_status_label.text = "Cú %d/%d   |   Vào lỗ: %d   |   Thưởng hiện tại: %d đ" % [
			shots_taken + 1, shots_per_round, pocketed, get_payout(),
		]
	elif played:
		_status_label.text = "Xong! %d/%d bi vào lỗ, thưởng %d đ." % [pocketed, shots_per_round, get_payout()]
	else:
		_status_label.text = "Bấm \"Bắt đầu\", rồi bấm \"Đánh!\" (hoặc Space) khi thanh lực nằm trong vùng xanh."


func _draw_table() -> void:
	var rect: Rect2 = Rect2(Vector2.ZERO, _table.size)
	_table.draw_rect(rect, Color(0.36, 0.22, 0.12))  # viền gỗ
	var felt: Rect2 = rect.grow(-18)
	_table.draw_rect(felt, Color(0.1, 0.45, 0.25))  # nỉ
	var pocket_color := Color(0.04, 0.04, 0.04)
	for x: float in [felt.position.x, felt.get_center().x, felt.end.x]:
		for y: float in [felt.position.y, felt.end.y]:
			_table.draw_circle(Vector2(x, y), 17.0, pocket_color)
	# Các bi còn lại xếp thành cụm giữa bàn; bi vào lỗ thì biến mất. Bi lấy từ sheet ảnh:
	# ô 0 là bi cái, ô 1..5 là bi màu (đỏ, vàng, xanh, cam, tím).
	var remaining: int = shots_per_round - pocketed
	for i: int in remaining:
		var pos := Vector2(felt.get_center().x + 120.0 + (i % 3) * BALL_DRAW_SIZE, felt.get_center().y + (i / 3) * BALL_DRAW_SIZE - BALL_DRAW_SIZE / 2.0)
		_draw_ball(1 + i % 5, pos)
	_draw_ball(0, Vector2(felt.position.x + 200.0, felt.get_center().y))


## Vẽ viên bi số [param index] trong sheet, tâm tại [param center].
func _draw_ball(index: int, center: Vector2) -> void:
	var half: float = BALL_DRAW_SIZE / 2.0
	_table.draw_texture_rect_region(
		BALLS_TEXTURE,
		Rect2(center - Vector2(half, half), Vector2(BALL_DRAW_SIZE, BALL_DRAW_SIZE)),
		Rect2(index * BALL_CELL, 0, BALL_CELL, BALL_CELL)
	)


func _draw_meter() -> void:
	var size: Vector2 = _meter.size
	_meter.draw_rect(Rect2(Vector2.ZERO, size), Color(0.18, 0.18, 0.22))
	var zone_left: float = (sweet_center - sweet_half_width) * size.x
	var zone_width: float = sweet_half_width * 2.0 * size.x
	_meter.draw_rect(Rect2(zone_left, 0, zone_width, size.y), Color(0.2, 0.7, 0.3))
	var pointer_x: float = _power * size.x
	_meter.draw_rect(Rect2(pointer_x - 3.0, 0, 6.0, size.y), Color.WHITE)
