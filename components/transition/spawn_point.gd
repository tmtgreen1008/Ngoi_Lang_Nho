class_name SpawnPoint
extends Marker2D
## Điểm xuất hiện của Player trong một map. SceneManager tìm theo [member spawn_id].

## Mã điểm spawn ("default", "from_market"...). Phải khớp với target_spawn của SceneExit dẫn tới đây.
@export var spawn_id: StringName = &"default"


func _ready() -> void:
	add_to_group(SceneManager.SPAWN_GROUP)
