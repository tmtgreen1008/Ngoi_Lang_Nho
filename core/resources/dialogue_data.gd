class_name DialogueData
extends Resource
## Lời thoại của một NPC (file .tres trong data/dialogues/), gắn vào VendorData.dialogue.
##
## Chỉ chứa chữ và quà tặng; độ thân thiết do RelationshipManager giữ, cách hiện do DialogueBox lo.
## Mỗi lần "Trò chuyện" bốc một câu từ kho chung + kho của mùa hiện tại + kho "người quen" khi đã đủ thân.

## Id người nói, trùng id cửa hàng (vd: &"tap_hoa") để lưu độ thân thiết.
@export var speaker_id: StringName = &""
@export var display_name: String = ""

@export_group("Chào hỏi")
## Câu chào lần đầu gặp.
@export var first_meeting: PackedStringArray = []
## Câu chào các lần sau (bốc theo ngày).
@export var greetings: PackedStringArray = []
## Câu tạm biệt.
@export var farewells: PackedStringArray = []

@export_group("Trò chuyện")
@export var lines_general: PackedStringArray = []
@export var lines_spring: PackedStringArray = []
@export var lines_summer: PackedStringArray = []
@export var lines_autumn: PackedStringArray = []
@export var lines_winter: PackedStringArray = []
## Chỉ nghe được khi đã quen biết (cấp 1 trở lên).
@export var friend_lines: PackedStringArray = []
## Chỉ nghe được khi thân thiết (cấp 3).
@export var close_lines: PackedStringArray = []

@export_group("Quà tặng")
## Đạt đủ [member gift_points] điểm thân thiết thì NPC tặng quà một lần.
@export var gift_item_id: StringName = &""
@export_range(1, 99, 1) var gift_amount: int = 1
@export_range(1, 100, 1) var gift_points: int = 3
@export var gift_text: String = ""


## Câu để trò chuyện: gộp kho chung, kho của [param season] (giá trị TimeManager.Season) và kho theo độ
## thân thiết [param level] (0-3). [param salt] chọn câu một cách xác định (cùng salt thì cùng câu).
func pick_line(season: int, level: int, salt: int) -> String:
	var pool: PackedStringArray = lines_general.duplicate()
	pool.append_array([lines_spring, lines_summer, lines_autumn, lines_winter][clampi(season, 0, 3)])
	if level >= 1:
		pool.append_array(friend_lines)
	if level >= 3:
		pool.append_array(close_lines)
	if pool.is_empty():
		return "..."
	return pool[posmod(salt, pool.size())]


func pick_greeting(salt: int) -> String:
	return _pick(greetings, salt, "Chào cháu.")


func pick_farewell(salt: int) -> String:
	return _pick(farewells, salt, "Đi nhé.")


func pick_first_meeting() -> String:
	return _pick(first_meeting, 0, "Chào cháu.")


func _pick(pool: PackedStringArray, salt: int, fallback: String) -> String:
	return fallback if pool.is_empty() else pool[posmod(salt, pool.size())]


func is_valid() -> bool:
	return speaker_id != &"" and not display_name.is_empty() and not lines_general.is_empty()
