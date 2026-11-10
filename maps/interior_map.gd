class_name InteriorMap
extends MapBase
## Lớp nền cho map trong nhà của các cửa hàng trong làng (Tiệm Tạp Hóa, Khu Giải trí): một căn phòng có tường sau,
## hai tường bên, cửa sổ và thảm cửa ở giữa cạnh dưới; ngoài phòng là màu tối. Bước lên thảm cửa thì ra lại làng.
##
## Lớp con gọi [method setup_room] trong _init và [method build_door] trong _build.

const WALL_HEIGHT: float = 96.0
const PLASTER := Color("#E8D8B0")
const BEAM := Color("#4E3320")
const FRAME := Color("#7A5230")
const SIDE_WALL := Color("#C9A66B")
const GLASS := Color("#5FA8A8")
const MAT := Color("#B5472F")

## Sàn phòng (vùng Player đi lại); tường sau nằm ngay phía trên.
var room: Rect2 = Rect2(320, 272, 640, 264)


## Đặt kích thước phòng: vùng đi lại là sàn phòng, ngoài phòng tối.
func setup_room(room_rect: Rect2) -> void:
	room = room_rect
	playable_rect = room_rect
	border_style = BorderStyle.VOID


## Tâm cửa ra (giữa cạnh dưới của phòng).
func door_center() -> Vector2:
	return Vector2(room.get_center().x, room.end.y)


## Đặt cửa ra về [param target_scene] (xuất hiện tại [param target_spawn]) và các điểm xuất hiện ngay trong cửa.
func build_door(target_scene: String, target_spawn: StringName) -> void:
	var inside: Vector2 = door_center() + Vector2(0, -48)
	for id: StringName in [&"default", &"from_village", &"from_home"]:
		add_spawn(id, inside)
	add_exit(door_center() + Vector2(0, -6), Vector2(72, 24), target_scene, target_spawn, "")


func _draw() -> void:
	super._draw()
	var left: float = room.position.x
	var width: float = room.size.x
	var wall_top: float = room.position.y - WALL_HEIGHT
	# Tường sau: vữa trắng, xà gỗ trên, chân tường gỗ.
	draw_rect(Rect2(left, wall_top, width, WALL_HEIGHT), PLASTER)
	draw_rect(Rect2(left, wall_top, width, 10), BEAM)
	draw_rect(Rect2(left, room.position.y - 14, width, 14), FRAME)
	# Tường hai bên.
	draw_rect(Rect2(left - 16, wall_top, 16, room.size.y + WALL_HEIGHT + 16), SIDE_WALL)
	draw_rect(Rect2(room.end.x, wall_top, 16, room.size.y + WALL_HEIGHT + 16), SIDE_WALL)
	# Hai ô cửa sổ.
	for x: float in [left + 100.0, left + width - 164.0]:
		draw_rect(Rect2(x - 4, wall_top + 22, 72, 52), FRAME)
		draw_rect(Rect2(x, wall_top + 26, 64, 44), GLASS)
		draw_rect(Rect2(x + 30, wall_top + 26, 4, 44), FRAME)
		draw_rect(Rect2(x, wall_top + 46, 64, 4), FRAME)
	# Thảm cửa trước lối ra.
	var door_x: float = door_center().x
	draw_rect(Rect2(door_x - 36, room.end.y - 24, 72, 24), BEAM)
	draw_rect(Rect2(door_x - 32, room.end.y - 22, 64, 20), MAT)
