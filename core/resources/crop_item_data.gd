class_name CropItemData
extends ItemData
## Hạt giống / cây trồng. Kế thừa ItemData và bổ sung dữ liệu sinh trưởng.
##
## Hệ thống cây trồng lắng nghe EventBus.day_changed rồi so sánh số ngày đã
## trồng với [member grow_days]; resource này chỉ chứa dữ liệu, không tự đếm.

## Số ngày từ lúc gieo đến lúc thu hoạch được.
@export_range(1, 365, 1) var grow_days: int = 1
## Id của ItemData nhận được khi thu hoạch (vd: &"lua").
@export var harvest_item_id: StringName = &""
## Số vật phẩm nhận được mỗi lần thu hoạch.
@export_range(1, 99, 1) var harvest_amount: int = 1
## Các mùa được phép gieo (giá trị của TimeManager.Season). Rỗng = mọi mùa.
@export var allowed_seasons: Array[int] = []


func _init() -> void:
	category = Category.SEED


## Cây này gieo được vào [param season] (giá trị của TimeManager.Season) hay không.
func can_plant_in(season: int) -> bool:
	return allowed_seasons.is_empty() or allowed_seasons.has(season)


## Cây đã chín sau [param days_grown] ngày chưa.
func is_ripe(days_grown: int) -> bool:
	return days_grown >= grow_days


func is_valid() -> bool:
	return super.is_valid() and harvest_item_id != &""
