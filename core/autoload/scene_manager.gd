extends Node
## SceneManager (Autoload): chuyển giữa các map, giữ Player ở lại qua các lần chuyển.
##
## Cấu trúc: Main đăng ký một node "world" (chứa map hiện tại và Player) bằng
## [method register_world]. Mỗi lần chuyển map:
##   làm mờ -> phát world_state_save_requested -> dỡ map cũ -> nạp map mới ->
##   đặt Player tại SpawnPoint -> phát scene_changed -> làm sáng.
##
## Cách yêu cầu chuyển map (không gọi trực tiếp, đi qua EventBus):
##   EventBus.scene_change_requested.emit("res://maps/home/home.tscn", &"from_market")

const FADE_TIME: float = 0.25
const SPAWN_GROUP: StringName = &"spawn_points"
const DEFAULT_SPAWN: StringName = &"default"

var current_scene_path: String = ""
var current_map: Node = null
var is_transitioning: bool = false

var _world: Node = null
var _player: Node2D = null
var _fade: ColorRect


func _ready() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 1)
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_fade)
	EventBus.scene_change_requested.connect(change_scene)


## Main gọi một lần: [param world] chứa map, [param player] là Player bền vững.
func register_world(world: Node, player: Node2D) -> void:
	_world = world
	_player = player


## Chuyển tới map [param scene_path], đặt Player tại SpawnPoint [param spawn_id].
## Bỏ qua nếu đang chuyển dở. Hàm chạy bất đồng bộ, không cần await.
func change_scene(scene_path: String, spawn_id: StringName = DEFAULT_SPAWN) -> void:
	if is_transitioning or _world == null:
		return
	var packed: PackedScene = load(scene_path) as PackedScene
	if packed == null:
		push_error("SceneManager: khong nap duoc map '%s'" % scene_path)
		return
	is_transitioning = true

	if current_map != null:
		await _fade_to(1.0)
		EventBus.world_state_save_requested.emit(current_scene_path)
		_world.remove_child(current_map)
		current_map.queue_free()
		current_map = null

	var map: Node = packed.instantiate()
	_world.add_child(map)
	_world.move_child(map, 0)  # Map nằm dưới Player.
	current_map = map
	current_scene_path = scene_path
	_place_player(map, spawn_id)
	EventBus.scene_changed.emit(scene_path)

	await _fade_to(0.0)
	is_transitioning = false


func _place_player(map: Node, spawn_id: StringName) -> void:
	var fallback: Node2D = null
	for node: Node in get_tree().get_nodes_in_group(SPAWN_GROUP):
		if not map.is_ancestor_of(node):
			continue
		if node.get("spawn_id") == spawn_id:
			_move_player_to(node as Node2D)
			return
		if fallback == null:
			fallback = node as Node2D
	if fallback != null:
		push_warning("SceneManager: khong thay spawn '%s', dung spawn khac" % spawn_id)
		_move_player_to(fallback)


func _move_player_to(spawn: Node2D) -> void:
	_player.global_position = spawn.global_position
	_player.set("velocity", Vector2.ZERO)


func _fade_to(alpha: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_fade, "color:a", alpha, FADE_TIME)
	await tween.finished
