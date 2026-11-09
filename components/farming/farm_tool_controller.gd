class_name FarmToolController
extends Node
## Nối thao tác người chơi với FarmField và kho đồ: cuốc, gieo hạt, thu hoạch.
##
## FarmField không biết kho đồ; controller này trừ hạt giống khi gieo và thêm
## nông sản khi thu hoạch. Phản hồi cho người chơi đi qua signal [signal feedback].

enum Tool { HOE, SEED, HARVEST }

const TOOL_NAMES: Dictionary = {
	Tool.HOE: "Cuốc",
	Tool.SEED: "Gieo hạt",
	Tool.HARVEST: "Thu hoạch",
}

## Công cụ đổi.
signal tool_changed(tool: Tool)
## Thông báo ngắn cho người chơi (lỗi hoặc kết quả).
signal feedback(text: String)

@export var field: FarmField
@export var inventory: InventoryComponent

var current_tool: Tool = Tool.HOE


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
	return false


func _use_hoe(cell: Vector2i) -> bool:
	if field.till(cell):
		return true
	feedback.emit("Ô này đã được cuốc.")
	return false


func _use_seed(cell: Vector2i) -> bool:
	var seed_item: CropItemData = _find_seed()
	var reason: String = field.get_plant_block_reason(cell, seed_item)
	if not reason.is_empty():
		feedback.emit(reason)
		return false
	inventory.remove_item(seed_item, 1)
	field.plant(cell, seed_item)
	return true


func _use_harvest(cell: Vector2i) -> bool:
	var plot: FarmPlot = field.get_plot(cell)
	if plot == null or not plot.is_planted():
		feedback.emit("Không có cây để thu hoạch.")
		return false
	if not plot.is_ripe():
		feedback.emit("Cây chưa chín.")
		return false
	var product: ItemData = ItemDatabase.get_item(plot.crop.harvest_item_id)
	if product == null:
		feedback.emit("Lỗi dữ liệu: không có vật phẩm thu hoạch.")
		return false
	var amount: int = plot.crop.harvest_amount
	if not inventory.can_add(product, amount):
		feedback.emit("Túi đồ đã đầy.")
		return false
	field.harvest(cell)
	inventory.add_item(product, amount)
	EventBus.item_picked.emit(product, amount)
	feedback.emit("Thu hoạch được %d %s." % [amount, product.display_name])
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
