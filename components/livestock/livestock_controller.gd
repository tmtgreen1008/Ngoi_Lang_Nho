class_name LivestockController
extends Node
## Nối [LivestockPen] với kho đồ của người chơi. Chuồng không biết kho đồ; controller này trừ thức ăn,
## trừ con giống và thêm sản phẩm. Một nút tương tác làm một việc theo thứ tự ưu tiên:
## thu sản phẩm, rồi cho ăn, rồi thả con giống vào chuồng.

## Phản hồi cho người chơi: (văn bản, loại: info/success/error).
signal feedback(text: String, kind: StringName)

@export var pen: LivestockPen


## Làm việc phù hợp nhất với [param inventory]. Trả về true nếu có gì thay đổi.
func interact(inventory: InventoryComponent) -> bool:
	if pen == null or pen.species == null or inventory == null:
		return false
	var feed_item: ItemData = ItemDatabase.get_item(pen.species.feed_item_id)
	var baby: ItemData = ItemDatabase.get_item(pen.species.baby_item_id)
	if pen.get_ready_count() > 0:
		return _collect(inventory)
	if pen.get_unfed_count() > 0 and inventory.has_item(feed_item):
		return _feed(inventory, feed_item)
	if inventory.has_item(baby):
		return _add_baby(inventory, baby)
	feedback.emit(_hint(feed_item, baby), &"info")
	return false


## Câu gợi ý khi không có việc nào làm được ngay.
func _hint(feed_item: ItemData, baby: ItemData) -> String:
	if pen.get_count() == 0:
		return "Chuồng trống. Mua %s ở Tiệm Tạp Hóa rồi mang về thả vào." % baby.display_name.to_lower()
	if pen.get_unfed_count() > 0:
		return "Cần %s để cho ăn." % feed_item.display_name.to_lower()
	return "Hôm nay mọi con đã được cho ăn (%d/%d)." % [pen.get_count(), pen.capacity]


## Lời nhắc ngắn ở HUD khi đứng gần chuồng, theo tình trạng chuồng.
func get_prompt(inventory: InventoryComponent) -> String:
	var species_name: String = pen.species.display_name
	var tag: String = "%s (%d/%d)" % [species_name, pen.get_count(), pen.capacity]
	if pen.get_ready_count() > 0:
		return "Thu hoạch %s" % tag
	if inventory != null and pen.get_unfed_count() > 0 and inventory.has_item(ItemDatabase.get_item(pen.species.feed_item_id)):
		return "Cho ăn %s" % tag
	if inventory != null and inventory.has_item(ItemDatabase.get_item(pen.species.baby_item_id)):
		return "Thả con giống vào chuồng %s" % tag
	return "Chuồng %s" % tag


func _collect(inventory: InventoryComponent) -> bool:
	var product: ItemData = ItemDatabase.get_item(pen.species.product_item_id)
	if product == null:
		feedback.emit("Lỗi dữ liệu: không có sản phẩm.", &"error")
		return false
	var amount: int = pen.species.product_amount * pen.get_ready_count()
	if not inventory.can_add(product, amount):
		feedback.emit("Túi đồ đã đầy.", &"error")
		return false
	pen.collect()
	inventory.add_item(product, amount)
	EventBus.item_picked.emit(product, amount)
	feedback.emit("Thu được %d %s." % [amount, product.display_name.to_lower()], &"success")
	return true


func _feed(inventory: InventoryComponent, feed_item: ItemData) -> bool:
	var fed: int = pen.feed(inventory.count_of(feed_item))
	inventory.remove_item(feed_item, fed)
	feedback.emit("Đã cho %d con ăn (hết %d %s)." % [fed, fed, feed_item.display_name.to_lower()], &"success")
	return fed > 0


func _add_baby(inventory: InventoryComponent, baby: ItemData) -> bool:
	if not pen.add_animal():
		feedback.emit("Chuồng đã đầy (%d/%d)." % [pen.get_count(), pen.capacity], &"error")
		return false
	inventory.remove_item(baby, 1)
	feedback.emit("Đã thả 1 %s vào chuồng (%d/%d)." % [baby.display_name.to_lower(), pen.get_count(), pen.capacity], &"success")
	return true
