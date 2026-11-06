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


func clear() -> void:
	item = null
	amount = 0
