extends Control
## Scene demo: hai kho (túi Player và Rương) để thử kéo/thả giữa các ô và giữa hai kho.
## Chỉ dùng để thử giao diện; game thật sẽ gắn InventoryUI vào HUD/Rương.

const INVENTORY_UI_SCENE: PackedScene = preload("res://ui/inventory/inventory_ui.tscn")

var player_inventory: InventoryComponent
var chest_inventory: InventoryComponent


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	player_inventory = _make_inventory(&"player", 12)
	chest_inventory = _make_inventory(&"ruong_nha", 12)
	var lua: ItemData = ItemDatabase.get_item(&"lua")
	var hat_giong: ItemData = ItemDatabase.get_item(&"hat_giong_lua")
	player_inventory.add_item(hat_giong, 5)
	player_inventory.add_item(lua, 120)
	chest_inventory.add_item(lua, 30)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	center.add_child(column)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	column.add_child(row)
	_add_ui(row, player_inventory, "Túi đồ")
	_add_ui(row, chest_inventory, "Rương")

	var hint := Label.new()
	hint.text = "Kéo ô để dời, gộp hoặc đổi chỗ; kéo sang kho bên kia để chuyển đồ."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(hint)


func _make_inventory(id: StringName, slots: int) -> InventoryComponent:
	var inv := InventoryComponent.new()
	inv.owner_id = id
	inv.slot_count = slots
	add_child(inv)
	return inv


## Tạo bảng kho, thêm vào [param parent] (để @onready chạy) rồi gắn với [param inv].
func _add_ui(parent: Node, inv: InventoryComponent, title: String) -> void:
	var ui: InventoryUI = INVENTORY_UI_SCENE.instantiate()
	ui.columns = 4
	parent.add_child(ui)
	ui.setup(inv, title)
