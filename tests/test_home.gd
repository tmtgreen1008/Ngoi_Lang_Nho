extends "res://tests/test_base.gd"
## Map nhà và trong nhà: vùng chơi thu hẹp, rặng cây, cây thành cụm, bóng đổ, biển chỉ đường
## thay chữ nổi, đường đất bo góc, vào nhà qua cửa, ngủ trong nhà (vườn vẫn lớn đúng).


## Số sprite trang trí (cây, hàng rào, chum...) của map thỏa [param condition].
func _count_decor(map: Node, condition: Callable) -> int:
	var count: int = 0
	for child: Node in map.get_children():
		if child is Sprite2D and child.region_enabled and String(child.texture.resource_path).ends_with("decor_sheet.png"):
			if condition.call(child):
				count += 1
	return count


func _shadows_near(map: Node, point: Vector2, distance: float, shadow_texture: Texture2D) -> int:
	var count: int = 0
	for child: Node in map.get_children():
		if child is Sprite2D and child.texture == shadow_texture and child.position.distance_to(point) <= distance:
			count += 1
	return count


func _find_all(node: Node, class_name_: StringName, out: Array) -> void:
	for child: Node in node.get_children():
		var script: Script = child.get_script()
		if script != null and script.get_global_name() == class_name_:
			out.append(child)
		_find_all(child, class_name_, out)


func run() -> void:
	var sm: Node = root.get_node("SceneManager")
	var tm: Node = root.get_node("TimeManager")
	var db: Node = root.get_node("ItemDatabase")

	var main: Node = await start_game()
	tm.pause()
	var player: Node = main.player
	var hud: Node = find_by_class(main, &"Hud")
	var home: Node = sm.current_map
	var rect: Rect2 = home.playable_rect

	# --- tên map: thông báo, không còn chữ nổi trên nền ---
	check("vào map hiện thông báo tên 'Khu nhà'", hud._toast_label.visible and hud._toast_label.text == "Khu nhà")
	var floating: int = 0
	for child: Node in home.get_children():
		if child is Label:
			floating += 1
	check("không còn nhãn chữ nổi nào trên map nhà", floating == 0)
	var exits: Array = []
	for child: Node in home.get_children():
		if child.get_script() != null and child.get_script().get_global_name() == &"SceneExit":
			exits.append(child)
	var markers: int = 0
	for exit_node in exits:
		markers += 1 if exit_node.show_marker else 0
	check("lối ra vô hình (không còn ô vàng, không nhãn)", exits.size() == 4 and markers == 0)

	# --- thu hẹp không gian ---
	check("vùng chơi thu hẹp so với màn hình (1008x528)", rect.size == Vector2(1008, 528) and rect.size.x < 1280.0 and rect.size.y < 720.0)
	check("viền rặng cây", home.border_style == home.BorderStyle.TREES)
	check("Player xuất hiện trong vùng chơi", rect.has_point(player.position))
	player.position = Vector2(170, 330)
	Input.action_press("move_left")
	await wait(1.0)
	Input.action_release("move_left")
	check("tường trái chặn ở mép vùng chơi (x >= 144)", player.position.x >= 144.0 and player.position.x < 170.0)
	player.position = Vector2(500, 120)
	Input.action_press("move_up")
	await wait(1.0)
	Input.action_release("move_up")
	check("tường trên chặn ở mép vùng chơi (y >= 96)", player.position.y >= 96.0 and player.position.y < 120.0)
	player.position = Vector2(500, 600)
	Input.action_press("move_down")
	await wait(1.0)
	Input.action_release("move_down")
	check("tường dưới chặn ở mép vùng chơi (y <= 624)", player.position.y <= 624.0 and player.position.y > 600.0)

	# --- rặng cây quanh vùng chơi và cây thành cụm ---
	var outside: int = _count_decor(home, func(s: Sprite2D) -> bool: return not rect.grow(8.0).has_point(s.position))
	check("rặng cây dày quanh ngoài vùng chơi (>= 60 cây)", outside >= 60)
	var bananas_near: int = _count_decor(home, func(s: Sprite2D) -> bool: return s.region_rect.position.x == 0.0 and s.position.distance_to(Vector2(1080, 210)) < 60.0)
	check("chuối trồng thành cụm >= 3 cây cạnh nhà", bananas_near >= 3)
	var bush_row: int = _count_decor(home, func(s: Sprite2D) -> bool: return s.region_rect.position.x == 96.0 and absf(s.position.y - 153.0) < 12.0 and s.position.x > 530.0 and s.position.x < 720.0)
	check("bụi hoa xếp thành hàng (>= 5 bụi cùng một dải)", bush_row >= 5)
	var cluster_a: Array = home.add_cluster(home.Decor.BANANA, Vector2(400, 150), 4, 30.0, 99)
	var cluster_b: Array = home.add_cluster(home.Decor.BANANA, Vector2(400, 150), 4, 30.0, 99)
	var same_layout: bool = cluster_a.size() == 4 and cluster_b.size() == 4
	for i: int in 4:
		same_layout = same_layout and cluster_a[i].position == cluster_b[i].position
	check("cụm cây cùng hạt giống thì cùng bố cục", same_layout)
	var sorted_by_y: bool = true
	for i: int in range(1, 4):
		sorted_by_y = sorted_by_y and cluster_a[i - 1].position.y <= cluster_a[i].position.y
	check("cây trong cụm xếp từ trên xuống để che đúng", sorted_by_y)

	# --- bóng đổ ---
	check("nhà có bóng đổ dưới chân", _shadows_near(home, Vector2(936, 230), 6.0, player.get_node("Shadow").texture) >= 1)
	check("cây chuối trong cụm có bóng", _shadows_near(home, bananas_near_position(home), 8.0, player.get_node("Shadow").texture) >= 1)
	var player_shadow: Node = player.get_node_or_null("Shadow")
	check("Player có bóng đổ dưới sprite", player_shadow != null and player.get_child(0) == player_shadow)
	var shadow_tex: Texture2D = player_shadow.texture
	check("bóng là hình bầu dục trong suốt (giữa đặc, góc trong suốt)", shadow_tex.get_image().get_pixel(32, 8).a > 0.2 and shadow_tex.get_image().get_pixel(0, 0).a == 0.0)

	# --- biển chỉ đường thay chữ nổi ---
	var signs: Array = []
	_find_all(home, &"Signpost", signs)
	var junction: Node = null
	for sign_node in signs:
		if sign_node.entries.size() == 3:
			junction = sign_node
	check("biển chỉ đường ở ngã ba có 3 tấm ván", junction != null and junction.entries == PackedStringArray(["Tiệm Tạp Hóa", "Khu Giải trí", "Chợ Quê"]))
	check("biển chỉ về phía đông (ra cổng)", junction.points_right)

	# --- đường đất bo góc, đốm cỏ ---
	var convex: int = home.PathCorner.CONVEX
	var concave: int = home.PathCorner.CONCAVE
	var none: int = home.PathCorner.NONE
	check("đầu đường ở cửa nhà: góc lồi (bo tròn)", home.path_corner_kind(Vector2i(19, 5), Vector2i(-1, -1)) == convex and home.path_corner_kind(Vector2i(19, 5), Vector2i(1, -1)) == convex)
	check("ngã ba đường: góc lõm (đất lấn ra cỏ)", home.path_corner_kind(Vector2i(19, 8), Vector2i(-1, -1)) == concave)
	check("giữa đường thẳng: không cần xử lý góc", home.path_corner_kind(Vector2i(16, 8), Vector2i(-1, -1)) == none and home.path_corner_kind(Vector2i(16, 8), Vector2i(1, 1)) == none)
	check("mép màn hình coi như đường (không cắt)", home._is_path(Vector2i(-1, 3)) and home._is_path(Vector2i(60, 3)))
	var cut: PackedVector2Array = home._convex_cut_polygon(Vector2(48, 48), Vector2i(1, 1))
	check("đa giác bo góc hợp lệ (>= 6 điểm, nằm gọn trong ô bán kính 16)", cut.size() >= 6 and cut[1].distance_to(Vector2(48, 48)) <= 16.01)
	check("đốm cỏ úa, cỏ rậm và vệt đất được bật", home.ground_variation)
	await shot("home_layout.png")

	# --- vào nhà qua cửa, ngủ trong nhà ---
	var controller: Node = home.controller
	controller.set_tool(0)
	controller.use_tool_at(Vector2i(1, 1))
	controller.set_tool(1)
	controller.use_tool_at(Vector2i(1, 1))
	var door_x: float = (home.DOOR_LEFT + home.DOOR_RIGHT) / 2.0
	player.position = Vector2(door_x, 330)
	await wait(0.2)
	Input.action_press("move_up")
	# Giữ phím tới khi sang map trong nhà rồi nhả ngay (không đi tiếp trong nhà).
	for i: int in 60:
		await wait(0.05)
		if sm.current_scene_path.ends_with("house_interior.tscn"):
			break
	Input.action_release("move_up")
	await wait(0.8)
	check("bước vào khe cửa thì sang map trong nhà", sm.current_scene_path.ends_with("house_interior.tscn"))
	var interior: Node = sm.current_map
	check("trong nhà: hiện thông báo 'Trong nhà'", hud._toast_label.text == "Trong nhà")
	check("trong nhà: xuất hiện ở điểm mặc định gần cửa", player.position.distance_to(interior.get_spawn_position(&"default")) < 15)
	await shot("interior.png")

	# tường phòng
	player.position = Vector2(400, 450)
	Input.action_press("move_left")
	await wait(1.0)
	Input.action_release("move_left")
	check("tường phòng chặn bên trái (x >= 320)", player.position.x >= 320.0 and player.position.x < 400.0)

	var days_before: int = tm.day
	player.position = Vector2(470, 440)
	await wait(0.3)
	check("lại gần giường nhắm được giường", player.get_target() != null and player.get_target().prompt_text == "Đi ngủ")
	for i: int in 4:
		await press_action("interact")
	check("ngủ 4 lần: sang 4 ngày mới", tm.day == days_before + 4)
	check("báo thông báo sau khi ngủ", hud._toast_label.text.begins_with("Bạn ngủ"))

	player.position = interior.get_exit_position("home.tscn")
	await wait(1.0)
	check("ra cửa phòng thì về sân nhà", sm.current_scene_path.ends_with("home.tscn"))
	var home2: Node = sm.current_map
	check("về đúng chỗ ngay dưới cửa nhà", player.position.distance_to(home2.get_spawn_position(&"from_house")) < 5)
	var plot: Variant = home2.field.get_plot(Vector2i(1, 1))
	check("ngủ trong nhà: cây ngoài vườn đã lớn đủ 4 ngày và chín", plot != null and plot.is_planted() and plot.days_grown == 4 and plot.is_ripe())

	# --- quay về từ các nơi khác: đứng ngay trong cổng, trong vùng chơi ---
	player.position = home2.get_exit_position("grocery_store.tscn")
	await wait(1.0)
	check("sang Tạp hóa: có biển 'Về nhà' chỉ sang trái", _has_sign(sm.current_map, "Về nhà", false))
	player.position = sm.current_map.get_exit_position("home.tscn")
	await wait(1.0)
	check("từ Tạp hóa về: đứng trong cổng, trong vùng chơi", sm.current_map.playable_rect.has_point(player.position) and player.position.distance_to(sm.current_map.get_spawn_position(&"from_grocery")) < 5)


## Vị trí cụm chuối cạnh nhà (xấp xỉ), dùng để tìm bóng của một cây chuối thật sự có trên map.
func bananas_near_position(home: Node) -> Vector2:
	for child: Node in home.get_children():
		if child is Sprite2D and child.region_enabled and child.region_rect.position.x == 0.0 and child.position.distance_to(Vector2(1080, 210)) < 60.0:
			return child.position + Vector2(0, -2)
	return Vector2.ZERO


func _has_sign(map: Node, text: String, points_right: bool) -> bool:
	var signs: Array = []
	_find_all(map, &"Signpost", signs)
	for sign_node in signs:
		if sign_node.entries == PackedStringArray([text]) and sign_node.points_right == points_right:
			return true
	return false
