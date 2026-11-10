class_name Player
extends CharacterBody2D
## Nhân vật người chơi: di chuyển 8 hướng, có kho đồ, và tương tác với đối tượng gần nhất.
##
## - Không gọi UI: gợi ý tương tác đi qua EventBus.interaction_prompt_changed.
## - Khoá di chuyển khi cửa hàng mở (nghe EventBus.shop_opened/shop_closed).
## - Input dùng InputMap: move_left/right/up/down và interact (khai báo trong project.godot).

## Hướng nhìn = hàng trong sheet ảnh (player_sheet.png, 3 khung x 4 hàng).
enum Facing { DOWN, LEFT, RIGHT, UP }

## Thứ tự khung khi đi bộ: chân trái, đứng, chân phải, đứng.
const WALK_CYCLE: Array[int] = [0, 1, 2, 1]
const IDLE_FRAME: int = 1
const WALK_FRAME_SECONDS: float = 0.14

## Sheet hoạt ảnh dùng công cụ (3 khung x 4 hướng, ô 42x56), theo tên hành động.
const ACTION_SHEETS: Dictionary = {
	&"hoe": "res://assets/art/characters/player_hoe.png",
	&"water": "res://assets/art/characters/player_water.png",
}
const ACTION_FRAMES: int = 3
const ACTION_FRAME_SECONDS: float = 0.12
## Đưa chân trong khung 42x56 về đúng chỗ chân của sheet đi bộ.
const ACTION_SPRITE_OFFSET: Vector2 = Vector2(0, -16)

@export_range(10.0, 600.0, 1.0) var speed: float = 120.0

## Kho đồ của người chơi (node con "Inventory").
@onready var inventory: InventoryComponent = $Inventory
@onready var _interaction_area: Area2D = $InteractionArea
@onready var _sprite: Sprite2D = $Sprite2D

## Bị khoá khi cửa hàng đang mở.
var movement_locked: bool = false
## Hướng đang nhìn (giữ nguyên khi đứng yên).
var facing: Facing = Facing.DOWN

var _walk_time: float = 0.0
var _last_step: int = -1
## Sprite riêng cho hoạt ảnh công cụ (khung to hơn sheet đi bộ); ẩn khi không dùng.
var _action_sprite: Sprite2D
## Thời gian đã chạy của hoạt ảnh công cụ; âm là không có hoạt ảnh nào.
var _action_time: float = -1.0

var _in_transition: bool = false
var _in_minigame: bool = false
var _nearby: Array[InteractableComponent] = []
var _target: InteractableComponent = null


func _ready() -> void:
	add_to_group(&"player")
	_add_shadow()
	_interaction_area.area_entered.connect(_on_area_entered)
	_interaction_area.area_exited.connect(_on_area_exited)
	EventBus.shop_opened.connect(func(_vendor: Resource) -> void: movement_locked = true)
	EventBus.shop_closed.connect(func(_vendor: Resource) -> void: movement_locked = false)
	EventBus.dialogue_opened.connect(func(_speaker: StringName) -> void: movement_locked = true)
	EventBus.dialogue_closed.connect(func(_speaker: StringName) -> void: movement_locked = false)
	# Túi đồ theo cấp nâng cấp (mua thêm hoặc nạp game / ván mới).
	EventBus.upgrade_purchased.connect(func(id: StringName, _level: int) -> void: _apply_bag_upgrade(id))
	EventBus.upgrades_reloaded.connect(func() -> void: _apply_bag_upgrade(UpgradeManager.BAG))
	_apply_bag_upgrade(UpgradeManager.BAG)
	# Đứng yên trong lúc chuyển map.
	EventBus.scene_change_requested.connect(func(_path: String, _spawn: StringName) -> void: _in_transition = true)
	EventBus.scene_changed.connect(func(_path: String) -> void: _in_transition = false)
	# Đứng yên trong lúc chơi mini-game.
	EventBus.minigame_started.connect(func(_id: StringName) -> void: _in_minigame = true)
	EventBus.minigame_finished.connect(func(_id: StringName, _result: Dictionary) -> void: _in_minigame = false)


func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO
	if not movement_locked and not _in_transition and not _in_minigame and not is_acting():
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
	if is_acting():
		_animate_action(delta)
	else:
		_animate(direction, delta)
	_update_target()


## Đang chạy hoạt ảnh dùng công cụ (đứng yên cho tới khi xong).
func is_acting() -> bool:
	return _action_time >= 0.0


## Đặt số ô túi đồ theo cấp nâng cấp túi (bỏ qua nếu [param id] không phải nâng cấp túi hoặc thiếu dữ liệu).
func _apply_bag_upgrade(id: StringName) -> void:
	var slots: int = UpgradeManager.get_value(UpgradeManager.BAG)
	if id == UpgradeManager.BAG and slots > 0:
		inventory.set_slot_count(slots)


## Chạy hoạt ảnh dùng công cụ [param action] ("hoe", "water"), quay mặt về [param target]
## (toạ độ thế giới). Trả về false nếu không có sheet cho hành động đó hoặc đang bận.
func play_action(action: StringName, target: Vector2) -> bool:
	if is_acting() or not ACTION_SHEETS.has(action):
		return false
	var to_target: Vector2 = target - global_position
	if to_target != Vector2.ZERO:
		if absf(to_target.x) > absf(to_target.y):
			facing = Facing.RIGHT if to_target.x > 0.0 else Facing.LEFT
		else:
			facing = Facing.DOWN if to_target.y > 0.0 else Facing.UP
	if _action_sprite == null:
		_action_sprite = Sprite2D.new()
		_action_sprite.hframes = ACTION_FRAMES
		_action_sprite.vframes = 4
		_action_sprite.offset = ACTION_SPRITE_OFFSET
		add_child(_action_sprite)
	_action_sprite.texture = load(ACTION_SHEETS[action])
	_action_sprite.frame_coords = Vector2i(0, facing)
	_action_sprite.show()
	_sprite.hide()
	_action_time = 0.0
	return true


## Toạ độ khung của hoạt ảnh công cụ đang chạy; (-1, -1) nếu không có. Dùng cho kiểm thử.
func get_action_frame_coords() -> Vector2i:
	return _action_sprite.frame_coords if is_acting() else Vector2i(-1, -1)


func _animate_action(delta: float) -> void:
	_action_time += delta
	var frame: int = int(_action_time / ACTION_FRAME_SECONDS)
	if frame >= ACTION_FRAMES:
		_action_time = -1.0
		_action_sprite.hide()
		_sprite.show()
		_sprite.frame_coords = Vector2i(IDLE_FRAME, facing)
		return
	_action_sprite.frame_coords = Vector2i(frame, facing)


func _unhandled_input(event: InputEvent) -> void:
	if movement_locked or _in_transition or _in_minigame or not event.is_action_pressed("interact"):
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
	EventBus.interaction_prompt_changed.emit("" if best == null else best.prompt_text)


## Chọn khung hình: hướng nhìn theo phương di chuyển trội hơn; đi thì lần lượt qua
## [constant WALK_CYCLE], đứng yên thì về [constant IDLE_FRAME].
func _animate(direction: Vector2, delta: float) -> void:
	if direction == Vector2.ZERO:
		_walk_time = 0.0
		_last_step = -1
		_sprite.frame_coords = Vector2i(IDLE_FRAME, facing)
		return
	if absf(direction.x) > absf(direction.y):
		facing = Facing.RIGHT if direction.x > 0.0 else Facing.LEFT
	else:
		facing = Facing.DOWN if direction.y > 0.0 else Facing.UP
	_walk_time += delta
	var step: int = int(_walk_time / WALK_FRAME_SECONDS) % WALK_CYCLE.size()
	_sprite.frame_coords = Vector2i(WALK_CYCLE[step], facing)
	# Chân chạm đất ở hai khung bước (0 và 2 của chu kỳ): phát tiếng một lần mỗi khi chuyển sang khung đó.
	if step != _last_step and WALK_CYCLE[step] != 1:
		EventBus.player_stepped.emit()
	_last_step = step


## Toạ độ khung hình đang hiển thị (cột, hàng); dùng cho kiểm thử.
func get_frame_coords() -> Vector2i:
	return _sprite.frame_coords


## Bóng đổ bầu dục dưới chân (chân ở y = +14), đặt dưới sprite.
func _add_shadow() -> void:
	var shadow: Sprite2D = Shadow.create(22.0)
	shadow.position = Vector2(0, 13)
	add_child(shadow)
	move_child(shadow, 0)
