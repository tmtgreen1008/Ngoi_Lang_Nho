class_name VillagerSchedule
extends Resource
## Lịch sinh hoạt của một dân làng (file .tres trong data/schedules/): theo giờ trong ngày người đó có mặt ở map nào,
## đứng ở đâu. MapBase đọc các lịch này để đặt / cất dân làng khi vào map và mỗi khi đồng hồ sang giờ mới.
##
## Mỗi chặng trong [member stops] là một Dictionary:
##   {"map": "home", "from": 5, "to": 18, "x": 860, "y": 330, "wander": [x, y, rộng, cao] (tuỳ chọn)}
## "map" là tên file scene của map (không đuôi), có mặt từ giờ "from" tới trước giờ "to". Ngoài mọi chặng thì
## người đó ở nhà riêng (không xuất hiện trên map nào).

const DATA_DIR: String = "res://data/schedules"
## Tên hiển thị của từng map, dùng trong thông báo "đi ra ...".
const MAP_NAMES: Dictionary = {
	"home": "Khu nhà", "grocery_store": "Tiệm Tạp Hóa", "morning_market": "Chợ Quê", "entertainment": "Khu Giải trí",
}

@export var dialogue: DialogueData
## Khung nhân vật trong characters/villagers.png.
@export_range(0, 5, 1) var frame: int = 0
## Nhận làm giúp (bảng nâng cấp), xem VillagerNPC.offers_upgrades.
@export var offers_upgrades: bool = false
@export var stops: Array[Dictionary] = []

static var _cache: Array[VillagerSchedule] = []


func get_id() -> StringName:
	return dialogue.speaker_id if dialogue != null else &""


func is_valid() -> bool:
	if dialogue == null or stops.is_empty():
		return false
	for stop: Dictionary in stops:
		if not (stop.has("map") and stop.has("from") and stop.has("to") and stop.has("x") and stop.has("y")):
			return false
		if int(stop["from"]) >= int(stop["to"]):
			return false
	return true


## Chặng đang diễn ra lúc [param hour] giờ (ở bất kỳ map nào), hoặc {} nếu đang ở nhà riêng.
func get_stop_at(hour: int) -> Dictionary:
	for stop: Dictionary in stops:
		if hour >= int(stop["from"]) and hour < int(stop["to"]):
			return stop
	return {}


## Chặng ở map [param map_key] lúc [param hour] giờ, hoặc {} nếu lúc đó không có mặt ở map này.
func get_stop(map_key: String, hour: int) -> Dictionary:
	var stop: Dictionary = get_stop_at(hour)
	return stop if not stop.is_empty() and String(stop["map"]) == map_key else {}


static func stop_position(stop: Dictionary) -> Vector2:
	return Vector2(float(stop["x"]), float(stop["y"]))


## Khung đi dạo của chặng (Rect2 rỗng nếu đứng yên).
static func stop_wander(stop: Dictionary) -> Rect2:
	var wander: Array = stop.get("wander", [])
	if wander.size() != 4:
		return Rect2()
	return Rect2(float(wander[0]), float(wander[1]), float(wander[2]), float(wander[3]))


## Câu báo khi người này rời map lúc [param hour] giờ: "… đi ra <nơi đến>." hoặc "… về nhà nghỉ."
func describe_departure(hour: int) -> String:
	var next: Dictionary = get_stop_at(hour)
	if next.is_empty():
		return "%s về nhà nghỉ." % dialogue.display_name
	return "%s đi ra %s." % [dialogue.display_name, MAP_NAMES.get(String(next["map"]), String(next["map"]))]


## Mọi lịch trong data/schedules (nạp một lần), sắp theo id.
static func load_all() -> Array[VillagerSchedule]:
	if not _cache.is_empty():
		return _cache
	for file_name: String in DirAccess.get_files_at(DATA_DIR):
		var clean_name: String = file_name.trim_suffix(".remap")
		if not clean_name.ends_with(".tres"):
			continue
		var schedule: VillagerSchedule = load(DATA_DIR.path_join(clean_name)) as VillagerSchedule
		if schedule != null and schedule.is_valid():
			_cache.append(schedule)
	_cache.sort_custom(func(a: VillagerSchedule, b: VillagerSchedule) -> bool: return String(a.get_id()) < String(b.get_id()))
	return _cache
