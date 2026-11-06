extends "res://tests/test_base.gd"
## TimeManager: tiến thời gian, tín hiệu, đổi ngày/mùa/năm, giờ mở cửa, lưu/nạp.


func run() -> void:
	var tm: Node = root.get_node("TimeManager")
	var bus: Node = root.get_node("EventBus")
	tm.pause()
	tm.load_save_data({})

	var ticks: Array = [0]
	var days: Array = []
	var seasons: Array = []
	bus.time_ticked.connect(func(_h: int, _m: int) -> void: ticks[0] += 1)
	bus.day_changed.connect(func(d: int) -> void: days.append(d))
	bus.season_changed.connect(func(s: int, y: int) -> void: seasons.append([s, y]))

	check("ngày mới bắt đầu 06:00 ngày 1 mùa Xuân", tm.get_time_string() == "06:00" and tm.day == 1 and tm.season == 0)
	ticks[0] = 0
	tm.advance_minutes(60)
	check("tiến 60 phút -> 07:00", tm.get_time_string() == "07:00")
	check("mỗi 10 phút một nhịp -> 6 time_ticked", ticks[0] == 6)

	tm.sleep_until_morning()
	check("ngủ -> ngày 2, 06:00", tm.day == 2 and tm.get_time_string() == "06:00")
	check("phát day_changed(2)", days == [2])

	for i: int in 27:
		tm.sleep_until_morning()
	check("ngày 29 -> sang mùa Hạ, phát season_changed", tm.season == 1 and tm.get_day_of_season() == 1 and seasons == [[1, 1]])

	for i: int in 28 * 3:
		tm.sleep_until_morning()
	check("qua đủ 4 mùa -> Xuân năm 2", tm.season == 0 and tm.year == 2)
	check("tên mùa tiếng Việt", tm.get_season_name() == "Xuân")

	tm.load_save_data({})
	check("giờ mở cửa [6,21): 06:00 mở", tm.is_within_hours(6.0, 21.0))
	tm.advance_minutes(15 * 60)
	check("đến 21:00 thì đóng cửa tạp hóa", not tm.is_within_hours(6.0, 21.0))

	tm.load_save_data({"minute": 30, "hour": 13, "day": 40, "season": 2, "year": 3})
	var saved: Dictionary = tm.get_save_data()
	check("lưu/nạp giữ nguyên trạng thái", saved == {"minute": 30, "hour": 13, "day": 40, "season": 2, "year": 3})
	check("giờ dạng số thực 13.5", is_equal_approx(tm.get_hour_float(), 13.5))

	tm.advance_minutes(11 * 60)  # 13:30 + 11h = 00:30 -> qua nửa đêm
	check("quá nửa đêm tự sang ngày mới", tm.day == 41 and tm.get_time_string() == "06:00")
	tm.load_save_data({})
