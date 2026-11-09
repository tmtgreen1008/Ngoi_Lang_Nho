extends "res://tests/test_base.gd"
## Cân bằng kinh tế: lãi mỗi ô mỗi ngày của từng loại cây nằm trong khoảng mục tiêu và không loại nào ăn đứt,
## không có chênh lệch giá để kiếm lời vô hạn, vật nuôi hoàn vốn đủ nhanh, mini-game không phải máy in tiền.
## Ngưỡng lấy từ tools/economy_report.gd (cùng bộ số với báo cáo); đổi giá thì chạy báo cáo để chỉnh lại.


func run() -> void:
	var db: Node = root.get_node("ItemDatabase")
	var targets: Dictionary = load("res://tools/economy_report.gd").TARGETS
	var crop_ids: Array = load("res://tools/economy_report.gd").CROP_IDS
	var grocery: VendorData = load("res://data/vendors/tap_hoa.tres")
	var market: VendorData = load("res://data/vendors/thuong_lai_rau.tres")

	# --- cây trồng ---
	var all_profitable: bool = true
	var in_range: bool = true
	var min_ppd: float = INF
	var max_ppd: float = 0.0
	var every_seed_sold: bool = true
	for id: String in crop_ids:
		var seed_item: CropItemData = db.get_item(StringName(id)) as CropItemData
		var product: ItemData = db.get_item(seed_item.harvest_item_id)
		var cost: int = grocery.get_buy_price(seed_item)
		var revenue: int = market.get_sell_price(product) * seed_item.harvest_amount
		var ppd: float = float(revenue - cost) / seed_item.grow_days
		all_profitable = all_profitable and revenue > cost
		in_range = in_range and ppd >= targets["min_crop_ppd"] and ppd <= targets["max_crop_ppd"]
		min_ppd = minf(min_ppd, ppd)
		max_ppd = maxf(max_ppd, ppd)
		every_seed_sold = every_seed_sold and grocery.fixed_items.has(seed_item)
	check("12 loại cây đều có lãi (doanh thu > giá hạt)", all_profitable and crop_ids.size() == 12)
	check("lãi/ô/ngày của mọi loại nằm trong khoảng %.0f-%.0f đ" % [targets["min_crop_ppd"], targets["max_crop_ppd"]], in_range)
	check("không loại nào ăn đứt: loại lãi nhất / ít nhất <= %.1f (thực tế %.2f)" % [targets["max_ppd_ratio"], max_ppd / min_ppd], max_ppd / min_ppd <= targets["max_ppd_ratio"])
	check("mọi hạt giống đều mua được ở Tạp Hóa", every_seed_sold)

	# --- không có chênh lệch giá ---
	check("Chợ thu mua rẻ hơn giá Chợ bán và giá Tạp Hóa bán (không kiếm lời bằng mua đi bán lại)", market.sell_multiplier < 1.0 and market.sell_multiplier < market.buy_multiplier and market.sell_multiplier < grocery.buy_multiplier)
	var arbitrage: bool = false
	for item: ItemData in grocery.fixed_items:
		if market.accepts(item) and market.get_sell_price(item) >= grocery.get_buy_price(item):
			arbitrage = true
	check("không món nào Tạp Hóa bán mà Chợ thu mua lại bằng hoặc hơn giá mua", not arbitrage)
	var positive_prices: bool = true
	for id: StringName in db.get_all_ids():
		var item: ItemData = db.get_item(id)
		if item.category != ItemData.Category.SEED or item.base_price > 0:
			continue
		positive_prices = false
	check("hạt giống nào cũng có giá > 0", positive_prices)

	# --- vật nuôi ---
	var hen: AnimalData = load("res://data/animals/ga.tres")
	var egg: ItemData = db.get_item(hen.product_item_id)
	var hen_feed: ItemData = db.get_item(hen.feed_item_id)
	check("gà ăn cám gà (mua ở Tạp Hóa), không ăn lúa", hen_feed.id == &"cam_ga" and grocery.fixed_items.has(hen_feed))
	var hen_daily: float = float(market.get_sell_price(egg) * hen.product_amount - grocery.get_buy_price(hen_feed)) / hen.fed_days_per_product
	var hen_cost: int = grocery.get_buy_price(db.get_item(hen.baby_item_id))
	check("gà lãi mỗi ngày (%.1f đ)" % hen_daily, hen_daily > 0.0)
	check("gà giống hoàn vốn trong %.0f ngày (thực tế %.1f)" % [targets["max_hen_payback_days"], hen_cost / hen_daily], hen_cost / hen_daily <= targets["max_hen_payback_days"])
	var pig: AnimalData = load("res://data/animals/lon.tres")
	var pork: ItemData = db.get_item(pig.product_item_id)
	var pig_feed: ItemData = db.get_item(pig.feed_item_id)
	var pig_feed_cost: int = grocery.get_buy_price(pig_feed) if grocery.fixed_items.has(pig_feed) else market.get_sell_price(pig_feed)
	var pig_baby: int = grocery.get_buy_price(db.get_item(pig.baby_item_id))
	var pig_revenue: int = market.get_sell_price(pork) * pig.product_amount
	var pig_gross: int = pig_revenue - pig_feed_cost * pig.fed_days_per_product
	check("mỗi lứa lợn lãi >= %.0f đ sau khi trừ giống và thức ăn (thực tế %d)" % [targets["min_pig_cycle_profit"], pig_gross - pig_baby], pig_gross - pig_baby >= targets["min_pig_cycle_profit"])
	check("lợn giống hoàn vốn trong %.0f lứa" % targets["max_pig_payback_cycles"], float(pig_baby) / maxf(pig_gross, 1.0) <= targets["max_pig_payback_cycles"])

	# --- mini-game ---
	var aim: Variant = load("res://minigames/net_cafe/aim_game.gd").new()
	var pool: Variant = load("res://minigames/billiards/billiards_game.gd").new()
	var aim_best: float = float(mini(int(aim.round_seconds / aim.spawn_interval) * aim.pay_per_hit, aim.max_payout) - aim.entry_fee) * 60.0 / aim.minutes_cost
	var pool_best: float = float(pool.shots_per_round * pool.pay_per_ball - pool.entry_fee) * 60.0 / pool.minutes_cost
	check("Quán Net hoàn hảo: %.1f đ/giờ trong khoảng %.0f-%.0f" % [aim_best, targets["min_minigame_hourly"], targets["max_minigame_hourly"]], aim_best >= targets["min_minigame_hourly"] and aim_best <= targets["max_minigame_hourly"])
	check("Quán Bida hoàn hảo: %.1f đ/giờ trong khoảng %.0f-%.0f" % [pool_best, targets["min_minigame_hourly"], targets["max_minigame_hourly"]], pool_best >= targets["min_minigame_hourly"] and pool_best <= targets["max_minigame_hourly"])
	var full_day_income: float = aim_best * 16.0
	var farm_day_income: float = min_ppd * 70.0
	check("chơi mini-game cả ngày (16 giờ) vẫn kiếm ít hơn một vườn đầy 70 ô (%.0f < %.0f đ/ngày)" % [full_day_income, farm_day_income], full_day_income < farm_day_income)
	aim.free()
	pool.free()

	# --- vốn khởi đầu ---
	var lua_seed: ItemData = db.get_item(&"hat_giong_lua")
	check("vốn 100 đ mua thêm được ít nhất 5 hạt giống lúa để mở rộng vườn", 100 / grocery.get_buy_price(lua_seed) >= 5)
	var start_value: int = market.get_sell_price(db.get_item(&"trung_ga")) * 4
	check("4 trứng khởi đầu bán được một khoản nhỏ (%d đ), không đáng kể so với vốn" % start_value, start_value > 0 and start_value <= 50)
