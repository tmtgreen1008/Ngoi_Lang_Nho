class_name FarmView
extends Node2D
## Vẽ FarmField bằng hai TileMapLayer: lớp đất (cỏ/đất cuốc, lấy từ TerrainTiles) và lớp
## cây (3 giai đoạn), cộng một lưới mờ đánh dấu vùng canh tác.
##
## Chỉ đọc dữ liệu từ FarmField và nghe plot_changed; không sửa trạng thái vườn.
## Ô đất dùng ảnh thật; ô cây vẫn là khối màu tạm (tạo bằng code) cho tới khi có ảnh
## cây lúa (xem docs/ASSET_PROMPTS.md, mục 2).

const TILE_SIZE: int = TerrainTiles.TILE_SIZE
## Nguồn 0 = nền đất thật; nguồn 1 = cây tạm.
const TERRAIN_SOURCE: int = 0
const CROP_SOURCE: int = 1
const CROP_SEEDLING := Vector2i(0, 0)
const CROP_GROWING := Vector2i(1, 0)
const CROP_RIPE := Vector2i(2, 0)

var field: FarmField

var _ground: TileMapLayer
var _crops: TileMapLayer
var _grid: Node2D


func _init() -> void:
	var tile_set: TileSet = _build_tile_set()
	_ground = TileMapLayer.new()
	_ground.tile_set = tile_set
	add_child(_ground)
	_crops = TileMapLayer.new()
	_crops.tile_set = tile_set
	add_child(_crops)
	# Lưới vẽ sau cùng để nằm trên đất và cây.
	_grid = Node2D.new()
	_grid.draw.connect(_draw_grid)
	add_child(_grid)


## Gắn view với [param farm_field] và vẽ toàn bộ vườn.
func setup(farm_field: FarmField) -> void:
	field = farm_field
	field.plot_changed.connect(_refresh_cell)
	for x: int in range(field.field_area.position.x, field.field_area.end.x):
		for y: int in range(field.field_area.position.y, field.field_area.end.y):
			_refresh_cell(Vector2i(x, y))
	_grid.queue_redraw()


## Đổi toạ độ màn hình/thế giới sang ô lưới (tính cả vị trí và scale của view).
func world_to_cell(global_pos: Vector2) -> Vector2i:
	return _ground.local_to_map(_ground.to_local(global_pos))


func _refresh_cell(cell: Vector2i) -> void:
	if not field.is_farmable(cell):
		return
	var plot: FarmPlot = field.get_plot(cell)
	var tilled: bool = plot != null and plot.is_tilled
	var tile: TerrainTiles.Tile = TerrainTiles.Tile.SOIL if tilled else TerrainTiles.Tile.GRASS
	_ground.set_cell(cell, TERRAIN_SOURCE, TerrainTiles.atlas_coords(tile))
	if plot != null and plot.is_planted():
		_crops.set_cell(cell, CROP_SOURCE, _stage_tile(plot))
	else:
		_crops.erase_cell(cell)


## Chọn ô cây theo tiến độ: chín, đã nửa đường, hoặc mới nảy mầm.
func _stage_tile(plot: FarmPlot) -> Vector2i:
	if plot.is_ripe():
		return CROP_RIPE
	var ratio: float = plot.days_grown / float(plot.crop.grow_days)
	return CROP_GROWING if ratio >= 0.5 else CROP_SEEDLING


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
	tile_set.add_source(TerrainTiles.create_atlas_source(), TERRAIN_SOURCE)
	tile_set.add_source(_build_crop_source(), CROP_SOURCE)
	return tile_set


## Ba ô cây tạm (mầm, đang lớn, chín) vẽ bằng khối màu trên nền trong suốt.
static func _build_crop_source() -> TileSetAtlasSource:
	var image: Image = Image.create(TILE_SIZE * 3, TILE_SIZE, false, Image.FORMAT_RGBA8)
	_paint_crop(image, 0, Color(0.44, 0.68, 0.25), 8, 12)
	_paint_crop(image, 1, Color(0.36, 0.6, 0.24), 18, 24)
	_paint_crop(image, 2, Color(0.91, 0.77, 0.28), 26, 34)
	var source := TileSetAtlasSource.new()
	source.texture = ImageTexture.create_from_image(image)
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	for i: int in 3:
		source.create_tile(Vector2i(i, 0))
	return source


## Vẽ cây là thân thẳng đứng cao [param height] px, rộng [param width] px.
static func _paint_crop(image: Image, index: int, color: Color, width: int, height: int) -> void:
	var origin := Vector2i(index * TILE_SIZE, 0)
	var stem := Vector2i(origin.x + (TILE_SIZE - width) / 2, origin.y + TILE_SIZE - 6 - height)
	image.fill_rect(Rect2i(stem, Vector2i(width, height)), color)
	image.fill_rect(Rect2i(stem, Vector2i(width, 2)), color.lightened(0.25))
