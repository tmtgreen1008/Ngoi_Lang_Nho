class_name ClothesLine
extends Node2D
## Dây phơi ngoài sân: giặt đồ bằng xà phòng (mua ở Tạp Hóa), phơi qua đêm, hôm sau thu vào thì có "áo quần sạch"
## trong vài ngày: trò chuyện với dân làng được gấp đôi điểm thân thiết (xem RelationshipManager).
##
## Bấm E làm một việc theo tình trạng: dây trống thì giặt và phơi (tốn 1 xà phòng, mất [constant WASH_MINUTES]
## phút); đồ còn ướt thì chờ; đồ đã khô (từ hôm sau) thì thu vào. Thuộc nhóm world_persistent nên được nhớ khi đổi
## map và trong bản lưu. Gốc toạ độ là chân dây phơi (giữa đáy ảnh).

const TEXTURE_FULL: String = "res://assets/art/props/clothesline.png"
const TEXTURE_EMPTY: String = "res://assets/art/props/clothesline_empty.png"
const SOAP_ID: StringName = &"xa_phong"
const WASH_MINUTES: int = 60
## Số ngày áo quần còn sạch kể từ ngày thu đồ (tính cả ngày thu).
const CLEAN_DAYS: int = 3

@export var persistent_key: StringName = &"clothes_line"

## Ngày đã phơi đồ lên dây; 0 nghĩa là dây trống.
var hung_day: int = 0
var interactable: InteractableComponent

var _sprite: Sprite2D


func _ready() -> void:
	add_to_group(WorldStateManager.PERSISTENT_GROUP)
	var texture: Texture2D = load(TEXTURE_EMPTY)
	var shadow: Sprite2D = Shadow.create(texture.get_width() * 0.9)
	shadow.position = Vector2(0, -2)
	add_child(shadow)
	_sprite = Sprite2D.new()
	_sprite.centered = false
	_sprite.offset = Vector2(-texture.get_width() / 2.0, -texture.get_height())
	add_child(_sprite)
	interactable = InteractableComponent.new()
	interactable.name = "Interactable"
	interactable.interact_radius = 60.0
	interactable.position = Vector2(0, -16)
	add_child(interactable)
	interactable.interacted.connect(func(interactor: Node) -> void: use(interactor.get("inventory") as InventoryComponent))
	EventBus.day_changed.connect(func(_day: int) -> void: _refresh())
	_refresh()


func has_laundry() -> bool:
	return hung_day > 0


## Đồ đã khô chưa (phơi từ hôm trước trở về trước).
func is_dry() -> bool:
	return has_laundry() and TimeManager.day > hung_day


## Làm việc phù hợp với tình trạng dây phơi. Trả về true nếu có gì thay đổi.
func use(inventory: InventoryComponent) -> bool:
	if is_dry():
		return _collect()
	if has_laundry():
		EventBus.notice_requested.emit("Quần áo còn ướt, mai mới khô.", &"info")
		return false
	return _wash(inventory)


func _wash(inventory: InventoryComponent) -> bool:
	var soap: ItemData = ItemDatabase.get_item(SOAP_ID)
	if inventory == null or soap == null or not inventory.has_item(soap):
		EventBus.notice_requested.emit("Cần xà phòng để giặt đồ (mua ở Tiệm Tạp Hóa).", &"error")
		return false
	inventory.remove_item(soap, 1)
	hung_day = TimeManager.day
	EventBus.sfx_requested.emit(&"splash")
	TimeManager.advance_minutes(WASH_MINUTES)
	# Giặt lúc khuya có thể làm sang ngày mới; đồ vẫn tính là phơi từ ngày vừa giặt.
	EventBus.notice_requested.emit("Bạn giặt đồ rồi phơi lên dây (mất %d phút). Mai là khô." % WASH_MINUTES, &"success")
	_refresh()
	return true


func _collect() -> bool:
	hung_day = 0
	RelationshipManager.wear_clean_clothes(CLEAN_DAYS)
	EventBus.sfx_requested.emit(&"pickup")
	EventBus.notice_requested.emit("Áo quần sạch thơm! Trong %d ngày tới, trò chuyện được gấp đôi điểm thân thiết." % CLEAN_DAYS, &"success")
	_refresh()
	return true


## Đổi ảnh và lời nhắc theo tình trạng.
func _refresh() -> void:
	_sprite.texture = load(TEXTURE_FULL if has_laundry() else TEXTURE_EMPTY)
	var prompt: String = "Giặt đồ (cần 1 xà phòng)"
	if is_dry():
		prompt = "Thu đồ đã khô"
	elif has_laundry():
		prompt = "Đồ đang phơi (mai mới khô)"
	if interactable.prompt_text != prompt:
		interactable.prompt_text = prompt
		var player: Node = get_tree().get_first_node_in_group("player")
		if player != null and player.has_method("get_target") and player.get_target() == interactable:
			EventBus.interaction_prompt_changed.emit(prompt)


func get_world_state() -> Dictionary:
	return {"hung_day": hung_day}


func apply_world_state(state: Dictionary) -> void:
	hung_day = maxi(0, int(state.get("hung_day", 0)))
	_refresh()
