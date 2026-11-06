class_name FarmField
extends Node
## Mảnh vườn: quản lý trạng thái các ô đất (cuốc, gieo, lớn lên, thu hoạch).
##
## - Chỉ chứa logic và dữ liệu; việc vẽ do FarmView lo, việc trừ hạt/thêm nông sản
##   do FarmToolController lo. Các bên nói chuyện qua signal.
## - Cây lớn nhờ nghe EventBus.day_changed (không dùng _process).
## - Sang mùa không hợp thì cây héo (EventBus.crop_withered).

## Một ô thay đổi (đất, cây hoặc giai đoạn lớn). FarmView nghe signal này.
signal plot_changed(cell: Vector2i)

## Vùng ô lưới được phép canh tác (toạ độ ô, không phải pixel).
@export var field_area: Rect2i = Rect2i(0, 0, 10, 7)

var _plots: Dictionary = {}  # Vector2i -> FarmPlot
var _last_day: int = 1


func _ready() -> void:
	_last_day = TimeManager.day
	EventBus.day_changed.connect(_on_day_changed)
	EventBus.season_changed.connect(_on_season_changed)


## Ô nằm trong vùng canh tác không.
func is_farmable(cell: Vector2i) -> bool:
	return field_area.has_point(cell)


## Trả về FarmPlot của ô, hoặc null nếu ô chưa được cuốc.
func get_plot(cell: Vector2i) -> FarmPlot:
	return _plots.get(cell)


## Danh sách các ô đã có dữ liệu (đã cuốc), để FarmView vẽ lại toàn bộ.
func get_plot_cells() -> Array:
	return _plots.keys()


## Cuốc đất. Trả về false nếu ngoài vùng canh tác hoặc ô đã cuốc rồi.
func till(cell: Vector2i) -> bool:
	if not is_farmable(cell) or _plots.has(cell):
		return false
	var plot := FarmPlot.new()
	plot.is_tilled = true
	_plots[cell] = plot
	EventBus.tile_tilled.emit(cell)
	plot_changed.emit(cell)
	return true


## Lý do không gieo được [param crop] vào [param cell]; chuỗi rỗng nghĩa là gieo được.
func get_plant_block_reason(cell: Vector2i, crop: CropItemData) -> String:
	var plot: FarmPlot = get_plot(cell)
	if crop == null:
		return "Không có hạt giống."
	if plot == null or not plot.is_tilled:
		return "Cần cuốc đất trước."
	if plot.is_planted():
		return "Ô này đã có cây."
	if not crop.can_plant_in(TimeManager.season):
		return "Không gieo được vào mùa này."
	return ""


## Gieo [param crop] vào [param cell]. Trả về false nếu không gieo được.
func plant(cell: Vector2i, crop: CropItemData) -> bool:
	if not get_plant_block_reason(cell, crop).is_empty():
		return false
	var plot: FarmPlot = _plots[cell]
	plot.crop = crop
	plot.days_grown = 0
	EventBus.crop_planted.emit(cell, crop)
	plot_changed.emit(cell)
	return true


## Thu hoạch cây đã chín: trả về CropItemData của cây (để bên gọi tính nông sản),
## ô trở lại đất trống. Trả về null nếu chưa có cây chín.
func harvest(cell: Vector2i) -> CropItemData:
	var plot: FarmPlot = get_plot(cell)
	if plot == null or not plot.is_ripe():
		return null
	var crop: CropItemData = plot.crop
	plot.clear_crop()
	EventBus.crop_harvested.emit(cell, crop)
	plot_changed.emit(cell)
	return crop


## Gói trạng thái vườn để lưu game (cho WorldStateManager/SaveManager).
func get_save_data() -> Dictionary:
	var entries: Array = []
	for cell: Vector2i in _plots:
		var plot: FarmPlot = _plots[cell]
		entries.append({
			"x": cell.x,
			"y": cell.y,
			"crop": String(plot.crop.id) if plot.crop != null else "",
			"days": plot.days_grown,
		})
	return {"last_day": _last_day, "plots": entries}


## Nạp lại trạng thái vườn. Ô có cây không còn trong ItemDatabase thành đất trống.
func load_save_data(data: Dictionary) -> void:
	var old_cells: Array = _plots.keys()
	_plots.clear()
	_last_day = int(data.get("last_day", TimeManager.day))
	for entry: Dictionary in data.get("plots", []):
		var plot := FarmPlot.new()
		plot.is_tilled = true
		var crop_id := StringName(entry.get("crop", ""))
		if crop_id != &"":
			plot.crop = ItemDatabase.get_item(crop_id) as CropItemData
			plot.days_grown = int(entry.get("days", 0)) if plot.crop != null else 0
		_plots[Vector2i(int(entry["x"]), int(entry["y"]))] = plot
	for cell: Vector2i in old_cells:
		plot_changed.emit(cell)
	for cell: Vector2i in _plots:
		plot_changed.emit(cell)


## Cây lớn theo số ngày đã trôi qua kể từ lần xử lý trước, nên nạp game
## (TimeManager phát lại day_changed với cùng ngày) không làm cây lớn thêm.
func _on_day_changed(day: int) -> void:
	var elapsed: int = day - _last_day
	_last_day = day
	if elapsed <= 0:
		return
	for cell: Vector2i in _plots:
		var plot: FarmPlot = _plots[cell]
		if plot.is_planted():
			plot.days_grown += elapsed
			plot_changed.emit(cell)


func _on_season_changed(season: int, _year: int) -> void:
	for cell: Vector2i in _plots:
		var plot: FarmPlot = _plots[cell]
		if plot.is_planted() and not plot.crop.can_plant_in(season):
			var withered: CropItemData = plot.crop
			plot.clear_crop()
			EventBus.crop_withered.emit(cell, withered)
			plot_changed.emit(cell)
