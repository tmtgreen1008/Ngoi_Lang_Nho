class_name InventoryUI
extends PanelContainer
## Bảng kho đồ: lưới các InventorySlotUI gắn với một InventoryComponent.
## Dùng chung cho túi Player, Rương và Kệ hàng: chỉ cần gọi [method setup].

@export var columns: int = 6

@onready var _title_label: Label = $Margin/VBox/TitleLabel
@onready var _grid: GridContainer = $Margin/VBox/Grid

var _inventory: InventoryComponent
var _slot_uis: Array[InventorySlotUI] = []


func _ready() -> void:
	theme = UiTheme.get_theme()


## Gắn bảng với [param inventory] và đặt tiêu đề. Có thể gọi lại để đổi kho.
func setup(inventory: InventoryComponent, title: String) -> void:
	if _inventory != null and _inventory.slot_changed.is_connected(_on_slot_changed):
		_inventory.slot_changed.disconnect(_on_slot_changed)
	_inventory = inventory
	_title_label.text = title
	_grid.columns = columns
	for child: Node in _grid.get_children():
		child.queue_free()
	_slot_uis.clear()
	for i: int in inventory.slots.size():
		var slot_ui := InventorySlotUI.new()
		_grid.add_child(slot_ui)
		slot_ui.setup(inventory, i)
		_slot_uis.append(slot_ui)
	inventory.slot_changed.connect(_on_slot_changed)


func _on_slot_changed(slot_index: int) -> void:
	if slot_index >= 0 and slot_index < _slot_uis.size():
		_slot_uis[slot_index].refresh()
