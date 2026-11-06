class_name InventorySlot
extends RefCounted
## Một ô trong kho đồ: một loại vật phẩm cùng số lượng. Dữ liệu chạy (runtime), không lưu thành .tres.

var item: ItemData = null
var amount: int = 0


func is_empty() -> bool:
	return item == null or amount <= 0


## Số lượng còn nhận thêm được nếu ô đang chứa [param candidate].
## Ô trống nhận tối đa max_stack của vật phẩm; ô khác loại nhận 0.
func free_space_for(candidate: ItemData) -> int:
	if candidate == null:
		return 0
	if is_empty():
		return candidate.get_max_stack()
	if item.id != candidate.id:
		return 0
	return maxi(0, item.get_max_stack() - amount)


## Thêm [param count] vật phẩm; trả về số lượng KHÔNG nhét vừa.
func add(candidate: ItemData, count: int) -> int:
	if count <= 0:
		return maxi(0, count)
	var accepted: int = mini(count, free_space_for(candidate))
	if accepted > 0:
		if is_empty():
			item = candidate
			amount = 0
		amount += accepted
	return count - accepted


## Lấy tối đa [param count] vật phẩm ra khỏi ô; trả về số lượng thực lấy được.
func remove(count: int) -> int:
	var removed: int = clampi(count, 0, amount)
	amount -= removed
	if amount <= 0:
		clear()
	return removed


## Chuyển nội dung ô [param from_slot] sang ô [param to_slot] (có thể thuộc kho khác).
## Đích trống thì dời sang; cùng loại thì gộp (phần thừa ở lại ô nguồn);
## khác loại thì đổi chỗ. Trả về false nếu không có gì thay đổi.
static func move_between(from_slot: InventorySlot, to_slot: InventorySlot) -> bool:
	if from_slot == to_slot or from_slot.is_empty():
		return false
	if to_slot.is_empty() or to_slot.item.id == from_slot.item.id:
		var leftover: int = to_slot.add(from_slot.item, from_slot.amount)
		if leftover == from_slot.amount:
			return false  # Ô đích đã đầy, không gộp được.
		from_slot.amount = leftover
		if leftover <= 0:
			from_slot.clear()
		return true
	var moved_item: ItemData = from_slot.item
	var moved_amount: int = from_slot.amount
	from_slot.item = to_slot.item
	from_slot.amount = to_slot.amount
	to_slot.item = moved_item
	to_slot.amount = moved_amount
	return true


func clear() -> void:
	item = null
	amount = 0
