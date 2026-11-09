class_name VillagerNPC
extends Node2D
## Dân làng: NPC chỉ để trò chuyện (không bán hàng). Ghép hình (một khung trong characters/villagers.png),
## InteractableComponent (bấm E) và lời thoại [DialogueData]. Bấm E phát EventBus.npc_talk_requested; hộp thoại,
## độ thân thiết và quà tặng do DialogueBox / RelationshipManager lo (giống VendorNPC, chỉ thiếu cửa hàng).
##
## Đặt [member wander_rect] khác rỗng thì NPC đi dạo trong khung đó (vd. trẻ con chạy quanh sân); đứng
## yên khi đang nói chuyện với người chơi. Gốc toạ độ ở giữa thân, chân cách gốc 14 px (như Player).

const SHEET_PATH: String = "res://assets/art/characters/villagers.png"
const FRAME_SIZE := Vector2i(32, 48)
## Số khung trong sheet (xếp ngang).
const FRAME_COUNT: int = 6
const FOOT_OFFSET: float = 14.0

@export var dialogue: DialogueData
## Khung nhân vật trong sheet: 0 nón lá, 1 ông cụ, 2 cô gái tóc bím, 3 chú thợ, 4 bà cụ, 5 cậu bé.
@export_range(0, 5, 1) var frame: int = 0
## Khung đi dạo (toạ độ thế giới); rỗng (kích thước 0) = đứng yên.
@export var wander_rect: Rect2 = Rect2()
@export var wander_speed: float = 22.0

## Villager không có cửa hàng; DialogueBox đọc thuộc tính này để biết có hiện nút "Mua bán" không.
var vendor: Node = null
var interactable: InteractableComponent
var sprite: Sprite2D

var _time: float = 0.0
var _target: Vector2 = Vector2.ZERO
var _wait: float = 0.0
var _talking: bool = false


func _ready() -> void:
	var shadow: Sprite2D = Shadow.create(24.0)
	shadow.position = Vector2(0, FOOT_OFFSET - 1.0)
	add_child(shadow)
	sprite = Sprite2D.new()
	sprite.texture = load(SHEET_PATH)
	sprite.region_enabled = true
	sprite.region_rect = Rect2(frame * FRAME_SIZE.x, 0, FRAME_SIZE.x, FRAME_SIZE.y)
	sprite.offset = Vector2(0, -10)
	add_child(sprite)

	var label := Label.new()
	label.name = "NameLabel"
	label.text = dialogue.display_name if dialogue != null else ""
	label.position = Vector2(-80, -66)
	label.size = Vector2(160, 23)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.z_index = 10
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	add_child(label)

	interactable = InteractableComponent.new()
	interactable.name = "Interactable"
	interactable.interact_radius = 44.0
	interactable.prompt_text = "Nói chuyện với %s" % (dialogue.display_name if dialogue != null else "dân làng")
	add_child(interactable)
	interactable.interacted.connect(_on_interacted)

	if wander_rect.size == Vector2.ZERO:
		_add_blocker()  # đứng yên thì chặn đường như đồ vật; đi dạo thì không (khỏi kẹt Player)
	else:
		_target = position
		_wait = randf_range(0.5, 2.0)
	EventBus.dialogue_opened.connect(func(speaker: StringName) -> void: _talking = dialogue != null and speaker == dialogue.speaker_id)
	EventBus.dialogue_closed.connect(func(_speaker: StringName) -> void: _talking = false)


func _process(delta: float) -> void:
	_time += delta
	var moving: bool = false
	if wander_rect.size != Vector2.ZERO and not _talking:
		moving = _wander(delta)
	# Nhún nhẹ khi đứng, nhún nhanh hơn khi đi.
	var rate: float = 7.0 if moving else 1.6
	sprite.offset.y = -10.0 + (1.0 if int(_time * rate) % 2 == 0 else 0.0)


## Đi tới điểm ngẫu nhiên trong khung, nghỉ vài giây rồi chọn điểm khác. Trả về true nếu đang đi.
func _wander(delta: float) -> bool:
	if _wait > 0.0:
		_wait -= delta
		return false
	var to_target: Vector2 = _target - position
	if to_target.length() < 2.0:
		_wait = randf_range(1.5, 4.0)
		_target = Vector2(
			randf_range(wander_rect.position.x, wander_rect.end.x),
			randf_range(wander_rect.position.y, wander_rect.end.y))
		return false
	position += to_target.normalized() * minf(wander_speed * delta, to_target.length())
	if absf(to_target.x) > 1.0:
		sprite.flip_h = to_target.x < 0.0
	return true


func _on_interacted(interactor: Node) -> void:
	if dialogue != null:
		EventBus.npc_talk_requested.emit(self, interactor)


## Dải chặn nhỏ ngay chân NPC đứng yên.
func _add_blocker() -> void:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(18, 10)
	shape.shape = box
	body.position = Vector2(0, FOOT_OFFSET - 5.0)
	body.add_child(shape)
	add_child(body)
