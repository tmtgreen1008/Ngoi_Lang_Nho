extends "res://tests/test_base.gd"
## Ba sạp ở Chợ: sạp rau chú Năm, sạp trứng thịt cô Ba (thu mua thực phẩm giá cao hơn), hàng xén cô Út (hạt giống
## rẻ hơn, mỗi ngày ba loại). Giá cả không tạo chênh lệch để kiếm lời; trong game cả ba sạp nói chuyện và mua bán được.


func _vendor(path: String) -> Node:
	var vendor: Node = load("res://components/vendor/vendor_component.gd").new()
	vendor.data = load(path)
	root.add_child(vendor)
	return vendor


func _ids(vendor: Node) -> Array:
	var ids: Array = []
	for entry in vendor.stock:
		ids.append(entry.item.id)
	ids.sort()
	return ids


func run() -> void:
	var tm: Node = root.get_node("TimeManager")
	var db: Node = root.get_node("ItemDatabase")
	var sm: Node = root.get_node("SceneManager")
	var economy: Node = root.get_node("EconomyManager")
	tm.pause()
	tm.load_save_data({})
	economy.load_save_data({})

	var grocery: Node = _vendor("res://data/vendors/tap_hoa.tres")
	var greens: Node = _vendor("res://data/vendors/thuong_lai_rau.tres")
	var food: Node = _vendor("res://data/vendors/quan_co_ba.tres")
	var seeds: Node = _vendor("res://data/vendors/hang_co_ut.tres")
	var egg: ItemData = db.get_item(&"trung_ga")
	var pork: ItemData = db.get_item(&"thit_lon")
	var lua: ItemData = db.get_item(&"lua")

	# --- dữ liệu ---
	check("ba sạp chợ cùng mở 5h-11h", greens.data.open_hour == 5.0 and food.data.open_hour == 5.0 and seeds.data.open_hour == 5.0 and food.data.close_hour == 11.0 and seeds.data.close_hour == 11.0)
	check("mỗi sạp có người bán (ảnh 2 khung) và lời thoại riêng", food.data.npc_sheet.get_size() == Vector2(64, 48) and seeds.data.npc_sheet.get_size() == Vector2(64, 48) and food.data.dialogue.is_valid() and seeds.data.dialogue.is_valid() and food.data.dialogue.speaker_id == food.data.id and seeds.data.dialogue.speaker_id == seeds.data.id)

	# --- cô Ba: chỉ thu mua thực phẩm, giá cao hơn ---
	check("cô Ba không bán gì", food.stock.is_empty())
	check("cô Ba nhận trứng, thịt; không nhận lúa hay hạt giống", food.data.accepts(egg) and food.data.accepts(pork) and not food.data.accepts(lua) and not food.data.accepts(db.get_item(&"hat_giong_lua")))
	check("cô Ba trả giá cao hơn chú Năm cho trứng và thịt", food.data.get_sell_price(egg) > greens.data.get_sell_price(egg) and food.data.get_sell_price(pork) > greens.data.get_sell_price(pork))
	var inv: Node = load("res://components/inventory/inventory_component.gd").new()
	inv.slot_count = 8
	root.add_child(inv)
	inv.add_item(egg, 10)
	inv.add_item(lua, 5)
	tm.hour = 8
	var money: int = economy.money
	check("bán 10 trứng cho cô Ba: +%d đ" % (food.data.get_sell_price(egg) * 10), food.sell(egg, 10, inv) == "" and economy.money == money + food.data.get_sell_price(egg) * 10 and inv.count_of(egg) == 0)
	check("cô Ba từ chối mua lúa", food.sell(lua, 1, inv) != "" and inv.count_of(lua) == 5)

	# --- cô Út: ba loại hạt giống mỗi ngày, rẻ hơn Tạp Hóa, không thu mua ---
	check("cô Út có 3 loại hạt mỗi ngày", seeds.stock.size() == 3)
	var all_seeds: bool = true
	var cheaper: bool = true
	var limited: bool = true
	var variety: Dictionary = {}
	for day: int in range(1, 15):
		seeds.generate_daily_stock(day)
		variety[str(_ids(seeds))] = true
		for entry in seeds.stock:
			all_seeds = all_seeds and entry.item is CropItemData
			cheaper = cheaper and seeds.data.get_buy_price(entry.item) < grocery.data.get_buy_price(entry.item)
			limited = limited and entry.amount >= 3 and entry.amount <= 8
	check("hàng cô Út toàn hạt giống, số lượng 3..8", all_seeds and limited)
	check("hạt giống cô Út luôn rẻ hơn Tạp Hóa", cheaper)
	check("mỗi ngày một bộ hạt khác (14 ngày có >= 6 bộ khác nhau)", variety.size() >= 6)
	seeds.generate_daily_stock(4)
	var day4: Array = _ids(seeds)
	seeds.generate_daily_stock(4)
	check("cùng ngày thì cùng hàng (xác định)", day4 == _ids(seeds))
	check("cô Út không thu mua", not seeds.data.accepts(lua) and not seeds.data.accepts(egg) and seeds.sell(lua, 1, inv) != "")
	var first: ItemData = seeds.stock[0].item
	money = economy.money
	check("mua 1 hạt ở cô Út trả đúng giá x0,9", seeds.buy(first, 1, inv) == "" and economy.money == money - seeds.data.get_buy_price(first) and inv.count_of(first) == 1)

	# --- không có chênh lệch giá giữa các nơi bán và nơi thu mua ---
	var vendors: Array[Node] = [grocery, greens, food, seeds]
	var arbitrage: Array = []
	for seller: Node in vendors:
		var items: Array = []
		items.append_array(seller.data.fixed_items)
		items.append_array(seller.data.random_pool)
		for item: ItemData in items:
			for buyer: Node in vendors:
				if buyer.data.accepts(item) and buyer.data.get_sell_price(item) >= seller.data.get_buy_price(item):
					arbitrage.append("%s: %s -> %s" % [item.id, seller.data.id, buyer.data.id])
	check("không món nào mua ở sạp này bán lại sạp khác có lời %s" % str(arbitrage), arbitrage.is_empty())
	var targets: Dictionary = load("res://tools/economy_report.gd").TARGETS
	var max_ppd: float = 0.0
	for id: String in load("res://tools/economy_report.gd").CROP_IDS:
		var crop: CropItemData = db.get_item(StringName(id)) as CropItemData
		var revenue: int = greens.data.get_sell_price(db.get_item(crop.harvest_item_id)) * crop.harvest_amount
		max_ppd = maxf(max_ppd, float(revenue - seeds.data.get_buy_price(crop)) / crop.grow_days)
	check("mua hạt rẻ ở cô Út, lãi/ô/ngày cao nhất vẫn trong mục tiêu (%.1f <= %.0f)" % [max_ppd, targets["max_crop_ppd"]], max_ppd <= targets["max_crop_ppd"])

	# --- trong game ---
	tm.load_save_data({})
	var main: Node = await start_game()
	tm.pause()
	var player: Node = main.player
	player.position = sm.current_map.get_exit_position("morning_market.tscn")
	await wait(1.0)
	var market_map: Node = sm.current_map
	check("vào Chợ: có đủ 3 sạp", sm.current_scene_path.ends_with("morning_market.tscn") and market_map.vendors.size() == 3 and market_map.vendors.has(&"quan_co_ba") and market_map.vendors.has(&"hang_co_ut"))
	var positions: Array = []
	for id: StringName in market_map.vendors:
		positions.append(market_map.vendors[id].position)
	check("ba người bán đứng cách nhau và trong vùng chơi", positions[0].distance_to(positions[1]) > 200.0 and positions[1].distance_to(positions[2]) > 200.0 and positions[0].distance_to(positions[2]) > 200.0 and market_map.playable_rect.has_point(positions[1]) and market_map.playable_rect.has_point(positions[2]))
	await shot("market_stalls.png")

	# Cô Ba: E, E mở cửa hàng; bán trứng khởi đầu.
	var co_ba: Node = market_map.vendors[&"quan_co_ba"]
	player.position = co_ba.position + Vector2(0, 30)
	await wait(0.3)
	check("nhắm được cô Ba", player.get_target() == co_ba.interactable)
	await press_action("interact")
	check("E mở hộp thoại cô Ba", main.dialogue_box.visible and main.dialogue_box._name_label.text == "Cô Ba")
	await press_action("interact")
	check("E lần hai mở sạp cô Ba, tab Mua báo không có hàng", main.shop_ui.visible and main.shop_ui._title_label.text == "Sạp trứng thịt cô Ba" and main.shop_ui._buy_list.get_child_count() == 1)
	var eggs: int = player.inventory.count_of(egg)
	money = economy.money
	check("bán 1 trứng qua sạp cô Ba", co_ba.vendor.sell(egg, 1, player.inventory) == "" and player.inventory.count_of(egg) == eggs - 1 and economy.money == money + 8)
	await press_action("ui_cancel")

	# Cô Út: cửa hàng có 3 dòng hạt giống.
	var co_ut: Node = market_map.vendors[&"hang_co_ut"]
	player.position = co_ut.position + Vector2(0, 30)
	await wait(0.3)
	check("nhắm được cô Út", player.get_target() == co_ut.interactable)
	await press_action("interact")
	await press_action("interact")
	check("sạp cô Út có 3 dòng hạt giống", main.shop_ui.visible and main.shop_ui._title_label.text == "Hàng xén cô Út" and main.shop_ui._buy_list.get_child_count() == 3)
	await shot("market_seed_stall.png")
	await press_action("ui_cancel")

	# Hết giờ chợ: cả ba sạp đóng.
	tm.hour = 12
	check("12 giờ: ba sạp đều đóng cửa", not co_ba.vendor.is_open() and not co_ut.vendor.is_open() and not market_map.vendors[&"thuong_lai_rau"].vendor.is_open())
