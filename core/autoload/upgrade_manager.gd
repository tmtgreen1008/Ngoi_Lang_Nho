extends Node
## UpgradeManager (Autoload): cấp độ các nâng cấp (vườn, công cụ, chuồng, túi đồ) và việc mua chúng.
##
## - Tự quét data/upgrades/*.tres (UpgradeData), nên thêm nâng cấp mới chỉ cần thả file dữ liệu.
## - [method buy] trừ tiền qua EconomyManager rồi phát EventBus.upgrade_purchased; các hệ thống tự áp hiệu lực
##   (manager không biết vườn hay chuồng là gì). Nạp game / ván mới phát EventBus.upgrades_reloaded.
## - Lưu cùng ván chơi qua SaveManager (get_save_data/load_save_data).

const DATA_DIR: String = "res://data/upgrades"
## Mã các nâng cấp có hiệu lực trong code (dữ liệu của chúng nằm ở data/upgrades/).
const GARDEN: StringName = &"garden"
const TOOL: StringName = &"tool"
const COOP: StringName = &"coop"
const BARN: StringName = &"barn"
const BAG: StringName = &"bag"
## Thứ tự hiện trong bảng nâng cấp.
const ORDER: Array[StringName] = [GARDEN, TOOL, COOP, BARN, BAG]

var _data: Dictionary = {}  # id -> UpgradeData
var _levels: Dictionary = {}  # id -> cấp


func _ready() -> void:
	reload()


## Quét lại thư mục dữ liệu.
func reload() -> void:
	_data.clear()
	for file_name: String in DirAccess.get_files_at(DATA_DIR):
		var clean_name: String = file_name.trim_suffix(".remap")  # bản export đổi tên .tres thành .tres.remap
		if not clean_name.ends_with(".tres"):
			continue
		var data: UpgradeData = load(DATA_DIR.path_join(clean_name)) as UpgradeData
		if data == null or not data.is_valid():
			push_warning("UpgradeManager: bo qua %s (khong hop le)" % clean_name)
		elif _data.has(data.id):
			push_warning("UpgradeManager: id '%s' bi trung (%s)" % [data.id, clean_name])
		else:
			_data[data.id] = data


func get_data(id: StringName) -> UpgradeData:
	return _data.get(id)


func has_upgrade(id: StringName) -> bool:
	return _data.has(id)


## Mọi nâng cấp để UI liệt kê: theo thứ tự [constant ORDER] (vườn, dụng cụ, chuồng, túi), nâng cấp khác sau đó theo id.
func get_all() -> Array[UpgradeData]:
	var ids: Array = _data.keys()
	ids.sort_custom(func(a: StringName, b: StringName) -> bool:
		var ia: int = ORDER.find(a) if ORDER.has(a) else 100
		var ib: int = ORDER.find(b) if ORDER.has(b) else 100
		return ia < ib or (ia == ib and String(a) < String(b)))
	var result: Array[UpgradeData] = []
	for id: StringName in ids:
		result.append(_data[id])
	return result


func get_level(id: StringName) -> int:
	return int(_levels.get(id, 0))


func is_maxed(id: StringName) -> bool:
	var data: UpgradeData = get_data(id)
	return data == null or get_level(id) >= data.max_level()


## Giá trị hiệu lực ở cấp hiện tại (0 nếu không có nâng cấp này).
func get_value(id: StringName) -> int:
	var data: UpgradeData = get_data(id)
	return 0 if data == null else data.value_at(get_level(id))


## Giá mua cấp kế tiếp, hoặc -1 nếu đã tối đa / không có.
func get_next_cost(id: StringName) -> int:
	var data: UpgradeData = get_data(id)
	return -1 if data == null else data.cost_for(get_level(id) + 1)


## Lý do chưa mua được; chuỗi rỗng nghĩa là mua được.
func get_buy_block_reason(id: StringName) -> String:
	if not has_upgrade(id):
		return "Không có nâng cấp này."
	if is_maxed(id):
		return "Đã nâng cấp tối đa."
	var cost: int = get_next_cost(id)
	if not EconomyManager.can_afford(cost):
		return "Không đủ tiền: cần %d đ." % cost
	return ""


## Mua cấp kế tiếp. Trả về lỗi hoặc "" nếu thành công.
func buy(id: StringName) -> String:
	var reason: String = get_buy_block_reason(id)
	if not reason.is_empty():
		return reason
	var cost: int = get_next_cost(id)
	EconomyManager.spend(cost)
	_levels[id] = get_level(id) + 1
	EventBus.upgrade_purchased.emit(id, get_level(id))
	return ""


## Quên hết (ván mới).
func clear() -> void:
	_levels.clear()
	EventBus.upgrades_reloaded.emit()


func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	for id: StringName in _levels:
		data[String(id)] = int(_levels[id])
	return data


## JSON đọc lại số nguyên thành số thực nên ép int(); id lạ bị bỏ, cấp bị kẹp trong khoảng hợp lệ.
func load_save_data(data: Dictionary) -> void:
	_levels.clear()
	for key: Variant in data:
		var id := StringName(String(key))
		var upgrade: UpgradeData = get_data(id)
		if upgrade != null:
			_levels[id] = clampi(int(data[key]), 0, upgrade.max_level())
	EventBus.upgrades_reloaded.emit()
