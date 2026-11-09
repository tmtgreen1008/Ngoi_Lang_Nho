extends SceneTree
## Ghép sheet nền đất cho từng mùa: lấy sheet gốc (assets/art/tiles/terrain_tiles.png, mùa Xuân) rồi thay
## các ô ngoài trời theo mùa (cỏ, cỏ điểm hoa/lá/sương giá, đường đất, đất cuốc, mặt nước) bằng ô cùng
## vị trí trong sheet đã cắt của mùa đó (assets/art/tiles/raw/<mùa>.png). Các ô trong nhà (sàn gỗ, nền chợ,
## sàn quán) giữ nguyên. Chạy:  godot --headless --path . -s tools/compose_season_tiles.gd
##
## Ô trong sheet gốc theo TerrainTiles.Tile; ở sheet mùa, ô mặt nước nằm ở vị trí 5 (không phải 7).
## Ô "đường" của sheet Thu và Đông là đường dọc có viền cỏ, lát ngang bị lặp nên dùng ô đất liền mạch (vị trí 7).

const SEASONS: Array[String] = ["summer", "autumn", "winter"]
## (ô đích trong sheet gốc, ô nguồn trong sheet mùa).
const PATH_SOURCE: Dictionary = {"summer": 2, "autumn": 7, "winter": 7}
const SWAPS: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 1), Vector2i(2, 2), Vector2i(3, 3), Vector2i(7, 5)]
const TILE: int = 48
const COLUMNS: int = 4


func _initialize() -> void:
	var base: Image = Image.load_from_file("res://assets/art/tiles/terrain_tiles.png")
	base.convert(Image.FORMAT_RGBA8)
	var failures: int = 0
	for season: String in SEASONS:
		var raw: Image = Image.load_from_file("res://assets/art/tiles/raw/%s.png" % season)
		if raw == null:
			push_error("Thieu sheet %s" % season)
			failures += 1
			continue
		raw.convert(Image.FORMAT_RGBA8)
		var out: Image = base.duplicate()
		for swap_template: Vector2i in SWAPS:
			var swap: Vector2i = swap_template
			if swap.x == 2:
				swap.y = PATH_SOURCE[season]
			var src := Rect2i((swap.y % COLUMNS) * TILE, (swap.y / COLUMNS) * TILE, TILE, TILE)
			out.blit_rect(raw, src, Vector2i((swap.x % COLUMNS) * TILE, (swap.x / COLUMNS) * TILE))
		var path: String = "res://assets/art/tiles/terrain_%s.png" % season
		if out.save_png(path) != OK:
			failures += 1
		print("COMPOSE ", path)
	quit(failures)
