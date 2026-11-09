class_name AnimalData
extends Resource
## Dữ liệu tĩnh của một loài vật nuôi (gà, lợn...). Mỗi loài là một file .tres trong data/animals/.
##
## Chỉ mô tả loài: con vật được mua dưới dạng vật phẩm "con giống" ([member baby_item_id]) rồi thả
## vào chuồng; chuồng ([LivestockPen]) tự đếm ngày theo dữ liệu này.

@export var id: StringName = &""
@export var display_name: String = ""
## Vật phẩm "con giống" trong kho (mua ở Tạp Hóa), thả vào chuồng thì biến mất khỏi kho.
@export var baby_item_id: StringName = &""
## Thức ăn: mỗi con ăn 1 vật phẩm này mỗi ngày (nếu không được cho ăn thì không tiến triển).
@export var feed_item_id: StringName = &""
## Số ngày được cho ăn để cho ra sản phẩm một lần.
@export_range(1, 60, 1) var fed_days_per_product: int = 1
## Sản phẩm thu được và số lượng mỗi lần (mỗi con).
@export var product_item_id: StringName = &""
@export_range(1, 99, 1) var product_amount: int = 1
## true: con vật ở lại và cho sản phẩm mãi (gà đẻ trứng); false: thu hoạch xong thì con vật rời chuồng (lợn xuất chuồng).
@export var keeps_producing: bool = true
## Chỉ số khung của con vật trong ảnh assets/art/animals/farm_a.png (ô 34 px, xếp ngang).
@export_range(0, 6, 1) var sprite_frame: int = 0


func is_valid() -> bool:
	return id != &"" and baby_item_id != &"" and feed_item_id != &"" and product_item_id != &""
