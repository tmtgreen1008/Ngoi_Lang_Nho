class_name SceneExit
extends Area2D
## Cửa/lối ra: Player bước vào thì yêu cầu chuyển sang map khác (qua EventBus).
##
## Không biết SceneManager: chỉ phát EventBus.scene_change_requested.
## Mặc định lối ra vô hình (dùng biển chỉ đường hoặc cửa vẽ sẵn để báo vị trí); đặt
## [member show_marker] = true để hiện ô vàng và chữ khi cần gỡ lỗi.

## Đường dẫn scene map đích, vd "res://maps/home/home.tscn".
@export_file("*.tscn") var target_scene: String = ""
## SpawnPoint ở map đích nơi Player xuất hiện.
@export var target_spawn: StringName = &"default"
@export var size: Vector2 = Vector2(40, 120)
## Chỉ dùng khi [member show_marker] bật.
@export var label_text: String = ""
@export var color: Color = Color(1.0, 0.9, 0.4, 0.35)
## Hiện ô đánh dấu và nhãn chữ (gỡ lỗi).
@export var show_marker: bool = false


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1  # Layer của Player.
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = size
	shape.shape = box
	add_child(shape)
	body_entered.connect(_on_body_entered)

	if show_marker and not label_text.is_empty():
		var label := Label.new()
		label.text = label_text
		label.add_theme_font_size_override("font_size", 13)
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constant_override("outline_size", 4)
		label.custom_minimum_size = Vector2(160, 0)
		label.position = Vector2(-80, -size.y / 2.0 - 24)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(label)
	queue_redraw()


func _draw() -> void:
	if show_marker:
		draw_rect(Rect2(-size / 2.0, size), color)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not target_scene.is_empty():
		EventBus.scene_change_requested.emit(target_scene, target_spawn)
