class_name TerrainTiles
extends RefCounted
## Sheet nền đất (assets/art/tiles/terrain_tiles.png): 8 ô 48x48, lưới 4 cột x 2 hàng.
## Dùng chung cho nền các map (MapBase) và mảnh vườn (FarmView).
##
## Thứ tự ô trong ảnh trùng với [enum Tile]; đổi ảnh thì giữ nguyên thứ tự này
## (xem docs/ASSET_PROMPTS.md, mục 1).

## Cạnh ô vuông (pixel). Mọi bản đồ và vườn lát theo lưới này.
const TILE_SIZE: int = 48
const COLUMNS: int = 4
## Sheet mùa Xuân (gốc). Các mùa khác ghép từ sheet này bằng tools/compose_season_tiles.gd.
const TEXTURE_PATH: String = "res://assets/art/tiles/terrain_tiles.png"
## Sheet theo mùa (giá trị của TimeManager.Season: Xuân, Hạ, Thu, Đông). Cùng bố cục 8 ô; chỉ các ô
## ngoài trời (cỏ, cỏ điểm hoa, đường, đất cuốc, mặt nước) đổi theo mùa, ô trong nhà giữ nguyên.
const SEASON_SHEETS: Array[String] = [
	TEXTURE_PATH,
	"res://assets/art/tiles/terrain_summer.png",
	"res://assets/art/tiles/terrain_autumn.png",
	"res://assets/art/tiles/terrain_winter.png",
]

enum Tile {
	GRASS,
	GRASS_FLOWERS,
	PATH,
	SOIL,
	WOOD_FLOOR,
	MARKET_GROUND,
	CAFE_FLOOR,
	WATER,
}

static var _season: int = 0
static var _textures: Dictionary = {}  # mùa -> Texture2D (nạp một lần)


## Mùa đang dùng cho nền (giá trị của TimeManager.Season).
static func get_season() -> int:
	return _season


## Đổi mùa của nền đất. Trả về true nếu mùa thực sự đổi (bên gọi cần vẽ lại).
static func set_season(season: int) -> bool:
	season = clampi(season, 0, SEASON_SHEETS.size() - 1)
	if season == _season:
		return false
	_season = season
	return true


## Ảnh sheet của mùa hiện tại (nạp một lần cho mỗi mùa).
static func get_texture() -> Texture2D:
	if not _textures.has(_season):
		_textures[_season] = load(SEASON_SHEETS[_season]) as Texture2D
	return _textures[_season]


## Toạ độ (cột, hàng) của [param tile] trong sheet.
static func atlas_coords(tile: Tile) -> Vector2i:
	return Vector2i(tile % COLUMNS, tile / COLUMNS)


## Vùng chữ nhật của [param tile] trong ảnh sheet (pixel).
static func source_rect(tile: Tile) -> Rect2:
	var coords: Vector2i = atlas_coords(tile)
	return Rect2(coords.x * TILE_SIZE, coords.y * TILE_SIZE, TILE_SIZE, TILE_SIZE)


## Nguồn atlas cho TileSet với đủ 8 ô.
static func create_atlas_source() -> TileSetAtlasSource:
	var source := TileSetAtlasSource.new()
	source.texture = get_texture()
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	for tile: int in Tile.size():
		source.create_tile(atlas_coords(tile as Tile))
	return source
