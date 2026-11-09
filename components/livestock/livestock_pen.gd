class_name LivestockPen
extends Node
## Chuồng nuôi: giữ các con vật cùng một loài, đếm ngày, cho ăn, thu sản phẩm.
##
## - Chỉ chứa logic và dữ liệu; kho đồ và thông báo do [LivestockController] lo, hình vẽ do
##   [LivestockHouse] lo. Các bên nói chuyện qua signal.
## - Nghe EventBus.day_changed (không dùng _process). Mỗi con được cho ăn trong ngày thì tiến thêm
##   một ngày; đủ [member AnimalData.fed_days_per_product] ngày thì có sản phẩm chờ thu.
## - Thuộc nhóm world_persistent nên được nhớ khi người chơi rời map; lúc vắng mặt con vật không được
##   cho ăn, nên chỉ ngày đầu tiên sau lần cuối ở lại tính tiến triển (bù ngày như FarmField).

## Chuồng thay đổi (thêm con, cho ăn, sang ngày, thu hoạch).
signal changed

@export var species: AnimalData
@export_range(1, 12, 1) var capacity: int = 4
## Khoá để WorldStateManager nhớ chuồng này (duy nhất trong map).
@export var persistent_key: StringName = &"livestock_pen"

## Mỗi con: {"fed": bool, "days": int, "ready": bool}.
var _animals: Array[Dictionary] = []
var _last_day: int = 1


func _ready() -> void:
	add_to_group(WorldStateManager.PERSISTENT_GROUP)
	_last_day = TimeManager.day
	EventBus.day_changed.connect(_on_day_changed)


func get_count() -> int:
	return _animals.size()


func is_full() -> bool:
	return _animals.size() >= capacity


## Số con chưa được cho ăn hôm nay (và chưa có sản phẩm chờ thu).
func get_unfed_count() -> int:
	var count: int = 0
	for animal: Dictionary in _animals:
		if not animal["fed"] and not animal["ready"]:
			count += 1
	return count


## Số con có sản phẩm chờ thu.
func get_ready_count() -> int:
	var count: int = 0
	for animal: Dictionary in _animals:
		if animal["ready"]:
			count += 1
	return count


## Thả thêm một con. Trả về false nếu chuồng đầy.
func add_animal() -> bool:
	if is_full():
		return false
	_animals.append({"fed": false, "days": 0, "ready": false})
	changed.emit()
	return true


## Cho ăn tối đa [param max_count] con chưa ăn. Trả về số con đã được cho ăn (bên gọi trừ thức ăn).
func feed(max_count: int) -> int:
	var fed: int = 0
	for animal: Dictionary in _animals:
		if fed >= max_count:
			break
		if not animal["fed"] and not animal["ready"]:
			animal["fed"] = true
			fed += 1
	if fed > 0:
		EventBus.animal_fed.emit(species.id)
		changed.emit()
	return fed


## Thu mọi sản phẩm đang chờ. Trả về số con đã cho sản phẩm (mỗi con = [member AnimalData.product_amount]).
## Con "xuất chuồng" ([member AnimalData.keeps_producing] = false) rời chuồng sau khi thu.
func collect() -> int:
	var batches: int = 0
	var remaining: Array[Dictionary] = []
	for animal: Dictionary in _animals:
		if animal["ready"]:
			batches += 1
			if species.keeps_producing:
				animal["ready"] = false
				animal["days"] = 0
				remaining.append(animal)
		else:
			remaining.append(animal)
	_animals = remaining
	if batches > 0:
		changed.emit()
	return batches


# --- Lưu / nạp -----------------------------------------------------------------------------


func get_save_data() -> Dictionary:
	return {"last_day": _last_day, "animals": _animals.duplicate(true)}


func load_save_data(data: Dictionary) -> void:
	_animals.clear()
	_last_day = int(data.get("last_day", TimeManager.day))
	for entry: Dictionary in data.get("animals", []):
		_animals.append({
			"fed": bool(entry.get("fed", false)),
			"days": int(entry.get("days", 0)),
			"ready": bool(entry.get("ready", false)),
		})
	# Trong lúc vắng mặt thời gian vẫn trôi: bù lại số ngày đã qua.
	_on_day_changed(TimeManager.day)
	changed.emit()


## Giao diện cho WorldStateManager (xem world_state_manager.gd).
func get_world_state() -> Dictionary:
	return get_save_data()


func apply_world_state(state: Dictionary) -> void:
	load_save_data(state)


## Theo số ngày đã trôi kể từ lần xử lý trước (nên nạp game, vốn phát lại day_changed cùng ngày,
## không làm con vật tiến thêm). Chỉ ngày đầu mang theo trạng thái "đã ăn"; các ngày vắng mặt sau đó
## không có ai cho ăn nên con vật đứng yên.
func _on_day_changed(day: int) -> void:
	var elapsed: int = day - _last_day
	_last_day = day
	if elapsed <= 0 or species == null:
		return
	for animal: Dictionary in _animals:
		if animal["ready"]:
			continue
		if animal["fed"]:
			animal["days"] = int(animal["days"]) + 1
			if int(animal["days"]) >= species.fed_days_per_product:
				animal["ready"] = true
		animal["fed"] = false
	changed.emit()
