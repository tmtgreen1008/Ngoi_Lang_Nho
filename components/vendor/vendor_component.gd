class_name VendorComponent
extends Node
## Gắn vào NPC bán hàng hoặc sạp: giữ kho hàng của ngày và xử lý mua/bán.
##
## - Kho hàng được dựng lại mỗi khi sang ngày mới (nghe EventBus.day_changed).
## - Hàng ngẫu nhiên được bốc bằng seed = (id cửa hàng, ngày), nên cùng một ngày
##   luôn ra cùng một danh sách (nạp game không làm đổi hàng).
## - Mua/bán trả về chuỗi lỗi để UI hiển thị; chuỗi rỗng nghĩa là thành công.

## Kho hàng thay đổi (đổi ngày hoặc có giao dịch).
signal stock_changed

@export var data: VendorData

## Kho hàng hiện tại: hàng cố định trước, rồi hàng ngẫu nhiên của ngày.
var stock: Array[VendorStockEntry] = []


func _ready() -> void:
	EventBus.day_changed.connect(generate_daily_stock)
	generate_daily_stock()


## Dựng lại kho hàng cho ngày [param day] (mặc định: ngày hiện tại của TimeManager).
func generate_daily_stock(day: int = -1) -> void:
	stock.clear()
	if data == null:
		stock_changed.emit()
		return
	if day < 0:
		day = TimeManager.day
	for item: ItemData in data.fixed_items:
		stock.append(VendorStockEntry.new(item, VendorStockEntry.UNLIMITED))

	var rng := RandomNumberGenerator.new()
	rng.seed = hash("%s:%d" % [data.id, day])
	var pool: Array[ItemData] = data.random_pool.duplicate()
	# Xáo trộn Fisher-Yates bằng rng riêng (Array.shuffle dùng RNG toàn cục, không lặp lại được).
	for i: int in range(pool.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp: ItemData = pool[i]
		pool[i] = pool[j]
		pool[j] = tmp
	var count: int = mini(data.daily_random_count, pool.size())
	var low: int = mini(data.daily_amount_min, data.daily_amount_max)
	var high: int = maxi(data.daily_amount_min, data.daily_amount_max)
	for i: int in count:
		stock.append(VendorStockEntry.new(pool[i], rng.randi_range(low, high)))
	stock_changed.emit()


## Cửa hàng đang mở không (theo giờ của TimeManager).
func is_open() -> bool:
	return data != null and data.is_open_at(TimeManager.get_hour_float())


## Người chơi mua [param amount] [param item] vào [param buyer]. Trả về lỗi hoặc "".
func buy(item: ItemData, amount: int, buyer: InventoryComponent) -> String:
	if data == null or item == null or amount <= 0 or buyer == null:
		return "Giao dịch không hợp lệ."
	if not is_open():
		return "Cửa hàng đã đóng cửa."
	var entry: VendorStockEntry = _find_entry(item)
	if entry == null or not entry.has_stock(1):
		return "Hết hàng."
	if not entry.has_stock(amount):
		return "Không đủ hàng."
	var total: int = data.get_buy_price(item) * amount
	if not EconomyManager.can_afford(total):
		return "Không đủ tiền."
	if not buyer.can_add(item, amount):
		return "Túi đồ đã đầy."
	EconomyManager.spend(total)
	buyer.add_item(item, amount)
	entry.take(amount)
	EventBus.transaction_completed.emit(item, amount, total, true)
	stock_changed.emit()
	return ""


## Người chơi bán [param amount] [param item] từ [param seller]. Trả về lỗi hoặc "".
func sell(item: ItemData, amount: int, seller: InventoryComponent) -> String:
	if data == null or item == null or amount <= 0 or seller == null:
		return "Giao dịch không hợp lệ."
	if not is_open():
		return "Cửa hàng đã đóng cửa."
	if not data.accepts(item):
		return "Cửa hàng không thu mua món này."
	if not seller.has_item(item, amount):
		return "Bạn không có đủ số lượng."
	var total: int = data.get_sell_price(item) * amount
	seller.remove_item(item, amount)
	EconomyManager.earn(total)
	EventBus.transaction_completed.emit(item, amount, total, false)
	stock_changed.emit()
	return ""


func _find_entry(item: ItemData) -> VendorStockEntry:
	for entry: VendorStockEntry in stock:
		if entry.item.id == item.id:
			return entry
	return null
