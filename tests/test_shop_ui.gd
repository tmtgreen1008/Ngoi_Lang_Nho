extends "res://tests/test_base.gd"
## ShopUI dùng chung: mở theo VendorData, bấm nút mua/bán, khoá nút khi đóng cửa,
## sự kiện shop_opened/shop_closed, mở qua EventBus.shop_open_requested.


## Nút [param button_text] trong dòng có nhãn [param row_text] (dòng có thể bắt đầu bằng icon).
func _find_row_button(list: Node, row_text: String, button_text: String) -> Button:
	for row: Node in list.get_children():
		var has_label: bool = false
		for child: Node in row.get_children():
			if child is Label and child.text == row_text:
				has_label = true
		if not has_label:
			continue
		for child: Node in row.get_children():
			if child is Button and child.text == button_text:
				return child
	return null


func run() -> void:
	var tm: Node = root.get_node("TimeManager")
	var bus: Node = root.get_node("EventBus")
	var economy: Node = root.get_node("EconomyManager")
	var db: Node = root.get_node("ItemDatabase")
	tm.pause()
	tm.load_save_data({})
	economy.load_save_data({})

	var vendor_script: GDScript = load("res://components/vendor/vendor_component.gd")
	var inventory_script: GDScript = load("res://components/inventory/inventory_component.gd")
	var grocery: Node = vendor_script.new()
	grocery.data = load("res://data/vendors/tap_hoa.tres")
	root.add_child(grocery)
	var market: Node = vendor_script.new()
	market.data = load("res://data/vendors/thuong_lai_rau.tres")
	root.add_child(market)
	var inv: Node = inventory_script.new()
	inv.slot_count = 8
	root.add_child(inv)
	inv.add_item(db.get_item(&"lua"), 12)
	inv.add_item(db.get_item(&"trung_ga"), 4)

	var shop: Node = load("res://ui/shop/shop_ui.tscn").instantiate()
	root.add_child(shop)
	await wait(0.2)
	var events: Array = []
	bus.shop_opened.connect(func(d: Resource) -> void: events.append("open:" + String(d.id)))
	bus.shop_closed.connect(func(d: Resource) -> void: events.append("close:" + String(d.id)))

	check("cửa hàng ẩn lúc đầu", not shop.visible)
	shop.open(grocery, inv)
	await shot("shop_grocery.png")
	check("tiêu đề theo VendorData tạp hóa", shop._title_label.text == "Tiệm Tạp Hóa bà Tư")
	check("4 dòng hàng cố định", shop._buy_list.get_child_count() == 4)
	var buy_button: Button = _find_row_button(shop._buy_list, "Mì tôm", "Mua 1")
	check("nút Mua 1 bật", buy_button != null and not buy_button.disabled)
	buy_button.pressed.emit()
	check("bấm nút mua: trừ tiền, thêm hàng", economy.money == 92 and inv.count_of(db.get_item(&"mi_tom")) == 1)
	check("hiện thông báo thành công", shop._message_label.text == "Đã mua 1 Mì tôm.")
	check("nhãn tiền được cập nhật", shop._info_label.text.contains("92"))
	check("tab Bán của tạp hóa báo không thu mua", shop._sell_list.get_child(0).text.contains("không thu mua"))

	shop.open(market, inv)  # cùng một ShopUI, đổi sang cửa hàng khác
	await shot("shop_market.png")
	check("cùng ShopUI hiển thị sạp chợ", shop._title_label.text == "Sạp rau chú Năm")
	check("chợ có 3 dòng hàng ngẫu nhiên", shop._buy_list.get_child_count() == 3)
	shop._tabs.current_tab = 1
	var sell_button: Button = _find_row_button(shop._sell_list, "Lúa", "Bán 1")
	check("tab Bán có dòng Lúa", sell_button != null and not sell_button.disabled)
	var money_before: int = economy.money
	sell_button.pressed.emit()
	check("bán 1 lúa +18 đ", economy.money == money_before + 18 and inv.count_of(db.get_item(&"lua")) == 11)

	tm.advance_minutes(5 * 60)  # 11:00: chợ đóng
	await shot("shop_market_closed.png")
	check("hiện ĐÃ ĐÓNG CỬA", shop._info_label.text.begins_with("ĐÃ ĐÓNG CỬA"))
	var all_disabled: bool = true
	var buttons: Array = find_buttons(shop._buy_list) + find_buttons(shop._sell_list)
	for button in buttons:
		all_disabled = all_disabled and button.disabled
	check("mọi nút mua/bán bị khoá khi đóng cửa", buttons.size() > 0 and all_disabled)
	shop.close()
	check("đóng cửa hàng ẩn UI", not shop.visible)
	check("sự kiện mở/đóng đúng thứ tự", events == ["open:tap_hoa", "close:tap_hoa", "open:thuong_lai_rau", "close:thuong_lai_rau"])

	tm.load_save_data({})
	bus.shop_open_requested.emit(grocery, inv)
	check("mở qua EventBus.shop_open_requested", shop.visible and shop._title_label.text == "Tiệm Tạp Hóa bà Tư")
	await press_action("ui_cancel")
	check("Esc đóng cửa hàng", not shop.visible)
