class_name Signpost
extends Node2D
## Biển chỉ đường bằng gỗ: một cột và các tấm ván có mũi tên, mỗi ván một dòng chữ.
## Thay cho chữ nổi trên nền map (chữ nổi chỉ nên dùng khi gỡ lỗi).
##
## Gốc toạ độ là CHÂN cột; biển vẽ phía trên. Hiện vẽ bằng code (khối gỗ); khi có ảnh biển
## thật (docs/ASSET_PROMPTS.md, đợt 2) có thể thay phần [method _draw].

## Mỗi phần tử là chữ trên một tấm ván.
@export var entries: PackedStringArray = []
## Mũi tên chỉ sang phải (true) hay sang trái (false).
@export var points_right: bool = true

const FONT_SIZE: int = 13
const PLANK_HEIGHT: int = 22
const PLANK_GAP: int = 4
const PADDING: int = 10
const ARROW_WIDTH: int = 10
const POST_WIDTH: int = 8

const WOOD := Color("#A67C52")
const WOOD_LIGHT := Color("#C9A66B")
const WOOD_DARK := Color("#7A5230")
const OUTLINE := Color("#2A1F1A")


func _ready() -> void:
	var shadow: Sprite2D = Shadow.create(26.0)
	shadow.position = Vector2(0, -2)
	add_child(shadow)
	# Cột biển chặn nhẹ để Player không đi xuyên.
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(POST_WIDTH + 4, 8)
	shape.shape = box
	body.position = Vector2(0, -4)
	body.add_child(shape)
	add_child(body)
	queue_redraw()


## Chiều cao toàn bộ biển (pixel).
func get_sign_height() -> float:
	return entries.size() * (PLANK_HEIGHT + PLANK_GAP) + 18.0


func _draw() -> void:
	var total_height: float = get_sign_height()
	# Cột.
	draw_rect(Rect2(-POST_WIDTH / 2.0 - 1, -total_height - 1, POST_WIDTH + 2, total_height + 1), OUTLINE)
	draw_rect(Rect2(-POST_WIDTH / 2.0, -total_height, POST_WIDTH, total_height), WOOD_DARK)
	var font: Font = ThemeDB.fallback_font
	for i: int in entries.size():
		var text_width: float = font.get_string_size(entries[i], HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x
		var width: float = text_width + PADDING * 2
		var top: float = -total_height + 6 + i * (PLANK_HEIGHT + PLANK_GAP)
		var left: float = -width / 2.0
		var right: float = width / 2.0
		var points := PackedVector2Array()
		if points_right:
			points = PackedVector2Array([
				Vector2(left, top), Vector2(right, top),
				Vector2(right + ARROW_WIDTH, top + PLANK_HEIGHT / 2.0),
				Vector2(right, top + PLANK_HEIGHT), Vector2(left, top + PLANK_HEIGHT),
			])
		else:
			points = PackedVector2Array([
				Vector2(right, top), Vector2(left, top),
				Vector2(left - ARROW_WIDTH, top + PLANK_HEIGHT / 2.0),
				Vector2(left, top + PLANK_HEIGHT), Vector2(right, top + PLANK_HEIGHT),
			])
		draw_colored_polygon(points, WOOD)
		# Dải sáng phía trên cho có khối.
		draw_rect(Rect2(left, top, width, 3), WOOD_LIGHT)
		var outline: PackedVector2Array = points.duplicate()
		outline.append(points[0])
		draw_polyline(outline, OUTLINE, 2.0)
		var text_x: float = left + PADDING
		draw_string(font, Vector2(text_x, top + PLANK_HEIGHT - 7), entries[i], HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, OUTLINE)
