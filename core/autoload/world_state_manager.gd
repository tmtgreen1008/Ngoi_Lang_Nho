extends Node
## WorldStateManager (Autoload): nhớ trạng thái từng map khi người chơi rời đi.
##
## Cách hoạt động (qua EventBus, không gọi thẳng nhau):
## 1. SceneManager phát world_state_save_requested(path) trước khi dỡ map.
## 2. Manager hỏi mọi node trong nhóm [constant PERSISTENT_GROUP] bằng get_world_state()
##    và lưu theo (đường dẫn map, persistent_key).
## 3. Khi map được nạp lại (scene_changed), manager gọi apply_world_state(state) cho
##    từng node có trạng thái đã lưu.
##
## Node muốn được nhớ chỉ cần: thêm vào nhóm "world_persistent", có thuộc tính
## persistent_key (duy nhất trong map), và hai hàm get_world_state()/apply_world_state().
## Trạng thái phải là dữ liệu thuần (số, chuỗi, mảng, dictionary) để lưu được ra file.

const PERSISTENT_GROUP: StringName = &"world_persistent"

var _states: Dictionary = {}  # scene_path -> { persistent_key -> Dictionary }


func _ready() -> void:
	EventBus.world_state_save_requested.connect(capture)
	EventBus.scene_changed.connect(restore)


## Ghi lại trạng thái các node bền vững đang có trong cây, gắn với [param scene_path].
func capture(scene_path: String) -> void:
	var snapshot: Dictionary = {}
	for node: Node in get_tree().get_nodes_in_group(PERSISTENT_GROUP):
		if node.has_method("get_world_state"):
			snapshot[String(node.get("persistent_key"))] = node.get_world_state()
	_states[scene_path] = snapshot


## Áp trạng thái đã lưu của [param scene_path] lên các node bền vững vừa được nạp.
func restore(scene_path: String) -> void:
	if not _states.has(scene_path):
		return
	var snapshot: Dictionary = _states[scene_path]
	for node: Node in get_tree().get_nodes_in_group(PERSISTENT_GROUP):
		var key: String = String(node.get("persistent_key"))
		if snapshot.has(key) and node.has_method("apply_world_state"):
			node.apply_world_state(snapshot[key])


func has_state(scene_path: String) -> bool:
	return _states.has(scene_path)


## Quên toàn bộ trạng thái (bắt đầu ván mới).
func clear() -> void:
	_states.clear()


## Gói trạng thái mọi map để lưu game.
func get_save_data() -> Dictionary:
	return _states.duplicate(true)


func load_save_data(data: Dictionary) -> void:
	_states = data.duplicate(true)
