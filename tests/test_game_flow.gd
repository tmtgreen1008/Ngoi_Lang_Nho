extends "res://tests/test_base.gd"
## Luồng chơi từ đầu đến cuối: ván mới, di chuyển giữa các map, gieo hạt rồi đi vắng,
## quay về (vườn được nhớ và tự bù ngày), mua bán, tương tác bằng phím E / Esc.


func run() -> void:
	var tm: Node = root.get_node("TimeManager")
	var sm: Node = root.get_node("SceneManager")
	var bus: Node = root.get_node("EventBus")
	var wsm: Node = root.get_node("WorldStateManager")
	var db: Node = root.get_node("ItemDatabase")
	var economy: Node = root.get_node("EconomyManager")

	var changes: Array = []
	bus.scene_changed.connect(func(path: String) -> void: changes.append(path.get_file()))
	var main: Node = await start_game()
	tm.pause()
	var player: Node = main.player
	var seed_item: ItemData = db.get_item(&"hat_giong_lua")
	var lua: ItemData = db.get_item(&"lua")

	check("ván mới vào map nhà", sm.current_scene_path == "res://maps/home/home.tscn")
	check("Player xuất hiện ở spawn mặc định", player.position.distance_to(sm.current_map.get_spawn_position(&"default")) < 5)
	check("kết thúc hiệu ứng chuyển cảnh", not sm.is_transitioning)
	check("đồ khởi đầu: 10 hạt giống, 100 đ", player.inventory.count_of(seed_item) == 10 and economy.money == 100)

	# --- đi lại và tường ---
	player.position = Vector2(170, 300)
	Input.action_press("move_left")
	await wait(1.0)
	Input.action_release("move_left")
	check("tường chặn Player ở mép trái vùng chơi (x >= 144)", player.position.x >= 144.0 and player.position.x < 170.0)
	player.position = sm.current_map.get_spawn_position(&"default")

	# --- vườn ở nhà ---
	var home: Node = sm.current_map
	var controller: Node = home.controller
	controller.set_tool(0)
	check("cuốc đất", controller.use_tool_at(Vector2i(1, 1)))
	controller.set_tool(1)
	check("gieo hạt", controller.use_tool_at(Vector2i(1, 1)))
	check("hạt giống bị trừ", player.inventory.count_of(seed_item) == 9)
	await shot("flow_home_planted.png")

	# --- đi Tạp hóa ---
	player.position = home.get_exit_position("grocery_store.tscn")
	await wait(1.0)
	check("sang Tiệm Tạp Hóa", sm.current_scene_path.ends_with("grocery_store.tscn"))
	check("Player ở spawn của map Tạp hóa", player.position.distance_to(Vector2(160, 360)) < 5)
	check("map nhà cũ đã được giải phóng", not is_instance_valid(home))
	check("kho đồ Player được giữ qua map", player.inventory.count_of(seed_item) == 9)
	check("trạng thái map nhà đã được ghi nhớ", wsm.has_state("res://maps/home/home.tscn"))

	player.position = Vector2(640, 345)
	await wait(0.3)
	check("nhắm được bà chủ tạp hóa", player.get_target() != null)
	await press_action("interact")
	check("phím E mở hộp thoại bà Tư (chưa mở cửa hàng)", main.dialogue_box.visible and not main.shop_ui.visible)
	await press_action("interact")  # E lần hai chọn "Mua bán"
	check("phím E mở cửa hàng tạp hóa",main.shop_ui.visible and main.shop_ui._title_label.text == "Tiệm Tạp Hóa bà Tư")
	var x_before: float = player.position.x
	Input.action_press("move_right")
	await wait(0.3)
	Input.action_release("move_right")
	check("không đi được khi cửa hàng mở", is_equal_approx(player.position.x, x_before))
	await press_action("ui_cancel")
	check("Esc đóng cửa hàng", not main.shop_ui.visible)

	# --- thời gian trôi trong lúc vắng mặt ---
	for i: int in 4:
		tm.sleep_until_morning()
	check("4 ngày đã trôi", tm.day == 5)

	# --- về nhà ---
	player.position = Vector2(30, 360)
	await wait(1.0)
	check("về lại map nhà", sm.current_scene_path.ends_with("home.tscn"))
	check("Player ở spawn from_grocery", player.position.distance_to(sm.current_map.get_spawn_position(&"from_grocery")) < 5)
	var home2: Node = sm.current_map
	var plot: Variant = home2.field.get_plot(Vector2i(1, 1))
	check("cây vẫn còn sau chuyến đi", plot != null and plot.is_planted())
	check("cây tự bù 4 ngày vắng mặt và đã chín", plot != null and plot.days_grown == 4 and plot.is_ripe())
	check("công cụ vườn gắn đúng kho Player", home2.controller.inventory == player.inventory)
	await shot("flow_home_ripe.png")
	home2.controller.set_tool(2)
	check("thu hoạch được 3 lúa", home2.controller.use_tool_at(Vector2i(1, 1)) and player.inventory.count_of(lua) == 3)

	# --- sang Chợ, yêu cầu chuyển map thứ hai khi đang chuyển bị bỏ qua ---
	player.position = home2.get_exit_position("morning_market.tscn")
	await wait(0.2)
	bus.scene_change_requested.emit("res://maps/grocery_store/grocery_store.tscn", &"default")
	await wait(1.0)
	check("sang Chợ (yêu cầu thứ hai bị bỏ qua)", sm.current_scene_path.ends_with("morning_market.tscn"))
	player.position = Vector2(760, 345)
	await wait(0.3)
	await press_action("interact")
	await press_action("interact")  # hộp thoại chú Năm, E lần hai chọn "Mua bán"
	check("mở sạp chợ, bán được lúa",main.shop_ui.visible and main.shop_ui._title_label.text == "Sạp rau chú Năm")
	var money: int = economy.money
	var sell_button: Button = null
	for row: Node in main.shop_ui._sell_list.get_children():
		for child: Node in row.get_children():
			if child is Label and child.text == "Lúa":
				for candidate: Node in row.get_children():
					if candidate is Button and candidate.text == "Bán 1":
						sell_button = candidate
	check("có nút bán lúa", sell_button != null)
	sell_button.pressed.emit()
	check("bán 1 lúa +18 đ", economy.money == money + 18)
	await press_action("ui_cancel")
	check("thứ tự scene_changed đúng", changes == ["home.tscn", "grocery_store.tscn", "home.tscn", "morning_market.tscn"])
