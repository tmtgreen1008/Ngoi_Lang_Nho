class_name FarmView
extends Node2D
## Vẽ FarmField bằng hai TileMapLayer: lớp đất (cỏ/đất cuốc) và lớp cây (3 giai đoạn).
##
## Chỉ đọc dữ liệu từ FarmField và nghe plot_changed; không sửa trạng thái vườn.
## Tileset hiện được tạo bằng code (ô màu tạm) để chạy được khi chưa có art;
## khi có art, thay [method _build_tile_set] bằng TileSet .tres thật.

const TILE_SIZE: int = 32
const TILE_GRASS := Vector2i(0, 0)
const TILE_SOIL := Vector2i(1, 0)
const TILE_SEEDLING := Vector2i(2, 0)
const TILE_GROWING := Vector2i(3, 0)
const TILE_RIPE := Vector2i(4, 0)
const SOURCE_ID: int = 0

var field: FarmField

var _ground: TileMapLayer
var _crops: TileMapLayer


func _init() -> void:
	var tile_set: TileSet = _build_tile_set()
	_ground = TileMapLayer.new()
	_ground.tile_set = tile_set
	add_child(_ground)
	_crops = TileMapLayer.new()
	_crops.tile_set = tile_set
	add_child(_crops)


## Gắn view với [param farm_field] và vẽ toàn bộ vườn.
func setup(farm_field: FarmField) -> void:
	field = farm_field
	field.plot_changed.connect(_refresh_cell)
	for x: int in range(field.field_area.position.x, field.field_area.end.x):
		for y: int in range(field.field_area.position.y, field.field_area.end.y):
			_refresh_cell(Vector2i(x, y))


## Đổi toạ độ màn hình/thế giới sang ô lưới (tính cả vị trí và scale của view).
func world_to_cell(global_pos: Vector2) -> Vector2i:
	return _ground.local_to_map(_ground.to_local(global_pos))


func _refresh_cell(cell: Vector2i) -> void:
	if not field.is_farmable(cell):
		return
	var plot: FarmPlot = field.get_plot(cell)
	var tilled: bool = plot != null and plot.is_tilled
	_ground.set_cell(cell, SOURCE_ID, TILE_SOIL if tilled else TILE_GRASS)
	if plot != null and plot.is_planted():
		_crops.set_cell(cell, SOURCE_ID, _stage_tile(plot))
	else:
		_crops.erase_cell(cell)


## Chọn ô cây theo tiến độ: chín, đã nửa đường, hoặc mới nảy mầm.
func _stage_tile(plot: FarmPlot) -> Vector2i:
	if plot.is_ripe():
		return TILE_RIPE
	var ratio: float = plot.days_grown / float(plot.crop.grow_days)
	return TILE_GROWING if ratio >= 0.5 else TILE_SEEDLING


static func _build_tile_set() -> TileSet:
	var image: Image = Image.create(TILE_SIZE * 5, TILE_SIZE, false, Image.FORMAT_RGBA8)
	_paint_ground(image, 0, Color(0.36, 0.62, 0.29))  # cỏ
	_paint_ground(image, 1, Color(0.47, 0.32, 0.18))  # đất cuốc
	_paint_crop(image, 2, Color(0.45, 0.78, 0.30), 6, 8)  # mầm
	_paint_crop(image, 3, Color(0.35, 0.72, 0.25), 12, 16)  # đang lớn
	_paint_crop(image, 4, Color(0.95, 0.80, 0.25), 18, 22)  # chín (vàng)

	var source := TileSetAtlasSource.new()
	source.texture = ImageTexture.create_from_image(image)
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	for i: int in 5:
		source.create_tile(Vector2i(i, 0))
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	tile_set.add_source(source, SOURCE_ID)
	return tile_set


static func _paint_ground(image: Image, index: int, color: Color) -> void:
	var origin := Vector2i(index * TILE_SIZE, 0)
	image.fill_rect(Rect2i(origin, Vector2i(TILE_SIZE, TILE_SIZE)), color.darkened(0.25))
	image.fill_rect(Rect2i(origin + Vector2i(1, 1), Vector2i(TILE_SIZE - 2, TILE_SIZE - 2)), color)


## Vẽ cây là thân thẳng đứng cao [param height] px, rộng [param width] px.
static func _paint_crop(image: Image, index: int, color: Color, width: int, height: int) -> void:
	var origin := Vector2i(index * TILE_SIZE, 0)
	var stem := Vector2i(origin.x + (TILE_SIZE - width) / 2, origin.y + TILE_SIZE - 4 - height)
	image.fill_rect(Rect2i(stem, Vector2i(width, height)), color)
