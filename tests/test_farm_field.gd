extends "res://tests/test_base.gd"
## FarmField + FarmToolController: cuốc, gieo, lớn theo ngày, héo khi đổi mùa,
## thu hoạch, lưu/nạp.


func run() -> void:
	var tm: Node = root.get_node("TimeManager")
	var bus: Node = root.get_node("EventBus")
	var db: Node = root.get_node("ItemDatabase")
	tm.pause()
	tm.load_save_data({})
	var crop: CropItemData = db.get_item(&"hat_giong_lua")
	var lua: ItemData = db.get_item(&"lua")
	var withered: Array = [0]
	bus.crop_withered.connect(func(_c: Vector2i, _k: CropItemData) -> void: withered[0] += 1)

	var field: Node = load("res://components/farming/farm_field.gd").new()
	root.add_child(field)
	var cell := Vector2i(2, 2)
	check("chưa cuốc thì không gieo được", field.get_plant_block_reason(cell, crop) == "Cần cuốc đất trước.")
	check("cuốc đất", field.till(cell))
	check("cuốc lần hai bị từ chối", not field.till(cell))
	check("cuốc ngoài vùng bị từ chối", not field.till(Vector2i(50, 50)))
	check("gieo hạt", field.plant(cell, crop))
	check("gieo đè lên cây bị từ chối", not field.plant(cell, crop))

	var other := Vector2i(3, 2)
	field.till(other)
	tm.season = 2
	check("mùa Thu: lúa không gieo được", not field.plant(other, crop))
	tm.season = 0
	check("mùa Xuân: gieo được", field.plant(other, crop))
	check("thu hoạch khi chưa chín trả về null", field.harvest(cell) == null)

	for i: int in 3:
		tm.sleep_until_morning()
	check("3 ngày chưa chín", not field.get_plot(cell).is_ripe())
	bus.day_changed.emit(tm.day)  # cùng ngày (như khi nạp game) không được làm cây lớn thêm
	check("day_changed lặp lại không làm cây lớn", field.get_plot(cell).days_grown == 3)
	tm.sleep_until_morning()
	check("4 ngày thì chín", field.get_plot(cell).is_ripe())
	check("thu hoạch trả về đúng loại cây", field.harvest(cell) == crop)
	check("sau thu hoạch ô còn đất, hết cây", field.get_plot(cell).is_tilled and not field.get_plot(cell).is_planted())

	var saved: Dictionary = JSON.parse_string(JSON.stringify(field.get_save_data()))
	var field2: Node = load("res://components/farming/farm_field.gd").new()
	root.add_child(field2)
	field2.load_save_data(saved)
	check("lưu/nạp qua JSON giữ cây và số ngày", field2.get_plot(other).crop == crop and field2.get_plot(other).days_grown == 4)

	bus.season_changed.emit(2, 1)
	check("sang mùa không hợp thì cây héo + phát tín hiệu", field.get_plot(other).crop == null and withered[0] >= 1)

	# --- FarmToolController nối với kho đồ ---
	var inventory: Node = load("res://components/inventory/inventory_component.gd").new()
	inventory.slot_count = 4
	root.add_child(inventory)
	inventory.add_item(crop, 10)
	var field3: Node = load("res://components/farming/farm_field.gd").new()
	root.add_child(field3)
	var controller: Node = load("res://components/farming/farm_tool_controller.gd").new()
	controller.field = field3
	controller.inventory = inventory
	root.add_child(controller)
	var feedback: Array = [""]
	controller.feedback.connect(func(t: String) -> void: feedback[0] = t)

	controller.set_tool(1)
	check("gieo khi chưa cuốc: từ chối, giữ hạt", not controller.use_tool_at(Vector2i(1, 1)) and inventory.count_of(crop) == 10)
	controller.set_tool(0)
	check("cuốc 3 ô", controller.use_tool_at(Vector2i(1, 1)) and controller.use_tool_at(Vector2i(2, 1)) and controller.use_tool_at(Vector2i(3, 1)))
	controller.set_tool(1)
	for x: int in range(1, 4):
		controller.use_tool_at(Vector2i(x, 1))
	check("gieo 3 ô tốn 3 hạt", inventory.count_of(crop) == 7)
	controller.set_tool(2)
	check("thu hoạch khi chưa chín bị từ chối", not controller.use_tool_at(Vector2i(1, 1)) and feedback[0] == "Cây chưa chín.")
	for i: int in 4:
		tm.sleep_until_morning()
	check("thu hoạch khi chín được 3 lúa", controller.use_tool_at(Vector2i(1, 1)) and inventory.count_of(lua) == 3)
	controller.use_tool_at(Vector2i(2, 1))
	controller.use_tool_at(Vector2i(3, 1))
	check("thu hoạch 3 ô được 9 lúa", inventory.count_of(lua) == 9)
	tm.load_save_data({})
