class_name Shadow
extends RefCounted
## Bóng đổ dưới chân nhân vật, nhà, cây, đồ vật: một hình bầu dục tối trong suốt.
##
## Tạo bằng [method create] rồi đặt ở CHÂN vật thể và thêm vào TRƯỚC sprite của vật thể
## (để sprite vẽ đè lên bóng). Nhờ bóng, vật thể không còn "nổi" trên mặt đất.

const TEXTURE_SIZE := Vector2i(64, 16)
const COLOR := Color(0.06, 0.1, 0.04, 0.3)
## Chiều cao bóng so với chiều rộng.
const HEIGHT_RATIO: float = 0.3

static var _texture: Texture2D


## Bóng rộng [param width] pixel, tâm tại gốc toạ độ của sprite trả về.
static func create(width: float) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.name = "Shadow"
	sprite.texture = _get_texture()
	var w: float = maxf(width, 4.0)
	sprite.scale = Vector2(w / TEXTURE_SIZE.x, w * HEIGHT_RATIO / TEXTURE_SIZE.y)
	return sprite


static func _get_texture() -> Texture2D:
	if _texture == null:
		var image := Image.create(TEXTURE_SIZE.x, TEXTURE_SIZE.y, false, Image.FORMAT_RGBA8)
		var half := Vector2(TEXTURE_SIZE) / 2.0
		for y: int in TEXTURE_SIZE.y:
			for x: int in TEXTURE_SIZE.x:
				var offset := Vector2(x + 0.5 - half.x, y + 0.5 - half.y) / half
				if offset.length_squared() <= 1.0:
					image.set_pixel(x, y, COLOR)
		_texture = ImageTexture.create_from_image(image)
	return _texture
