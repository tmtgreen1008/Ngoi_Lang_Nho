class_name PetDog
extends Node2D
## Chó nhà (Vàng): đi loanh quanh sân trong [member wander_rect], bấm E để vuốt ve. Lần vuốt ve đầu tiên mỗi ngày
## chó tha về một hạt giống gieo được trong mùa hiện tại (chọn theo ngày, nên cùng ngày thì cùng món); các lần
## sau chỉ vẫy đuôi. Túi đầy thì món quà chờ tới khi có chỗ.
##
## Thuộc nhóm world_persistent (nhớ ngày nhận quà gần nhất khi đổi map và trong bản lưu). Ảnh: anim_dog.png
## (lưới 4x3 ô 32x32; hàng 0 nhìn ngang: 3 khung bước, 1 khung cúi ngửi).

const SHEET_PATH: String = "res://assets/art/characters/anim_dog.png"
const CELL := Vector2i(32, 32)
const WALK_FRAMES: Array[int] = [0, 1, 0, 2]
const SNIFF_FRAME: int = 3
const FRAME_SECONDS: float = 0.16

@export var pet_name: String = "Vàng"
@export var wander_rect: Rect2 = Rect2()
@export var speed: float = 34.0
@export var persistent_key: StringName = &"pet_dog"

var interactable: InteractableComponent
var sprite: Sprite2D
## Ngày gần nhất chó đã tha quà về (0 = chưa lần nào).
var last_gift_day: int = 0

var _target: Vector2 = Vector2.ZERO
var _wait: float = 1.0
var _time: float = 0.0
var _sniffing: bool = false


func _ready() -> void:
	add_to_group(WorldStateManager.PERSISTENT_GROUP)
	var shadow: Sprite2D = Shadow.create(20.0)
	shadow.position = Vector2(0, -1)
	add_child(shadow)
	sprite = Sprite2D.new()
	sprite.texture = load(SHEET_PATH)
	sprite.hframes = 4
	sprite.vframes = 3
	sprite.centered = false
	sprite.offset = Vector2(-CELL.x / 2.0, -CELL.y + 3)  # gốc toạ độ ở chân chó
	add_child(sprite)
	interactable = InteractableComponent.new()
	interactable.name = "Interactable"
	interactable.interact_radius = 36.0
	interactable.position = Vector2(0, -10)
	interactable.prompt_text = "Vuốt ve %s" % pet_name
	add_child(interactable)
	interactable.interacted.connect(_on_interacted)
	_target = position


func _process(delta: float) -> void:
	_time += delta
	if wander_rect.size == Vector2.ZERO:
		sprite.frame_coords = Vector2i(0, 0)
		return
	if _wait > 0.0:
		_wait -= delta
		sprite.frame_coords = Vector2i(SNIFF_FRAME if _sniffing else 0, 0)
		return
	var to_target: Vector2 = _target - position
	if to_target.length() < 2.0:
		_wait = randf_range(1.0, 3.5)
		_sniffing = randf() < 0.4
		_target = Vector2(
			randf_range(wander_rect.position.x, wander_rect.end.x),
			randf_range(wander_rect.position.y, wander_rect.end.y))
		return
	position += to_target.normalized() * minf(speed * delta, to_target.length())
	if absf(to_target.x) > 1.0:
		sprite.flip_h = to_target.x < 0.0
	sprite.frame_coords = Vector2i(WALK_FRAMES[int(_time / FRAME_SECONDS) % WALK_FRAMES.size()], 0)


## Hôm nay chó đã tha quà về chưa.
func has_fetched_today() -> bool:
	return last_gift_day == TimeManager.day


## Món quà của ngày [param day] trong mùa [param season]: một hạt giống gieo được mùa đó (xác định theo ngày).
static func gift_for_day(day: int, season: int) -> ItemData:
	var ids: Array = ItemDatabase.get_all_ids()
	ids.sort()
	var seeds: Array[ItemData] = []
	for id: StringName in ids:
		var item: ItemData = ItemDatabase.get_item(id)
		if item is CropItemData and (item as CropItemData).can_plant_in(season):
			seeds.append(item)
	if seeds.is_empty():
		return null
	return seeds[posmod(day * 7 + season * 3, seeds.size())]


## Vuốt ve: lần đầu trong ngày nhận quà vào [param inventory] (nếu có chỗ). Trả về true nếu có quà.
func pet(inventory: InventoryComponent) -> bool:
	EventBus.sfx_requested.emit(&"pickup")
	if has_fetched_today() or inventory == null:
		EventBus.notice_requested.emit("%s vẫy đuôi mừng rỡ." % pet_name, &"info")
		return false
	var gift: ItemData = gift_for_day(TimeManager.day, TimeManager.season)
	if gift == null:
		EventBus.notice_requested.emit("%s vẫy đuôi mừng rỡ." % pet_name, &"info")
		return false
	if not inventory.can_add(gift, 1):
		EventBus.notice_requested.emit("%s tha về một món quà nhưng túi đồ của bạn đã đầy." % pet_name, &"error")
		return false
	last_gift_day = TimeManager.day
	inventory.add_item(gift, 1)
	EventBus.item_picked.emit(gift, 1)
	EventBus.notice_requested.emit("%s tha về cho bạn 1 %s." % [pet_name, gift.display_name.to_lower()], &"success")
	return true


func _on_interacted(interactor: Node) -> void:
	pet(interactor.get("inventory") as InventoryComponent)


func get_world_state() -> Dictionary:
	return {"last_gift_day": last_gift_day}


func apply_world_state(state: Dictionary) -> void:
	last_gift_day = int(state.get("last_gift_day", 0))
