class_name Player
extends CharacterBody2D
## Nhân vật người chơi: di chuyển 8 hướng, có kho đồ, và tương tác với đối tượng gần nhất.
##
## - Không gọi UI: gợi ý tương tác đi qua EventBus.interaction_prompt_changed.
## - Khoá di chuyển khi cửa hàng mở (nghe EventBus.shop_opened/shop_closed).
## - Input dùng InputMap: move_left/right/up/down và interact (khai báo trong project.godot).

@export_range(10.0, 600.0, 1.0) var speed: float = 120.0

## Kho đồ của người chơi (node con "Inventory").
@onready var inventory: InventoryComponent = $Inventory
@onready var _interaction_area: Area2D = $InteractionArea

## Bị khoá khi cửa hàng đang mở.
var movement_locked: bool = false

var _in_transition: bool = false
var _nearby: Array[InteractableComponent] = []
var _target: InteractableComponent = null


func _ready() -> void:
	add_to_group(&"player")
	_interaction_area.area_entered.connect(_on_area_entered)
	_interaction_area.area_exited.connect(_on_area_exited)
	EventBus.shop_opened.connect(func(_vendor: Resource) -> void: movement_locked = true)
	EventBus.shop_closed.connect(func(_vendor: Resource) -> void: movement_locked = false)
	# Đứng yên trong lúc chuyển map.
	EventBus.scene_change_requested.connect(func(_path: String, _spawn: StringName) -> void: _in_transition = true)
	EventBus.scene_changed.connect(func(_path: String) -> void: _in_transition = false)


func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO
	if not movement_locked and not _in_transition:
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
	_update_target()


func _unhandled_input(event: InputEvent) -> void:
	if movement_locked or _in_transition or not event.is_action_pressed("interact"):
		return
	if _target != null and _target.can_interact():
		EventBus.interaction_started.emit(_target)
		_target.interact(self)
		get_viewport().set_input_as_handled()


## Đối tượng tương tác đang được nhắm (gần nhất), hoặc null.
func get_target() -> InteractableComponent:
	return _target


func _on_area_entered(area: Area2D) -> void:
	if area is InteractableComponent and not _nearby.has(area):
		_nearby.append(area)


func _on_area_exited(area: Area2D) -> void:
	if area is InteractableComponent:
		_nearby.erase(area)


## Chọn đối tượng gần nhất còn tương tác được; phát gợi ý khi lựa chọn đổi.
func _update_target() -> void:
	var best: InteractableComponent = null
	var best_distance: float = INF
	for candidate: InteractableComponent in _nearby:
		if not is_instance_valid(candidate) or not candidate.can_interact():
			continue
		var distance: float = global_position.distance_squared_to(candidate.global_position)
		if distance < best_distance:
			best_distance = distance
			best = candidate
	if best == _target:
		return
	_target = best
	EventBus.interaction_prompt_changed.emit("" if best == null else "[E] " + best.prompt_text)

# Vẽ tạm khi chưa có sprite.


func _draw() -> void:
	draw_circle(Vector2(0, 0), 12.0, Color(0.25, 0.5, 0.9))
	draw_circle(Vector2(0, -4), 5.0, Color(0.95, 0.8, 0.65))
