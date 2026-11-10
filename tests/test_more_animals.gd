extends "res://tests/test_base.gd"
## Vịt, trâu, chó: dữ liệu và giá (vịt đẻ trứng, trâu cho phân bón), phân bón (bón, thu hoạch thêm, lưu/nạp, công cụ
## số 4), ao vịt và máng trâu ở sân nhà, chó Vàng (đi dạo, vuốt ve nhận quà mỗi ngày một lần).


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
	var bus: Node = root.get_node("EventBus")
	tm.pause()
	tm.load_save_data({})

	# --- dữ liệu ---
	var duck: AnimalData = load("res://data/animals/vit.tres")
	var buffalo: AnimalData = load("res://data/animals/trau.tres")
	var grocery: VendorData = load("res://data/vendors/tap_hoa.tres")
	var market: VendorData = load("res://data/vendors/thuong_lai_rau.tres")
	var duckling: ItemData = db.get_item(&"vit_giong")
	var calf: ItemData = db.get_item(&"trau_giong")
	var duck_egg: ItemData = db.get_item(&"trung_vit")
	var fertilizer: ItemData = db.get_item(&"phan_bon")
	var greens: ItemData = db.get_item(&"rau_muong")
	check("dữ liệu vịt và trâu hợp lệ", duck.is_valid() and buffalo.is_valid())
	check("vật phẩm mới có trong ItemDatabase và có icon", duckling != null and calf != null and duck_egg != null and fertilizer != null and duckling.icon != null and calf.icon != null and duck_egg.icon != null and fertilizer.icon != null)
	check("Tạp Hóa bán vịt giống và nghé", grocery.fixed_items.has(duckling) and grocery.fixed_items.has(calf))
	check("vịt ăn rau muống, đẻ 2 trứng vịt mỗi ngày; trâu ăn rau muống, cho 1 phân bón mỗi ngày", duck.feed_item_id == &"rau_muong" and duck.product_item_id == &"trung_vit" and duck.product_amount == 2 and buffalo.product_item_id == &"phan_bon" and buffalo.product_amount == 1 and buffalo.keeps_producing)
	var duck_daily: float = float(market.get_sell_price(duck_egg) * duck.product_amount - market.get_sell_price(greens))
	check("vịt lãi mỗi ngày (%.0f đ) và hoàn vốn trong 8 ngày" % duck_daily, duck_daily > 0.0 and grocery.get_buy_price(duckling) / duck_daily <= 8.0)
	check("trứng vịt bán được giá hơn trứng gà", market.get_sell_price(duck_egg) > market.get_sell_price(db.get_item(&"trung_ga")))
	check("Chợ thu mua trứng vịt, không thu mua phân bón", market.accepts(duck_egg) and not market.accepts(fertilizer))
	for sheet: String in ["anim_duck", "anim_buffalo", "anim_dog"]:
		check("có sheet hoạt ảnh %s" % sheet, ResourceLoader.exists("res://assets/art/characters/%s.png" % sheet))

	# --- chuồng: vịt đẻ trứng, trâu cho phân bón ---
	var pond: Node = _make_pen(duck, 4)
	pond.add_animal()
	pond.feed(1)
	tm.sleep_until_morning()
	check("vịt được cho ăn thì hôm sau có trứng", pond.get_ready_count() == 1 and pond.collect() == 1 and pond.get_count() == 1)
	var post: Node = _make_pen(buffalo, 1)
	check("máng trâu chỉ buộc được 1 con", post.add_animal() and not post.add_animal())
	post.feed(1)
	tm.sleep_until_morning()
	check("trâu được cho ăn thì hôm sau có phân bón, trâu ở lại", post.get_ready_count() == 1 and post.collect() == 1 and post.get_count() == 1)

	# --- phân bón trên vườn ---
	tm.load_save_data({})
	var field: Node = load("res://components/farming/farm_field.gd").new()
	root.add_child(field)
	var inv: Node = load("res://components/inventory/inventory_component.gd").new()
	inv.slot_count = 8
	inv.owner_id = &"animals_test"
	root.add_child(inv)
	var controller: Node = load("res://components/farming/farm_tool_controller.gd").new()
	controller.field = field
	controller.inventory = inv
	root.add_child(controller)
	var feedback: Array = []
	controller.feedback.connect(func(text: String) -> void: feedback.append(text))
	var seed_item: CropItemData = db.get_item(&"hat_giong_lua") as CropItemData
	var lua: ItemData = db.get_item(&"lua")
	var a := Vector2i(1, 1)
	var b := Vector2i(2, 1)
	check("công cụ thứ tư là Bón phân", controller.TOOL_NAMES.size() == 4 and controller.TOOL_NAMES[3] == "Bón phân")
	check("ô trống không bón được", field.get_fertilize_block_reason(a) == "Chỉ bón phân cho ô đang có cây." and not field.fertilize(a))
	for cell: Vector2i in [a, b]:
		field.till(cell)
		field.plant(cell, seed_item)
	controller.set_tool(3)
	check("không có phân bón trong túi: báo lý do", not controller.use_tool_at(a) and feedback.back().begins_with("Không có phân bón"))
	inv.add_item(fertilizer, 2)
	check("bón phân: tốn 1 phân bón, ô được đánh dấu", controller.use_tool_at(a) and inv.count_of(fertilizer) == 1 and field.get_plot(a).fertilized)
	check("bón lần hai lên cùng cây bị từ chối, không tốn phân", not controller.use_tool_at(a) and inv.count_of(fertilizer) == 1 and feedback.back() == "Cây này đã được bón phân.")
	check("số nông sản dự kiến: ô bón 4, ô thường 3", field.get_harvest_amount(a) == 4 and field.get_harvest_amount(b) == 3 and field.get_harvest_amount(Vector2i(5, 5)) == 0)
	var saved: Dictionary = JSON.parse_string(JSON.stringify(field.get_save_data()))
	var field2: Node = load("res://components/farming/farm_field.gd").new()
	root.add_child(field2)
	field2.load_save_data(saved)
	check("lưu/nạp giữ trạng thái đã bón", field2.get_plot(a).fertilized and not field2.get_plot(b).fertilized)
	field2.load_save_data({"plots": [{"x": 0, "y": 0, "crop": "hat_giong_lua", "days": 1}]})
	check("bản lưu cũ (không có mục phân bón) nạp được", not field2.get_plot(Vector2i(0, 0)).fertilized)
	field2.queue_free()
	for day: int in 4:
		tm.sleep_until_morning()
	controller.set_tool(2)
	check("thu hoạch ô đã bón được 4 lúa (thêm 1)", controller.use_tool_at(a) and inv.count_of(lua) == 4)
	check("thu hoạch ô thường được 3 lúa", controller.use_tool_at(b) and inv.count_of(lua) == 7)
	check("thu hoạch xong ô hết trạng thái bón", not field.get_plot(a).fertilized)
	field.plant(a, seed_item)
	check("cây mới trồng lại chưa được bón", field.get_harvest_amount(a) == 3)
	field.queue_free()

	# --- chó Vàng: quà theo ngày ---
	var dog_script: GDScript = load("res://entities/pet/pet_dog.gd")
	var gifts_valid: bool = true
	var distinct: Dictionary = {}
	for season: int in 4:
		for day: int in range(1, 15):
			var gift: ItemData = dog_script.gift_for_day(day, season)
			gifts_valid = gifts_valid and gift is CropItemData and (gift as CropItemData).can_plant_in(season)
			distinct[gift.id] = true
	check("quà của chó luôn là hạt giống gieo được trong mùa đó", gifts_valid)
	check("quà thay đổi theo ngày (nhiều loại hạt)", distinct.size() >= 6)
	check("cùng ngày cùng mùa thì cùng món", dog_script.gift_for_day(5, 1) == dog_script.gift_for_day(5, 1))

	# --- trong game ---
	tm.load_save_data({})
	var main: Node = await start_game()
	tm.pause()
	var player: Node = main.player
	var home: Node = sm.current_map
	check("sân nhà có ao vịt (4 chỗ), máng trâu (1 chỗ) và chó", home.duck_pond != null and home.duck_pond.pen.capacity == 4 and home.duck_pond.species == duck and home.buffalo_post != null and home.buffalo_post.pen.capacity == 1 and home.dog != null)
	var spots: Array[Vector2] = [home.coop.position, home.barn.position, home.duck_pond.position, home.buffalo_post.position]
	var apart: bool = true
	for i: int in spots.size():
		apart = apart and home.playable_rect.has_point(spots[i])
		for j: int in range(i + 1, spots.size()):
			apart = apart and spots[i].distance_to(spots[j]) > 100.0
	check("bốn chỗ nuôi nằm trong vùng chơi và không chồng lên nhau", apart)
	check("nâng cấp chuồng gà không ảnh hưởng ao vịt", home.duck_pond.upgrade_id == &"" and home.buffalo_post.upgrade_id == &"")
	check("thanh công cụ có ô Bón phân, phím 4 chọn nó", home._tool_buttons.size() == 4 and home._tool_buttons[3].icon != null)
	var key := InputEventKey.new()
	key.keycode = KEY_4
	key.pressed = true
	home._unhandled_input(key)
	check("bấm phím 4: đang cầm phân bón", home.controller.current_tool == 3 and home._tool_buttons[3].button_pressed)
	home.controller.set_tool(0)

	# Thả vịt và nghé bằng phím E.
	player.inventory.add_item(duckling, 1)
	player.position = home.duck_pond.position + Vector2(0, 30)
	await wait(0.3)
	check("đứng cạnh ao thì nhắm được ao vịt", player.get_target() == home.duck_pond.interactable)
	await press_action("interact")
	check("bấm E thả vịt xuống ao", home.duck_pond.pen.get_count() == 1 and player.inventory.count_of(duckling) == 0 and home.duck_pond.get_node("Animals").get_child_count() == 1)
	player.inventory.add_item(calf, 1)
	player.inventory.add_item(greens, 2)
	player.position = home.buffalo_post.position + Vector2(0, 30)
	await wait(0.3)
	check("đứng cạnh máng thì nhắm được máng trâu", player.get_target() == home.buffalo_post.interactable)
	await press_action("interact")
	check("bấm E buộc nghé vào máng", home.buffalo_post.pen.get_count() == 1 and player.inventory.count_of(calf) == 0)
	await press_action("interact")
	check("bấm E cho trâu ăn rau muống", home.buffalo_post.pen.get_unfed_count() == 0 and player.inventory.count_of(greens) == 1)
	tm.sleep_until_morning()
	await press_action("interact")
	check("hôm sau thu được 1 phân bón", player.inventory.count_of(fertilizer) == 1)
	await shot("more_animals.png")

	# Chó: đi dạo trong khung, vuốt ve nhận quà.
	var dog: Node = home.dog
	var inside: bool = true
	var start: Vector2 = dog.position
	var moved: float = 0.0
	for i: int in 25:
		await wait(0.2)
		inside = inside and dog.wander_rect.grow(2.0).has_point(dog.position)
		moved = maxf(moved, dog.position.distance_to(start))
	check("chó đi loanh quanh và không ra khỏi khung", inside and moved > 8.0)
	var expected: ItemData = dog_script.gift_for_day(tm.day, tm.season)
	var before: int = player.inventory.count_of(expected)
	var notices: Array = []
	bus.notice_requested.connect(func(text: String, kind: StringName) -> void: notices.append([text, kind]))
	check("chưa vuốt ve hôm nay", not dog.has_fetched_today())
	check("vuốt ve lần đầu trong ngày: nhận đúng món quà của ngày", dog.pet(player.inventory) and player.inventory.count_of(expected) == before + 1 and dog.has_fetched_today() and notices.back()[1] == &"success")
	check("vuốt ve lần hai: chỉ vẫy đuôi, không thêm quà", not dog.pet(player.inventory) and player.inventory.count_of(expected) == before + 1 and "vẫy đuôi" in notices.back()[0])
	tm.sleep_until_morning()
	check("hôm sau lại có quà", not dog.has_fetched_today() and dog.pet(player.inventory))
	# Túi đầy: không mất quà.
	tm.sleep_until_morning()
	var full: Node = load("res://components/inventory/inventory_component.gd").new()
	full.slot_count = 1
	full.owner_id = &"full_test"
	root.add_child(full)
	full.add_item(db.get_item(&"lua"), 99)
	check("túi đầy: không nhận được, hôm nay vẫn còn quà", not dog.pet(full) and not dog.has_fetched_today() and notices.back()[1] == &"error")
	check("có chỗ thì nhận được", dog.pet(player.inventory))
	# Bấm E thật.
	tm.sleep_until_morning()
	dog.position = Vector2(630, 400)  # chỗ trống cạnh vườn, xa bé Tí và ông Bảy để nhắm cho chắc
	player.position = dog.position + Vector2(0, 16)
	dog.wander_rect = Rect2()  # đứng yên để nhắm cho chắc
	await wait(0.3)
	check("đứng cạnh chó thì nhắm được", player.get_target() == dog.interactable and dog.interactable.prompt_text == "Vuốt ve Vàng")
	await press_action("interact")
	check("bấm E vuốt ve: nhận quà", dog.has_fetched_today())
	# Nhớ qua đổi map.
	var gift_day: int = dog.last_gift_day
	travel("grocery_store")
	await wait(1.0)
	travel("home", &"from_village")
	await wait(1.0)
	check("về lại nhà: chó nhớ hôm nay đã tha quà", sm.current_scene_path.ends_with("home.tscn") and sm.current_map.dog.last_gift_day == gift_day and sm.current_map.dog.has_fetched_today())
	check("ao vịt và trâu được nhớ qua đổi map", sm.current_map.duck_pond.pen.get_count() == 1 and sm.current_map.buffalo_post.pen.get_count() == 1)

	# --- vườn thu gọn và khu chăn nuôi có rào ---
	var yard: Node = sm.current_map
	check("vườn gốc 8 x 5 = 40 ô", yard.field.field_area == Rect2i(0, 0, 8, 5))
	var rails: int = 0
	var posts: int = 0
	for child: Node in yard.get_children():
		if child is Sprite2D and child.texture != null and String(child.texture.resource_path).ends_with("fences_a.png"):
			if child.region_rect.size.x > 20.0 and child.position.y > 440.0 and child.position.x >= yard.YARD_LEFT:
				rails += 1
			elif child.region_rect.size.x <= 20.0:
				posts += 1
	check("khu chăn nuôi có rào ngang hai cạnh (6 đoạn phía bắc chừa cổng, 7 đoạn phía nam) và cọc rào hai bên", rails == 13 and posts >= 30)
	var yard_rect := Rect2(yard.YARD_LEFT, yard.YARD_NORTH, 430.0, yard.YARD_SOUTH - yard.YARD_NORTH)
	check("chuồng gà, chuồng lợn và máng trâu nằm trong sân rào", yard_rect.has_point(yard.coop.position) and yard_rect.has_point(yard.barn.position) and yard_rect.has_point(yard.buffalo_post.position))
	player.position = Vector2(680, 436)
	Input.action_press("move_down")
	await wait(0.8)
	Input.action_release("move_down")
	check("rào phía bắc chặn đường vào sân", player.position.y < yard.YARD_NORTH)
	player.position = Vector2((yard.YARD_GATE_FROM + yard.YARD_GATE_TO) / 2.0, 436)
	Input.action_press("move_down")
	await wait(0.8)
	Input.action_release("move_down")
	check("đi qua cổng (khoảng hở) thì vào được sân", player.position.y > yard.YARD_NORTH + 20.0)
	player.position = Vector2(780, 400)
	Input.action_press("move_up")
	await wait(1.0)
	Input.action_release("move_up")
	await wait(0.2)
	check("rào ao vịt chặn phía trước ao", player.position.y > yard.POND_PEN.end.y - 4.0)
	check("đứng ngoài rào vẫn cho vịt ăn / thu trứng được", player.get_target() == yard.duck_pond.interactable)
	await shot("home_pens.png")
