class_name VendorData
extends Resource
## Dữ liệu tĩnh của một cửa hàng/sạp hàng. ShopUI chỉ cần resource này (qua
## VendorComponent) để dựng danh sách hàng, nên một ShopUI phục vụ mọi cửa hàng.
##
## - Tiệm Tạp Hóa: chỉ có [member fixed_items], mở 6h-21h.
## - Sạp ở Chợ: có [member random_pool], mỗi ngày bốc [member daily_random_count]
##   món ngẫu nhiên, mở 5h-11h.

@export var id: StringName = &""
@export var display_name: String = ""
## Ảnh người bán: hai khung đứng yên xếp ngang (khung nhún nhẹ), mỗi khung 32x48.
@export var npc_sheet: Texture2D
## Lời thoại của người bán (trò chuyện, độ thân thiết, quà tặng); null thì bấm E mở thẳng cửa hàng.
@export var dialogue: DialogueData

@export_group("Giờ mở cửa")
@export_range(0.0, 24.0, 0.5) var open_hour: float = 6.0
@export_range(0.0, 24.0, 0.5) var close_hour: float = 21.0

@export_group("Hàng bán")
## Hàng luôn có, không giới hạn số lượng (nhu yếu phẩm).
@export var fixed_items: Array[ItemData] = []
## Kho hàng ngẫu nhiên: mỗi ngày bốc [member daily_random_count] món trong danh sách này.
@export var random_pool: Array[ItemData] = []
@export_range(0, 20, 1) var daily_random_count: int = 0
@export_range(1, 99, 1) var daily_amount_min: int = 3
@export_range(1, 99, 1) var daily_amount_max: int = 10

@export_group("Giá")
## Giá người chơi mua = base_price x hệ số này.
@export_range(0.1, 10.0, 0.05) var buy_multiplier: float = 1.0
## Giá cửa hàng thu mua lại = base_price x hệ số này.
@export_range(0.0, 10.0, 0.05) var sell_multiplier: float = 0.5

@export_group("Thu mua")
@export var buys_from_player: bool = true
## Chỉ thu mua các nhóm này (giá trị của ItemData.Category). Rỗng = nhận mọi loại.
@export var buyable_categories: Array[int] = []


## Giờ [param hour_float] (vd 13.5 = 13:30) có nằm trong giờ mở cửa không.
func is_open_at(hour_float: float) -> bool:
	return hour_float >= open_hour and hour_float < close_hour


## Giá người chơi trả khi mua 1 [param item] (tối thiểu 1 đồng).
func get_buy_price(item: ItemData) -> int:
	return maxi(1, item.get_price(buy_multiplier))


## Giá cửa hàng trả khi thu mua 1 [param item] từ người chơi.
func get_sell_price(item: ItemData) -> int:
	return item.get_price(sell_multiplier)


## Cửa hàng có thu mua [param item] không (theo cờ và nhóm hàng).
func accepts(item: ItemData) -> bool:
	if not buys_from_player or item == null:
		return false
	return buyable_categories.is_empty() or buyable_categories.has(item.category)
