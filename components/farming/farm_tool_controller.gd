class_name FarmToolController
extends Node
## Nối thao tác người chơi với FarmField và kho đồ: cuốc, gieo hạt, thu hoạch.
##
## FarmField không biết kho đồ; controller này trừ hạt giống khi gieo và thêm
## nông sản khi thu hoạch. Phản hồi cho người chơi đi qua signal [signal feedback].

enum Tool { HOE, SEED, HARVEST, FERTILIZE }

const TOOL_NAMES: Dictionary = {
	Tool.HOE: "Cuốc",
	Tool.SEED: "Gieo hạt",
	Tool.HARVEST: "Thu hoạch",
	Tool.FERTILIZE: "Bón phân",
}

## Công cụ đổi.
signal tool_changed(tool: Tool)
## Thông báo ngắn cho người chơi (lỗi hoặc kết quả).
signal feedback(text: String)

@export var field: FarmField
@export var inventory: InventoryComponent

var current_tool: Tool = Tool.HOE

var _muted: bool = false
var _first_message: String = ""


## Phát phản hồi cho người chơi; khi đang dùng công cụ trên nhiều ô ([method use_tool_area_at]) thì chỉ nhớ
## câu đầu tiên để báo một lần ở cuối, khỏi nhấp nháy theo từng ô.
func _say(text: String) -> void:
	if _first_message.is_empty():
		_first_message = text
	if not _muted:
		feedback.emit(text)


## Các ô bị tác động quanh ô bấm với [param cells] ô mỗi lần (xem nâng cấp "Dụng cụ tốt hơn"):
## 1 = chỉ ô bấm; 2 = ô bấm và ô bên phải; 3 = ba ô liền ngang, ô bấm ở giữa; 6 = hai hàng ba ô (ô bấm ở hàng
## trên, giữa). Toạ độ tương đối so với ô bấm.
static func pattern_for(cells: int) -> Array[Vector2i]:
	match cells:
		2:
			return [Vector2i(0, 0), Vector2i(1, 0)]
		3:
			return [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)]
		6:
			return [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1)]
	return [Vector2i(0, 0)]


## Dùng công cụ hiện tại lên mọi ô của [param pattern] quanh ô [param center]. Trả về số ô có hành động.
## Ô ngoài vườn bị bỏ qua. Phản hồi gộp: có ô thành công thì chỉ báo tổng kết (thu hoạch), không thì báo lý do đầu tiên.
func use_tool_area_at(center: Vector2i, pattern: Array[Vector2i]) -> int:
	if field == null or inventory == null:
		return 0
	if pattern.size() <= 1:
		return 1 if use_tool_at(center) else 0
	_muted = true
	_first_message = ""
	var done: int = 0
	for offset: Vector2i in pattern:
		if use_tool_at(center + offset):
			done += 1
	_muted = false
	if done == 0 and not _first_message.is_empty():
		feedback.emit(_first_message)
	elif done > 0 and current_tool == Tool.HARVEST:
		feedback.emit("Thu hoạch xong %d ô." % done)
	_first_message = ""
	return done


func set_tool(tool: Tool) -> void:
	current_tool = tool
	tool_changed.emit(tool)


func get_tool_name() -> String:
	return TOOL_NAMES[current_tool]


## Dùng công cụ hiện tại lên ô [param cell]. Trả về true nếu có hành động xảy ra.
func use_tool_at(cell: Vector2i) -> bool:
	if field == null or inventory == null or not field.is_farmable(cell):
		return false
	match current_tool:
		Tool.HOE:
			return _use_hoe(cell)
		Tool.SEED:
			return _use_seed(cell)
		Tool.HARVEST:
			return _use_harvest(cell)
		Tool.FERTILIZE:
			return _use_fertilize(cell)
	return false


func _use_hoe(cell: Vector2i) -> bool:
	if field.till(cell):
		return true
	_say("Ô này đã được cuốc.")
	return false


func _use_seed(cell: Vector2i) -> bool:
	var seed_item: CropItemData = _find_seed()
	var reason: String = field.get_plant_block_reason(cell, seed_item)
	if not reason.is_empty():
		_say(reason)
		return false
	inventory.remove_item(seed_item, 1)
	field.plant(cell, seed_item)
	return true


func _use_harvest(cell: Vector2i) -> bool:
	var plot: FarmPlot = field.get_plot(cell)
	if plot == null or not plot.is_planted():
		_say("Không có cây để thu hoạch.")
		return false
	if not plot.is_ripe():
		_say("Cây chưa chín.")
		return false
	var product: ItemData = ItemDatabase.get_item(plot.crop.harvest_item_id)
	if product == null:
		_say("Lỗi dữ liệu: không có vật phẩm thu hoạch.")
		return false
	var amount: int = field.get_harvest_amount(cell)  # đã tính phân bón
	if not inventory.can_add(product, amount):
		_say("Túi đồ đã đầy.")
		return false
	field.harvest(cell)
	inventory.add_item(product, amount)
	EventBus.item_picked.emit(product, amount)
	_say("Thu hoạch được %d %s." % [amount, product.display_name])
	return true


## Vật phẩm phân bón (mỗi lần bón tốn 1).
const FERTILIZER_ID: StringName = &"phan_bon"


func _use_fertilize(cell: Vector2i) -> bool:
	var fertilizer: ItemData = ItemDatabase.get_item(FERTILIZER_ID)
	if fertilizer == null or not inventory.has_item(fertilizer):
		_say("Không có phân bón (trâu cho phân bón mỗi ngày).")
		return false
	var reason: String = field.get_fertilize_block_reason(cell)
	if not reason.is_empty():
		_say(reason)
		return false
	inventory.remove_item(fertilizer, 1)
	field.fertilize(cell)
	return true


## Hạt giống để gieo: ưu tiên loại đầu tiên trong kho gieo được vào mùa hiện tại (để có nhiều loại
## hạt trong túi mà không bị kẹt ở loại sai mùa). Không loại nào hợp mùa thì trả về hạt đầu tiên
## để FarmField báo đúng lý do.
func _find_seed() -> CropItemData:
	var first: CropItemData = null
	for slot: InventorySlot in inventory.slots:
		if slot.is_empty() or not slot.item is CropItemData:
			continue
		var crop: CropItemData = slot.item as CropItemData
		if crop.can_plant_in(TimeManager.season):
			return crop
		if first == null:
			first = crop
	return first
