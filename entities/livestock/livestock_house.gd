class_name LivestockHouse
extends Node2D
## Chuồng nuôi trên bản đồ (chuồng gà, chuồng lợn): ghép [LivestockPen] (logic), [LivestockController]
## (nối kho đồ), [InteractableComponent] (bấm E) và hình vẽ (công trình, các con vật, dấu hiệu có sản phẩm).
##
## Gốc toạ độ là CHÂN công trình (giữa đáy ảnh), giống [ArcadeStation]. Con vật đứng ở bãi trước chuồng.

const STRUCTURES_SHEET: String = "res://assets/art/props/farm_structures.png"
const ANIMALS_SHEET: String = "res://assets/art/animals/farm_a.png"
const STRUCTURE_CELL := Vector2i(58, 53)
const ANIMAL_CELL := Vector2i(34, 30)
## Sheet hoạt ảnh theo loài (lưới 4x3; hàng đầu nhìn ngang: 3 khung bước và 1 khung mổ/ăn):
## [đường dẫn, cỡ ô, khoảng trống dưới chân trong ô]. Loài không có ở đây vẽ ảnh tĩnh từ ANIMALS_SHEET.
const ANIM_SHEETS: Dictionary = {
	&"ga": ["res://assets/art/characters/anim_chicken.png", Vector2i(32, 32), 4],
	&"lon": ["res://assets/art/characters/anim_pig.png", Vector2i(48, 40), 6],
}
## Chu kỳ khung của con vật: đứng, cúi mổ/ăn, bước vài bước tại chỗ.
const ANIM_CYCLE: Array[int] = [1, 1, 1, 1, 3, 3, 3, 1, 0, 1, 2, 1]
const ANIM_FRAME_SECONDS: float = 0.3
## Công trình phóng 2 lần cho cân với ngôi nhà (cũng phóng 2 lần).
const STRUCTURE_SCALE: int = 2
## Khung của công trình trong sheet.
enum Structure { COOP, BARN }

@export var species: AnimalData
@export var structure: Structure = Structure.COOP
@export var capacity: int = 4
@export var persistent_key: StringName = &"livestock_pen"

var pen: LivestockPen
var controller: LivestockController
var interactable: InteractableComponent

var _animal_layer: Node2D
var _marker: Sprite2D
var _inventory: InventoryComponent
var _anim_time: float = 0.0


func _ready() -> void:
	var width: float = STRUCTURE_CELL.x * STRUCTURE_SCALE
	var height: float = STRUCTURE_CELL.y * STRUCTURE_SCALE
	var shadow: Sprite2D = Shadow.create(width * 0.9)
	shadow.position = Vector2(0, -2)
	add_child(shadow)

	var sprite := Sprite2D.new()
	sprite.texture = load(STRUCTURES_SHEET)
	sprite.region_enabled = true
	sprite.region_rect = Rect2(structure * STRUCTURE_CELL.x, 0, STRUCTURE_CELL.x, STRUCTURE_CELL.y)
	sprite.centered = false
	sprite.offset = Vector2(-STRUCTURE_CELL.x / 2.0, -STRUCTURE_CELL.y)
	sprite.scale = Vector2(STRUCTURE_SCALE, STRUCTURE_SCALE)
	add_child(sprite)
	_add_blocker(width * 0.9)

	pen = LivestockPen.new()
	pen.species = species
	pen.capacity = capacity
	pen.persistent_key = persistent_key
	add_child(pen)
	controller = LivestockController.new()
	controller.pen = pen
	add_child(controller)

	# Con vật đứng trước chuồng (sau sprite chuồng trong cây node nên được vẽ đè lên).
	_animal_layer = Node2D.new()
	_animal_layer.name = "Animals"
	add_child(_animal_layer)

	# Dấu hiệu có sản phẩm chờ thu: icon sản phẩm lơ lửng phía trên chuồng.
	_marker = Sprite2D.new()
	_marker.name = "ProductMarker"
	var product: ItemData = ItemDatabase.get_item(species.product_item_id)
	if product != null:
		_marker.texture = product.icon
	_marker.position = Vector2(0, -height - 14.0)
	_marker.hide()
	add_child(_marker)

	interactable = InteractableComponent.new()
	interactable.name = "Interactable"
	interactable.interact_radius = 64.0
	interactable.position = Vector2(0, 14.0)
	add_child(interactable)
	interactable.interacted.connect(_on_interacted)

	controller.feedback.connect(func(text: String, kind: StringName) -> void: EventBus.notice_requested.emit(text, kind))
	pen.changed.connect(_refresh)
	EventBus.inventory_changed.connect(func(_owner: StringName) -> void: _refresh())
	_refresh()


## Kho đồ của Player (tìm lười, vì Player có thể được dựng sau map).
func _get_inventory() -> InventoryComponent:
	if _inventory == null or not is_instance_valid(_inventory):
		var player: Node = get_tree().get_first_node_in_group("player")
		if player != null:
			_inventory = player.get("inventory") as InventoryComponent
	return _inventory


func _on_interacted(_interactor: Node) -> void:
	controller.interact(_get_inventory())
	_refresh()


func _process(delta: float) -> void:
	_anim_time += delta
	_animate_animals()


## Khung hoạt ảnh của con thứ [param index] tại thời điểm hiện tại (mỗi con lệch pha nhau).
func get_animal_frame(index: int) -> int:
	var step: int = int(_anim_time / ANIM_FRAME_SECONDS) + index * 5
	return ANIM_CYCLE[step % ANIM_CYCLE.size()]


## Đặt khung cho các con vật có sheet hoạt ảnh (hàng 0: nhìn ngang).
func _animate_animals() -> void:
	if not ANIM_SHEETS.has(species.id):
		return
	for index: int in _animal_layer.get_child_count():
		(_animal_layer.get_child(index) as Sprite2D).frame_coords = Vector2i(get_animal_frame(index), 0)


## Vẽ lại các con vật, dấu sản phẩm và lời nhắc.
func _refresh() -> void:
	for child: Node in _animal_layer.get_children():
		child.free()
	var anim: Array = ANIM_SHEETS.get(species.id, [])
	for index: int in pen.get_count():
		var animal := Sprite2D.new()
		animal.centered = false
		if anim.is_empty():
			animal.texture = load(ANIMALS_SHEET)
			animal.region_enabled = true
			animal.region_rect = Rect2(species.sprite_frame * ANIMAL_CELL.x, 0, ANIMAL_CELL.x, ANIMAL_CELL.y)
			animal.offset = Vector2(-ANIMAL_CELL.x / 2.0, -ANIMAL_CELL.y)
		else:
			var cell: Vector2i = anim[1]
			animal.texture = load(anim[0])
			animal.hframes = 4
			animal.vframes = 3
			animal.offset = Vector2(-cell.x / 2.0, -cell.y + int(anim[2]))
			# Con ở vị trí lẻ quay mặt ngược lại cho đàn trông tự nhiên.
			animal.flip_h = index % 2 == 1
		animal.position = _animal_spot(index)
		_animal_layer.add_child(animal)
	_animate_animals()
	_marker.visible = pen.get_ready_count() > 0 and _marker.texture != null
	var prompt: String = controller.get_prompt(_get_inventory())
	if interactable.prompt_text != prompt:
		interactable.prompt_text = prompt
		# Player chỉ phát lại lời nhắc khi đổi mục tiêu, nên báo HUD khi nó đang nhắm chuồng này.
		var player: Node = get_tree().get_first_node_in_group("player")
		if player != null and player.has_method("get_target") and player.get_target() == interactable:
			EventBus.interaction_prompt_changed.emit(prompt)


## Chỗ đứng của con thứ [param index]: hai hàng so le ở bãi trước chuồng, chân con vật tại điểm này.
func _animal_spot(index: int) -> Vector2:
	var columns: int = 4
	var column: int = index % columns
	var row: int = index / columns
	var spread: float = STRUCTURE_CELL.x * STRUCTURE_SCALE * 0.62
	var x: float = -spread / 2.0 + (spread / (columns - 1)) * column + (row % 2) * 8.0
	return Vector2(x, 26.0 + row * 16.0 + (column % 2) * 6.0).round()


func _add_blocker(width: float) -> void:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(width, 16.0)
	shape.shape = box
	body.position = Vector2(0, -8.0)
	body.add_child(shape)
	add_child(body)
