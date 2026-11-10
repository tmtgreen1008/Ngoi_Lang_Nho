extends "res://tests/test_base.gd"
## Túi đồ: sắp xếp kho (gộp chồng, xếp theo nhóm rồi tên), màn hình túi đồ trong game (Tab / I mở và đóng, Esc đóng,
## chọn ô xem chi tiết, nút Sắp xếp, số ô theo nâng cấp túi), không mở được khi đang bận, chuột không cuốc đất khi túi mở.


func run() -> void:
	var tm: Node = root.get_node("TimeManager")
	var db: Node = root.get_node("ItemDatabase")
	var sm: Node = root.get_node("SceneManager")
	var um: Node = root.get_node("UpgradeManager")
	var economy: Node = root.get_node("EconomyManager")
	tm.pause()
	tm.load_save_data({})
	um.clear()

	# --- sắp xếp kho ---
	var lua: ItemData = db.get_item(&"lua")
	var egg: ItemData = db.get_item(&"trung_ga")
	var seed_item: ItemData = db.get_item(&"hat_giong_lua")
	var soap: ItemData = db.get_item(&"xa_phong")
	var inv: Node = load("res://components/inventory/inventory_component.gd").new()
	inv.slot_count = 8
	inv.owner_id = &"bag_test"
	root.add_child(inv)
	inv.add_item(soap, 2)
	inv.add_item(lua, 99)
	inv.add_item(egg, 3)
	inv.add_item(lua, 30)
	inv.add_item(seed_item, 4)
	inv.move_slot(0, 7)  # xà phòng xuống ô cuối, để lại ô trống ở đầu
	inv.move_slot(4, 6)
	var changed: Array = [0]
	inv.slot_changed.connect(func(_index: int) -> void: changed[0] += 1)
	inv.sort_slots()
	var order: Array = []
	for slot in inv.slots:
		order.append("" if slot.is_empty() else "%s:%d" % [slot.item.id, slot.amount])
	check("sắp xếp: hạt giống, nông sản (gộp 129 lúa thành 99 + 30), thực phẩm, khác; ô trống dồn về cuối", order == ["hat_giong_lua:4", "lua:99", "lua:30", "trung_ga:3", "xa_phong:2", "", "", ""])
	check("sắp xếp không làm mất hay thêm đồ", inv.count_of(lua) == 129 and inv.count_of(egg) == 3 and inv.count_of(seed_item) == 4 and inv.count_of(soap) == 2)
	check("sắp xếp báo mọi ô vẽ lại", changed[0] >= 8)
	inv.sort_slots()
	var again: Array = []
	for slot in inv.slots:
		again.append("" if slot.is_empty() else "%s:%d" % [slot.item.id, slot.amount])
	check("sắp xếp lần hai không đổi gì", again == order)

	# --- trong game ---
	var main: Node = load("res://main.tscn").instantiate()
	root.add_child(main)
	await wait(0.2)
	var bag: Node = main.bag_screen
	check("hành động 'inventory' gắn phím Tab và I", InputMap.has_action(&"inventory") and InputMap.action_get_events(&"inventory").size() == 2)
	check("ở màn hình chính không mở được túi đồ", not bag.open() and not bag.visible)
	main.start_new_game()
	await wait(0.8)
	tm.pause()
	var player: Node = main.player
	var home: Node = sm.current_map
	await press_action("inventory")
	check("bấm Tab mở túi đồ, Player đứng yên", bag.visible and bag.is_open() and player.movement_locked)
	check("lưới có 16 ô, tiêu đề ghi số ô đang dùng", bag.inventory_ui._grid.get_child_count() == 16 and bag.inventory_ui._title_label.text == "Túi đồ (2/16 ô)")
	check("chưa chọn gì: bảng chi tiết hướng dẫn", bag._name_label.text == "Chọn một vật phẩm")
	await shot("bag_open.png")
	bag.inventory_ui._slot_uis[0].selected.emit(0)
	check("bấm ô hạt giống: hiện tên, nhóm, số lượng", bag.selected_index == 0 and bag._name_label.text == "Hạt giống lúa" and "Hạt giống" in bag._info_label.text and "đang có 10" in bag._info_label.text and bag._icon.texture != null)
	check("hạt giống ghi mùa gieo, số ngày lớn và số nông sản", "Gieo vào mùa: Xuân, Hạ" in bag._description_label.text and "4 ngày" in bag._description_label.text and "thu 3" in bag._description_label.text)
	await shot("bag_detail.png")
	bag.select(1)
	check("chọn ô trứng gà: nhóm Thực phẩm, có giá gốc", bag._name_label.text == "Trứng gà" and "Thực phẩm" in bag._info_label.text and "giá gốc 12 đ" in bag._info_label.text)
	bag.select(9)
	check("chọn ô trống: bỏ chọn", bag._name_label.text == "Chọn một vật phẩm" and bag._icon.texture == null)

	# Kéo thả (qua dữ liệu) và nút Sắp xếp.
	player.inventory.move_slot(0, 12)
	check("dời đồ sang ô khác: ô giao diện cập nhật", bag.inventory_ui._slot_uis[12]._icon.texture != null and bag.inventory_ui._slot_uis[0]._icon.texture == null)
	bag.sort_items()
	check("bấm Sắp xếp: đồ dồn về đầu túi theo nhóm", player.inventory.slots[0].item == seed_item and player.inventory.slots[1].item == egg and player.inventory.slots[2].is_empty() and bag.inventory_ui._slot_uis[0]._icon.texture != null)

	# Chuột bấm ra ngoài bảng khi túi đang mở không cuốc đất.
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = Vector2(192 + 48 * 2 + 20, 240 + 48 * 2 + 20)
	home._unhandled_input(click)
	check("túi đang mở: bấm chuột không cuốc đất", home.field.get_plot(Vector2i(2, 2)) == null)

	await press_action("ui_cancel")
	check("Esc đóng túi đồ (không mở menu tạm dừng), Player cử động được", not bag.visible and not main.pause_menu.visible and not player.movement_locked)
	await press_action("inventory")
	await press_action("inventory")
	check("Tab hai lần: mở rồi đóng", not bag.visible and not bag.is_open())

	# Không mở được khi đang nói chuyện.
	player.position = home.ong_bay.position + Vector2(0, 38)
	await wait(0.3)
	await press_action("interact")
	check("đang mở hộp thoại", main.dialogue_box.visible)
	await press_action("inventory")
	check("đang nói chuyện thì Tab không mở túi đồ", not bag.visible and main.dialogue_box.visible)
	main.dialogue_box.close()
	await wait(0.1)
	await press_action("inventory")
	check("nói chuyện xong thì mở lại được", bag.visible)
	bag.close()

	# Nâng cấp túi: lưới thêm ô.
	economy.earn(1000)
	um.buy(&"bag")
	await press_action("inventory")
	check("sau khi nâng cấp túi: lưới có 24 ô, tiêu đề cập nhật", bag.inventory_ui._grid.get_child_count() == 24 and bag.inventory_ui._title_label.text == "Túi đồ (2/24 ô)")
	player.inventory.add_item(lua, 5)
	await wait(0.1)
	check("nhận thêm đồ khi túi đang mở: tiêu đề cập nhật", bag.inventory_ui._title_label.text == "Túi đồ (3/24 ô)")
	bag.close()
	um.clear()
