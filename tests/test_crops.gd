extends "res://tests/test_base.gd"
## Các loại cây trồng (11 loại thêm vào cạnh lúa): dữ liệu và ảnh, mùa gieo, lớn theo ngày, thu hoạch,
## chọn hạt giống hợp mùa, tiệm tạp hóa bán đủ hạt.

const CROP_IDS: Array[StringName] = [
	&"ca_chua", &"bap_cai", &"dua_leo", &"rau_muong", &"ngo", &"ca_rot", &"khoai_lang", &"ot", &"bi_do", &"dua_hau", &"dau",
]


func run() -> void:
	var tm: Node = root.get_node("TimeManager")
	var db: Node = root.get_node("ItemDatabase")
	tm.pause()
	tm.load_save_data({})

	# --- dữ liệu và ảnh của từng loại ---
	var data_ok: bool = true
	var art_ok: bool = true
	var seasons_ok: bool = true
	var seed_icon_regions: Dictionary = {}
	for id: StringName in CROP_IDS:
		var seed_item: CropItemData = db.get_item(StringName("hat_giong_%s" % id)) as CropItemData
		var product: ItemData = db.get_item(id)
		if seed_item == null or product == null:
			data_ok = false
			continue
		data_ok = data_ok and seed_item.harvest_item_id == id and seed_item.grow_days >= 1 and seed_item.harvest_amount >= 1 and product.base_price > 0
		art_ok = art_ok and seed_item.growth_sheet != null and seed_item.growth_sheet.get_size() == Vector2(144, 48) and seed_item.icon != null and seed_item.icon.get_size() == Vector2(32, 32) and product.icon != null and product.icon.get_size() == Vector2(32, 32)
		seasons_ok = seasons_ok and not seed_item.allowed_seasons.is_empty() and seed_item.allowed_seasons.size() < 4
		if seed_item.icon != null:
			seed_icon_regions[str((seed_item.icon as AtlasTexture).region)] = true
	check("11 loại hạt giống và nông sản đều có trong ItemDatabase", data_ok)
	check("mỗi cây có ảnh 3 khung 48x48, hạt và nông sản có icon 32x32", art_ok)
	check("mỗi hạt giống một ô icon riêng", seed_icon_regions.size() == CROP_IDS.size())
	check("mỗi loại chỉ gieo được vài mùa (không phải mọi mùa)", seasons_ok)

	# --- gieo, lớn, thu hoạch cho từng loại (trong một mùa hợp lệ của nó) ---
	var field: Node = load("res://components/farming/farm_field.gd").new()
	root.add_child(field)
	var inv: Node = load("res://components/inventory/inventory_component.gd").new()
	inv.slot_count = 20
	inv.owner_id = &"crops_test"
	root.add_child(inv)
	var controller: Node = load("res://components/farming/farm_tool_controller.gd").new()
	controller.field = field
	controller.inventory = inv
	root.add_child(controller)

	var cycle_ok: bool = true
	var yield_ok: bool = true
	for id: StringName in CROP_IDS:
		var seed_item: CropItemData = db.get_item(StringName("hat_giong_%s" % id)) as CropItemData
		var product: ItemData = db.get_item(id)
		tm.load_save_data({})  # ngày 1 mùa Xuân, để không vượt ranh giới mùa giữa chừng
		tm.season = seed_item.allowed_seasons[0]
		var cell := Vector2i(0, 0)
		field.till(cell)
		inv.add_item(seed_item, 1)
		controller.set_tool(1)
		cycle_ok = cycle_ok and controller.use_tool_at(cell) and inv.count_of(seed_item) == 0
		for day: int in seed_item.grow_days:
			cycle_ok = cycle_ok and not field.get_plot(cell).is_ripe()
			tm.sleep_until_morning()
		cycle_ok = cycle_ok and field.get_plot(cell).is_ripe()
		controller.set_tool(2)
		var before: int = inv.count_of(product)
		yield_ok = yield_ok and controller.use_tool_at(cell) and inv.count_of(product) == before + seed_item.harvest_amount
		field.get_plot(cell).clear_crop()
	check("mọi loại gieo được, chín đúng số ngày", cycle_ok)
	check("mọi loại thu hoạch đúng số lượng nông sản", yield_ok)

	# --- luật mùa ---
	var melon: CropItemData = db.get_item(&"hat_giong_dua_hau") as CropItemData
	var morning_glory: CropItemData = db.get_item(&"hat_giong_rau_muong") as CropItemData
	field.till(Vector2i(1, 0))
	tm.season = 0
	check("dưa hấu không gieo được vào mùa Xuân", field.get_plant_block_reason(Vector2i(1, 0), melon) == "Không gieo được vào mùa này.")
	tm.season = 1
	check("dưa hấu gieo được vào mùa Hạ", field.get_plant_block_reason(Vector2i(1, 0), melon).is_empty())

	# --- chọn hạt giống hợp mùa khi túi có nhiều loại ---
	var inv2: Node = load("res://components/inventory/inventory_component.gd").new()
	inv2.slot_count = 6
	inv2.owner_id = &"crops_test2"
	root.add_child(inv2)
	var field2: Node = load("res://components/farming/farm_field.gd").new()
	root.add_child(field2)
	var controller2: Node = load("res://components/farming/farm_tool_controller.gd").new()
	controller2.field = field2
	controller2.inventory = inv2
	root.add_child(controller2)
	inv2.add_item(melon, 1)  # ô đầu tiên là dưa hấu (sai mùa Xuân)
	inv2.add_item(morning_glory, 1)
	tm.season = 0
	field2.till(Vector2i(2, 0))
	controller2.set_tool(1)
	check("mùa Xuân: bỏ qua dưa hấu, gieo rau muống ở ô sau", controller2.use_tool_at(Vector2i(2, 0)) and field2.get_plot(Vector2i(2, 0)).crop == morning_glory and inv2.count_of(melon) == 1 and inv2.count_of(morning_glory) == 0)
	field2.till(Vector2i(3, 0))
	var messages: Array = []
	controller2.feedback.connect(func(text: String) -> void: messages.append(text))
	check("chỉ còn hạt sai mùa: báo đúng lý do, không mất hạt", not controller2.use_tool_at(Vector2i(3, 0)) and messages.back() == "Không gieo được vào mùa này." and inv2.count_of(melon) == 1)

	# --- tiệm tạp hóa bán đủ hạt giống ---
	var grocery: VendorData = load("res://data/vendors/tap_hoa.tres")
	var sold_ok: bool = grocery.fixed_items.has(db.get_item(&"hat_giong_lua"))
	for id: StringName in CROP_IDS:
		sold_ok = sold_ok and grocery.fixed_items.has(db.get_item(StringName("hat_giong_%s" % id)))
	check("tạp hóa bán hạt giống lúa và 11 loại mới", sold_ok)
	check("tạp hóa có 19 món: mì, cám, xà phòng, hạt lúa, 4 con giống và 11 hạt giống mới", grocery.fixed_items.size() == 19)
