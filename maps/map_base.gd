class_name MapBase
extends Node2D
## Lớp nền cho các map: nền màu, tường quanh màn hình, tiêu đề, và hàm tiện ích
## đặt SpawnPoint / SceneExit. Map cụ thể kế thừa và ghi đè [method _build].
##
## Nền và hình vẽ hiện là khối màu tạm; khi có art, thay bằng TileMapLayer trong scene.

const WORLD_SIZE: Vector2 = Vector2(1280, 720)

@export var map_title: String = ""
@export var background_color: Color = Color(0.36, 0.55, 0.3)


func _ready() -> void:
	_build_walls()
	if not map_title.is_empty():
		var label := Label.new()
		label.text = map_title
		label.position = Vector2(0, 52)
		label.custom_minimum_size = Vector2(WORLD_SIZE.x, 0)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 22)
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constant_override("outline_size", 5)
		add_child(label)
	_build()


## Map cụ thể ghi đè để đặt spawn, lối ra, NPC, vườn...
func _build() -> void:
	pass


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), background_color)


## Đặt một điểm xuất hiện của Player.
func add_spawn(id: StringName, pos: Vector2) -> SpawnPoint:
	var spawn := SpawnPoint.new()
	spawn.spawn_id = id
	spawn.position = pos
	add_child(spawn)
	return spawn


## Đặt một lối ra dẫn tới [param target_scene] (xuất hiện tại SpawnPoint [param target_spawn]).
func add_exit(center: Vector2, size: Vector2, target_scene: String, target_spawn: StringName, label: String) -> SceneExit:
	var exit := SceneExit.new()
	exit.position = center
	exit.size = size
	exit.target_scene = target_scene
	exit.target_spawn = target_spawn
	exit.label_text = label
	add_child(exit)
	return exit


## Bốn bức tường vô hình quanh màn hình để Player không đi ra ngoài.
func _build_walls() -> void:
	var t: float = 40.0
	var rects: Array[Rect2] = [
		Rect2(-t, -t, WORLD_SIZE.x + t * 2, t),
		Rect2(-t, WORLD_SIZE.y, WORLD_SIZE.x + t * 2, t),
		Rect2(-t, 0, t, WORLD_SIZE.y),
		Rect2(WORLD_SIZE.x, 0, t, WORLD_SIZE.y),
	]
	for rect: Rect2 in rects:
		var body := StaticBody2D.new()
		var shape := CollisionShape2D.new()
		var box := RectangleShape2D.new()
		box.size = rect.size
		shape.shape = box
		body.position = rect.position + rect.size / 2.0
		body.add_child(shape)
		add_child(body)
