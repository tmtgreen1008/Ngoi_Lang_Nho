extends MapBase
## Trong nhà: một căn phòng gỗ nhỏ có giường để ngủ qua đêm. Ra cửa (thảm đỏ phía dưới) về sân nhà.
##
## Ngủ ở đây cho thời gian sang sáng hôm sau; vườn ngoài sân vẫn lớn đúng số ngày (xem FarmField).

const HOME_MAP: String = "res://maps/home/home.tscn"
## Sàn phòng (vùng Player đi lại). Tường sau nằm ngay phía trên sàn.
const ROOM := Rect2(320, 272, 640, 264)
const WALL_HEIGHT: float = 96.0
const PLASTER := Color("#E8D8B0")
const BEAM := Color("#4E3320")
const FRAME := Color("#7A5230")
const SIDE_WALL := Color("#C9A66B")
const GLASS := Color("#5FA8A8")
const MAT := Color("#B5472F")

## Vùng tương tác của bếp lò.
var stove: InteractableComponent


func _init() -> void:
	playable_rect = ROOM
	border_style = BorderStyle.VOID
	floor_tile = TerrainTiles.Tile.WOOD_FLOOR


func _build() -> void:
	var door_center: float = ROOM.get_center().x
	add_spawn(&"default", Vector2(door_center, ROOM.end.y - 48))
	add_spawn(&"from_home", Vector2(door_center, ROOM.end.y - 48))
	add_exit(Vector2(door_center, ROOM.end.y - 6), Vector2(72, 24), HOME_MAP, &"from_house", "")

	# Giường kê sát tường sau bên trái; lại gần bấm E để ngủ.
	var bed_feet := Vector2(430, 392)
	add_prop("res://assets/art/props/bed.png", bed_feet, 1, 14.0)
	var bed := InteractableComponent.new()
	bed.position = bed_feet + Vector2(0, -34)
	bed.prompt_text = "Đi ngủ"
	bed.interact_radius = 56.0
	bed.interacted.connect(_on_bed_used)
	add_child(bed)

	# Bếp lò sát tường sau, giữa phòng; lại gần bấm E để nấu ăn (CookingUI nghe EventBus.cooking_requested).
	var stove_feet := Vector2(640, 336)
	add_prop("res://assets/art/props/stove.png", stove_feet, 1, 14.0)
	stove = InteractableComponent.new()
	stove.position = stove_feet + Vector2(0, -20)
	stove.prompt_text = "Nấu ăn"
	stove.interact_radius = 52.0
	stove.interacted.connect(func(interactor: Node) -> void: EventBus.cooking_requested.emit(interactor))
	add_child(stove)

	# Chum nước và chậu cây ở góc phải.
	add_decor(Decor.JAR, Vector2(912, 330))
	add_decor(Decor.JAR, Vector2(912, 392))
	add_decor(Decor.BUSH, Vector2(860, 318))


func _on_bed_used(_interactor: Node) -> void:
	StaminaManager.go_to_bed()  # ngủ giường thì sáng mai đầy sức
	TimeManager.sleep_until_morning()
	EventBus.notice_requested.emit("Bạn ngủ một giấc ngon, thể lực đã hồi đầy. Sang ngày mới!", &"success")


func _draw() -> void:
	super._draw()
	var left: float = ROOM.position.x
	var width: float = ROOM.size.x
	var wall_top: float = ROOM.position.y - WALL_HEIGHT
	# Tường sau: vữa trắng, xà gỗ trên, chân tường gỗ.
	draw_rect(Rect2(left, wall_top, width, WALL_HEIGHT), PLASTER)
	draw_rect(Rect2(left, wall_top, width, 10), BEAM)
	draw_rect(Rect2(left, ROOM.position.y - 14, width, 14), FRAME)
	# Tường hai bên.
	draw_rect(Rect2(left - 16, wall_top, 16, ROOM.size.y + WALL_HEIGHT + 16), SIDE_WALL)
	draw_rect(Rect2(ROOM.end.x, wall_top, 16, ROOM.size.y + WALL_HEIGHT + 16), SIDE_WALL)
	# Hai ô cửa sổ.
	for x: float in [left + 100.0, left + width - 164.0]:
		draw_rect(Rect2(x - 4, wall_top + 22, 72, 52), FRAME)
		draw_rect(Rect2(x, wall_top + 26, 64, 44), GLASS)
		draw_rect(Rect2(x + 30, wall_top + 26, 4, 44), FRAME)
		draw_rect(Rect2(x, wall_top + 46, 64, 4), FRAME)
	# Thảm cửa trước lối ra.
	var door_center: float = ROOM.get_center().x
	draw_rect(Rect2(door_center - 36, ROOM.end.y - 24, 72, 24), BEAM)
	draw_rect(Rect2(door_center - 32, ROOM.end.y - 22, 64, 20), MAT)
