extends "res://tests/test_base.gd"
## Chăn nuôi: dữ liệu loài, LivestockPen (thả, cho ăn, đếm ngày, thu, lưu/nạp), LivestockController
## (thứ tự ưu tiên, kho đồ), tiệm tạp hóa bán con giống, chuồng ở khu nhà và được nhớ khi đổi map.


func _make_inventory(slots: int) -> Node:
	var inv: Node = load("res://components/inventory/inventory_component.gd").new()
	inv.slot_count = slots
	inv.owner_id = &"livestock_test"
	root.add_child(inv)
	return inv


func _make_pen(species: Resource, capacity: int) -> Node:
	var pen: Node = load("res://components/livestock/livestock_pen.gd").new()
	pen.species = species
	pen.capacity = capacity
	root.add_child(pen)
	return pen


func run() -> void:
	var tm: Node = root.get_node("TimeManager")
	var db: Node = root.get_node("ItemDatabase")
	var sm: Node = root.get_node("SceneManager")
	tm.pause()
	tm.load_save_data({})

	var hen: Resource = load("res://data/animals/ga.tres")
	var pig: Resource = load("res://data/animals/lon.tres")
	var lua: ItemData = db.get_item(&"cam_ga")  # thức ăn của gà là cám gà (biến giữ tên cũ)
	var egg: ItemData = db.get_item(&"trung_ga")
	var pork: ItemData = db.get_item(&"thit_lon")
	var chick: ItemData = db.get_item(&"ga_giong")
	var piglet: ItemData = db.get_item(&"lon_giong")

	# --- dữ liệu ---
	check("dữ liệu gà và lợn hợp lệ", hen.is_valid() and pig.is_valid())
	check("con giống, trứng, thịt lợn đã vào ItemDatabase", chick != null and piglet != null and egg != null and pork != null)
	check("các vật phẩm mới có icon", chick.icon != null and piglet.icon != null and pork.icon != null)
	var grocery: Resource = load("res://data/vendors/tap_hoa.tres")
	check("tiệm tạp hóa bán gà giống và lợn giống", grocery.fixed_items.has(chick) and grocery.fixed_items.has(piglet))
	check("gà đẻ mỗi ngày, lợn nuôi 5 ngày rồi xuất chuồng", hen.keeps_producing and hen.fed_days_per_product == 1 and not pig.keeps_producing and pig.fed_days_per_product == 5)

	# --- chuồng gà: thả, cho ăn, sang ngày, thu ---
	var coop: Node = _make_pen(hen, 2)
	check("chuồng trống", coop.get_count() == 0 and not coop.is_full())
	check("thả gà thứ nhất", coop.add_animal())
	check("thả gà thứ hai", coop.add_animal())
	check("chuồng đầy không thả thêm được", coop.is_full() and not coop.add_animal())
	check("hai con chưa ăn", coop.get_unfed_count() == 2)
	check("cho ăn chỉ 1 phần thức ăn thì 1 con ăn", coop.feed(1) == 1 and coop.get_unfed_count() == 1)
	check("cho ăn không có thức ăn thì không con nào ăn", coop.feed(0) == 0)
	tm.sleep_until_morning()
	check("sang ngày: con đã ăn thì có trứng, con nhịn thì không", coop.get_ready_count() == 1)
	check("sang ngày: trạng thái 'đã ăn' được đặt lại", coop.get_unfed_count() == 1)
	var batches: int = coop.collect()
	check("thu trứng: 1 con cho sản phẩm", batches == 1 and coop.get_ready_count() == 0)
	check("gà vẫn ở lại chuồng sau khi thu", coop.get_count() == 2)
	coop.feed(5)
	tm.sleep_until_morning()
	check("gà tiếp tục đẻ ngày sau", coop.get_ready_count() == 2)

	# --- lưu/nạp qua JSON, con vật không tiến triển khi nạp lại cùng ngày ---
	var saved: Dictionary = JSON.parse_string(JSON.stringify(coop.get_save_data()))
	var coop2: Node = _make_pen(hen, 2)
	coop2.load_save_data(saved)
	check("lưu/nạp giữ số con và sản phẩm chờ thu", coop2.get_count() == 2 and coop2.get_ready_count() == 2)
	tm.load_save_data(tm.get_save_data())
	check("nạp lại cùng ngày không làm con vật tiến thêm", coop2.get_ready_count() == 2)

	# --- chuồng lợn: nuôi 5 ngày rồi xuất chuồng, vắng mặt thì đứng yên ---
	var barn: Node = _make_pen(pig, 3)
	barn.add_animal()
	for day: int in 4:
		barn.feed(1)
		tm.sleep_until_morning()
	check("nuôi 4 ngày lợn chưa xuất chuồng được", barn.get_ready_count() == 0)
	barn.feed(1)
	tm.sleep_until_morning()
	check("đủ 5 ngày được cho ăn thì lợn sẵn sàng", barn.get_ready_count() == 1)
	check("thu hoạch: lợn rời chuồng", barn.collect() == 1 and barn.get_count() == 0)

	var barn2: Node = _make_pen(pig, 3)
	barn2.add_animal()
	barn2.feed(1)
	for day: int in 3:
		tm.sleep_until_morning()  # chỉ ngày đầu có cho ăn; hai ngày sau vắng mặt
	check("vắng mặt 3 ngày chỉ tính 1 ngày được ăn", barn2.get_save_data()["animals"][0]["days"] == 1)

	# --- controller: thứ tự ưu tiên và kho đồ ---
	var inv: Node = _make_inventory(4)
	var pen: Node = _make_pen(hen, 3)
	var controller: Node = load("res://components/livestock/livestock_controller.gd").new()
	controller.pen = pen
	root.add_child(controller)
	var messages: Array = []
	controller.feedback.connect(func(text: String, kind: StringName) -> void: messages.append([text, kind]))

	check("không có gì trong túi: không làm được gì, có gợi ý mua gà giống", not controller.interact(inv) and messages.back()[1] == &"info" and "Tạp Hóa" in messages.back()[0])
	inv.add_item(chick, 2)
	inv.add_item(lua, 1)
	check("thả gà giống vào chuồng", controller.interact(inv) and pen.get_count() == 1 and inv.count_of(chick) == 1)
	# Có con chưa ăn và có thức ăn thì cho ăn trước khi thả thêm (dù túi còn gà giống).
	check("ưu tiên cho ăn trước khi thả thêm", controller.interact(inv) and pen.get_count() == 1 and inv.count_of(lua) == 0 and pen.get_unfed_count() == 0 and inv.count_of(chick) == 1)
	check("hết thức ăn, còn con giống thì thả tiếp", controller.interact(inv) and pen.get_count() == 2 and inv.count_of(chick) == 0)
	check("hết việc: nhắc cần thức ăn", not controller.interact(inv) and "cám gà" in messages.back()[0])
	inv.add_item(lua, 5)
	check("cho ăn trừ đúng số lúa theo số con chưa ăn", controller.interact(inv) and inv.count_of(lua) == 4)
	tm.sleep_until_morning()
	check("sang ngày: cả hai con đã ăn nên đều có trứng", pen.get_ready_count() == 2)
	check("ưu tiên thu sản phẩm: 2 con x 3 trứng", controller.interact(inv) and inv.count_of(egg) == 6 and pen.get_ready_count() == 0)

	# Túi đầy thì không thu được và sản phẩm không mất.
	var full: Node = _make_inventory(1)
	full.add_item(lua, 99)
	var pen_full: Node = _make_pen(hen, 1)
	var controller_full: Node = load("res://components/livestock/livestock_controller.gd").new()
	controller_full.pen = pen_full
	root.add_child(controller_full)
	pen_full.add_animal()
	pen_full.feed(1)
	tm.sleep_until_morning()
	check("túi đầy: không thu được, trứng vẫn chờ", not controller_full.interact(full) and pen_full.get_ready_count() == 1)

	# Chuồng đầy thì không thả thêm.
	var small: Node = _make_pen(hen, 1)
	small.add_animal()
	var controller_small: Node = load("res://components/livestock/livestock_controller.gd").new()
	controller_small.pen = small
	root.add_child(controller_small)
	var inv_small: Node = _make_inventory(2)
	inv_small.add_item(chick, 1)
	check("chuồng đầy: giữ nguyên con giống trong túi", not controller_small.interact(inv_small) and inv_small.count_of(chick) == 1)

	# --- trong game: chuồng ở khu nhà, tương tác bằng phím E, được nhớ khi đổi map ---
	tm.load_save_data({})
	var main: Node = await start_game()
	tm.pause()
	var player: Node = main.player
	var home: Node = sm.current_map
	check("khu nhà có chuồng gà và chuồng lợn", home.coop != null and home.barn != null and home.coop.species == hen and home.barn.species == pig)
	check("hai chuồng không đè lên nhau và nằm trong vùng chơi", home.coop.position.distance_to(home.barn.position) > 120.0 and home.playable_rect.has_point(home.coop.position) and home.playable_rect.has_point(home.barn.position))
	check("chuồng có vùng tương tác", home.coop.interactable != null and home.coop.interactable.can_interact())

	player.inventory.add_item(chick, 1)
	player.position = home.coop.position + Vector2(0, 14)
	await wait(0.3)
	check("đứng gần chuồng thì nhắm được chuồng", player.get_target() == home.coop.interactable)
	check("lời nhắc là thả con giống", "Thả con giống" in home.coop.interactable.prompt_text)
	await press_action("interact")
	check("bấm E thả gà vào chuồng", home.coop.pen.get_count() == 1 and player.inventory.count_of(chick) == 0)
	check("con vật hiện trên màn hình", home.coop.get_node("Animals").get_child_count() == 1)
	check("lời nhắc đổi sau khi thả (chưa có lúa)", "Thả con giống" not in home.coop.interactable.prompt_text)
	# Gà dùng sheet hoạt ảnh (4x3 khung): khung đổi theo thời gian, lấy từ chu kỳ đứng/mổ/bước.
	var hen_sprite: Sprite2D = home.coop.get_node("Animals").get_child(0)
	check("gà dùng sheet hoạt ảnh 4x3", hen_sprite.hframes == 4 and hen_sprite.vframes == 3 and String(hen_sprite.texture.resource_path).ends_with("anim_chicken.png"))
	var seen_frames: Dictionary = {}
	for i: int in 16:
		seen_frames[hen_sprite.frame_coords.x] = true
		await wait(0.3)
	check("gà cử động: thấy cả khung đứng, mổ và bước", seen_frames.has(1) and seen_frames.has(3) and (seen_frames.has(0) or seen_frames.has(2)) and hen_sprite.frame_coords.y == 0)
	# Hàng rào vườn mới: 8 đoạn tre liền nhau, dài đúng bằng bề ngang vườn.
	var fence_count: int = 0
	for child: Node in home.get_children():
		if child is Sprite2D and child.texture != null and String(child.texture.resource_path).ends_with("fences_a.png"):
			fence_count += 1
	check("hàng rào tre mới: 8 đoạn dọc mép nam của vườn", fence_count == 8)
	await shot("livestock_coop.png")

	# Cho ăn rồi đi vắng: chuồng được nhớ và con vật vẫn ở đó.
	player.inventory.add_item(lua, 1)
	await press_action("interact")
	check("bấm E cho gà ăn", player.inventory.count_of(lua) == 0 and home.coop.pen.get_unfed_count() == 0)
	travel("grocery_store")
	await wait(1.0)
	check("sang Tiệm Tạp Hóa", sm.current_scene_path.ends_with("grocery_store.tscn"))
	tm.sleep_until_morning()
	travel("home", &"from_village")
	await wait(1.0)
	var home2: Node = sm.current_map
	check("về nhà: chuồng gà vẫn còn con vật", sm.current_scene_path.ends_with("home.tscn") and home2.coop.pen.get_count() == 1)
	check("con gà đã ăn trước khi đi nên có trứng", home2.coop.pen.get_ready_count() == 1)
	check("có dấu hiệu sản phẩm trên chuồng", home2.coop.get_node("ProductMarker").visible)
	await shot("livestock_ready.png")
	player.position = home2.coop.position + Vector2(0, 14)
	await wait(0.3)
	var eggs_before: int = player.inventory.count_of(egg)
	await press_action("interact")
	check("bấm E thu 3 trứng", player.inventory.count_of(egg) == eggs_before + 3 and not home2.coop.get_node("ProductMarker").visible)

	# Lưu game giữ chuồng.
	var wsm: Node = root.get_node("WorldStateManager")
	wsm.capture("res://maps/home/home.tscn")
	var data: Dictionary = JSON.parse_string(JSON.stringify(wsm.get_save_data()))
	var home_state: Dictionary = data.get("res://maps/home/home.tscn", {})
	check("trạng thái hai chuồng nằm trong dữ liệu lưu của map nhà", home_state.has("coop") and home_state.has("barn") and home_state.has("farm_field"))
