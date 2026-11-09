class_name AimGame
extends MinigameBase
## Quán Net: bắn mục tiêu. Trong [member round_seconds] giây, các mục tiêu hiện ra ở
## chỗ ngẫu nhiên và biến mất sau [member target_lifetime] giây; bấm trúng để lấy điểm.
## Tiền thưởng = số lần trúng x [member pay_per_hit], tối đa [member max_payout].

@export_range(5.0, 120.0, 1.0) var round_seconds: float = 20.0
@export_range(0.2, 5.0, 0.1) var spawn_interval: float = 0.7
@export_range(0.3, 5.0, 0.1) var target_lifetime: float = 1.2
@export_range(0, 100, 1) var pay_per_hit: int = 2
@export_range(0, 1000, 1) var max_payout: int = 30

const TARGET_SIZE: Vector2 = Vector2(64, 64)
const TARGET_TEXTURE: Texture2D = preload("res://assets/art/minigames/aim_target.png")

var hits: int = 0
var misses: int = 0
var is_playing: bool = false
## Bộ sinh số ngẫu nhiên riêng, để kiểm thử đặt seed cố định.
var rng := RandomNumberGenerator.new()

var _field: Control
var _status_label: Label
var _start_button: Button
var _round_timer: Timer
var _spawn_timer: Timer


func _init() -> void:
	minigame_id = &"net_cafe_aim"
	title = "Quán Net: Bắn mục tiêu"
	entry_fee = 5
	minutes_cost = 60


func _setup() -> void:
	rng.randomize()
	_status_label = Label.new()
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.add_theme_font_size_override("font_size", 18)
	content.add_child(_status_label)

	_field = Control.new()
	_field.custom_minimum_size = Vector2(820, 340)
	_field.clip_contents = true
	_field.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var field_bg := ColorRect.new()
	field_bg.color = Color(0.05, 0.06, 0.1)
	field_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	field_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_field.add_child(field_bg)
	content.add_child(_field)

	_start_button = Button.new()
	_start_button.text = "Bắt đầu"
	_start_button.pressed.connect(start_round)
	content.add_child(_start_button)

	_round_timer = Timer.new()
	_round_timer.one_shot = true
	_round_timer.timeout.connect(end_round)
	add_child(_round_timer)
	_spawn_timer = Timer.new()
	_spawn_timer.timeout.connect(spawn_target)
	add_child(_spawn_timer)
	_update_status()


## Bắt đầu vòng chơi.
func start_round() -> void:
	if is_playing:
		return
	hits = 0
	misses = 0
	is_playing = true
	mark_played()
	_start_button.disabled = true
	_round_timer.start(round_seconds)
	_spawn_timer.start(spawn_interval)
	spawn_target()
	_update_status()


## Tạo một mục tiêu ở vị trí ngẫu nhiên trong khung chơi. Trả về nút mục tiêu.
func spawn_target() -> Button:
	if not is_playing:
		return null
	var target := Button.new()
	target.icon = TARGET_TEXTURE
	target.flat = true
	target.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for state: String in ["normal", "hover", "pressed", "focus", "disabled"]:
		target.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	target.custom_minimum_size = TARGET_SIZE
	target.size = TARGET_SIZE
	var max_x: float = maxf(0.0, _field.size.x - TARGET_SIZE.x)
	var max_y: float = maxf(0.0, _field.size.y - TARGET_SIZE.y)
	target.position = Vector2(rng.randf_range(0.0, max_x), rng.randf_range(0.0, max_y))
	target.pressed.connect(_on_target_pressed.bind(target))
	var life := Timer.new()
	life.one_shot = true
	life.autostart = true
	life.wait_time = target_lifetime
	life.timeout.connect(_on_target_expired.bind(target))
	target.add_child(life)
	_field.add_child(target)
	return target


## Số mục tiêu đang hiện trên màn hình.
func get_active_targets() -> Array[Button]:
	var targets: Array[Button] = []
	for child: Node in _field.get_children():
		if child is Button:
			targets.append(child)
	return targets


## Kết thúc vòng chơi và trả kết quả.
func end_round() -> void:
	if not is_playing:
		return
	is_playing = false
	_round_timer.stop()
	_spawn_timer.stop()
	_clear_targets()
	_update_status()
	finish(get_payout(), {"hits": hits, "misses": misses})


func get_payout() -> int:
	return mini(hits * pay_per_hit, max_payout)


func quit() -> void:
	if is_playing:
		is_playing = false
		_round_timer.stop()
		_spawn_timer.stop()
	super.quit()


func _on_target_pressed(target: Button) -> void:
	if not is_playing:
		return
	hits += 1
	target.queue_free()
	_update_status()


func _on_target_expired(target: Button) -> void:
	if is_instance_valid(target) and not target.is_queued_for_deletion():
		misses += 1
		target.queue_free()
		_update_status()


func _clear_targets() -> void:
	for target: Button in get_active_targets():
		target.queue_free()


func _update_status() -> void:
	if _status_label == null:
		return
	if is_playing:
		_status_label.text = "Trúng: %d   |   Trượt: %d   |   Thưởng hiện tại: %d đ" % [hits, misses, get_payout()]
	elif played:
		_status_label.text = "Hết giờ! Trúng %d mục tiêu, thưởng %d đ." % [hits, get_payout()]
	else:
		_status_label.text = "Bấm \"Bắt đầu\", rồi bắn trúng càng nhiều mục tiêu càng tốt trong %d giây." % int(round_seconds)
