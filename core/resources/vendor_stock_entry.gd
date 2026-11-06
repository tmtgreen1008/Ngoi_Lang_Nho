class_name VendorStockEntry
extends RefCounted
## Một dòng hàng trong kho của cửa hàng: vật phẩm và số lượng còn lại (dữ liệu runtime).

## Giá trị amount nghĩa là không giới hạn số lượng.
const UNLIMITED: int = -1

var item: ItemData
var amount: int = UNLIMITED


func _init(p_item: ItemData = null, p_amount: int = UNLIMITED) -> void:
	item = p_item
	amount = p_amount


func is_unlimited() -> bool:
	return amount == UNLIMITED


## Còn đủ [param count] món để bán không.
func has_stock(count: int) -> bool:
	return is_unlimited() or amount >= count


## Bán đi [param count] món (không làm gì nếu hàng không giới hạn).
func take(count: int) -> void:
	if not is_unlimited():
		amount = maxi(0, amount - count)
