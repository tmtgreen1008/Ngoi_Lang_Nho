extends "res://tests/test_base.gd"
## Giặt đồ: dây phơi (giặt bằng xà phòng, phơi qua đêm, thu đồ), áo quần sạch cho gấp đôi điểm thân thiết trong
## 3 ngày, lưu/nạp và nhớ qua đổi map.


func run() -> void:
	var tm: Node = root.get_node("TimeManager")
	var rm: Node = root.get_node("RelationshipManager")
	var db: Node = root.get_node("ItemDatabase")
	var sm: Node = root.get_node("SceneManager")
	var bus: Node = root.get_node("EventBus")
	var am: Node = root.get_node("AudioManager")
	tm.pause()
	tm.load_save_data({})
	rm.clear()
	var soap: ItemData = db.get_item(&"xa_phong")
	check("xà phòng có bán ở Tạp Hóa", load("res://data/vendors/tap_hoa.tres").fixed_items.has(soap))
	check("có ảnh dây phơi đầy và trống cùng cỡ", load("res://assets/art/props/clothesline.png").get_size() == load("res://assets/art/props/clothesline_empty.png").get_size())

	# --- áo quần sạch và điểm thân thiết ---
	check("mặc định không có áo quần sạch", not rm.is_wearing_clean())
	check("trò chuyện thường: +1 điểm, không có thưởng", rm.talk(&"a")["bonus"] == false and rm.get_points(&"a") == 1)
	rm.wear_clean_clothes(3)
	check("mặc áo sạch 3 ngày: tính tới hết ngày 3", rm.is_wearing_clean() and rm.clean_until_day == 3)
	var bonus_talk: Dictionary = rm.talk(&"b")
	check("áo quần sạch: lần đầu trong ngày được +2 điểm", bonus_talk["bonus"] and rm.get_points(&"b") == 2)
	check("trò chuyện lần hai cùng ngày vẫn không cộng thêm", not rm.talk(&"b")["gained"] and rm.get_points(&"b") == 2)
	var saved: Dictionary = JSON.parse_string(JSON.stringify(rm.get_save_data()))
	rm.clear()
	check("clear: hết áo quần sạch", not rm.is_wearing_clean())
	rm.load_save_data(saved)
	check("lưu/nạp giữ hạn áo quần sạch và điểm", rm.is_wearing_clean() and rm.clean_until_day == 3 and rm.get_points(&"b") == 2 and rm.get_points(&"_clean_until") == 0)
	tm.sleep_until_morning()
	tm.sleep_until_morning()
	check("ngày 3 vẫn còn sạch", tm.day == 3 and rm.is_wearing_clean())
	tm.sleep_until_morning()
	check("ngày 4 hết sạch, trò chuyện lại +1", not rm.is_wearing_clean() and rm.talk(&"b")["bonus"] == false and rm.get_points(&"b") == 3)
	rm.clear()

	# --- dây phơi ---
	tm.load_save_data({})
	var main: Node = await start_game()
	tm.pause()
	var player: Node = main.player
	var home: Node = sm.current_map
	var line: Node = home.clothes_line
	var notices: Array = []
	bus.notice_requested.connect(func(text: String, kind: StringName) -> void: notices.append([text, kind]))
	check("sân nhà có dây phơi trong vùng chơi", line != null and home.playable_rect.has_point(line.position))
	check("dây trống: ảnh dây trống, lời nhắc giặt đồ", not line.has_laundry() and line._sprite.texture.resource_path.ends_with("clothesline_empty.png") and line.interactable.prompt_text == "Giặt đồ (cần 1 xà phòng)")
	check("không có xà phòng: không giặt được, báo lỗi", not line.use(player.inventory) and notices.back()[1] == &"error" and "xà phòng" in notices.back()[0])
	player.inventory.add_item(soap, 2)
	var minutes: int = tm.hour * 60 + tm.minute
	var splash: int = int(am.play_counts.get(&"splash", 0))
	player.position = line.position + Vector2(0, 26)
	await wait(0.3)
	check("đứng cạnh dây phơi thì nhắm được", player.get_target() == line.interactable)
	await press_action("interact")
	check("bấm E giặt đồ: tốn 1 xà phòng, mất 60 phút", line.has_laundry() and player.inventory.count_of(soap) == 1 and tm.hour * 60 + tm.minute == minutes + 60)
	check("có tiếng nước", int(am.play_counts.get(&"splash", 0)) == splash + 1)
	check("dây có đồ: ảnh đầy quần áo, lời nhắc chờ khô", line._sprite.texture.resource_path.ends_with("clothesline.png") and line.interactable.prompt_text == "Đồ đang phơi (mai mới khô)" and not line.is_dry())
	await shot("laundry_hung.png")
	check("bấm lại khi đồ còn ướt: không đổi gì, không tốn xà phòng", not line.use(player.inventory) and player.inventory.count_of(soap) == 1 and "còn ướt" in notices.back()[0])

	# Đi vắng một ngày: dây phơi được nhớ, đồ khô.
	travel("grocery_store")
	await wait(1.0)
	tm.sleep_until_morning()
	travel("home", &"from_village")
	await wait(1.0)
	var line2: Node = sm.current_map.clothes_line
	check("về nhà hôm sau: đồ vẫn trên dây và đã khô", line2.has_laundry() and line2.is_dry() and line2.interactable.prompt_text == "Thu đồ đã khô")
	check("chưa thu đồ thì chưa có áo quần sạch", not rm.is_wearing_clean())
	player.position = line2.position + Vector2(0, 26)
	await wait(0.3)
	await press_action("interact")
	check("bấm E thu đồ: dây trống lại, có áo quần sạch 3 ngày", not line2.has_laundry() and rm.is_wearing_clean() and rm.clean_until_day == tm.day + 2 and line2._sprite.texture.resource_path.ends_with("clothesline_empty.png"))
	check("thông báo nói rõ lợi ích", notices.back()[1] == &"success" and "gấp đôi" in notices.back()[0])

	# Hộp thoại hiện trạng thái, trò chuyện được +2.
	var ong_bay: Node = sm.current_map.ong_bay
	player.position = ong_bay.position + Vector2(0, 38)
	await wait(0.3)
	await press_action("interact")
	check("hộp thoại ghi 'áo quần sạch (x2 điểm)'", main.dialogue_box.visible and "áo quần sạch" in main.dialogue_box._status_label.text)
	main.dialogue_box._talk_button.pressed.emit()
	check("trò chuyện với ông Bảy: +2 điểm, lên cấp Quen biết ngay", rm.get_points(&"ong_bay") == 2 and rm.get_level(&"ong_bay") == 1)
	main.dialogue_box.close()

	# Lưu game giữ cả hai trạng thái.
	line2.use(player.inventory)
	var save: Node = root.get_node("SaveManager")
	check("giặt mẻ mới rồi lưu game", line2.has_laundry() and save.save_game(&"test_laundry") == "")
	var hung: int = line2.hung_day
	var until: int = rm.clean_until_day
	rm.clear()
	check("nạp game", await save.load_game(&"test_laundry") == "")
	await wait(0.5)
	check("nạp game: đồ vẫn trên dây, áo quần sạch còn hạn", sm.current_map.clothes_line.hung_day == hung and rm.clean_until_day == until)
	DirAccess.remove_absolute(save.get_slot_path(&"test_laundry"))
