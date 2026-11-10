class_name FarmPlot
extends RefCounted
## Trạng thái một ô đất trong FarmField (dữ liệu runtime, không phải Resource).

## Đã cuốc đất (gieo hạt được).
var is_tilled: bool = false
## Cây đang trồng, null nếu ô trống.
var crop: CropItemData = null
## Số ngày cây đã lớn.
var days_grown: int = 0
## Đã bón phân cho cây đang trồng (thu hoạch được thêm nông sản); hết khi cây bị nhổ.
var fertilized: bool = false


func is_planted() -> bool:
	return crop != null


func is_ripe() -> bool:
	return crop != null and crop.is_ripe(days_grown)


## Xoá cây khỏi ô, giữ nguyên đất đã cuốc.
func clear_crop() -> void:
	crop = null
	days_grown = 0
	fertilized = false
