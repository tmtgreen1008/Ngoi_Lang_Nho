extends "res://tests/test_base.gd"
## VendorComponent + EconomyManager: kho hàng theo ngày (xác định), mua/bán,
## giờ mở cửa, các lỗi.


func _stock_ids(vendor: Node) -> Array:
	var ids: Array = []
	for entry in vendor.stock:
		ids.append(String(entry.item.id))
	return ids


func run() -> void:
	var tm: Node = root.get_node("TimeManager")
	var bus: Node = root.get_node("EventBus")
	var economy: Node = root.get_node("EconomyManager")
	var db: Node = root.get_node("ItemDatabase")
	tm.pause()
	tm.load_save_data({})
	economy.load_save_data({})

	var vendor_script: GDScript = load("res://components/vendor/vendor_component.gd")
	var inventory_script: GDScript = load("res://components/inventory/inventory_component.gd")
	var grocery: Node = vendor_script.new()
	grocery.data = load("res://data/vendors/tap_hoa.tres")
	root.add_child(grocery)
	var market: Node = vendor_script.new()
	market.data = load("res://data/vendors/thuong_lai_rau.tres")
	root.add_child(market)
	var inv: Node = inventory_script.new()
	inv.slot_count = 8
	root.add_child(inv)
	var noodles: ItemData = db.get_item(&"mi_tom")
	var lua: ItemData = db.get_item(&"lua")
	var seed_item: ItemData = db.get_item(&"hat_giong_lua")

	check("tạp hóa: 19 món cố định (kèm 4 con giống và 11 hạt giống), không giới hạn", grocery.stock.size() == 19 and grocery.stock[0].is_unlimited())
	check("chợ: 3 món ngẫu nhiên", market.stock.size() == 3)
	var amounts_ok: bool = true
	for entry in market.stock:
		amounts_ok = amounts_ok and entry.amount >= 3 and entry.amount <= 10
	check("số lượng hàng chợ trong 3..10", amounts_ok)
	market.generate_daily_stock(5)
	var first: Array = _stock_ids(market)
	market.generate_daily_stock(5)
	check("cùng ngày ra cùng hàng (xác định)", first == _stock_ids(market))
	var variety: Dictionary = {}
	for d: int in range(1, 15):
		market.generate_daily_stock(d)
		variety[str(_stock_ids(market))] = true
	check("các ngày khác nhau ra hàng khác nhau", variety.size() > 1)
	market.generate_daily_stock()

	check("tiền khởi đầu 100", economy.money == 100)
	check("mua 2 mì tôm", grocery.buy(noodles, 2, inv) == "" and economy.money == 84 and inv.count_of(noodles) == 2)
	check("hết tiền: từ chối, không đổi gì", grocery.buy(seed_item, 99, inv) == "Không đủ tiền." and economy.money == 84)
	check("tạp hóa không thu mua", grocery.sell(noodles, 1, inv) == "Cửa hàng không thu mua món này.")
	inv.add_item(lua, 10)
	check("chợ thu mua lúa 10 x 14 = 140", market.sell(lua, 10, inv) == "" and economy.money == 224)
	check("bán quá số đang có bị từ chối", market.sell(lua, 1, inv) == "Bạn không có đủ số lượng.")

	var entry = market.stock[0]
	var amount: int = entry.amount
	check("mua quá tồn kho bị từ chối", market.buy(entry.item, amount + 1, inv) == "Không đủ hàng.")
	check("mua hết tồn kho", market.buy(entry.item, amount, inv) == "" and entry.amount == 0)
	check("hết hàng", market.buy(entry.item, 1, inv) == "Hết hàng.")

	var tiny: Node = inventory_script.new()
	tiny.slot_count = 1
	root.add_child(tiny)
	tiny.add_item(lua, 1)
	var money_before: int = economy.money
	check("túi đầy: từ chối, giữ tiền", grocery.buy(noodles, 1, tiny) == "Túi đồ đã đầy." and economy.money == money_before)

	var tx: Array = [0]
	bus.transaction_completed.connect(func(_i: ItemData, _a: int, _t: int, _b: bool) -> void: tx[0] += 1)
	grocery.buy(noodles, 1, inv)
	check("phát transaction_completed", tx[0] == 1)

	entry.amount = 0
	tm.sleep_until_morning()
	var restocked: bool = false
	for e in market.stock:
		restocked = restocked or e.amount > 0
	check("sang ngày mới kho hàng chợ được làm mới", restocked and market.stock.size() == 3)
	check("6:00 cả hai cửa hàng mở", grocery.is_open() and market.is_open())
	tm.advance_minutes(5 * 60)
	check("11:00 chợ đóng, tạp hóa còn mở", not market.is_open() and grocery.is_open())
	check("mua khi đóng cửa bị từ chối", market.buy(market.stock[0].item, 1, inv) == "Cửa hàng đã đóng cửa.")
	tm.advance_minutes(10 * 60)
	check("21:00 tạp hóa đóng", not grocery.is_open())
	check("bán khi đóng cửa bị từ chối", grocery.sell(noodles, 1, inv) == "Cửa hàng đã đóng cửa.")
	tm.load_save_data({})
	economy.load_save_data({})
