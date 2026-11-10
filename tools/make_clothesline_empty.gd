extends SceneTree
## Tạo ảnh dây phơi TRỐNG (assets/art/props/clothesline_empty.png) từ ảnh dây phơi có quần áo: giữ hai cọc tre
## (dải [constant POLE_WIDTH] px hai bên) rồi vẽ lại sợi dây võng giữa hai cọc. Chạy sau khi cắt clothesline.png:
##   godot --headless --path . -s tools/make_clothesline_empty.gd

const SOURCE: String = "res://assets/art/props/clothesline.png"
const OUTPUT: String = "res://assets/art/props/clothesline_empty.png"
const POLE_WIDTH: int = 14
## Chỗ buộc dây trên cọc (tính từ đỉnh ảnh) và độ võng ở giữa (pixel).
const ROPE_Y: int = 8
const ROPE_SAG: int = 7
const ROPE_LIGHT := Color("#D9A066")
const ROPE_DARK := Color("#7A5230")


func _initialize() -> void:
	var source: Image = Image.load_from_file(SOURCE)
	source.convert(Image.FORMAT_RGBA8)
	var width: int = source.get_width()
	var out: Image = Image.create(width, source.get_height(), false, Image.FORMAT_RGBA8)
	out.blit_rect(source, Rect2i(0, 0, POLE_WIDTH, source.get_height()), Vector2i.ZERO)
	out.blit_rect(source, Rect2i(width - POLE_WIDTH, 0, POLE_WIDTH, source.get_height()), Vector2i(width - POLE_WIDTH, 0))
	for x: int in range(POLE_WIDTH - 4, width - POLE_WIDTH + 4):
		var t: float = float(x - POLE_WIDTH + 4) / float(width - 2 * POLE_WIDTH + 7)
		var y: int = ROPE_Y + int(round(ROPE_SAG * sin(PI * t)))
		out.set_pixel(x, y, ROPE_LIGHT)
		out.set_pixel(x, y + 1, ROPE_DARK)
	var error: int = out.save_png(OUTPUT)
	print("CLOTHESLINE ", OUTPUT, " ", out.get_size(), " loi=", error)
	quit(error)
