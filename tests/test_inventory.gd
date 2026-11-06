extends "res://tests/test_base.gd"
## InventoryComponent + ItemDatabase: thêm/bớt, tràn kho, kéo/thả (move_slot),
## chuyển giữa kho, lưu/nạp.


func run() -> void:
	var db: Node = root.get_node("ItemDatabase")
	var bus: Node = root.get_node("EventBus")
	var inventory_script: GDScript = load("res://components/inventory/inventory_component.gd")

	check("ItemDatabase thấy lúa và hạt giống", db.has_item(&"lua") and db.has_item(&"hat_giong_lua"))
	var lua: ItemData = db.get_item(&"lua")
	var seed_item: ItemData = db.get_item(&"hat_giong_lua")

	var inv: Node = inventory_script.new()
	inv.slot_count = 3
	inv.owner_id = &"test"
	root.add_child(inv)
	var hits: Array = [0]
	bus.inventory_changed.connect(func(id: StringName) -> void: if id == &"test": hits[0] += 1)

	check("thêm 150 lúa vào 3 ô: không dư", inv.add_item(lua, 150) == 0)
	check("ô 99 / 51 / trống", inv.slots[0].amount == 99 and inv.slots[1].amount == 51 and inv.slots[2].is_empty())
	check("tràn kho: thêm 200 dư 53", inv.add_item(lua, 200) == 53)
	check("tổng 297", inv.count_of(lua) == 297)
	check("bớt quá số lượng thất bại, không đổi gì", not inv.remove_item(lua, 300) and inv.count_of(lua) == 297)
	check("bớt 100 thành công", inv.remove_item(lua, 100) and inv.count_of(lua) == 197)
	check("phát EventBus.inventory_changed", hits[0] >= 3)
	check("can_add phản ánh chỗ trống", inv.can_add(lua, 100) and not inv.can_add(lua, 101))

	var inv2: Node = inventory_script.new()
	inv2.slot_count = 4
	root.add_child(inv2)
	inv2.add_item(lua, 10)
	inv2.add_item(seed_item, 5)
	check("kéo vào ô trống", inv2.move_slot(0, 3) and inv2.slots[0].is_empty() and inv2.slots[3].amount == 10)
	check("kéo sang ô khác loại thì đổi chỗ", inv2.move_slot(3, 1) and inv2.slots[3].item.id == &"hat_giong_lua" and inv2.slots[1].item.id == &"lua")
	inv2.add_item(lua, 95)
	var before: int = inv2.count_of(lua)
	inv2.move_slot(2, 1)
	check("gộp ô cùng loại giữ nguyên tổng", inv2.count_of(lua) == before)
	check("chỉ số sai / cùng ô trả về false", not inv2.move_slot(0, 99) and not inv2.move_slot(1, 1))

	var inv3: Node = inventory_script.new()
	inv3.slot_count = 2
	root.add_child(inv3)
	check("chuyển sang kho khác", inv2.transfer_slot(3, inv3, 0) and inv3.count_of(seed_item) == 5 and inv2.count_of(seed_item) == 0)

	var saved: Array = inv2.get_save_data()
	var inv4: Node = inventory_script.new()
	inv4.slot_count = 4
	root.add_child(inv4)
	inv4.load_save_data(JSON.parse_string(JSON.stringify(saved)))  # qua JSON như file save thật
	check("lưu/nạp qua JSON giữ nguyên nội dung", inv4.count_of(lua) == inv2.count_of(lua))
