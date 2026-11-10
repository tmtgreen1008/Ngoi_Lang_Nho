extends "res://tests/test_base.gd"
## Thể lực và tưới cây: StaminaManager (tốn, hồi, ngủ giường / thức khuya, lưu/nạp), cây chỉ lớn vào ngày được tưới,
## công cụ Tưới nước, việc đồng áng tốn sức và bị chặn khi kiệt sức, ăn đồ trong túi để hồi sức, thanh thể lực trên HUD.


func run() -> void:
	var tm: Node = root.get_node("TimeManager")
	var stamina: Node = root.get_node("StaminaManager")
	var bus: Node = root.get_node("EventBus")
	var db: Node = root.get_node("ItemDatabase")
	var sm: Node = root.get_node("SceneManager")
	var um: Node = root.get_node("UpgradeManager")
	tm.pause()
	tm.load_save_data({})
	um.clear()
	stamina.reset()

	# --- thể lực ---
	var changes: Array = []
	bus.stamina_changed.connect(func(current: int, maximum: int) -> void: changes.append([current, maximum]))
	check("bắt đầu đầy 100 thể lực", stamina.stamina == 100 and stamina.is_full())
	check("tốn 30 còn 70, có phát tín hiệu", stamina.spend(30) and stamina.stamina == 70 and changes.back() == [70, 100])
	check("không đủ sức thì không trừ", not stamina.spend(71) and stamina.stamina == 70)
	check("hồi quá tối đa thì chỉ tính phần thực sự hồi", stamina.restore(50) == 30 and stamina.stamina == 100)
	check("mức tốn: cuốc 3, gieo / tưới / thu hoạch / bón phân 1", stamina.get_cost(&"hoe") == 3 and stamina.get_cost(&"seed") == 1 and stamina.get_cost(&"water") == 1 and stamina.get_cost(&"harvest") == 1 and stamina.get_cost(&"fertilize") == 1 and stamina.get_cost(&"khong_co") == 0)
	stamina.spend(90)
	tm.sleep_until_morning()
	check("sang ngày mà không ngủ giường: chỉ hồi tới 50", stamina.stamina == 50)
	stamina.restore(30)
	tm.sleep_until_morning()
	check("đang 80 mà không ngủ giường: giữ nguyên 80", stamina.stamina == 80)
	stamina.spend(60)
	stamina.go_to_bed()
	tm.sleep_until_morning()
	check("ngủ giường: sáng dậy đầy 100", stamina.stamina == 100)
	stamina.spend(40)
	bus.day_changed.emit(tm.day)
	check("day_changed lặp lại cùng ngày (như khi nạp game) không hồi sức", stamina.stamina == 60)
	var saved: Dictionary = JSON.parse_string(JSON.stringify(stamina.get_save_data()))
	stamina.reset()
	stamina.load_save_data(saved)
	check("lưu/nạp giữ thể lực; bản lưu cũ thì đầy sức", stamina.stamina == 60)
	stamina.load_save_data({})
	check("bản lưu cũ (không có mục thể lực) nạp thành đầy sức", stamina.stamina == 100)

	# --- tưới cây (FarmField bật needs_water) ---
	tm.load_save_data({})
	var seed_item: CropItemData = db.get_item(&"hat_giong_lua") as CropItemData
	var field: Node = load("res://components/farming/farm_field.gd").new()
	field.needs_water = true
	root.add_child(field)
	var a := Vector2i(1, 1)
	var b := Vector2i(2, 1)
	check("mặc định FarmField không cần tưới (map nhà mới bật)", not load("res://components/farming/farm_field.gd").new().needs_water)
	check("chưa cuốc thì không tưới được", field.get_water_block_reason(a) == "Chỉ tưới được đất đã cuốc." and not field.water(a))
	field.till(a)
	field.till(b)
	field.plant(a, seed_item)
	field.plant(b, seed_item)
	check("tưới ô đã gieo", field.water(a) and field.get_plot(a).watered)
	check("tưới lần hai trong ngày bị từ chối", not field.water(a) and field.get_water_block_reason(a) == "Ô này hôm nay đã tưới rồi.")
	tm.sleep_until_morning()
	check("sang ngày: ô được tưới lớn 1 ngày, ô không tưới đứng yên", field.get_plot(a).days_grown == 1 and field.get_plot(b).days_grown == 0)
	check("sang ngày: đất khô lại", not field.get_plot(a).watered)
	tm.sleep_until_morning()
	check("ngày không tưới: cây không lớn thêm", field.get_plot(a).days_grown == 1)
	check("water_all tưới mọi ô đã cuốc chưa tưới", field.water_all() == 2 and field.water_all() == 0)
	var wet: Dictionary = JSON.parse_string(JSON.stringify(field.get_save_data()))
	var field2: Node = load("res://components/farming/farm_field.gd").new()
	field2.needs_water = true
	root.add_child(field2)
	field2.load_save_data(wet)
	check("lưu/nạp giữ trạng thái đã tưới", field2.get_plot(a).watered and field2.get_plot(b).watered)
	for day: int in 3:
		tm.sleep_until_morning()
	check("vườn đang trong cây (field) qua 3 ngày: chỉ ngày đã tưới được tính", field.get_plot(a).days_grown == 2 and field.get_plot(b).days_grown == 1)
	var field3: Node = load("res://components/farming/farm_field.gd").new()
	field3.needs_water = true
	root.add_child(field3)
	field3.load_save_data(wet)
	check("đi vắng 3 ngày rồi nạp lại: cũng chỉ lớn 1 ngày (ngày đã tưới)", field3.get_plot(a).days_grown == 2 and not field3.get_plot(a).watered)
	var free_field: Node = load("res://components/farming/farm_field.gd").new()
	root.add_child(free_field)
	free_field.till(a)
	free_field.plant(a, seed_item)
	tm.sleep_until_morning()
	check("vườn không bật needs_water: cây lớn theo ngày như cũ", free_field.get_plot(a).days_grown == 1)
	for node: Node in [field, field2, field3, free_field]:
		node.queue_free()

	# --- trong game ---
	tm.load_save_data({})
	var main: Node = await start_game()
	tm.pause()
	var player: Node = main.player
	var home: Node = sm.current_map
	var hud: Node = main.hud
	check("ván mới: đầy sức, HUD ghi 'Sức 100/100'", stamina.stamina == 100 and hud._stamina_label.text == "Sức 100/100" and hud._stamina_bar.value == 100.0)
	check("vườn ở sân nhà cần tưới", home.field.needs_water)
	var key := InputEventKey.new()
	key.keycode = KEY_5
	key.pressed = true
	home._unhandled_input(key)
	check("thanh công cụ có 5 ô, phím 5 chọn Tưới nước", home._tool_buttons.size() == 5 and home.controller.current_tool == 4 and home._tool_buttons[4].icon != null)
	var cell := Vector2i(2, 2)
	var spot := Vector2(192 + 48 * 2 + 24, 240 + 48 * 2 + 24)
	home.controller.set_tool(0)
	check("cuốc một ô tốn 3 sức", home.use_tool_at_world(spot) == 1 and stamina.stamina == 97 and home.field.get_plot(cell) != null)
	check("cuốc lại ô đã cuốc: không làm được gì nên không tốn sức", home.use_tool_at_world(spot) == 0 and stamina.stamina == 97)
	home.controller.set_tool(1)
	check("gieo hạt tốn 1 sức", home.use_tool_at_world(spot) == 1 and stamina.stamina == 96)
	home.controller.set_tool(4)
	check("tưới tốn 1 sức, ô vẽ đất ướt có hốc hạt", home.use_tool_at_world(spot) == 1 and stamina.stamina == 95 and home.field.get_plot(cell).watered and home.view._ground.get_cell_atlas_coords(cell) == home.view.FARMLAND_WET_SEEDED)
	check("Player làm động tác tưới", player.is_acting())
	check("HUD cập nhật theo thể lực", hud._stamina_label.text == "Sức 95/100")
	await shot("stamina_water.png")
	await wait(0.6)

	# Ngủ giường: hồi đầy; cây đã tưới lớn thêm 1 ngày.
	await travel("house_interior", &"from_home")
	player.position = Vector2(470, 440)
	await wait(0.3)
	await press_action("interact")
	check("ngủ giường: sang ngày 2, thể lực đầy lại", tm.day == 2 and stamina.stamina == 100)
	home = await travel("home", &"from_house")
	check("về sân nhà: cây đã tưới lớn 1 ngày, đất đã khô (luống thường)", home.field.get_plot(cell).days_grown == 1 and not home.field.get_plot(cell).watered and home.view._ground.get_cell_atlas_coords(cell) == home.view.FARMLAND_FURROWS)

	# Kiệt sức: không cuốc được; cụm nhiều ô chỉ làm số ô còn đủ sức.
	stamina.spend(98)
	home.controller.set_tool(0)
	var far := Vector2(192 + 48 * 5 + 24, 240 + 48 * 3 + 24)
	check("còn 2 sức: không cuốc được (cần 3), có báo mệt, không tốn sức", home.use_tool_at_world(far) == 0 and stamina.stamina == 2 and home.field.get_plot(Vector2i(5, 3)) == null and "mệt" in home._feedback_label.text)
	for x: int in [4, 5, 6]:
		home.field.till(Vector2i(x, 4))
	um.load_save_data({"tool": 2})
	home.controller.set_tool(4)
	var row := Vector2(192 + 48 * 5 + 24, 240 + 48 * 4 + 24)
	check("dụng cụ 3 ô nhưng chỉ còn 2 sức: tưới được đúng 2 ô", home.use_tool_at_world(row) == 2 and stamina.stamina == 0)
	check("hết sạch sức: không tưới thêm được", home.use_tool_at_world(row) == 0 and not home.field.get_plot(Vector2i(6, 4)).watered)
	check("thanh thể lực về 0", hud._stamina_label.text == "Sức 0/100" and hud._stamina_bar.value == 0.0)
	um.clear()

	# Ăn đồ trong túi để hồi sức.
	var rice: ItemData = db.get_item(&"com_trang")
	var seeds: ItemData = db.get_item(&"hat_giong_lua")
	check("cơm trắng ăn được (hồi 17), hạt giống thì không", rice.energy == 17 and seeds.energy == 0)
	player.inventory.sort_slots()
	player.inventory.add_item(rice, 2)
	var bag: Node = main.bag_screen
	await press_action("inventory")
	var rice_index: int = -1
	var seed_index: int = -1
	for i: int in player.inventory.slots.size():
		if not player.inventory.slots[i].is_empty():
			if player.inventory.slots[i].item == rice:
				rice_index = i
			elif player.inventory.slots[i].item == seeds:
				seed_index = i
	bag.select(seed_index)
	check("chọn hạt giống: không có nút Ăn", not bag._eat_button.visible and not bag.eat_selected())
	bag.select(rice_index)
	check("chọn cơm trắng: có nút 'Ăn (+17 sức)' và ghi chú ăn được", bag._eat_button.visible and bag._eat_button.text == "Ăn (+17 sức)" and "hồi 17 thể lực" in bag._description_label.text)
	bag._eat_button.pressed.emit()
	check("bấm Ăn: mất 1 cơm, hồi 17 sức", player.inventory.count_of(rice) == 1 and stamina.stamina == 17)
	await shot("stamina_eat.png")
	stamina.restore(100)
	check("đang đầy sức thì không ăn (không mất đồ)", not bag.eat_selected() and player.inventory.count_of(rice) == 1)
	bag.close()

	# Thức quá nửa đêm: sáng hôm sau chỉ hồi tới 50.
	stamina.spend(95)
	tm.hour = 23
	tm.minute = 50
	tm.advance_minutes(20)
	check("thức quá nửa đêm (không ngủ giường): sang ngày mới với 50 sức", tm.day == 3 and stamina.stamina == 50)

	# Lưu / nạp game giữ thể lực; ván mới đầy lại.
	var save: Node = root.get_node("SaveManager")
	stamina.spend(13)
	check("lưu game", save.save_game(&"test_stamina") == "")
	stamina.restore(100)
	check("nạp game", await save.load_game(&"test_stamina") == "")
	check("nạp game khôi phục thể lực 37", stamina.stamina == 37)
	DirAccess.remove_absolute(save.get_slot_path(&"test_stamina"))
	await wait(0.6)
	main.start_new_game()
	await wait(0.8)
	check("ván mới: thể lực đầy lại", stamina.stamina == 100)
