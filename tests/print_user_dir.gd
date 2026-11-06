extends SceneTree
## Tiện ích cho run_all.sh: in đường dẫn thư mục dữ liệu người dùng (nơi game ghi file lưu).


func _initialize() -> void:
	print("USERDIR ", OS.get_user_data_dir())
	quit()
