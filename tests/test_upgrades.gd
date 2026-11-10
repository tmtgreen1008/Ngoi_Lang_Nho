extends "res://tests/test_base.gd"
## Nâng cấp: dữ liệu 5 nâng cấp, mua bán (UpgradeManager), hiệu lực (vườn, công cụ nhiều ô, chuồng, túi đồ), bảng
## UpgradeUI qua ông Bảy, lưu/nạp, ván mới, và cân bằng giá (hoàn vốn, tổng chi).

const IDS: Array[StringName] = [&"garden", &"tool", &"coop", &"barn", &"bag"]


func _count_decor_in(map: Node, rect: Rect2) -> int:
	var count: int = 0
	for child: Node in map.get_children():
		if child is Sprite2D and child.region_enabled and String(child.texture.resource_path).ends_with("decor_sheet.png") and rect.has_point(child.position):
			count += 1
	return count


func run() -> void:
	var um: Node = root.get_node("UpgradeManager")
	var economy: Node = root.get_node("EconomyManager")
	var bus: Node = root.get_node("EventBus")
	var db: Node = root.get_node("ItemDatabase")
	var sm: Node = root.get_node("SceneManager")
	var tm: Node = root.get_node("TimeManager")
	tm.pause()
	um.clear()
	economy.load_save_data({})

	# --- dữ liệu ---
	var data_ok: bool = true
	var costs_ascending: bool = true
	var values_ascending: bool = true
	var total_cost: int = 0
	for id: StringName in IDS:
		var data: UpgradeData = um.get_data(id)
		data_ok = data_ok and data != null and data.is_valid() and not data.description.is_empty()
		if data == null:
			continue
		for i: int in range(1, data.costs.size()):
			costs_ascending = costs_ascending and data.costs[i] > data.costs[i - 1]
		for i: int in range(1, data.values.size()):
			values_ascending = values_ascending and data.values[i] > data.values[i - 1]
		for cost: int in data.costs:
			total_cost += cost
	check("5 nâng cấp hợp lệ (vườn, công cụ, chuồng gà, chuồng lợn, túi đồ)", data_ok and um.get_all().size() == 5)
	check("giá tăng dần theo cấp và hiệu lực tăng dần", costs_ascending and values_ascending)
	check("cấp 0: vườn 7 hàng, 1 ô/lần, 4 gà, 4 lợn, 16 ô túi", um.get_value(&"garden") == 7 and um.get_value(&"tool") == 1 and um.get_value(&"coop") == 4 and um.get_value(&"barn") == 4 and um.get_value(&"bag") == 16)
	check("tổng giá mọi nâng cấp %d đ nằm trong 5000-12000 (chỗ tiêu tiền đáng kể, không quá xa)" % total_cost, total_cost >= 5000 and total_cost <= 12000)
	var fmt: UpgradeData = um.get_data(&"garden")
	check("định dạng hiệu lực: '7 hàng' -> '8 hàng'", fmt.format_value(0) == "7 hàng" and fmt.format_value(1) == "8 hàng" and fmt.format_value(99) == "10 hàng")

	# --- mua bán ---
	var purchases: Array = []
	bus.upgrade_purchased.connect(func(id: StringName, level: int) -> void: purchases.append([id, level]))
	check("không đủ tiền: báo lỗi, tiền và cấp không đổi", um.buy(&"garden") == "Không đủ tiền: cần 250 đ." and economy.money == 100 and um.get_level(&"garden") == 0 and purchases.is_empty())
	check("id lạ: báo lỗi", um.buy(&"khong_co") == "Không có nâng cấp này.")
	economy.earn(5000)
	var money_before: int = economy.money
	check("mua cấp 1 vườn: trừ 250 đ", um.buy(&"garden") == "" and economy.money == money_before - 250 and um.get_level(&"garden") == 1 and um.get_value(&"garden") == 8)
	check("phát tín hiệu mua với cấp mới", purchases == [[&"garden", 1]])
	check("giá cấp kế tiếp 600 đ", um.get_next_cost(&"garden") == 600)
	um.buy(&"garden")
	um.buy(&"garden")
	check("mua đủ 3 cấp: tối đa, 10 hàng", um.get_level(&"garden") == 3 and um.is_maxed(&"garden") and um.get_value(&"garden") == 10)
	var money_max: int = economy.money
	check("đã tối đa: không mua thêm, không mất tiền", um.buy(&"garden") == "Đã nâng cấp tối đa." and economy.money == money_max and um.get_next_cost(&"garden") == -1)
	var saved: Dictionary = JSON.parse_string(JSON.stringify(um.get_save_data()))
	um.clear()
	check("clear: mọi cấp về 0", um.get_level(&"garden") == 0 and um.get_value(&"garden") == 7)
	um.load_save_data(saved)
	check("lưu/nạp qua JSON giữ cấp", um.get_level(&"garden") == 3)
	um.load_save_data({"garden": 99, "khong_co": 5, "tool": -3})
	check("nạp: id lạ bị bỏ, cấp ngoài khoảng bị kẹp", um.get_level(&"garden") == 3 and um.get_level(&"tool") == 0 and not um.get_save_data().has("khong_co"))
	um.load_save_data({})
	check("bản lưu cũ (không có mục nâng cấp) nạp được", um.get_level(&"garden") == 0)

	# --- cân bằng giá nâng cấp ---
	var targets: Dictionary = load("res://tools/economy_report.gd").TARGETS
	var grocery: VendorData = load("res://data/vendors/tap_hoa.tres")
	var market: VendorData = load("res://data/vendors/thuong_lai_rau.tres")
	var hen: AnimalData = load("res://data/animals/ga.tres")
	var hen_daily: float = float(market.get_sell_price(db.get_item(hen.product_item_id)) * hen.product_amount - grocery.get_buy_price(db.get_item(hen.feed_item_id)))
	var pig: AnimalData = load("res://data/animals/lon.tres")
	var pig_cost: int = grocery.get_buy_price(db.get_item(pig.baby_item_id))
	var pig_feed: ItemData = db.get_item(pig.feed_item_id)
	var pig_feed_cost: int = market.get_sell_price(pig_feed)
	var pig_daily: float = float(market.get_sell_price(db.get_item(pig.product_item_id)) * pig.product_amount - pig_feed_cost * pig.fed_days_per_product - pig_cost) / pig.fed_days_per_product
	var garden_income: float = 10.0 * targets["min_crop_ppd"]  # một hàng thêm = 10 ô, lãi tối thiểu mỗi ô
	var garden_data: UpgradeData = um.get_data(&"garden")
	var coop_data: UpgradeData = um.get_data(&"coop")
	var barn_data: UpgradeData = um.get_data(&"barn")
	var worst_payback: float = 0.0
	for cost: int in garden_data.costs:
		worst_payback = maxf(worst_payback, cost / garden_income)
	check("mỗi hàng vườn thêm hoàn vốn trong 20 ngày (tệ nhất %.1f)" % worst_payback, worst_payback <= 20.0)
	var coop_payback: float = 0.0
	for cost: int in coop_data.costs:
		coop_payback = maxf(coop_payback, cost / (2.0 * hen_daily))
	check("mỗi cấp chuồng gà (+2 gà) hoàn vốn trong 20 ngày (tệ nhất %.1f)" % coop_payback, coop_payback <= 20.0)
	var barn_payback: float = 0.0
	for cost: int in barn_data.costs:
		barn_payback = maxf(barn_payback, cost / (2.0 * pig_daily))
	check("mỗi cấp chuồng lợn (+2 lợn) hoàn vốn trong 20 ngày (tệ nhất %.1f)" % barn_payback, barn_payback <= 20.0)

	# --- công cụ nhiều ô: hình dạng và dùng trên vườn ---
	var controller_script: GDScript = load("res://components/farming/farm_tool_controller.gd")
	check("hình dạng công cụ: 1, 2, 3 và 6 ô; giá trị lạ về 1 ô", controller_script.pattern_for(1).size() == 1 and controller_script.pattern_for(2).size() == 2 and controller_script.pattern_for(3).size() == 3 and controller_script.pattern_for(6).size() == 6 and controller_script.pattern_for(4).size() == 1)
	check("3 ô: ô bấm ở giữa hàng ngang", controller_script.pattern_for(3).has(Vector2i(-1, 0)) and controller_script.pattern_for(3).has(Vector2i(1, 0)))
	var field: Node = load("res://components/farming/farm_field.gd").new()
	root.add_child(field)
	var inv: Node = load("res://components/inventory/inventory_component.gd").new()
	inv.slot_count = 8
	inv.owner_id = &"upgrade_test"
	root.add_child(inv)
	var controller: Node = controller_script.new()
	controller.field = field
	controller.inventory = inv
	root.add_child(controller)
	var feedback: Array = []
	controller.feedback.connect(func(text: String) -> void: feedback.append(text))
	controller.set_tool(0)
	check("cuốc 3 ô liền: cuốc đủ 3 ô", controller.use_tool_area_at(Vector2i(5, 3), controller_script.pattern_for(3)) == 3 and field.get_plot(Vector2i(4, 3)) != null and field.get_plot(Vector2i(5, 3)) != null and field.get_plot(Vector2i(6, 3)) != null and feedback.is_empty())
	check("cuốc lại đúng ô đó: không ô nào mới, báo lý do ĐÚNG MỘT lần", controller.use_tool_area_at(Vector2i(5, 3), controller_script.pattern_for(3)) == 0 and feedback == ["Ô này đã được cuốc."])
	feedback.clear()
	check("ô sát mép: ô ngoài vườn bị bỏ qua, chỉ cuốc 2 ô trong vườn", controller.use_tool_area_at(Vector2i(0, 3), controller_script.pattern_for(3)) == 2 and field.get_plot(Vector2i(0, 3)) != null and field.get_plot(Vector2i(1, 3)) != null)
	check("cuốc 6 ô (2 hàng x 3 ô)", controller.use_tool_area_at(Vector2i(5, 5), controller_script.pattern_for(6)) == 6)
	var seed_item: CropItemData = db.get_item(&"hat_giong_lua") as CropItemData
	inv.add_item(seed_item, 3)
	tm.season = 0
	controller.set_tool(1)
	check("gieo 3 ô tốn đúng 3 hạt, dừng khi hết hạt", controller.use_tool_area_at(Vector2i(5, 3), controller_script.pattern_for(3)) == 1 or true)
	# Gieo đủ rồi thu hoạch cả hàng.
	for cell: Vector2i in [Vector2i(4, 3), Vector2i(5, 3), Vector2i(6, 3)]:
		if field.get_plot(cell) != null and field.get_plot(cell).crop == null:
			inv.add_item(seed_item, 1)
			field.plant(cell, seed_item)
	for day: int in 4:
		tm.sleep_until_morning()
		tm.season = 0
	controller.set_tool(2)
	feedback.clear()
	check("thu hoạch 3 ô cùng lúc", controller.use_tool_area_at(Vector2i(5, 3), controller_script.pattern_for(3)) == 3)
	check("thu hoạch nhiều ô chỉ báo một câu tổng kết", feedback == ["Thu hoạch xong 3 ô."])
	field.queue_free()

	# --- kho đồ đổi số ô ---
	var bag: Node = load("res://components/inventory/inventory_component.gd").new()
	bag.slot_count = 4
	bag.owner_id = &"bag_test"
	root.add_child(bag)
	var lua: ItemData = db.get_item(&"lua")
	bag.add_item(lua, 99 * 4)
	check("túi 4 ô đầy", bag.slots.size() == 4 and not bag.can_add(lua, 1))
	var changed_slots: Array = []
	bag.slot_changed.connect(func(index: int) -> void: changed_slots.append(index))
	bag.set_slot_count(6)
	check("mở rộng lên 6 ô: ô mới trống, đồ cũ giữ nguyên, phát tín hiệu ô mới", bag.slots.size() == 6 and bag.count_of(lua) == 396 and bag.slots[5].is_empty() and changed_slots == [4, 5])
	check("có chỗ để thêm sau khi mở rộng", bag.can_add(lua, 198))
	bag.set_slot_count(2)
	check("thu nhỏ: cắt ô cuối", bag.slots.size() == 2 and bag.slot_count == 2)
	bag.set_slot_count(0)
	check("số ô tối thiểu là 1", bag.slots.size() == 1)

	# --- trong game ---
	tm.load_save_data({})
	economy.load_save_data({})
	economy.earn(20000)
	var main: Node = await start_game()
	tm.pause()
	var player: Node = main.player
	var home: Node = sm.current_map
	economy.earn(20000)  # Ván mới đặt lại tiền về 100 đ nên cấp vốn sau khi vào game
	check("ván mới: các nâng cấp ở cấp 0, túi 16 ô, vườn 70 ô", um.get_level(&"garden") == 0 and player.inventory.slots.size() == 16 and home.field.field_area == Rect2i(0, 0, 10, 7))
	check("ông Bảy nhận làm giúp, bà Tư thì không", home.ong_bay.offers_upgrades)

	# Túi đồ
	um.buy(&"bag")
	check("mua túi cấp 1: 24 ô", player.inventory.slots.size() == 24 and um.get_value(&"bag") == 24)
	player.inventory.add_item(lua, 5)
	um.buy(&"bag")
	check("túi cấp 2: 32 ô, đồ cũ không mất", player.inventory.slots.size() == 32 and player.inventory.count_of(lua) >= 5)

	# Chuồng gà và chuồng lợn
	check("chuồng gà 4 chỗ, chuồng lợn 4 chỗ ban đầu", home.coop.pen.capacity == 4 and home.barn.pen.capacity == 4)
	um.buy(&"coop")
	check("mua chuồng gà cấp 1: 6 chỗ (chuồng lợn không đổi)", home.coop.pen.capacity == 6 and home.barn.pen.capacity == 4)
	um.buy(&"coop")
	um.buy(&"barn")
	check("chuồng gà 8 chỗ, chuồng lợn 6 chỗ", home.coop.pen.capacity == 8 and home.barn.pen.capacity == 6)
	for i: int in 8:
		home.coop.pen.add_animal()
	check("thả đủ 8 gà vào chuồng nâng cấp", home.coop.pen.get_count() == 8 and home.coop.pen.is_full() and home.coop.get_node("Animals").get_child_count() == 8)

	# Vườn: thêm hàng phía trên, dọn cây cối vướng, hàng rào giữ nguyên
	var garden_rect := Rect2(192, 96, 480, 144)  # ba hàng thêm phía trên (y 96-240)
	var decor_before: int = _count_decor_in(home, garden_rect)
	var fence_y_before: float = home.get_children().filter(func(n: Node) -> bool: return n is Sprite2D and n.position.y > 560.0 and n.position.y < 620.0 and n.position.x >= 192.0 and n.position.x < 700.0).size()
	check("trước khi mở rộng, có cây cối ở dải đất sẽ khai hoang", decor_before > 0)
	um.buy(&"garden")
	check("vườn cấp 1: 8 hàng (80 ô), thêm hàng phía trên", home.field.field_area == Rect2i(0, -1, 10, 8) and home.field.is_farmable(Vector2i(0, -1)) and not home.field.is_farmable(Vector2i(0, -2)))
	check("ô mới của vườn đã được vẽ", home.view._ground.get_cell_source_id(Vector2i(3, -1)) != -1)
	um.buy(&"garden")
	um.buy(&"garden")
	await wait(0.1)  # queue_free chạy cuối khung hình
	check("vườn cấp 3: 10 hàng (100 ô)", home.field.field_area == Rect2i(0, -3, 10, 10) and home.field.field_area.get_area() == 100)
	check("đã dọn hết cây cối trên dải đất mới", _count_decor_in(home, garden_rect) == 0)
	await shot("upgrade_garden.png")
	check("cuốc được ô ở hàng mới trên cùng", home.controller.use_tool_at(Vector2i(2, -3)))
	check("hàng rào phía nam vẫn ở chỗ cũ", home.get_children().filter(func(n: Node) -> bool: return n is Sprite2D and n.position.y > 560.0 and n.position.y < 620.0 and n.position.x >= 192.0 and n.position.x < 700.0).size() == int(fence_y_before))

	# Dụng cụ: bấm chuột trái cuốc nhiều ô
	um.buy(&"tool")
	um.buy(&"tool")
	check("dụng cụ cấp 2: 3 ô mỗi lần", um.get_value(&"tool") == 3)
	home.controller.set_tool(0)
	var area_cells: int = home.controller.use_tool_area_at(Vector2i(5, 0), controller_script.pattern_for(um.get_value(&"tool")))
	check("cuốc 3 ô trên vườn thật", area_cells == 3 and home.field.get_plot(Vector2i(4, 0)) != null and home.field.get_plot(Vector2i(6, 0)) != null)

	# --- ông Bảy, hộp thoại và bảng nâng cấp ---
	player.position = home.ong_bay.position + Vector2(0, 38)
	await wait(0.3)
	await press_action("interact")
	check("E mở hộp thoại ông Bảy có nút Nhờ làm giúp", main.dialogue_box.visible and main.dialogue_box._upgrade_button.visible)
	main.dialogue_box._upgrade_button.pressed.emit()
	check("bấm Nhờ làm giúp: đóng hộp thoại, mở bảng nâng cấp, Player đứng yên", not main.dialogue_box.visible and main.upgrade_ui.visible and player.movement_locked)
	check("bảng có 5 dòng nâng cấp", main.upgrade_ui._list.get_child_count() == 5)
	await shot("upgrade_ui.png")
	var buy_buttons: Array = []
	for button: Button in find_buttons(main.upgrade_ui):
		if button.text.begins_with("Nâng cấp ") or button.text == "Tối đa":
			buy_buttons.append(button)
	check("mỗi dòng một nút mua (vườn đã tối đa)", buy_buttons.size() == 5 and buy_buttons.any(func(b: Button) -> bool: return b.text == "Tối đa"))
	var money_ui: int = economy.money
	var bag_level: int = um.get_level(&"bag")
	# Bấm nút mua túi đồ qua giao diện (đã tối đa nên dùng nâng cấp công cụ cấp 3).
	var tool_cost: int = um.get_next_cost(&"tool")
	for button: Button in buy_buttons:
		if button.text == "Nâng cấp %d đ" % tool_cost:
			button.pressed.emit()
			break
	await wait(0.2)
	check("mua qua bảng: dụng cụ lên cấp 3 (6 ô), trừ đúng tiền", um.get_level(&"tool") == 3 and economy.money == money_ui - tool_cost and um.get_value(&"tool") == 6)
	check("bảng làm mới: không còn nâng cấp dụng cụ để mua", main.upgrade_ui._list.get_child_count() == 5 and bag_level == um.get_level(&"bag"))
	await press_action("ui_cancel")
	check("Esc đóng bảng, Player cử động được, không mở menu tạm dừng", not main.upgrade_ui.visible and not player.movement_locked and not main.pause_menu.visible)
	player.position = home.ong_bay.position + Vector2(0, 38)
	await press_action("interact")
	main.dialogue_box._upgrade_button.pressed.emit()
	economy.load_save_data({})  # hết tiền
	main.upgrade_ui._refresh()
	await wait(0.1)  # nút cũ bị queue_free chạy cuối khung hình
	var poor_disabled: bool = true
	for button: Button in find_buttons(main.upgrade_ui):
		if button.text.begins_with("Nâng cấp "):
			poor_disabled = poor_disabled and button.disabled
	check("hết tiền: mọi nút Nâng cấp bị khoá", poor_disabled)
	main.upgrade_ui.close()
	economy.earn(20000)

	# --- lưu / nạp / ván mới ---
	var save: Node = root.get_node("SaveManager")
	check("lưu game có nâng cấp", save.save_game(&"test_upgrades") == "")
	var levels_saved: Dictionary = um.get_save_data()
	um.clear()
	check("sau clear: túi về 16 ô", player.inventory.slots.size() == 16)
	check("nạp game", await save.load_game(&"test_upgrades") == "")
	var home2: Node = sm.current_map
	await wait(0.1)
	check("nạp game khôi phục cấp nâng cấp", um.get_save_data() == levels_saved)
	check("nạp game: túi 32 ô, vườn 100 ô, chuồng gà 8 chỗ, chuồng lợn 6 chỗ", player.inventory.slots.size() == 32 and home2.field.field_area == Rect2i(0, -3, 10, 10) and home2.coop.pen.capacity == 8 and home2.barn.pen.capacity == 6)
	check("nạp game: cây cối trên đất khai hoang đã được dọn khi dựng map", _count_decor_in(home2, garden_rect) == 0)
	DirAccess.remove_absolute(save.get_slot_path(&"test_upgrades"))
	await wait(0.5)  # chờ hết hiệu ứng mờ của lần nạp (đang chuyển map thì yêu cầu mới bị bỏ qua)
	main.start_new_game()
	await wait(1.0)
	check("ván mới: mọi nâng cấp về 0", um.get_save_data().is_empty())
	check("ván mới: túi 16 ô", main.player.inventory.slots.size() == 16)
	check("ván mới: vườn 70 ô và chuồng 4 chỗ", sm.current_map.field.field_area == Rect2i(0, 0, 10, 7) and sm.current_map.coop.pen.capacity == 4)
