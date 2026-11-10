extends "res://tests/test_base.gd"
## Nấu ăn: 10 công thức (dữ liệu, giá món so với nguyên liệu sống, không chênh lệch giá), logic nấu (thiếu nguyên liệu,
## túi đầy, trừ đúng nguyên liệu), bếp trong nhà và bảng CookingUI (E mở, nấu, thời gian trôi, Esc đóng).


func run() -> void:
	var tm: Node = root.get_node("TimeManager")
	var db: Node = root.get_node("ItemDatabase")
	var sm: Node = root.get_node("SceneManager")
	var am: Node = root.get_node("AudioManager")
	tm.pause()
	tm.load_save_data({})

	var recipe_script: GDScript = load("res://core/resources/recipe_data.gd")
	var recipes: Array = recipe_script.load_all()
	var vendors: Array[VendorData] = [
		load("res://data/vendors/tap_hoa.tres"), load("res://data/vendors/thuong_lai_rau.tres"),
		load("res://data/vendors/quan_co_ba.tres"), load("res://data/vendors/hang_co_ut.tres"),
	]
	var co_ba: VendorData = vendors[2]

	# --- dữ liệu ---
	check("có 10 công thức", recipes.size() == 10)
	var data_ok: bool = true
	var sorted_ok: bool = true
	var last_price: int = 0
	for recipe: Variant in recipes:
		var dish: ItemData = recipe.get_output()
		data_ok = data_ok and recipe.is_valid() and dish != null and dish.icon != null and dish.icon.get_size() == Vector2(32, 32) and dish.category == ItemData.Category.FOOD and recipe.cook_minutes > 0
		for id: StringName in recipe.ingredient_ids:
			data_ok = data_ok and db.has_item(id)
		sorted_ok = sorted_ok and dish.base_price >= last_price
		last_price = dish.base_price
	check("mọi công thức hợp lệ: món có icon, nguyên liệu có thật, có thời gian nấu", data_ok)
	check("danh sách sắp theo giá món tăng dần", sorted_ok)

	# --- giá: món đáng giá hơn nguyên liệu sống 10-35%, không có chênh lệch giá ---
	var ratios_ok: bool = true
	var worst: String = ""
	var arbitrage: Array = []
	for recipe: Variant in recipes:
		var dish: ItemData = recipe.get_output()
		var dish_price: int = co_ba.get_sell_price(dish)
		var raw_value: int = 0
		var buy_cost: int = 0
		var purchasable: bool = true
		for i: int in recipe.ingredient_ids.size():
			var item: ItemData = db.get_item(recipe.ingredient_ids[i])
			var best_sell: int = 0
			var cheapest: int = -1
			for vendor: VendorData in vendors:
				if vendor.accepts(item):
					best_sell = maxi(best_sell, vendor.get_sell_price(item))
				if vendor.fixed_items.has(item) or vendor.random_pool.has(item):
					var price: int = vendor.get_buy_price(item)
					cheapest = price if cheapest < 0 else mini(cheapest, price)
			raw_value += best_sell * recipe.ingredient_amounts[i]
			if cheapest < 0:
				purchasable = false
			else:
				buy_cost += cheapest * recipe.ingredient_amounts[i]
		var ratio: float = float(dish_price) / maxf(raw_value, 1.0)
		if ratio < 1.1 or ratio > 1.35:
			ratios_ok = false
			worst += "%s=%.2f " % [recipe.id, ratio]
		if purchasable and dish_price >= buy_cost:
			arbitrage.append(recipe.id)
	check("mỗi món bán được hơn nguyên liệu sống 10-35%% %s" % worst, ratios_ok)
	check("mua đủ nguyên liệu ngoài chợ rồi nấu bán lại không có lời %s" % str(arbitrage), arbitrage.is_empty())
	check("cô Ba trả giá món cao hơn chú Năm", co_ba.get_sell_price(db.get_item(&"com_trang")) > vendors[1].get_sell_price(db.get_item(&"com_trang")))

	# --- logic nấu ---
	var inv: Node = load("res://components/inventory/inventory_component.gd").new()
	inv.slot_count = 4
	inv.owner_id = &"cook_test"
	root.add_child(inv)
	var rice: Variant = load("res://data/recipes/com_trang.tres")
	var sticky: Variant = load("res://data/recipes/xoi.tres")
	var lua: ItemData = db.get_item(&"lua")
	var bean: ItemData = db.get_item(&"dau")
	var cooked_rice: ItemData = db.get_item(&"com_trang")
	check("mô tả nguyên liệu", rice.describe_ingredients() == "2 Lúa" and sticky.describe_ingredients() == "3 Lúa, 1 Đậu")
	check("túi trống: báo thiếu nguyên liệu kèm số lượng", rice.get_block_reason(inv) == "Thiếu Lúa (cần 2, có 0)." and rice.cook(inv) != "")
	inv.add_item(lua, 5)
	check("nấu cơm: trừ 2 lúa, thêm 1 cơm trắng", rice.cook(inv) == "" and inv.count_of(lua) == 3 and inv.count_of(cooked_rice) == 1)
	check("xôi thiếu đậu: báo đúng món thiếu, không trừ gì", sticky.get_missing(inv) == "Đậu (cần 1, có 0)" and sticky.cook(inv) != "" and inv.count_of(lua) == 3)
	inv.add_item(bean, 1)
	check("đủ nguyên liệu: nấu được xôi", sticky.cook(inv) == "" and inv.count_of(lua) == 0 and inv.count_of(bean) == 0 and inv.count_of(db.get_item(&"xoi")) == 1)
	check("không có túi đồ: báo lỗi", rice.get_block_reason(null) != "")
	var full: Node = load("res://components/inventory/inventory_component.gd").new()
	full.slot_count = 1
	full.owner_id = &"cook_full"
	root.add_child(full)
	full.add_item(lua, 99)
	check("túi đầy: không nấu, không mất nguyên liệu", rice.cook(full) == "Túi đồ đã đầy." and full.count_of(lua) == 99)

	# --- trong game: bếp trong nhà ---
	tm.load_save_data({})
	var main: Node = await start_game()
	tm.pause()
	var player: Node = main.player
	var ui: Node = main.cooking_ui
	check("bảng nấu ăn nạp đủ 10 công thức", ui.get_recipes().size() == 10 and not ui.visible)
	travel("house_interior")
	await wait(1.0)
	var house: Node = sm.current_map
	check("vào trong nhà: có bếp lò", sm.current_scene_path.ends_with("house_interior.tscn") and house.stove != null and house.stove.prompt_text == "Nấu ăn")
	player.position = house.stove.position + Vector2(0, 56)
	await wait(0.3)
	check("đứng trước bếp thì nhắm được bếp", player.get_target() == house.stove)
	await press_action("interact")
	check("E mở bảng nấu ăn, Player đứng yên", ui.visible and ui.is_open() and player.movement_locked)
	await wait(0.1)
	check("bảng có 10 dòng công thức", ui._list.get_child_count() == 10)
	var cook_buttons: Array = find_buttons(ui._list)
	var enabled: int = 0
	for button: Button in cook_buttons:
		if not button.disabled:
			enabled += 1
	check("đồ khởi đầu (4 trứng gà) chỉ đủ nấu trứng ốp la", cook_buttons.size() == 10 and enabled == 1)
	await shot("cooking_ui.png")
	var egg: ItemData = db.get_item(&"trung_ga")
	var fried: ItemData = db.get_item(&"trung_op_la")
	var minutes_before: int = tm.hour * 60 + tm.minute
	var sizzle_before: int = int(am.play_counts.get(&"sizzle", 0))
	for button: Button in cook_buttons:
		if not button.disabled:
			button.pressed.emit()
	await wait(0.2)
	check("bấm Nấu: 2 trứng thành 1 trứng ốp la", player.inventory.count_of(egg) == 2 and player.inventory.count_of(fried) == 1)
	check("đồng hồ trôi 15 phút", tm.hour * 60 + tm.minute == minutes_before + 15)
	check("có tiếng xèo xèo", int(am.play_counts.get(&"sizzle", 0)) == sizzle_before + 1)
	check("báo kết quả màu xanh", ui._message_label.text.begins_with("Đã nấu xong 1 trứng ốp la"))
	check("nấu lần hai bằng hàm cook", ui.cook(load("res://data/recipes/trung_op_la.tres")) and player.inventory.count_of(egg) == 0 and player.inventory.count_of(fried) == 2)
	check("hết trứng: nấu tiếp bị từ chối, có báo lỗi", not ui.cook(load("res://data/recipes/trung_op_la.tres")) and ui._message_label.text.begins_with("Thiếu Trứng gà"))
	await wait(0.2)
	enabled = 0
	for button: Button in find_buttons(ui._list):
		if not button.disabled:
			enabled += 1
	check("hết nguyên liệu: mọi nút Nấu bị khoá", enabled == 0)
	await press_action("ui_cancel")
	check("Esc đóng bảng, Player cử động được, không mở menu tạm dừng", not ui.visible and not player.movement_locked and not main.pause_menu.visible)

	# Bán món cho cô Ba.
	var stall: Node = load("res://components/vendor/vendor_component.gd").new()
	stall.data = co_ba
	root.add_child(stall)
	tm.hour = 8
	var economy: Node = root.get_node("EconomyManager")
	var money: int = economy.money
	check("bán 2 trứng ốp la cho cô Ba: +%d đ" % (co_ba.get_sell_price(fried) * 2), stall.sell(fried, 2, player.inventory) == "" and economy.money == money + co_ba.get_sell_price(fried) * 2)
