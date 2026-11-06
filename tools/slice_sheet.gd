extends SceneTree
## Công cụ hậu kỳ sheet ảnh do AI tạo: cắt vùng, chia lưới, thu nhỏ, quy về bảng màu, xoá nền hồng tím.
##
## Chạy:
##   godot --headless --path . -s tools/slice_sheet.gd -- in=<ảnh> out=<png> cols=4 rows=2 cell=32,32 \
##       [crop=x,y,w,h] [palette=assets/art/palette.hex] [filter=lanczos|nearest] [key=magenta] [tol=60]
##
## Tham số:
##   in, out   Ảnh vào (png/webp/jpg) và PNG ra.
##   crop      Vùng cắt trước khi chia lưới (bỏ viền/giao diện); mặc định cả ảnh.
##   cols,rows Số cột, số hàng của lưới (ô vuông hoặc chữ nhật đều nhau).
##   cell      Kích thước MỖI Ô sau khi thu nhỏ, vd 32,32 (kích thước cuối trong game).
##   filter    lanczos (mặc định, mượt) hoặc nearest (giữ pixel cứng nếu ảnh đã là pixel-art chuẩn).
##   palette   File .hex (mỗi dòng một màu RRGGBB); mỗi pixel được đổi sang màu gần nhất.
##   key       "magenta": pixel gần #FF00FF (dung sai tol) thành trong suốt.
##
## Đây là bước 5 trong docs/ASSET_PROMPTS.md.


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
	var cell_parts: PackedStringArray = String(args.get("cell", "32,32")).split(",")
	var cell_size := Vector2i(int(cell_parts[0]), int(cell_parts[1]))
	var palette: Array[Color] = _load_palette(String(args.get("palette", "")))
	var use_nearest: bool = String(args.get("filter", "lanczos")) == "nearest"
	var key_magenta: bool = String(args.get("key", "")) == "magenta"
	var tolerance: float = float(args.get("tol", 60)) / 255.0

	var source_cell := Vector2i(source.get_width() / cols, source.get_height() / rows)
	var result: Image = Image.create(cols * cell_size.x, rows * cell_size.y, false, Image.FORMAT_RGBA8)
	result.fill(Color(0, 0, 0, 0))
	for row: int in rows:
		for col: int in cols:
			var cell: Image = source.get_region(Rect2i(col * source_cell.x, row * source_cell.y, source_cell.x, source_cell.y))
			if cell.get_size() != cell_size:
				cell.resize(cell_size.x, cell_size.y, Image.INTERPOLATE_NEAREST if use_nearest else Image.INTERPOLATE_LANCZOS)
			_process_pixels(cell, palette, key_magenta, tolerance)
			result.blit_rect(cell, Rect2i(Vector2i.ZERO, cell_size), Vector2i(col * cell_size.x, row * cell_size.y))

	var out_path: String = String(args.get("out", "out.png"))
	DirAccess.make_dir_recursive_absolute(out_path.get_base_dir())
	var error: int = result.save_png(out_path)
	print("SLICE ", "OK" if error == OK else "ERROR %d" % error, " -> ", out_path, " ", result.get_size(), " (", cols, "x", rows, " o, moi o ", cell_size, ")")
	quit(0 if error == OK else 1)


func _process_pixels(image: Image, palette: Array[Color], key_magenta: bool, tolerance: float) -> void:
	var magenta := Color(1.0, 0.0, 1.0)
	for y: int in image.get_height():
		for x: int in image.get_width():
			var pixel: Color = image.get_pixel(x, y)
			if key_magenta and _color_distance(pixel, magenta) <= tolerance:
				image.set_pixel(x, y, Color(0, 0, 0, 0))
			elif not palette.is_empty():
				image.set_pixel(x, y, _nearest(pixel, palette))


func _nearest(pixel: Color, palette: Array[Color]) -> Color:
	var best: Color = palette[0]
	var best_distance: float = INF
	for candidate: Color in palette:
		var distance: float = _color_distance(pixel, candidate)
		if distance < best_distance:
			best_distance = distance
			best = candidate
	return best


func _color_distance(a: Color, b: Color) -> float:
	return sqrt(pow(a.r - b.r, 2) + pow(a.g - b.g, 2) + pow(a.b - b.b, 2))


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
