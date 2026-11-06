class_name InteractableComponent
extends Area2D
## Gắn vào bất kỳ thực thể nào có thể tương tác (NPC, rương, cửa, giường...).
##
## Component chỉ báo "người chơi đã tương tác" qua signal [signal interacted];
## thực thể chủ sở hữu tự quyết định làm gì (mở shop, ngủ, nhặt đồ...).
## Người chơi tìm thấy component qua vật lý: component nằm ở layer 2 ("interactable"),
## còn vùng tìm của Player quét layer 2.

## Người chơi bấm nút tương tác khi đang đứng gần.
signal interacted(interactor: Node)

## Vật lý: layer dành cho đối tượng tương tác được.
const INTERACTABLE_LAYER: int = 2

## Dòng gợi ý hiện ở HUD, vd "Nói chuyện với bà Tư".
@export var prompt_text: String = "Tương tác"
## Bán kính vùng mà người chơi phải bước vào mới tương tác được.
@export_range(4.0, 200.0, 1.0) var interact_radius: float = 40.0
## Tắt tạm thời (cửa hàng đang đóng, rương bị khoá...).
@export var enabled: bool = true


func _ready() -> void:
	collision_layer = INTERACTABLE_LAYER
	collision_mask = 0
	monitoring = false  # Chỉ để người khác phát hiện, không tự phát hiện ai.
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = interact_radius
	shape.shape = circle
	add_child(shape)


func can_interact() -> bool:
	return enabled


## Người chơi [param interactor] tương tác. Không làm gì nếu đang tắt.
func interact(interactor: Node) -> void:
	if can_interact():
		interacted.emit(interactor)
