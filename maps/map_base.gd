class_name MapBase
extends Node2D
## Lớp nền cho các map: nền lát ô thật, vùng đi lại, vành đai cây, đường đất bo góc, đốm cỏ/đất,
## bóng đổ, biển chỉ đường, và hàm tiện ích đặt SpawnPoint / SceneExit / đồ vật / cụm cây.
## Map cụ thể kế thừa và ghi đè [method _build] (và [method _tile_for_cell] nếu có đường đi).
##
## Tên map hiện bằng thông báo ngắn khi vào (thay cho chữ nổi trên nền đất).

const WORLD_SIZE: Vector2 = Vector2(1280, 720)

## Cách xử lý vùng bên ngoài [member playable_rect].
enum BorderStyle {
	NONE,  ## Chỉ có tường vô hình.
	TREES,  ## Rặng cây rậm viền quanh vùng chơi, ngoài vùng tối hơn.
	VOID,  ## Ngoài vùng là màu tối (trong nhà).
}

## Đồ trang trí trong sheet props/decor_sheet.png (thứ tự khung trong ảnh).
enum Decor { BANANA, BAMBOO, BUSH, FENCE, JAR }

const DECOR_SHEET: String = "res://assets/art/props/decor_sheet.png"
const DECOR_CELL: int = 48
## Bề rộng bóng đổ ứng với từng món trang trí (pixel).
const DECOR_SHADOW_WIDTH: Dictionary = {
	Decor.BANANA: 30.0, Decor.BAMBOO: 26.0, Decor.BUSH: 32.0, Decor.FENCE: 36.0, Decor.JAR: 28.0,
}
## Màu nhân vào lá cây theo mùa (Xuân, Hạ, Thu, Đông): Xuân giữ nguyên, Hạ xanh đậm hơn, Thu ngả vàng
## cam, Đông xỉn và lạnh. Chỉ áp cho cây cối ([constant FOLIAGE]); hàng rào, chum không đổi.
const FOLIAGE_TINTS: Array[Color] = [
	Color(1.0, 1.0, 1.0),
	Color(0.92, 1.06, 0.9),
	Color(1.2, 0.92, 0.62),
	Color(0.72, 0.84, 0.92),
]
const FOLIAGE: Array[Decor] = [Decor.BANANA, Decor.BAMBOO, Decor.BUSH]
## Bán kính bo góc đường đất (pixel).
const PATH_CORNER_RADIUS: float = 16.0
const PATCH_COUNT: int = 160
const VOID_COLOR := Color("#1B120D")

@export var map_title: String = ""
@export var background_color: Color = Color(0.36, 0.55, 0.3)
## Loại nền lát khắp map (xem TerrainTiles.Tile).
@export var floor_tile: TerrainTiles.Tile = TerrainTiles.Tile.GRASS
## Vùng Player đi lại được (toạ độ thế giới). Mặc định cả màn hình.
@export var playable_rect: Rect2 = Rect2(Vector2.ZERO, WORLD_SIZE)
@export var border_style: BorderStyle = BorderStyle.NONE
## Rải đốm cỏ úa, cỏ rậm và vệt đất lên bãi cỏ cho đỡ lặp.
@export var ground_variation: bool = false
## Hạt giống cho việc rải đốm và rặng cây (cùng hạt giống thì map luôn giống nhau).
@export var variation_seed: int = 7

var _exit_rects: Array[Rect2] = []
var _foliage_sprites: Array[Sprite2D] = []


func _ready() -> void:
	# Xếp lớp theo chiều sâu: đồ vật, cây, NPC và Player (được SceneManager đưa vào map) đứng thấp hơn
	# (y lớn hơn) thì vẽ đè lên đồ đứng cao hơn. Nền map (_draw) luôn nằm dưới mọi node con.
	y_sort_enabled = true
	# Nền đất theo mùa hiện tại; đổi mùa khi đang ở trong map thì vẽ lại.
	TerrainTiles.set_season(TimeManager.season)
	EventBus.season_changed.connect(_on_season_changed)
	_build_walls()
	_build()
	if border_style == BorderStyle.TREES:
		_build_tree_belt()
	if not map_title.is_empty():
		EventBus.toast_requested.emit(map_title)


func _on_season_changed(season: int, _year: int) -> void:
	if TerrainTiles.set_season(season):
		queue_redraw()
	_tint_foliage()


## Màu lá cây của mùa [param season] (giá trị của TimeManager.Season).
static func foliage_tint(season: int) -> Color:
	return FOLIAGE_TINTS[clampi(season, 0, FOLIAGE_TINTS.size() - 1)]


## Áp màu mùa hiện tại lên mọi cây đã đặt (cả rặng cây viền map).
func _tint_foliage() -> void:
	var tint: Color = foliage_tint(TerrainTiles.get_season())
	for sprite: Sprite2D in _foliage_sprites:
		sprite.modulate = tint


## Map cụ thể ghi đè để đặt spawn, lối ra, NPC, vườn...
func _build() -> void:
	pass


## Loại ô nền tại [param cell] (toạ độ ô lưới). Mặc định cả map một loại nền [member floor_tile];
## map cụ thể ghi đè để thêm đường đi, hoa cỏ...
func _tile_for_cell(_cell: Vector2i) -> TerrainTiles.Tile:
	return floor_tile


# --- Vẽ nền -------------------------------------------------------------------------------


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), background_color)
	var texture: Texture2D = TerrainTiles.get_texture()
	if texture == null:
		return
	_draw_floor(texture)
	if ground_variation:
		_draw_ground_patches(texture)
	_draw_path_blend(texture)
	_draw_border_overlay()


## Lát từng ô nền (ô cuối hàng/cột bị cắt cho vừa màn hình).
func _draw_floor(texture: Texture2D) -> void:
	var size: int = TerrainTiles.TILE_SIZE
	var world_rect := Rect2(Vector2.ZERO, WORLD_SIZE)
	for cell_y: int in ceili(WORLD_SIZE.y / size):
		for cell_x: int in ceili(WORLD_SIZE.x / size):
			var destination: Rect2 = Rect2(cell_x * size, cell_y * size, size, size).intersection(world_rect)
			var source: Rect2 = TerrainTiles.source_rect(_tile_for_cell(Vector2i(cell_x, cell_y)))
			source.size = destination.size
			draw_texture_rect_region(texture, destination, source)


## Rải các đốm nhỏ lên bãi cỏ: cỏ úa vàng, cỏ rậm sẫm, vệt đất lởm chởm. Mỗi đốm nằm gọn trong
## một ô nên ảnh không lấn sang ô khác trong sheet.
func _draw_ground_patches(texture: Texture2D) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = variation_seed
	var size: int = TerrainTiles.TILE_SIZE
	var cols: int = floori(WORLD_SIZE.x / size)
	var rows: int = floori(WORLD_SIZE.y / size)
	for i: int in PATCH_COUNT:
		var cell := Vector2i(rng.randi_range(0, cols - 1), rng.randi_range(0, rows - 1))
		var kind: int = rng.randi_range(0, 2)
		var radius: float = rng.randf_range(8.0, 20.0)
		var center := Vector2(rng.randf_range(radius, size - radius), rng.randf_range(radius, size - radius))
		var tile: TerrainTiles.Tile = _tile_for_cell(cell)
		if tile != TerrainTiles.Tile.GRASS and tile != TerrainTiles.Tile.GRASS_FLOWERS:
			continue
		# Đốm sát đường đất thì bỏ để không đè lên chỗ bo góc.
		if _touches_path(cell):
			continue
		var origin := Vector2(cell * size)
		var source_tile: TerrainTiles.Tile = TerrainTiles.Tile.PATH if kind == 2 else tile
		var tint: Color = Color.WHITE
		if kind == 0:
			tint = Color(1.0, 0.86, 0.42)  # cỏ úa vàng
		elif kind == 1:
			tint = Color(0.52, 0.78, 0.52)  # cỏ rậm sẫm
		var points := PackedVector2Array()
		for step: int in 9:
			var angle: float = TAU * step / 9.0
			var r: float = radius * rng.randf_range(0.6, 1.0)
			points.append((center + Vector2(cos(angle), sin(angle) * 0.75) * r).round())
		_draw_textured_polygon(texture, points, origin, source_tile, tint)


## Làm mềm viền đường đất: góc lồi bo tròn (cỏ lấn vào), góc lõm lấp tròn (đất lấn ra cỏ).
func _draw_path_blend(texture: Texture2D) -> void:
	var size: int = TerrainTiles.TILE_SIZE
	var directions: Array[Vector2i] = [Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(1, 1)]
	for cell_y: int in ceili(WORLD_SIZE.y / size):
		for cell_x: int in ceili(WORLD_SIZE.x / size):
			var cell := Vector2i(cell_x, cell_y)
			if not _is_path(cell):
				continue
			for direction: Vector2i in directions:
				var kind: int = path_corner_kind(cell, direction)
				var corner := Vector2(cell * size) + Vector2((direction.x + 1) / 2 * size, (direction.y + 1) / 2 * size)
				if kind == PathCorner.CONVEX:
					var neighbor: TerrainTiles.Tile = _tile_for_cell(cell + Vector2i(direction.x, 0))
					var cut: PackedVector2Array = _convex_cut_polygon(corner, direction)
					_draw_textured_polygon(texture, cut, Vector2(cell * size), neighbor, Color.WHITE)
				elif kind == PathCorner.CONCAVE:
					var diagonal: Vector2i = cell + direction
					var fill: PackedVector2Array = _concave_fill_polygon(corner, direction)
					_draw_textured_polygon(texture, fill, Vector2(diagonal * size), TerrainTiles.Tile.PATH, Color.WHITE)


## Kiểu góc của ô đường [param cell] ở hướng [param direction] (mỗi toạ độ -1 hoặc 1).
enum PathCorner {
	NONE,  ## Không cần xử lý.
	CONVEX,  ## Góc lồi: hai ô kề cạnh đều không phải đường, bo tròn góc đường.
	CONCAVE,  ## Góc lõm: hai ô kề cạnh là đường nhưng ô chéo thì không, lấp tròn phần ô chéo.
}


## Phân loại góc để bo tròn. Ô ngoài màn hình coi như đường để không cắt ở mép.
func path_corner_kind(cell: Vector2i, direction: Vector2i) -> int:
	var horizontal: bool = _is_path(cell + Vector2i(direction.x, 0))
	var vertical: bool = _is_path(cell + Vector2i(0, direction.y))
	if not horizontal and not vertical:
		return PathCorner.CONVEX
	if horizontal and vertical and not _is_path(cell + direction):
		return PathCorner.CONCAVE
	return PathCorner.NONE


func _is_path(cell: Vector2i) -> bool:
	var size: int = TerrainTiles.TILE_SIZE
	if cell.x < 0 or cell.y < 0 or cell.x >= ceili(WORLD_SIZE.x / size) or cell.y >= ceili(WORLD_SIZE.y / size):
		return true
	return _tile_for_cell(cell) == TerrainTiles.Tile.PATH


func _touches_path(cell: Vector2i) -> bool:
	for dy: int in range(-1, 2):
		for dx: int in range(-1, 2):
			if _tile_for_cell(cell + Vector2i(dx, dy)) == TerrainTiles.Tile.PATH:
				return true
	return false


## Phần góc nằm NGOÀI cung tròn bán kính [constant PATH_CORNER_RADIUS] (phủ cỏ lên góc đường).
func _convex_cut_polygon(corner: Vector2, direction: Vector2i) -> PackedVector2Array:
	var r: float = PATH_CORNER_RADIUS
	var arc_center: Vector2 = corner - Vector2(direction.x * r, direction.y * r)
	var points := PackedVector2Array([corner, Vector2(corner.x - direction.x * r, corner.y)])
	for step: int in range(1, 6):
		var angle: float = deg_to_rad(90.0 - step * 15.0)
		points.append(arc_center + Vector2(direction.x * r * cos(angle), direction.y * r * sin(angle)))
	points.append(Vector2(corner.x, corner.y - direction.y * r))
	return points


## Phần đất lấn sang ô chéo ở góc lõm: hình vuông cạnh r trừ phần cỏ tròn ở góc xa.
func _concave_fill_polygon(corner: Vector2, direction: Vector2i) -> PackedVector2Array:
	var r: float = PATH_CORNER_RADIUS
	var far_center: Vector2 = corner + Vector2(direction.x * r, direction.y * r)
	var points := PackedVector2Array([corner, Vector2(corner.x + direction.x * r, corner.y)])
	for step: int in range(1, 6):
		var angle: float = deg_to_rad(step * 15.0)
		points.append(far_center + Vector2(-direction.x * r * sin(angle), -direction.y * r * cos(angle)))
	points.append(Vector2(corner.x, corner.y + direction.y * r))
	return points


## Vẽ đa giác phủ ảnh của ô [param tile]; điểm [param origin] là góc trên trái của ô chứa đa giác
## (để ảnh khớp liền mạch). [param tint] nhân vào màu ảnh.
func _draw_textured_polygon(texture: Texture2D, points: PackedVector2Array, origin: Vector2, tile: TerrainTiles.Tile, tint: Color) -> void:
	var source: Rect2 = TerrainTiles.source_rect(tile)
	var texture_size: Vector2 = texture.get_size()
	var uvs := PackedVector2Array()
	var colors := PackedColorArray()
	for point: Vector2 in points:
		var local: Vector2 = (point - origin).clamp(Vector2.ZERO, Vector2(TerrainTiles.TILE_SIZE, TerrainTiles.TILE_SIZE))
		uvs.append((source.position + local) / texture_size)
		colors.append(tint)
	draw_polygon(points, colors, uvs, texture)


## Tối vùng bên ngoài [member playable_rect] (rặng cây hoặc trong nhà).
func _draw_border_overlay() -> void:
	if border_style == BorderStyle.NONE:
		return
	var color: Color = VOID_COLOR if border_style == BorderStyle.VOID else Color(0.0, 0.1, 0.0, 0.32)
	var rect: Rect2 = playable_rect
	draw_rect(Rect2(0, 0, WORLD_SIZE.x, rect.position.y), color)
	draw_rect(Rect2(0, rect.end.y, WORLD_SIZE.x, WORLD_SIZE.y - rect.end.y), color)
	draw_rect(Rect2(0, rect.position.y, rect.position.x, rect.size.y), color)
	draw_rect(Rect2(rect.end.x, rect.position.y, WORLD_SIZE.x - rect.end.x, rect.size.y), color)


# --- Đặt đồ vật ---------------------------------------------------------------------------


## Đặt một đồ vật bằng ảnh [param texture_path], chân đồ vật ở [param feet], kèm bóng đổ.
## [param scale_factor] phóng to nguyên lần (pixel không méo). [param blocker_height] > 0 thì
## chặn Player bằng một dải hình chữ nhật cao chừng đó, rộng 90% đồ vật, ngay sát chân.
func add_prop(texture_path: String, feet: Vector2, scale_factor: int = 1, blocker_height: float = 0.0) -> Sprite2D:
	var texture: Texture2D = load(texture_path)
	_add_shadow(feet, texture.get_width() * scale_factor * 0.8)
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = false
	sprite.offset = Vector2(-texture.get_width() / 2.0, -texture.get_height())
	sprite.position = feet
	sprite.scale = Vector2(scale_factor, scale_factor)
	add_child(sprite)
	if blocker_height > 0.0:
		_add_blocker(feet, texture.get_width() * scale_factor * 0.9, blocker_height)
	return sprite


## Đặt một món trang trí (cây, hàng rào, chum) với chân ở [param feet], kèm bóng đổ.
## [param blocker_width] > 0 thì chặn Player bằng dải rộng chừng đó cao 10 px.
func add_decor(decor: Decor, feet: Vector2, blocker_width: float = 0.0) -> Sprite2D:
	_add_shadow(feet, DECOR_SHADOW_WIDTH[decor])
	var sprite := Sprite2D.new()
	sprite.texture = load(DECOR_SHEET)
	sprite.region_enabled = true
	sprite.region_rect = Rect2(decor * DECOR_CELL, 0, DECOR_CELL, DECOR_CELL)
	sprite.centered = false
	sprite.offset = Vector2(-DECOR_CELL / 2.0, -DECOR_CELL)
	sprite.position = feet
	add_child(sprite)
	if decor in FOLIAGE:
		sprite.modulate = foliage_tint(TerrainTiles.get_season())
		_foliage_sprites.append(sprite)
	if blocker_width > 0.0:
		_add_blocker(feet, blocker_width, 10.0)
	return sprite


## Trồng một cụm [param count] món [param decor] quanh [param center] (rải đều trong bán kính
## [param radius], hơi dẹt theo chiều dọc), xếp từ trên xuống để cây dưới che cây trên.
## Cùng [param seed_value] thì cụm luôn giống nhau.
func add_cluster(decor: Decor, center: Vector2, count: int, radius: float, seed_value: int) -> Array[Sprite2D]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var spots: Array[Vector2] = []
	for i: int in count:
		var angle: float = rng.randf_range(0.0, TAU)
		var distance: float = sqrt(rng.randf()) * radius
		spots.append((center + Vector2(cos(angle), sin(angle) * 0.6) * distance).round())
	spots.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.y < b.y)
	var sprites: Array[Sprite2D] = []
	for spot: Vector2 in spots:
		sprites.append(add_decor(decor, spot))
	return sprites


## Đặt biển chỉ đường với các tấm ván [param entries], chân cột ở [param feet].
func add_signpost(feet: Vector2, entries: Array[String], points_right: bool = true) -> Signpost:
	var signpost := Signpost.new()
	signpost.position = feet
	signpost.entries = PackedStringArray(entries)
	signpost.points_right = points_right
	add_child(signpost)
	return signpost


## Đặt một điểm xuất hiện của Player.
func add_spawn(id: StringName, pos: Vector2) -> SpawnPoint:
	var spawn := SpawnPoint.new()
	spawn.spawn_id = id
	spawn.position = pos
	add_child(spawn)
	return spawn


## Đặt một lối ra vô hình dẫn tới [param target_scene] (xuất hiện tại SpawnPoint [param target_spawn]).
## [param label] khác rỗng thì dựng thêm một biển chỉ đường nhỏ ở phía trong, cạnh lối ra, ghi
## tên nơi đến; để rỗng khi map tự báo lối ra bằng biển chung hoặc cửa vẽ sẵn.
func add_exit(center: Vector2, size: Vector2, target_scene: String, target_spawn: StringName, label: String) -> SceneExit:
	var exit := SceneExit.new()
	exit.position = center
	exit.size = size
	exit.target_scene = target_scene
	exit.target_spawn = target_spawn
	add_child(exit)
	_exit_rects.append(Rect2(center - size / 2.0, size))
	if not label.is_empty():
		var points_right: bool = center.x > WORLD_SIZE.x / 2.0
		var inward: float = -64.0 if points_right else 64.0
		add_signpost(Vector2(center.x + inward, center.y - size.y / 2.0 + 20.0), [label], points_right)
	return exit


## Vị trí điểm xuất hiện [param id], hoặc Vector2.ZERO nếu map không có.
func get_spawn_position(id: StringName) -> Vector2:
	for child: Node in get_children():
		if child is SpawnPoint and (child as SpawnPoint).spawn_id == id:
			return (child as SpawnPoint).position
	return Vector2.ZERO


## Vị trí lối ra dẫn tới file scene có tên kết thúc bằng [param target_file], hoặc Vector2.ZERO.
func get_exit_position(target_file: String) -> Vector2:
	for child: Node in get_children():
		if child is SceneExit and (child as SceneExit).target_scene.ends_with(target_file):
			return (child as SceneExit).position
	return Vector2.ZERO


## Dải chặn Player trải từ [param x_from] tới [param x_to] (toạ độ x), đáy tại [param feet_y].
## Dùng khi một đồ vật chừa lối đi (vd. hai bên cửa nhà).
func _add_blocker_span(x_from: float, x_to: float, feet_y: float, height: float) -> void:
	_add_blocker(Vector2((x_from + x_to) / 2.0, feet_y), absf(x_to - x_from), height)


## Bóng đổ bầu dục dưới chân đồ vật; thêm trước sprite để sprite đè lên.
func _add_shadow(feet: Vector2, width: float) -> void:
	var shadow: Sprite2D = Shadow.create(width)
	shadow.position = feet + Vector2(0, -2)
	add_child(shadow)


## Dải chặn Player: rộng [param width], cao [param height], đáy nằm tại [param feet].
func _add_blocker(feet: Vector2, width: float, height: float) -> void:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(width, height)
	shape.shape = box
	body.position = feet + Vector2(0, -height / 2.0)
	body.add_child(shape)
	add_child(body)


## Bốn bức tường vô hình quanh [member playable_rect] để Player không đi ra ngoài.
func _build_walls() -> void:
	var t: float = 40.0
	var r: Rect2 = playable_rect
	var rects: Array[Rect2] = [
		Rect2(r.position.x - t, r.position.y - t, r.size.x + t * 2, t),
		Rect2(r.position.x - t, r.end.y, r.size.x + t * 2, t),
		Rect2(r.position.x - t, r.position.y, t, r.size.y),
		Rect2(r.end.x, r.position.y, t, r.size.y),
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


## Rặng cây rậm hai hàng quanh vùng chơi (bỏ chừa chỗ lối ra); sắp xếp từ trên xuống để che đúng.
func _build_tree_belt() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = variation_seed * 31 + 5
	var r: Rect2 = playable_rect
	var spots: Array[Dictionary] = []
	for row: int in 2:
		var back: float = 8.0 + row * 30.0
		var x: float = r.position.x - 56.0 - row * 12.0
		while x < r.end.x + 60.0:
			spots.append({"pos": Vector2(x, r.position.y - back), "row": row})
			spots.append({"pos": Vector2(x + 14.0, r.end.y + 44.0 + row * 30.0), "row": row})
			x += rng.randf_range(30.0, 38.0)
		var y: float = r.position.y - 20.0
		while y < r.end.y + 40.0:
			spots.append({"pos": Vector2(r.position.x - 18.0 - row * 30.0, y), "row": row})
			spots.append({"pos": Vector2(r.end.x + 18.0 + row * 30.0, y + 12.0), "row": row})
			y += rng.randf_range(30.0, 38.0)
	spots.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["pos"].y < b["pos"].y)
	for spot: Dictionary in spots:
		var pos: Vector2 = spot["pos"]
		if pos.x < -20.0 or pos.x > WORLD_SIZE.x + 20.0 or pos.y < 24.0 or pos.y > WORLD_SIZE.y + 60.0:
			continue
		if _near_exit(pos):
			continue
		var roll: float = rng.randf()
		var decor: Decor = Decor.BAMBOO if roll < 0.4 else (Decor.BANANA if roll < 0.65 else Decor.BUSH)
		if spot["row"] == 1 and decor == Decor.BANANA:
			decor = Decor.BUSH
		add_decor(decor, pos.round())


func _near_exit(pos: Vector2) -> bool:
	for rect: Rect2 in _exit_rects:
		if rect.grow(24.0).has_point(pos):
			return true
	return false
