extends SceneTree
## Lớp nền cho các bài test chạy bằng `godot --path . -s tests/test_xxx.gd`.
##
## Mỗi bài test kế thừa file này và ghi đè [method run]; dùng [method check] để khẳng định.
## Thoát với mã 0 nếu mọi kiểm tra đạt, 1 nếu có kiểm tra trượt (để tập lệnh CI bắt được).
##
## LƯU Ý quan trọng: ở chế độ `-s`, script test được compile TRƯỚC khi các autoload
## (EventBus, TimeManager...) được đăng ký. Vì vậy trong file test:
##   - KHÔNG nhắc tên class dùng autoload (InventoryComponent, FarmField, AimGame...)
##     bằng cú pháp `is X` hay `X.new()`; hãy dùng load("res://...gd").new() và
##     get_script().get_global_name().
##   - Lấy autoload bằng root.get_node("TimeManager"), không gọi trực tiếp tên autoload.

## Thư mục lưu ảnh chụp màn hình của test (trong thư mục dữ liệu người dùng của game).
const SHOT_DIR: String = "user://test_shots/"

var fails: int = 0
var checks: int = 0


func _initialize() -> void:
	await process_frame
	await run()
	print("RESULT %s: %d checks, %d failed" % [_script_name(), checks, fails])
	quit(1 if fails > 0 else 0)


## Bài test ghi đè hàm này.
func run() -> void:
	pass


func check(label: String, condition: bool) -> void:
	checks += 1
	if not condition:
		fails += 1
	print(("PASS " if condition else "FAIL ") + label)


## Chờ [param seconds] giây thật (vẫn chạy khi game đang dừng).
func wait(seconds: float) -> void:
	await create_timer(seconds).timeout


func wait_frames(count: int) -> void:
	for i: int in count:
		await physics_frame


## Giả lập nhấn rồi nhả một hành động InputMap (vd "interact", "ui_cancel").
func press_action(action: String) -> void:
	var down := InputEventAction.new()
	down.action = action
	down.pressed = true
	Input.parse_input_event(down)
	await wait(0.1)
	var up := InputEventAction.new()
	up.action = action
	up.pressed = false
	Input.parse_input_event(up)
	await wait(0.1)


## Chụp màn hình vào [constant SHOT_DIR]; bỏ qua khi chạy headless (không có hình).
func shot(file_name: String) -> void:
	await wait(0.25)
	if DisplayServer.get_name() == "headless":
		return
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	root.get_texture().get_image().save_png(SHOT_DIR + file_name)


## Nút (Button) con cháu của [param node], theo thứ tự cây.
func find_buttons(node: Node) -> Array:
	var found: Array = []
	for child: Node in node.get_children():
		if child is Button:
			found.append(child)
		found.append_array(find_buttons(child))
	return found


## Tìm node con theo tên class do người dùng định nghĩa (class_name).
func find_by_class(node: Node, class_name_: StringName) -> Node:
	for child: Node in node.get_children():
		var script: Script = child.get_script()
		if script != null and script.get_global_name() == class_name_:
			return child
		var deeper: Node = find_by_class(child, class_name_)
		if deeper != null:
			return deeper
	return null


## Khởi động game như người chơi: dựng Main, bấm "Ván mới", chờ vào map nhà.
func start_game() -> Node:
	var main: Node = load("res://main.tscn").instantiate()
	root.add_child(main)
	await wait(0.2)
	main.start_new_game()
	await wait(0.8)
	return main


func _script_name() -> String:
	return String(get_script().resource_path).get_file()


## Đi thẳng tới map [param file] (tên file scene không đuôi: "home", "village", "grocery_store", "entertainment",
## "house_interior") qua SceneManager, xuất hiện ở [param spawn], rồi chờ chuyển cảnh xong. Trả về map mới.
func travel(file: String, spawn: StringName = &"default") -> Node:
	var folder: String = file
	root.get_node("EventBus").scene_change_requested.emit("res://maps/%s/%s.tscn" % [folder, file], spawn)
	await wait(1.0)
	return root.get_node("SceneManager").current_map
