class_name ItemData
extends Resource
## Dữ liệu tĩnh của một vật phẩm. Mỗi vật phẩm là một file .tres trong data/items/.
##
## Không chứa logic trò chơi: chỉ mô tả vật phẩm. Số lượng, vị trí trong kho
## thuộc về InventoryComponent (Slot), không nằm ở đây.

## Nhóm vật phẩm, dùng để lọc trong kho và quyết định cửa hàng nào nhận mua.
enum Category { SEED, CROP, FOOD, TOOL, MATERIAL, MISC }

## Mã định danh duy nhất, dùng để tham chiếu và lưu game (vd: &"hat_giong_lua").
@export var id: StringName = &""
## Tên hiển thị cho người chơi (spec gọi là "name"; tránh trùng với thuộc tính Node.name).
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var category: Category = Category.MISC
## Giá gốc (đồng). Giá mua/bán thực tế do VendorData quyết định bằng hệ số.
@export_range(0, 1000000, 1) var base_price: int = 0
## Vật phẩm cộng dồn được trong một ô kho hay không.
@export var is_stackable: bool = true
## Số lượng tối đa trong một ô. Bị bỏ qua (coi là 1) khi is_stackable = false.
@export_range(1, 999, 1) var max_stack_size: int = 99


## Số lượng tối đa thực tế trong một ô kho.
func get_max_stack() -> int:
	return max_stack_size if is_stackable else 1


## Giá bán lại cho người chơi theo hệ số [param multiplier] (làm tròn xuống, tối thiểu 0).
func get_price(multiplier: float = 1.0) -> int:
	return maxi(0, int(floor(base_price * multiplier)))


## Trả về false nếu thiếu dữ liệu bắt buộc. Dùng để kiểm tra khi nạp resource.
func is_valid() -> bool:
	return id != &"" and not display_name.is_empty()
