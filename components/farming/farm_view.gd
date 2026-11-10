class_name FarmView
extends Node2D
## Vẽ FarmField: lớp đất (TileMapLayer, ô cỏ từ TerrainTiles, đất cuốc từ farmland.png), cây (mỗi cây một
## Sprite2D lấy ảnh từ CropItemData.growth_sheet) và một lưới mờ đánh dấu vùng canh tác.
##
## Chỉ đọc dữ liệu từ FarmField và nghe plot_changed; không sửa trạng thái vườn.
## Ảnh cây nằm trong dữ liệu của từng loại cây nên thêm cây mới không cần sửa code.

const TILE_SIZE: int = TerrainTiles.TILE_SIZE
## Sheet đất canh tác (lưới 4x2, ô 48x48): hàng trên là luống khô/ướt, hàng dưới là đất có hốc gieo hạt.
const FARMLAND_PATH: String = "res://assets/art/tiles/farmland.png"
## Số nguồn trong TileSet: 0 là nền theo mùa (cỏ), 1 là đất canh tác.
const SOURCE_TERRAIN: int = 0
const SOURCE_FARMLAND: int = 1
## Ô trong sheet đất canh tác: luống đã cuốc, và đất có hốc vừa gieo hạt.
const FARMLAND_FURROWS := Vector2i(0, 0)
const FARMLAND_SEEDED := Vector2i(0, 1)

var field: FarmField

var _ground: TileMapLayer
var _grid: Node2D
var _crop_sprites: Dictionary = {}  # Vector2i -> Sprite2D


func _init() -> void:
	# Cây xếp lớp cùng Player và đồ vật của map (y-sort lồng nhau được gộp chung). Nền đất và lưới nằm ở
	# y của view (đỉnh vườn) nên luôn vẽ trước cây và Player, vốn đứng dưới đỉnh vườn.
	y_sort_enabled = true
	_ground = TileMapLayer.new()
	_ground.tile_set = _build_tile_set()
	add_child(_ground)
	# Lưới mờ nằm trên nền đất, dưới cây (cùng y với nền, thứ tự trong cây node).
	_grid = Node2D.new()
	_grid.draw.connect(_draw_grid)


func _ready() -> void:
	EventBus.season_changed.connect(_on_season_changed)


## Đổi mùa thì đổi ảnh nền đất của vườn (cỏ, đất cuốc) sang sheet của mùa mới.
func _on_season_changed(season: int, _year: int) -> void:
	TerrainTiles.set_season(season)
	var source := _ground.tile_set.get_source(0) as TileSetAtlasSource
	source.texture = TerrainTiles.get_texture()


## Gắn view với [param farm_field] và vẽ toàn bộ vườn.
func setup(farm_field: FarmField) -> void:
	field = farm_field
	field.plot_changed.connect(_refresh_cell)
	for x: int in range(field.field_area.position.x, field.field_area.end.x):
		for y: int in range(field.field_area.position.y, field.field_area.end.y):
			_refresh_cell(Vector2i(x, y))
	if _grid.get_parent() == null:
		add_child(_grid)
	_grid.queue_redraw()


## Đổi toạ độ màn hình/thế giới sang ô lưới (tính cả vị trí và scale của view).
func world_to_cell(global_pos: Vector2) -> Vector2i:
	return _ground.local_to_map(_ground.to_local(global_pos))


## Sprite cây ở [param cell], hoặc null nếu ô không có cây.
func get_crop_sprite(cell: Vector2i) -> Sprite2D:
	return _crop_sprites.get(cell)


func _refresh_cell(cell: Vector2i) -> void:
	if not field.is_farmable(cell):
		return
	var plot: FarmPlot = field.get_plot(cell)
	if plot == null or not plot.is_tilled:
		_ground.set_cell(cell, SOURCE_TERRAIN, TerrainTiles.atlas_coords(TerrainTiles.Tile.GRASS))
	elif plot.is_planted() and plot.days_grown == 0:
		# Ngày gieo: đất có hốc hạt; từ hôm sau cây mọc trên luống.
		_ground.set_cell(cell, SOURCE_FARMLAND, FARMLAND_SEEDED)
	else:
		_ground.set_cell(cell, SOURCE_FARMLAND, FARMLAND_FURROWS)
	if plot != null and plot.is_planted():
		_show_crop(cell, plot)
	else:
		_hide_crop(cell)


## Hiện cây ở [param cell] với khung hình ứng với số ngày đã lớn.
func _show_crop(cell: Vector2i, plot: FarmPlot) -> void:
	var sheet: Texture2D = plot.crop.growth_sheet
	if sheet == null:
		_hide_crop(cell)
		return
	var sprite: Sprite2D = _crop_sprites.get(cell)
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.centered = false
		# Gốc toạ độ ở CHÂN cây (đáy ô) để y-sort so với Player đúng; ảnh vẽ phía trên chân.
		sprite.position = Vector2(cell * TILE_SIZE) + Vector2(0, TILE_SIZE)
		sprite.offset = Vector2(0, -TILE_SIZE)
		add_child(sprite)
		# Cây luôn nằm dưới lưới mờ.
		if _grid.get_parent() == self:
			move_child(_grid, get_child_count() - 1)
		_crop_sprites[cell] = sprite
	sprite.texture = sheet
	sprite.region_enabled = true
	var frame: int = plot.crop.get_growth_frame(plot.days_grown)
	sprite.region_rect = Rect2(frame * TILE_SIZE, 0, TILE_SIZE, TILE_SIZE)


func _hide_crop(cell: Vector2i) -> void:
	var sprite: Sprite2D = _crop_sprites.get(cell)
	if sprite != null:
		sprite.queue_free()
		_crop_sprites.erase(cell)


## Lưới mờ quanh từng ô canh tác, để thấy được ranh giới mảnh vườn trên nền cỏ.
func _draw_grid() -> void:
	if field == null:
		return
	var area: Rect2i = field.field_area
	var line_color := Color(0.1, 0.18, 0.05, 0.3)
	for x: int in range(area.position.x, area.end.x + 1):
		_grid.draw_line(Vector2(x * TILE_SIZE, area.position.y * TILE_SIZE), Vector2(x * TILE_SIZE, area.end.y * TILE_SIZE), line_color)
	for y: int in range(area.position.y, area.end.y + 1):
		_grid.draw_line(Vector2(area.position.x * TILE_SIZE, y * TILE_SIZE), Vector2(area.end.x * TILE_SIZE, y * TILE_SIZE), line_color)


static func _build_tile_set() -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	tile_set.add_source(TerrainTiles.create_atlas_source(), SOURCE_TERRAIN)
	var farmland := TileSetAtlasSource.new()
	farmland.texture = load(FARMLAND_PATH)
	farmland.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	for coords: Vector2i in [FARMLAND_FURROWS, FARMLAND_SEEDED]:
		farmland.create_tile(coords)
	tile_set.add_source(farmland, SOURCE_FARMLAND)
	return tile_set
