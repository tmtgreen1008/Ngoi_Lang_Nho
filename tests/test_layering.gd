extends "res://tests/test_base.gd"
## Xếp lớp theo chiều sâu: Player là con của map hiện tại (và sống sót khi đổi map), đứng sau nhà / cây
## thì bị che, đứng trước thì đè lên. Kiểm tra bằng ảnh chụp màn hình thật (cần cửa sổ, không headless).

## Chụp màn hình rồi trả về ảnh.
func _capture() -> Image:
	await wait(0.2)
	return root.get_texture().get_image()


## Số pixel khác nhau giữa hai ảnh trong vùng [param rect].
func _diff(a: Image, b: Image, rect: Rect2i) -> int:
	var count: int = 0
	for y: int in range(rect.position.y, rect.end.y):
		for x: int in range(rect.position.x, rect.end.x):
			if a.get_pixel(x, y) != b.get_pixel(x, y):
				count += 1
	return count


func run() -> void:
	if DisplayServer.get_name() == "headless":
		check("bỏ qua test xếp lớp khi chạy headless (cần ảnh chụp)", true)
		return
	var tm: Node = root.get_node("TimeManager")
	var sm: Node = root.get_node("SceneManager")
	var db: Node = root.get_node("ItemDatabase")
	var main: Node = await start_game()
	tm.pause()
	var player: Node = main.player
	var home: Node = sm.current_map

	# --- cấu trúc ---
	check("map bật xếp lớp theo y", home.y_sort_enabled)
	check("Player là con của map hiện tại", player.get_parent() == home)
	check("view vườn bật xếp lớp", home.view.y_sort_enabled)

	# --- đi sau nhà: bị nhà che; đứng trước nhà: đè lên nhà ---
	var house_center := Vector2(936, 196)
	player.position = Vector2(400, 150)  # xa nhà: ảnh nền để so sánh
	await wait(0.2)
	var away: Image = await _capture()
	var region := Rect2i(int(house_center.x) - 14, int(house_center.y) - 22, 28, 40)
	player.position = house_center
	var behind: Image = await _capture()
	check("đứng sau nhà (chân phía trên mép dưới nhà): nhà che kín Player", _diff(away, behind, region) == 0)
	player.position = Vector2(900, 270)  # trước nhà (y chân > 232), ngoài lối vào nhà
	var in_front_region := Rect2i(900 - 14, 270 - 22, 28, 40)
	player.position = Vector2(400, 150)
	var empty_front: Image = await _capture()
	player.position = Vector2(900, 270)
	var front: Image = await _capture()
	check("đứng trước nhà: Player hiện rõ", _diff(empty_front, front, in_front_region) > 100)

	# --- đi sau cây trong vườn ---
	var crop: CropItemData = db.get_item(&"hat_giong_ca_chua") as CropItemData
	tm.season = 0
	home.field.till(Vector2i(3, 3))
	home.field.plant(Vector2i(3, 3), crop)
	for day: int in crop.grow_days:
		tm.sleep_until_morning()
	tm.season = 0
	check("cây cà chua đã chín", home.field.get_plot(Vector2i(3, 3)).is_ripe())
	var sprite: Sprite2D = home.view.get_crop_sprite(Vector2i(3, 3))
	check("sprite cây có gốc ở chân (đáy ô) để xếp lớp", sprite != null and sprite.global_position.y == 240 + 4 * 48 and sprite.offset == Vector2(0, -48))
	var crop_top := Vector2(192 + 3 * 48 + 24, 240 + 3 * 48)  # đỉnh ô cây (giữa)
	player.position = Vector2(400, 150)
	var crop_away: Image = await _capture()
	player.position = crop_top + Vector2(0, 30)  # chân Player phía trên chân cây (432): đứng sau cây
	var crop_behind: Image = await _capture()
	# Lá cây có chỗ trống nên Player lộ ra qua kẽ lá; chỉ xét các pixel ĐẶC của cây (alpha = 1):
	# ở đó ảnh phải y hệt khi Player đứng xa (cây vẽ đè lên Player).
	var crop_image: Image = sprite.texture.get_image()
	var frame_x: int = crop.get_growth_frame(crop.grow_days) * 48
	var tile_origin := Vector2i(192 + 3 * 48, 240 + 3 * 48)
	var player_box := Rect2i(int(crop_top.x) - 16, int(crop_top.y) + 30 - 34, 32, 48)
	var opaque_under_player: int = 0
	var mismatches: int = 0
	for py: int in 48:
		for px: int in 48:
			if crop_image.get_pixel(frame_x + px, py).a < 0.99:
				continue
			var screen := tile_origin + Vector2i(px, py)
			if player_box.has_point(screen):
				opaque_under_player += 1
				if crop_away.get_pixel(screen.x, screen.y) != crop_behind.get_pixel(screen.x, screen.y):
					mismatches += 1
	check("Player đứng sau phần đặc của cây (đủ nhiều pixel để so sánh)", opaque_under_player > 150)
	check("đứng sau cây cà chua: mọi pixel đặc của cây đè lên Player", mismatches == 0)
	var below: Vector2 = Vector2(crop_top.x, 240 + 4 * 48 + 20)  # đứng ngay dưới ô cây, trước cây
	player.position = below
	var crop_front: Image = await _capture()
	var below_region := Rect2i(int(below.x) - 14, int(below.y) - 22, 28, 40)
	player.position = Vector2(400, 150)
	var below_empty: Image = await _capture()
	player.position = below
	var below_with: Image = await _capture()
	check("đứng trước cây: Player hiện rõ", crop_front != null and _diff(below_empty, below_with, below_region) > 100)
	player.position = crop_top + Vector2(0, 30)
	await shot("layering_behind_crop.png")
	player.position = house_center
	await shot("layering_behind_house.png")

	# --- đổi map: Player sống sót và vào map mới ---
	player.position = home.get_exit_position("grocery_store.tscn")
	await wait(1.0)
	check("sang Tiệm Tạp Hóa: Player còn sống và là con của map mới", is_instance_valid(player) and sm.current_scene_path.ends_with("grocery_store.tscn") and player.get_parent() == sm.current_map)
	check("map cũ đã được giải phóng", not is_instance_valid(home))
	check("map mới cũng xếp lớp theo y", sm.current_map.y_sort_enabled)
