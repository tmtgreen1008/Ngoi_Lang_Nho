extends "res://tests/test_base.gd"
## InventoryUI + InventorySlotUI: hiển thị, kéo/thả trong một kho và giữa hai kho.
## Không gọi _get_drag_data (cần thao tác kéo thật của chuột); dựng dữ liệu kéo bằng tay.

const DRAG_TYPE: String = "inventory_slot"


func _slot_uis(ui: Node) -> Array:
	return ui._grid.get_children()


func _drag_data(inventory: Node, index: int) -> Dictionary:
	return {"type": DRAG_TYPE, "inventory": inventory, "index": index}


func run() -> void:
	var db: Node = root.get_node("ItemDatabase")
	var inventory_script: GDScript = load("res://components/inventory/inventory_component.gd")
	var ui_scene: PackedScene = load("res://ui/inventory/inventory_ui.tscn")
	var lua: ItemData = db.get_item(&"lua")
	var seed_item: ItemData = db.get_item(&"hat_giong_lua")

	var bag: Node = inventory_script.new()
	bag.owner_id = &"player"
	bag.slot_count = 6
	root.add_child(bag)
	var chest: Node = inventory_script.new()
	chest.owner_id = &"chest"
	chest.slot_count = 6
	root.add_child(chest)
	bag.add_item(seed_item, 5)
	bag.add_item(lua, 120)  # ô 1 = 99, ô 2 = 21
	chest.add_item(lua, 30)

	var row := HBoxContainer.new()
	root.add_child(row)
	var bag_ui: Node = ui_scene.instantiate()
	bag_ui.columns = 3
	row.add_child(bag_ui)
	bag_ui.setup(bag, "Túi đồ")
	var chest_ui: Node = ui_scene.instantiate()
	chest_ui.columns = 3
	row.add_child(chest_ui)
	chest_ui.setup(chest, "Rương")
	await wait(0.3)

	var bag_slots: Array = _slot_uis(bag_ui)
	var chest_slots: Array = _slot_uis(chest_ui)
	check("mỗi bảng có 6 ô giao diện", bag_slots.size() == 6 and chest_slots.size() == 6)
	check("ô hạt giống hiện icon (không hiện tên chữ) và số lượng", bag_slots[0]._icon.texture == seed_item.icon and seed_item.icon != null and bag_slots[0]._name_label.text == "" and bag_slots[0]._amount_label.text == "x5")
	check("tooltip vẫn có tên vật phẩm", bag_slots[0].tooltip_text.begins_with("Hạt giống lúa"))
	check("ô lúa đầy hiện x99", bag_slots[1]._amount_label.text == "x99")
	check("ô trống không hiện icon, không hiện chữ", bag_slots[5]._icon.texture == null and bag_slots[5]._name_label.text == "" and bag_slots[5]._amount_label.text == "")
	check("số lượng và tên trong ô kho là chữ trắng (đọc được trên ô tối)", bag_slots[1]._amount_label.get_theme_color("font_color") == Color.WHITE and bag_slots[0]._name_label.get_theme_color("font_color") == Color.WHITE)
	bag_slots[1]._set_highlight(true)
	check("trỏ vào ô: đổi sang khung sáng (ô 1 của slots.png)", bag_slots[1].get_theme_stylebox("panel") == bag_slots[1]._hover_style and bag_slots[1]._hover_style.texture.region != bag_slots[1]._normal_style.texture.region)
	bag_slots[1]._set_highlight(false)
	check("rời chuột: về khung thường", bag_slots[1].get_theme_stylebox("panel") == bag_slots[1]._normal_style)
	await shot("inventory_ui_before.png")

	var data: Dictionary = _drag_data(bag, 1)
	check("thả được lên ô của kho khác", chest_slots[0]._can_drop_data(Vector2.ZERO, data))
	check("dữ liệu lạ bị từ chối", not chest_slots[0]._can_drop_data(Vector2.ZERO, "rác") and not chest_slots[0]._can_drop_data(Vector2.ZERO, {"type": "khac"}))

	var total_before: int = bag.count_of(lua) + chest.count_of(lua)
	chest_slots[0]._drop_data(Vector2.ZERO, data)
	check("gộp lúa giữa hai kho giữ nguyên tổng", bag.count_of(lua) + chest.count_of(lua) == total_before)
	check("ô rương gộp lên 99, giao diện cập nhật", chest.slots[0].amount == 99 and chest_slots[0]._amount_label.text == "x99")
	check("phần dư ở lại ô nguồn", bag.slots[1].amount == 30 and bag_slots[1]._amount_label.text == "x30")

	chest_slots[5]._drop_data(Vector2.ZERO, _drag_data(bag, 0))
	check("hạt giống chuyển sang ô trống của rương", chest.slots[5].item.id == &"hat_giong_lua" and bag.slots[0].is_empty())
	check("ô nguồn trên giao diện được dọn sạch", bag_slots[0]._icon.texture == null and bag_slots[0]._amount_label.text == "")
	await shot("inventory_ui_after.png")
