extends "res://tests/test_base.gd"
## Dân làng (NPC chỉ trò chuyện): ảnh 6 khung, lời thoại của 5 người, vị trí trong các map, nói chuyện bằng E
## (không có nút Mua bán), đi dạo của bé Tí (dừng khi đang nói chuyện), quà tặng.

const VILLAGER_IDS: Array[StringName] = [&"ong_bay", &"be_ti", &"co_lan", &"anh_hai", &"chi_hanh"]


## Tìm VillagerNPC trong [param map] theo id người nói.
func _find_villager(map: Node, speaker_id: StringName) -> Node:
	for child: Node in map.get_children():
		var script: Script = child.get_script()
		if script != null and script.get_global_name() == &"VillagerNPC" and child.dialogue.speaker_id == speaker_id:
			return child
	return null


func run() -> void:
	var tm: Node = root.get_node("TimeManager")
	var rm: Node = root.get_node("RelationshipManager")
	var db: Node = root.get_node("ItemDatabase")
	var sm: Node = root.get_node("SceneManager")

	# --- ảnh và dữ liệu ---
	var sheet: Image = Image.load_from_file("res://assets/art/characters/villagers.png")
	check("ảnh dân làng 6 khung 32x48", sheet != null and sheet.get_size() == Vector2i(192, 48))
	var data_ok: bool = true
	var gifts_ok: bool = true
	var ids: Dictionary = {}
	for id: StringName in VILLAGER_IDS:
		var data: DialogueData = load("res://data/dialogues/%s.tres" % id)
		data_ok = data_ok and data != null and data.is_valid() and data.speaker_id == id and not data.first_meeting.is_empty() and not data.friend_lines.is_empty() and not data.lines_winter.is_empty()
		gifts_ok = gifts_ok and data != null and db.has_item(data.gift_item_id) and data.gift_points >= 1
		ids[id] = true
	check("5 lời thoại hợp lệ (chào, câu bốn mùa, câu người quen)", data_ok)
	check("quà tặng của mọi người đều là vật phẩm có thật", gifts_ok)
	ids[&"tap_hoa"] = true
	ids[&"thuong_lai_rau"] = true
	check("id người nói không trùng nhau (7 NPC)", ids.size() == 7)

	# --- trong game ---
	tm.pause()
	tm.load_save_data({})
	var main: Node = await start_game()
	tm.pause()
	var player: Node = main.player
	var box: Node = main.dialogue_box
	rm.clear()

	var home: Node = sm.current_map
	var ong_bay: Node = home.ong_bay
	var be_ti: Node = home.be_ti
	check("sân nhà có ông Bảy và bé Tí", ong_bay != null and be_ti != null and ong_bay.dialogue.display_name == "Ông Bảy" and be_ti.dialogue.display_name == "Bé Tí")
	check("mỗi người đúng khung ảnh (ông cụ 1, cậu bé 5)", ong_bay.sprite.region_rect.position.x == 32.0 and be_ti.sprite.region_rect.position.x == 160.0)
	check("tên hiện phía trên đầu và lời nhắc đúng", ong_bay.get_node("NameLabel").text == "Ông Bảy" and ong_bay.interactable.prompt_text == "Nói chuyện với Ông Bảy")
	check("NPC nằm trong vùng chơi", home.playable_rect.has_point(ong_bay.position) and home.playable_rect.has_point(be_ti.position))
	var static_blocker: bool = false
	for child: Node in ong_bay.get_children():
		static_blocker = static_blocker or child is StaticBody2D
	var wander_blocker: bool = false
	for child: Node in be_ti.get_children():
		wander_blocker = wander_blocker or child is StaticBody2D
	check("NPC đứng yên chặn đường, NPC đi dạo thì không", static_blocker and not wander_blocker)

	# Nói chuyện với ông Bảy: không có nút Mua bán, E chọn Trò chuyện.
	player.position = ong_bay.position + Vector2(0, 38)
	await wait(0.3)
	check("đứng gần thì nhắm được ông Bảy", player.get_target() == ong_bay.interactable)
	await press_action("interact")
	check("E mở hộp thoại ông Bảy", box.visible and box._name_label.text == "Ông Bảy" and ong_bay.dialogue.first_meeting.has(box._text_label.text))
	check("không bán hàng nên không có nút Mua bán", not box._shop_button.visible and box._talk_button.visible)
	await shot("villager_ong_bay.png")
	await press_action("interact")
	check("E lần hai chọn Trò chuyện: +1 điểm thân thiết", rm.get_points(&"ong_bay") == 1 and box._status_label.text.begins_with("Người lạ · 1 điểm"))
	box.close()

	# Bé Tí đi dạo trong khung; đứng yên khi đang nói chuyện.
	var rect: Rect2 = be_ti.wander_rect
	var start: Vector2 = be_ti.position
	var inside: bool = true
	var moved: float = 0.0
	for i: int in 30:
		await wait(0.2)
		moved = maxf(moved, be_ti.position.distance_to(start))
		inside = inside and rect.grow(2.0).has_point(be_ti.position)
	check("bé Tí đi dạo (dịch chuyển đáng kể)", moved > 8.0)
	check("bé Tí luôn ở trong khung đi dạo", inside)
	player.position = be_ti.position + Vector2(0, 30)
	await wait(0.3)
	be_ti.interactable.interact(player)
	check("bấm E với bé Tí mở hộp thoại", box.visible and box._name_label.text == "Bé Tí")
	var frozen_at: Vector2 = be_ti.position
	await wait(1.5)
	check("đang nói chuyện thì bé Tí đứng yên", be_ti.position == frozen_at)
	box.close()
	await wait(4.0)
	check("nói chuyện xong bé Tí lại đi dạo", be_ti.position != frozen_at)

	# Các NPC ở map khác.
	var expectations: Array = [
		["grocery_store", &"chi_hanh", "Chị Hạnh", 0],
		["village", &"co_lan", "Cô Lan", 2],
		["entertainment", &"anh_hai", "Anh Hai", 3],
	]
	for entry: Array in expectations:

		travel(entry[0])
		await wait(1.0)
		var here: Node = sm.current_map
		var villager: Node = _find_villager(here, entry[1])
		check("%s có %s (khung %d)" % [entry[0], entry[2], entry[3]], villager != null and villager.dialogue.display_name == entry[2] and villager.sprite.region_rect.position.x == entry[3] * 32.0 and here.playable_rect.has_point(villager.position))
		if entry[1] == &"anh_hai":
			# Quà tặng: đủ 3 điểm thì anh Hai tặng gà giống.
			rm.load_save_data({"anh_hai": {"points": 2, "day": tm.day - 1, "gift": false}})
			var chick: ItemData = db.get_item(&"ga_giong")
			var chicks: int = player.inventory.count_of(chick)
			player.position = villager.position + Vector2(0, 38)
			await wait(0.3)
			await press_action("interact")
			await press_action("interact")
			check("đủ 3 điểm: anh Hai tặng gà giống", rm.get_points(&"anh_hai") == 3 and player.inventory.count_of(chick) == chicks + 1 and box._text_label.text == villager.dialogue.gift_text)
			box.close()
		travel("home", &"from_village")
		await wait(1.0)
		check("về lại sân nhà", sm.current_scene_path.ends_with("home.tscn"))

	# Độ thân thiết nằm trong bản lưu (load_save_data ở trên đã thay mục cũ bằng mục của anh Hai).
	var save: Dictionary = rm.get_save_data()
	check("bản lưu có mục của anh Hai: 3 điểm, đã nhận quà", save.has("anh_hai") and save["anh_hai"]["points"] == 3 and save["anh_hai"]["gift"])
