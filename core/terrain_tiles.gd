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
const TEXTURE_PATH: String = "res://assets/art/tiles/terrain_tiles.png"

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

static var _texture: Texture2D


## Ảnh sheet (nạp một lần).
static func get_texture() -> Texture2D:
	if _texture == null:
		_texture = load(TEXTURE_PATH) as Texture2D
	return _texture


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
