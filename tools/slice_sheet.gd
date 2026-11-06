extends SceneTree
## Công cụ hậu kỳ ảnh pixel-art do AI tạo: cắt vùng, chia lưới, cắt sát nhân vật, thu về cỡ
## "1 pixel ra = 1 pixel nghệ thuật", xoá nền hồng tím, quy về bảng màu.
##
## Chạy:
##   godot --headless --path . -s tools/slice_sheet.gd -- in=<ảnh> out=<png> [tham số]
##
## Tham số:
##   in, out     Ảnh vào (png/webp/jpg) và PNG ra.
##   crop        x,y,w,h: vùng cắt trước khi chia lưới (bỏ viền/giao diện).
##   cols, rows  Số cột, hàng của lưới trong ảnh nguồn (mặc định 1x1).
##   key         "magenta": pixel hồng tím (#FF00FF và các sắc gần nó) thành trong suốt.
##   anchor      grid (mặc định): thu cả ô nguồn về `cell` (chia lưới đều).
##               feet: cắt sát phần không trong suốt của từng ô, thu theo `px`, rồi đặt
##               GIỮA-ĐÁY ô đầu ra. Dùng cho nhân vật/đồ vật vẽ lệch trong ô.
##   px          Số pixel nguồn ứng với 1 pixel đầu ra (cỡ một "pixel nghệ thuật" của ảnh;
##               đo bằng khoảng cách các cạnh màu). Bắt buộc với anchor=feet.
##   split       "auto": (rows=1) tách các sprite theo khoảng trống thay vì chia lưới đều.
##   cell        W,H: kích thước mỗi ô đầu ra, hoặc "auto": vừa đủ ô sprite lớn nhất (anchor=feet).
##   pad         Số pixel đệm quanh sprite khi cell=auto, và cách đáy ô khi anchor=feet (mặc định 1).
##   sample      nearest (mặc định, giữ pixel cứng, không lem viền) hoặc lanczos (mượt, cho nền lát).
##   defringe    "1": pixel tím lẫn ở mép (do khử nền hồng tím) đổi sang màu viền #2A1F1A.
##               Đừng bật cho ảnh có màu tím thật (vd. bi bida tím).
##   palette     File .hex (mỗi dòng RRGGBB): mỗi pixel đổi sang màu gần nhất trong bảng.
##               Mặc định KHÔNG dùng: ép về 17 màu làm sprite bạc màu; chỉ nên dùng khi cần.
##
## Ví dụ (Player: 3 cột x 4 hàng, mỗi khung 32x48):
##   godot --headless --path . -s tools/slice_sheet.gd -- in=nguon.png out=player.png cols=3 rows=4 \
##       cell=32,48 key=magenta
## Ví dụ (NPC: 2 khung, cắt sát và neo chân, 16 px nguồn = 1 pixel nghệ thuật):
##   godot --headless --path . -s tools/slice_sheet.gd -- in=nguon.png out=npc.png cols=2 rows=1 \
##       anchor=feet px=16 cell=32,48 key=magenta
##
## Đây là bước hậu kỳ trong docs/ASSET_PROMPTS.md. Lệnh đã dùng cho toàn bộ asset: tools/process_assets.sh.


func _initialize() -> void:
	var args: Dictionary = _parse_args()
	var source: Image = Image.load_from_file(String(args.get("in", "")))
	if source == null:
		push_error("Khong doc duoc anh dau vao: %s" % args.get("in", ""))
		quit(1)
		return
	source.convert(Image.FORMAT_RGBA8)
	if args.has("crop"):
		var c: PackedStringArray = String(args["crop"]).split(",")
		source = source.get_region(Rect2i(int(c[0]), int(c[1]), int(c[2]), int(c[3])))

	var cols: int = int(args.get("cols", 1))
	var rows: int = int(args.get("rows", 1))
	var anchor_feet: bool = String(args.get("anchor", "grid")) == "feet"
	var pixel_size: float = float(args.get("px", 0))
	var pad: int = int(args.get("pad", 1))
	var use_lanczos: bool = String(args.get("sample", args.get("filter", "nearest"))) == "lanczos"
	var palette: Array[Color] = _load_palette(String(args.get("palette", "")))
	if String(args.get("key", "")) == "magenta":
		_key_magenta(source)

	var source_cell := Vector2i(source.get_width() / cols, source.get_height() / rows)
	var cell_arg: String = String(args.get("cell", "32,32"))
	var fixed_cell := Vector2i.ZERO
	if cell_arg != "auto":
		var parts: PackedStringArray = cell_arg.split(",")
		fixed_cell = Vector2i(int(parts[0]), int(parts[1]))
	if anchor_feet and pixel_size <= 0.0:
		push_error("anchor=feet can tham so px=")
		quit(1)
		return

	# split=auto (chỉ cho rows=1): tách theo khoảng trống giữa các sprite thay vì chia lưới đều,
	# để sprite vẽ rộng hơn ô không bị cắt ngang.
	var segments: Array[Vector2i] = []
	if String(args.get("split", "")) == "auto":
		segments = _find_column_segments(source)
		if rows != 1 or segments.size() != cols:
			push_error("split=auto can rows=1 va tim dung %d sprite (thay %d)" % [cols, segments.size()])
			quit(1)
			return

	# 1) Cắt và thu từng ô thành sprite riêng.
	var sprites: Array[Image] = []
	for row: int in rows:
		for col: int in cols:
			var region: Image
			if segments.is_empty():
				region = source.get_region(Rect2i(col * source_cell.x, row * source_cell.y, source_cell.x, source_cell.y))
			else:
				region = source.get_region(Rect2i(segments[col].x, 0, segments[col].y - segments[col].x, source.get_height()))
			var out_size: Vector2i = fixed_cell
			if anchor_feet:
				var used: Rect2i = region.get_used_rect()
				if used.size.x <= 0 or used.size.y <= 0:
					sprites.append(Image.create(1, 1, false, Image.FORMAT_RGBA8))
					continue
				region = region.get_region(used)
				out_size = Vector2i(maxi(1, roundi(used.size.x / pixel_size)), maxi(1, roundi(used.size.y / pixel_size)))
			elif cell_arg == "auto":
				out_size = Vector2i(maxi(1, roundi(region.get_width() / pixel_size)), maxi(1, roundi(region.get_height() / pixel_size)))
			if region.get_size() != out_size:
				region.resize(out_size.x, out_size.y, Image.INTERPOLATE_LANCZOS if use_lanczos else Image.INTERPOLATE_NEAREST)
			sprites.append(region)

	# 2) Kích thước ô đầu ra.
	var cell_size: Vector2i = fixed_cell
	if cell_arg == "auto":
		for sprite: Image in sprites:
			cell_size.x = maxi(cell_size.x, sprite.get_width() + pad * 2)
			cell_size.y = maxi(cell_size.y, sprite.get_height() + pad * 2)

	# 3) Ghép vào ảnh kết quả.
	var result: Image = Image.create(cols * cell_size.x, rows * cell_size.y, false, Image.FORMAT_RGBA8)
	result.fill(Color(0, 0, 0, 0))
	var index: int = 0
	for row: int in rows:
		for col: int in cols:
			var sprite: Image = sprites[index]
			index += 1
			var offset := Vector2i.ZERO
			if anchor_feet or cell_arg == "auto":
				offset = Vector2i((cell_size.x - sprite.get_width()) / 2, cell_size.y - sprite.get_height() - pad)
			result.blit_rect(sprite, Rect2i(Vector2i.ZERO, sprite.get_size()), Vector2i(col * cell_size.x, row * cell_size.y) + offset)

	# 4) Alpha cứng, khử viền tím (nếu bật) và quy về bảng màu (nếu có).
	_finalize_pixels(result, palette, String(args.get("defringe", "")) == "1")

	var out_path: String = String(args.get("out", "out.png"))
	DirAccess.make_dir_recursive_absolute(out_path.get_base_dir())
	var error: int = result.save_png(out_path)
	print("SLICE ", "OK" if error == OK else "ERROR %d" % error, " -> ", out_path, " ", result.get_size(), " (", cols, "x", rows, " o, moi o ", cell_size, ")")
	quit(0 if error == OK else 1)


## Các đoạn cột [x_đầu, x_cuối) có pixel không trong suốt, cách nhau bởi ít nhất 6 cột trống.
func _find_column_segments(image: Image) -> Array[Vector2i]:
	var min_gap: int = 6
	var segments: Array[Vector2i] = []
	var start: int = -1
	var empty_run: int = 0
	for x: int in image.get_width():
		var occupied: bool = false
		for y: int in range(0, image.get_height(), 2):
			if image.get_pixel(x, y).a > 0.0:
				occupied = true
				break
		if occupied:
			if start < 0:
				start = x
			empty_run = 0
		elif start >= 0:
			empty_run += 1
			if empty_run >= min_gap:
				segments.append(Vector2i(start, x - empty_run + 1))
				start = -1
				empty_run = 0
	if start >= 0:
		segments.append(Vector2i(start, image.get_width()))
	return segments


## Pixel hồng tím (kể cả sắc hơi lệch do AI/nén ảnh) thành trong suốt.
func _key_magenta(image: Image) -> void:
	for y: int in image.get_height():
		for x: int in image.get_width():
			var pixel: Color = image.get_pixel(x, y)
			if minf(pixel.r, pixel.b) > 0.5 and (pixel.r + pixel.b) / 2.0 - pixel.g > 0.3:
				image.set_pixel(x, y, Color(pixel.r, pixel.g, pixel.b, 0.0))


func _finalize_pixels(image: Image, palette: Array[Color], defringe: bool) -> void:
	var outline := Color.html("#2A1F1A")
	for y: int in image.get_height():
		for x: int in image.get_width():
			var pixel: Color = image.get_pixel(x, y)
			if pixel.a < 0.5:
				image.set_pixel(x, y, Color(0, 0, 0, 0))
				continue
			pixel.a = 1.0
			# Pixel tím ở mép là phần pha giữa viền tối và nền hồng tím: đổi sang màu viền.
			if defringe and pixel.r - pixel.g > 0.1 and pixel.b - pixel.g > 0.1 and absf(pixel.r - pixel.b) < 0.35:
				pixel = outline
			image.set_pixel(x, y, _nearest(pixel, palette) if not palette.is_empty() else pixel)


func _nearest(pixel: Color, palette: Array[Color]) -> Color:
	var best: Color = palette[0]
	var best_distance: float = INF
	for candidate: Color in palette:
		var distance: float = pow(pixel.r - candidate.r, 2) + pow(pixel.g - candidate.g, 2) + pow(pixel.b - candidate.b, 2)
		if distance < best_distance:
			best_distance = distance
			best = candidate
	return best


func _load_palette(path: String) -> Array[Color]:
	var colors: Array[Color] = []
	if path.is_empty():
		return colors
	for line: String in FileAccess.get_file_as_string(path).split("\n"):
		var hex: String = line.strip_edges()
		if hex.length() == 6:
			colors.append(Color.html("#" + hex))
	return colors


func _parse_args() -> Dictionary:
	var parsed: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		var parts: PackedStringArray = arg.split("=", true, 1)
		if parts.size() == 2:
			parsed[parts[0]] = parts[1]
	return parsed
