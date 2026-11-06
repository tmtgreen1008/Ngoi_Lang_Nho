extends Node
## SaveManager (Autoload): lưu và nạp ván chơi ra file JSON trong user://saves.
##
## Gom dữ liệu của các hệ thống qua get_save_data()/load_save_data() của từng bên:
## TimeManager, EconomyManager, WorldStateManager (trạng thái các map), kho đồ
## Player, cùng map và vị trí hiện tại. Tự lưu vào slot "autosave" mỗi khi sang ngày mới.
##
## An toàn dữ liệu:
## - Ghi ra file tạm rồi đổi tên, nên bị ngắt giữa chừng cũng không làm hỏng bản cũ.
## - Nạp game kiểm tra file hợp lệ TRƯỚC khi đổi bất kỳ trạng thái nào.
## - Hàm trả về chuỗi lỗi để UI hiển thị; chuỗi rỗng nghĩa là thành công.
##
## Lưu ý JSON: số nguyên đọc lại thành số thực, nên các hàm load_save_data phải ép kiểu int().

const SAVE_VERSION: int = 1
const SAVE_DIR: String = "user://saves"
const DEFAULT_SLOT: StringName = &"slot1"
const AUTOSAVE_SLOT: StringName = &"autosave"

var _busy: bool = false


func _ready() -> void:
	EventBus.day_changed.connect(_on_day_changed)


func get_slot_path(slot: StringName) -> String:
	return SAVE_DIR.path_join("%s.json" % slot)


func has_save(slot: StringName = DEFAULT_SLOT) -> bool:
	return FileAccess.file_exists(get_slot_path(slot))


## Thông tin tóm tắt của một slot để hiển thị; rỗng nếu không có hoặc file hỏng.
func get_slot_info(slot: StringName = DEFAULT_SLOT) -> Dictionary:
	var result: Dictionary = _read_save(slot)
	if result.has("error"):
		return {}
	return result["data"].get("meta", {})


## Slot có bản lưu hợp lệ mới nhất (so sánh thời điểm lưu), hoặc &"" nếu chưa có bản nào.
## Dùng cho nút "Tiếp tục" ở màn hình chính.
func get_latest_slot() -> StringName:
	var best_slot: StringName = &""
	var best_time: String = ""
	for slot: StringName in [DEFAULT_SLOT, AUTOSAVE_SLOT]:
		var info: Dictionary = get_slot_info(slot)
		if info.is_empty():
			continue
		# Chuỗi ISO "YYYY-MM-DDTHH:MM:SS" so sánh theo thứ tự chữ cái cũng là thứ tự thời gian.
		var saved_at: String = String(info.get("saved_at", ""))
		if best_slot == &"" or saved_at > best_time:
			best_slot = slot
			best_time = saved_at
	return best_slot


## Lưu ván chơi hiện tại vào [param slot]. Trả về lỗi hoặc "".
func save_game(slot: StringName = DEFAULT_SLOT) -> String:
	if _busy or SceneManager.is_transitioning:
		return "Đang bận, thử lại sau."
	var snapshot: Dictionary = _build_snapshot()
	if snapshot.is_empty():
		return "Chưa có ván chơi để lưu."
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var path: String = get_slot_path(slot)
	var temp_path: String = path + ".tmp"
	var file: FileAccess = FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		return "Không ghi được file lưu (lỗi %d)." % FileAccess.get_open_error()
	file.store_string(JSON.stringify(snapshot, "\t"))
	file.close()
	var rename_error: int = DirAccess.rename_absolute(temp_path, path)
	if rename_error != OK:
		return "Không hoàn tất được file lưu (lỗi %d)." % rename_error
	EventBus.game_saved.emit()
	return ""


## Nạp ván chơi từ [param slot]. Chạy bất đồng bộ (đổi map có hiệu ứng mờ); dùng
## `await` nếu cần biết khi nào xong. Trả về lỗi hoặc "".
func load_game(slot: StringName = DEFAULT_SLOT) -> String:
	if _busy or SceneManager.is_transitioning:
		return "Đang bận, thử lại sau."
	var result: Dictionary = _read_save(slot)
	if result.has("error"):
		return result["error"]
	var data: Dictionary = result["data"]
	var map_path: String = String(data.get("map", ""))
	if map_path.is_empty() or not ResourceLoader.exists(map_path):
		return "Bản lưu hỏng: không tìm thấy map."

	_busy = true
	var player: Node = get_tree().get_first_node_in_group("player")
	var player_data: Dictionary = data.get("player", {})
	EconomyManager.load_save_data(data.get("economy", {}))
	WorldStateManager.load_save_data(data.get("world", {}))
	if player != null:
		player.inventory.load_save_data(player_data.get("inventory", []))
	TimeManager.load_save_data(data.get("time", {}))

	# Không ghi trạng thái map cũ (sẽ đè lên dữ liệu vừa nạp).
	# Đăng ký lắng nghe TRƯỚC khi gọi: khi chưa có map nào (nạp từ màn hình chính),
	# change_scene không có bước làm mờ trước nên phát scene_changed ngay trong lời gọi,
	# nếu chỉ await sau đó sẽ lỡ tín hiệu và chờ mãi.
	var map_loaded: Array = [false]
	var mark_loaded: Callable = func(_path: String) -> void: map_loaded[0] = true
	EventBus.scene_changed.connect(mark_loaded, CONNECT_ONE_SHOT)
	SceneManager.change_scene(map_path, SceneManager.DEFAULT_SPAWN, false)
	if not map_loaded[0]:
		if not SceneManager.is_transitioning:
			# change_scene từ chối (không nạp được scene): không chờ vô ích.
			EventBus.scene_changed.disconnect(mark_loaded)
			_busy = false
			return "Không nạp được map của bản lưu."
		await EventBus.scene_changed
	var position_data: Array = player_data.get("position", [])
	if player != null and position_data.size() == 2:
		player.global_position = Vector2(float(position_data[0]), float(position_data[1]))
	_busy = false
	EventBus.game_loaded.emit()
	return ""


func _build_snapshot() -> Dictionary:
	var player: Node = get_tree().get_first_node_in_group("player")
	if player == null or SceneManager.current_scene_path.is_empty():
		return {}
	# Chốt trạng thái map đang đứng (các map đã rời đã được ghi từ trước).
	WorldStateManager.capture(SceneManager.current_scene_path)
	return {
		"version": SAVE_VERSION,
		"meta": {
			"saved_at": Time.get_datetime_string_from_system(),
			"day": TimeManager.day,
			"season": int(TimeManager.season),
			"time": TimeManager.get_time_string(),
			"money": EconomyManager.money,
			"map": SceneManager.current_scene_path,
		},
		"map": SceneManager.current_scene_path,
		"time": TimeManager.get_save_data(),
		"economy": EconomyManager.get_save_data(),
		"world": WorldStateManager.get_save_data(),
		"player": {
			"inventory": player.inventory.get_save_data(),
			"position": [player.global_position.x, player.global_position.y],
		},
	}


## Đọc và kiểm tra file. Trả về {"data": Dictionary} hoặc {"error": String}.
func _read_save(slot: StringName) -> Dictionary:
	var path: String = get_slot_path(slot)
	if not FileAccess.file_exists(path):
		return {"error": "Chưa có bản lưu."}
	var text: String = FileAccess.get_file_as_string(path)
	# JSON.new().parse() trả mã lỗi êm; JSON.parse_string() in lỗi đỏ ra console.
	var json := JSON.new()
	if json.parse(text) != OK or not json.data is Dictionary:
		return {"error": "Bản lưu bị hỏng."}
	var parsed: Dictionary = json.data
	var version: int = int(parsed.get("version", 0))
	if version < 1 or version > SAVE_VERSION:
		return {"error": "Bản lưu có phiên bản không hỗ trợ (%d)." % version}
	return {"data": parsed}


## Tự lưu khi sang ngày mới. Hoãn một nhịp để các hệ thống khác xử lý day_changed xong.
func _on_day_changed(_day: int) -> void:
	if _busy or SceneManager.current_map == null or SceneManager.is_transitioning:
		return
	_autosave.call_deferred()


func _autosave() -> void:
	var error: String = save_game(AUTOSAVE_SLOT)
	if not error.is_empty():
		push_warning("SaveManager: tu luu that bai: %s" % error)
