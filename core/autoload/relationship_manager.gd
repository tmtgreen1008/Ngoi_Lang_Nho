extends Node
## RelationshipManager (Autoload): độ thân thiết của người chơi với từng NPC.
##
## - Mỗi ngày trò chuyện lần đầu với một NPC được +1 điểm thân thiết.
## - Cấp độ theo điểm (xem [constant LEVEL_THRESHOLDS]): Người lạ, Quen biết, Thân, Thân thiết.
## - Đủ điểm theo dữ liệu thì NPC tặng quà một lần (DialogueBox lo việc đưa quà).
## - Lưu cùng ván chơi qua SaveManager (get_save_data/load_save_data); ván mới gọi [method clear].

const LEVEL_NAMES: Array[String] = ["Người lạ", "Quen biết", "Thân", "Thân thiết"]
## Điểm tối thiểu để đạt từng cấp (cùng thứ tự [constant LEVEL_NAMES]).
const LEVEL_THRESHOLDS: Array[int] = [0, 2, 5, 10]

var _points: Dictionary = {}  # speaker_id -> điểm
var _last_talk_day: Dictionary = {}  # speaker_id -> ngày trò chuyện gần nhất
var _gifts_claimed: Dictionary = {}  # speaker_id -> true


func get_points(speaker_id: StringName) -> int:
	return int(_points.get(speaker_id, 0))


## Đã từng trò chuyện với NPC này chưa.
func has_met(speaker_id: StringName) -> bool:
	return _last_talk_day.has(speaker_id)


func get_level(speaker_id: StringName) -> int:
	return level_for_points(get_points(speaker_id))


static func level_for_points(points: int) -> int:
	var level: int = 0
	for i: int in LEVEL_THRESHOLDS.size():
		if points >= LEVEL_THRESHOLDS[i]:
			level = i
	return level


func get_level_name(speaker_id: StringName) -> String:
	return LEVEL_NAMES[get_level(speaker_id)]


## Hôm nay đã trò chuyện với NPC này chưa (chỉ lần đầu trong ngày được cộng điểm).
func has_talked_today(speaker_id: StringName) -> bool:
	return _last_talk_day.get(speaker_id, -1) == TimeManager.day


## Ghi nhận một lần trò chuyện. Trả về {"gained": bool, "leveled_up": bool, "level": int}.
func talk(speaker_id: StringName) -> Dictionary:
	var level_before: int = get_level(speaker_id)
	var gained: bool = not has_talked_today(speaker_id)
	_last_talk_day[speaker_id] = TimeManager.day
	if gained:
		_points[speaker_id] = get_points(speaker_id) + 1
	var level: int = get_level(speaker_id)
	var leveled_up: bool = level > level_before
	if leveled_up:
		EventBus.relationship_changed.emit(speaker_id, level)
	return {"gained": gained, "leveled_up": leveled_up, "level": level}


## Quà đang chờ nhận: đủ điểm [param points_needed] và chưa nhận.
func is_gift_ready(speaker_id: StringName, points_needed: int) -> bool:
	return not _gifts_claimed.has(speaker_id) and get_points(speaker_id) >= points_needed


func claim_gift(speaker_id: StringName) -> void:
	_gifts_claimed[speaker_id] = true


func has_claimed_gift(speaker_id: StringName) -> bool:
	return _gifts_claimed.has(speaker_id)


## Quên hết (ván mới).
func clear() -> void:
	_points.clear()
	_last_talk_day.clear()
	_gifts_claimed.clear()


func get_save_data() -> Dictionary:
	var entries: Dictionary = {}
	for id: StringName in _last_talk_day:
		entries[String(id)] = {
			"points": get_points(id),
			"day": int(_last_talk_day[id]),
			"gift": _gifts_claimed.has(id),
		}
	return entries


## JSON đọc lại số nguyên thành số thực nên ép kiểu int(); bản lưu cũ chưa có mục này thì rỗng.
func load_save_data(data: Dictionary) -> void:
	clear()
	for key: Variant in data:
		var entry: Variant = data[key]
		if not entry is Dictionary:
			continue
		var id := StringName(String(key))
		_points[id] = maxi(0, int(entry.get("points", 0)))
		_last_talk_day[id] = int(entry.get("day", 0))
		if bool(entry.get("gift", false)):
			_gifts_claimed[id] = true
