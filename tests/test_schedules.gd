extends "res://tests/test_base.gd"
## Lịch sinh hoạt của dân làng: dữ liệu (5 lịch hợp lệ, không chồng giờ), đến / đi theo giờ khi đang ở trong map,
## có mặt đúng nơi khi vào map, người đang được trò chuyện thì ở lại tới khi nói xong, sang ngày mới thì về chỗ cũ.

const MAPS: Array[String] = ["home", "grocery_store", "morning_market", "entertainment"]


func run() -> void:
	var tm: Node = root.get_node("TimeManager")
	var sm: Node = root.get_node("SceneManager")
	var bus: Node = root.get_node("EventBus")
	tm.pause()
	tm.load_save_data({})

	# --- dữ liệu ---
	var schedules: Array = load("res://core/resources/villager_schedule.gd").load_all()
	var by_id: Dictionary = {}
	var valid: bool = true
	var no_overlap: bool = true
	var maps_ok: bool = true
	for schedule: Variant in schedules:
		by_id[schedule.get_id()] = schedule
		valid = valid and schedule.is_valid()
		for hour: int in 24:
			var active: int = 0
			for stop: Dictionary in schedule.stops:
				if hour >= int(stop["from"]) and hour < int(stop["to"]):
					active += 1
			no_overlap = no_overlap and active <= 1
		for stop: Dictionary in schedule.stops:
			maps_ok = maps_ok and MAPS.has(String(stop["map"])) and int(stop["from"]) >= 0 and int(stop["to"]) <= 24 and float(stop["x"]) > 0.0 and float(stop["x"]) < 1280.0 and float(stop["y"]) > 0.0 and float(stop["y"]) < 720.0
	check("có 5 lịch hợp lệ (ông Bảy, bé Tí, chị Hạnh, cô Lan, anh Hai)", schedules.size() == 5 and valid and by_id.has(&"ong_bay") and by_id.has(&"be_ti") and by_id.has(&"chi_hanh") and by_id.has(&"co_lan") and by_id.has(&"anh_hai"))
	check("mỗi người mỗi giờ chỉ ở một nơi", no_overlap)
	check("mọi chặng nằm ở map có thật, giờ trong 0-24, vị trí trong màn hình", maps_ok)
	var ong_bay: Variant = by_id[&"ong_bay"]
	check("ông Bảy: 17 giờ ở sân nhà, 18 giờ ở Khu Giải trí, 3 giờ sáng ở nhà riêng", String(ong_bay.get_stop_at(17)["map"]) == "home" and String(ong_bay.get_stop_at(18)["map"]) == "entertainment" and ong_bay.get_stop_at(3).is_empty())
	check("get_stop chỉ trả chặng của đúng map", not ong_bay.get_stop("home", 10).is_empty() and ong_bay.get_stop("entertainment", 10).is_empty())
	check("câu báo lúc rời đi", ong_bay.describe_departure(18) == "Ông Bảy đi ra Khu Giải trí." and by_id[&"be_ti"].describe_departure(20) == "Bé Tí về nhà nghỉ.")
	check("ông Bảy nhận làm giúp ở mọi nơi ông có mặt", ong_bay.offers_upgrades)
	var morning: Dictionary = {&"ong_bay": "home", &"be_ti": "home", &"chi_hanh": "grocery_store", &"co_lan": "morning_market", &"anh_hai": "entertainment"}
	var morning_ok: bool = true
	for id: StringName in morning:
		morning_ok = morning_ok and String(by_id[id].get_stop_at(6).get("map", "")) == morning[id]
	check("6 giờ sáng mỗi người ở chỗ quen thuộc", morning_ok)

	# --- trong game: đến và đi theo giờ ---
	var main: Node = await start_game()
	tm.pause()
	var player: Node = main.player
	var home: Node = sm.current_map
	var notices: Array = []
	bus.notice_requested.connect(func(text: String, _kind: StringName) -> void: notices.append(text))
	check("map nhà có tên khoá 'home'", home.map_key() == "home")
	check("6 giờ: sân nhà có ông Bảy và bé Tí", home.ong_bay != null and home.be_ti != null and home.get_villager_ids().size() == 2)
	check("bé Tí đi dạo trong khung của lịch", home.be_ti.wander_rect == Rect2(700, 290, 160, 80))
	notices.clear()
	tm.advance_minutes(170)  # 8:50
	check("8 giờ 50: chưa ai đi", home.be_ti != null and notices.is_empty())
	tm.advance_minutes(10)  # 9:00
	await wait(0.1)
	check("9 giờ: bé Tí rời sân ra chợ, có thông báo", home.be_ti == null and notices.has("Bé Tí đi ra Chợ Quê.") and home.ong_bay != null)
	notices.clear()
	tm.advance_minutes(120)  # 11:00
	check("11 giờ: bé Tí về lại sân, có thông báo", home.be_ti != null and notices.has("Bé Tí vừa tới."))

	# Đang trò chuyện thì ở lại tới khi nói xong.
	tm.advance_minutes(410)  # 17:50
	player.position = home.ong_bay.position + Vector2(0, 38)
	await wait(0.3)
	await press_action("interact")
	check("17 giờ 50: mở hộp thoại với ông Bảy", main.dialogue_box.visible and main.dialogue_box._name_label.text == "Ông Bảy")
	notices.clear()
	tm.advance_minutes(10)  # 18:00
	check("18 giờ, đang trò chuyện: ông Bảy vẫn ở lại", home.ong_bay != null and not notices.has("Ông Bảy đi ra Khu Giải trí."))
	main.dialogue_box.close()
	await wait(0.1)
	check("nói xong: ông Bảy mới đi ra Khu Giải trí", home.ong_bay == null and notices.has("Ông Bảy đi ra Khu Giải trí."))
	notices.clear()
	tm.advance_minutes(60)  # 19:00
	await wait(0.1)
	check("19 giờ: bé Tí về nhà nghỉ, sân vắng", home.be_ti == null and notices.has("Bé Tí về nhà nghỉ.") and home.get_villager_ids().is_empty())

	# --- vào map khác đúng giờ ---
	player.position = home.get_exit_position("entertainment.tscn")
	await wait(1.0)
	var leisure: Node = sm.current_map
	check("19 giờ ở Khu Giải trí: có anh Hai và ông Bảy, không có chị Hạnh", sm.current_scene_path.ends_with("entertainment.tscn") and leisure.get_villager(&"anh_hai") != null and leisure.get_villager(&"ong_bay") != null and leisure.get_villager(&"chi_hanh") == null)
	check("ông Bảy ở Khu Giải trí vẫn nhận làm giúp", leisure.get_villager(&"ong_bay").offers_upgrades and not leisure.get_villager(&"anh_hai").offers_upgrades)
	check("không báo đến/đi khi vừa vào map", not notices.has("Ông Bảy vừa tới.") and not notices.has("Anh Hai vừa tới."))
	await shot("schedule_evening.png")
	player.position = Vector2(30, 360)
	await wait(1.0)

	# Sang ngày mới: mọi người về chỗ buổi sáng.
	tm.sleep_until_morning()
	await wait(0.1)
	var home2: Node = sm.current_map
	check("sáng hôm sau: ông Bảy và bé Tí lại có mặt ở sân nhà", sm.current_scene_path.ends_with("home.tscn") and home2.ong_bay != null and home2.be_ti != null)

	# Buổi chiều: cô Lan ở Tạp Hóa, chị Hạnh đã rời Tạp Hóa.
	tm.advance_minutes(7 * 60)  # 13:00
	player.position = home2.get_exit_position("grocery_store.tscn")
	await wait(1.0)
	var grocery: Node = sm.current_map
	check("13 giờ ở Tạp Hóa: có cô Lan, không còn chị Hạnh", grocery.get_villager(&"co_lan") != null and grocery.get_villager(&"chi_hanh") == null)
	notices.clear()
	tm.advance_minutes(5 * 60)  # 18:00
	await wait(0.1)
	check("18 giờ: cô Lan về nhà nghỉ", grocery.get_villager(&"co_lan") == null and notices.has("Cô Lan về nhà nghỉ."))
