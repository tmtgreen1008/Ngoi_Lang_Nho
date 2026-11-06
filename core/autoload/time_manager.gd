extends Node
## TimeManager (Autoload): đồng hồ và lịch trong game (phút, giờ, ngày, mùa).
##
## - Chạy bằng một Timer (không dùng _process): mỗi lần Timer hết giờ, đồng hồ
##   tiến [member minutes_per_tick] phút trong game.
## - Mọi thay đổi được báo qua EventBus; hệ thống khác chỉ việc nghe tín hiệu.
## - Tốc độ mặc định: 1 giây thật = 10 phút game, nên một ngày game (6h -> 24h)
##   kéo dài khoảng 108 giây thật. Chỉnh trong Inspector hoặc qua [method set_speed].

enum Season { SPRING, SUMMER, AUTUMN, WINTER }

const MINUTES_PER_HOUR: int = 60
const HOURS_PER_DAY: int = 24

const SEASON_NAMES: Dictionary = {
	Season.SPRING: "Xuân",
	Season.SUMMER: "Hạ",
	Season.AUTUMN: "Thu",
	Season.WINTER: "Đông",
}

## Số giây thật giữa hai nhịp đồng hồ.
@export_range(0.05, 60.0, 0.05) var real_seconds_per_tick: float = 1.0
## Số phút game trôi qua mỗi nhịp (nên chia hết cho 60).
@export_range(1, 60, 1) var minutes_per_tick: int = 10
@export_range(1, 365, 1) var days_per_season: int = 28
## Giờ bắt đầu một ngày mới.
@export_range(0, 23, 1) var wake_up_hour: int = 6
## Đến giờ này mà chưa ngủ thì ngày tự kết thúc (24 = nửa đêm).
@export_range(1, 24, 1) var day_end_hour: int = 24

var minute: int = 0
var hour: int = 6
## Tổng số ngày đã trôi qua, bắt đầu từ 1.
var day: int = 1
var season: Season = Season.SPRING
var year: int = 1

var _timer: Timer


func _ready() -> void:
	hour = wake_up_hour
	_timer = Timer.new()
	_timer.wait_time = real_seconds_per_tick
	_timer.one_shot = false
	_timer.autostart = false
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)
	start()


## Bắt đầu hoặc tiếp tục chạy đồng hồ.
func start() -> void:
	if _timer.is_stopped():
		_timer.start()


## Tạm dừng đồng hồ (mở menu, hội thoại, mini-game...).
func pause() -> void:
	_timer.stop()


func is_running() -> bool:
	return not _timer.is_stopped()


## Đổi tốc độ: [param seconds] giây thật cho mỗi nhịp.
func set_speed(seconds: float) -> void:
	real_seconds_per_tick = maxf(0.05, seconds)
	_timer.wait_time = real_seconds_per_tick


## Tiến đồng hồ [param minutes] phút game; phát tín hiệu cho từng nhịp.
## Dùng cho hành động tốn thời gian (nấu ăn, giặt đồ) hoặc để kiểm thử.
func advance_minutes(minutes: int) -> void:
	var remaining: int = maxi(0, minutes)
	while remaining > 0:
		var step: int = mini(remaining, minutes_per_tick)
		remaining -= step
		_advance_clock(step)


## Ngủ: kết thúc ngày hiện tại và bắt đầu ngày mới lúc [member wake_up_hour].
func sleep_until_morning() -> void:
	_start_new_day()


## Giờ hiện tại dạng số thực (vd 13.5 = 13:30), tiện so sánh với giờ mở cửa.
func get_hour_float() -> float:
	return hour + minute / float(MINUTES_PER_HOUR)


## Ngày thứ mấy trong mùa (1..days_per_season).
func get_day_of_season() -> int:
	return (day - 1) % days_per_season + 1


func get_season_name() -> String:
	return SEASON_NAMES[season]


## Chuỗi "HH:MM" để hiển thị trên HUD.
func get_time_string() -> String:
	return "%02d:%02d" % [hour, minute]


## Giờ hiện tại có nằm trong [open_hour, close_hour) không. Dùng cho Tiệm Tạp Hóa (6-21), Chợ (5-11).
func is_within_hours(open_hour: float, close_hour: float) -> bool:
	var now: float = get_hour_float()
	return now >= open_hour and now < close_hour


## Gói trạng thái để lưu game.
func get_save_data() -> Dictionary:
	return {"minute": minute, "hour": hour, "day": day, "season": season, "year": year}


## Nạp lại trạng thái đã lưu. Phát tín hiệu để UI và hệ thống đồng bộ.
func load_save_data(data: Dictionary) -> void:
	minute = int(data.get("minute", 0))
	hour = int(data.get("hour", wake_up_hour))
	day = maxi(1, int(data.get("day", 1)))
	season = int(data.get("season", Season.SPRING)) as Season
	year = maxi(1, int(data.get("year", 1)))
	EventBus.time_ticked.emit(hour, minute)
	EventBus.day_changed.emit(day)


func _on_timer_timeout() -> void:
	_advance_clock(minutes_per_tick)


func _advance_clock(minutes: int) -> void:
	var previous_hour: int = hour
	minute += minutes
	while minute >= MINUTES_PER_HOUR:
		minute -= MINUTES_PER_HOUR
		hour += 1
	if hour >= day_end_hour:
		_start_new_day()
		return
	EventBus.time_ticked.emit(hour, minute)
	if hour != previous_hour:
		EventBus.hour_changed.emit(hour)


func _start_new_day() -> void:
	EventBus.day_ended.emit(day)
	day += 1
	hour = wake_up_hour
	minute = 0
	if get_day_of_season() == 1:
		_advance_season()
	EventBus.day_changed.emit(day)
	EventBus.time_ticked.emit(hour, minute)


func _advance_season() -> void:
	if season == Season.WINTER:
		season = Season.SPRING
		year += 1
	else:
		season = (season + 1) as Season
	EventBus.season_changed.emit(season, year)
