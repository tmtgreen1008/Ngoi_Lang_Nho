extends Node
## ItemDatabase (Autoload): tra cứu ItemData theo id.
##
## Tự quét các thư mục trong [constant SCAN_DIRS] khi khởi động, nên thêm vật
## phẩm mới chỉ cần thả file .tres vào đó, không phải sửa code. Dùng để đổi
## harvest_item_id hoặc id trong file save thành ItemData.

const SCAN_DIRS: PackedStringArray = ["res://data/items", "res://data/crops"]

var _items: Dictionary = {}  # StringName -> ItemData


func _ready() -> void:
	reload()


## Quét lại các thư mục dữ liệu.
func reload() -> void:
	_items.clear()
	for dir_path: String in SCAN_DIRS:
		_scan_directory(dir_path)


## Trả về ItemData theo id, hoặc null nếu không tồn tại.
func get_item(id: StringName) -> ItemData:
	if not _items.has(id):
		push_warning("ItemDatabase: khong tim thay item '%s'" % id)
		return null
	return _items[id]


func has_item(id: StringName) -> bool:
	return _items.has(id)


func get_all_ids() -> Array:
	return _items.keys()


func _scan_directory(dir_path: String) -> void:
	for file_name: String in DirAccess.get_files_at(dir_path):
		# Ban export doi ten .tres thanh .tres.remap, nen bo hau to .remap.
		var clean_name: String = file_name.trim_suffix(".remap")
		if not clean_name.ends_with(".tres"):
			continue
		var res: Resource = load(dir_path.path_join(clean_name))
		if res is ItemData:
			_register(res as ItemData, clean_name)


func _register(item: ItemData, file_name: String) -> void:
	if not item.is_valid():
		push_warning("ItemDatabase: %s thieu id hoac ten, bo qua" % file_name)
		return
	if _items.has(item.id):
		push_warning("ItemDatabase: id '%s' bi trung (%s)" % [item.id, file_name])
		return
	_items[item.id] = item
