class_name InventoryComponent
extends Node
## Quản lý một mảng InventorySlot. Gắn vào Player, Rương chứa đồ hoặc Kệ hàng.
##
## Component không biết chủ sở hữu là ai; nó chỉ phát signal cục bộ
## [signal slot_changed] và EventBus.inventory_changed(owner_id) để UI cập nhật.

## Một ô thay đổi (thêm, bớt, kéo/thả).
signal slot_changed(index: int)

## Định danh kho để UI biết kho nào đổi (vd: &"player", &"ruong_nha").
@export var owner_id: StringName = &"player"
@export_range(1, 200, 1) var slot_count: int = 24

var slots: Array[InventorySlot] = []


func _ready() -> void:
	_build_slots()


## Số lượng [param item] có thể thêm vào mà không bị tràn.
func get_capacity_for(item: ItemData) -> int:
	_build_slots()
	var space: int = 0
	for slot: InventorySlot in slots:
		space += slot.free_space_for(item)
	return space


func can_add(item: ItemData, amount: int = 1) -> bool:
	return item != null and amount > 0 and get_capacity_for(item) >= amount


## Thêm vật phẩm: lấp ô cùng loại trước, rồi mới dùng ô trống.
## Trả về số lượng KHÔNG nhét vừa (0 = thêm đủ).
func add_item(item: ItemData, amount: int = 1) -> int:
	_build_slots()
	if item == null or amount <= 0:
		return maxi(0, amount)
	var remaining: int = amount
	# Luot 1: ô đang chứa cùng loại. Luot 2: ô trống.
	for pass_empty: bool in [false, true]:
		for i: int in slots.size():
			if remaining <= 0:
				break
			var slot: InventorySlot = slots[i]
			if slot.is_empty() != pass_empty:
				continue
			var before: int = remaining
			remaining = slot.add(item, remaining)
			if remaining != before:
				slot_changed.emit(i)
	if remaining != amount:
		_notify_changed()
	return remaining


## Bớt [param amount] vật phẩm theo kiểu "được hết hoặc không gì cả".
## Trả về false (và không đổi gì) nếu không đủ số lượng.
func remove_item(item: ItemData, amount: int = 1) -> bool:
	_build_slots()
	if item == null or amount <= 0 or count_of(item) < amount:
		return false
	var remaining: int = amount
	# Lay tu cuoi kho truoc de giu cac ô dau day.
	for i: int in range(slots.size() - 1, -1, -1):
		if remaining <= 0:
			break
		var slot: InventorySlot = slots[i]
		if slot.is_empty() or slot.item.id != item.id:
			continue
		remaining -= slot.remove(remaining)
		slot_changed.emit(i)
	_notify_changed()
	return true


func count_of(item: ItemData) -> int:
	_build_slots()
	if item == null:
		return 0
	var total: int = 0
	for slot: InventorySlot in slots:
		if not slot.is_empty() and slot.item.id == item.id:
			total += slot.amount
	return total


func has_item(item: ItemData, amount: int = 1) -> bool:
	return count_of(item) >= amount


## Logic kéo/thả: chuyển nội dung ô [param from_index] sang [param to_index].
## Ô đích trống thì dời sang; cùng loại thì gộp (phần thừa ở lại ô nguồn);
## khác loại thì đổi chỗ. Trả về false nếu chỉ số sai hoặc không có gì đổi.
func move_slot(from_index: int, to_index: int) -> bool:
	return transfer_slot(from_index, self, to_index)


## Như [method move_slot] nhưng đích có thể là kho khác (Player ↔ Rương ↔ Kệ hàng).
func transfer_slot(from_index: int, target: InventoryComponent, to_index: int) -> bool:
	if target == null:
		return false
	_build_slots()
	target._build_slots()
	if not _is_valid_index(from_index) or not target._is_valid_index(to_index):
		return false
	if not InventorySlot.move_between(slots[from_index], target.slots[to_index]):
		return false
	slot_changed.emit(from_index)
	_notify_changed()
	if target != self:
		target.slot_changed.emit(to_index)
		target._notify_changed()
	else:
		slot_changed.emit(to_index)
	return true


## Gói nội dung kho để lưu game: danh sách {"id", "amount"} theo thứ tự ô (ô trống = null).
func get_save_data() -> Array:
	_build_slots()
	var data: Array = []
	for slot: InventorySlot in slots:
		if slot.is_empty():
			data.append(null)
		else:
			data.append({"id": String(slot.item.id), "amount": slot.amount})
	return data


## Nạp lại kho từ dữ liệu đã lưu. Id không còn tồn tại trong ItemDatabase bị bỏ qua.
func load_save_data(data: Array) -> void:
	_build_slots()
	for slot: InventorySlot in slots:
		slot.clear()
	for i: int in mini(data.size(), slots.size()):
		var entry: Variant = data[i]
		if entry is Dictionary:
			var item: ItemData = ItemDatabase.get_item(StringName(entry.get("id", "")))
			if item != null:
				slots[i].add(item, int(entry.get("amount", 0)))
	for i: int in slots.size():
		slot_changed.emit(i)
	_notify_changed()


## Đổi số ô kho thành [param count]: thêm ô trống ở cuối (nâng cấp túi), hoặc cắt bớt ô cuối (ván mới, khi kho
## đã được xoá; ô bị cắt mất đồ nếu còn chứa). Phát signal cho ô mới và EventBus.inventory_changed.
func set_slot_count(count: int) -> void:
	count = clampi(count, 1, 200)
	_build_slots()
	if count == slots.size():
		return
	var old_size: int = slots.size()
	slot_count = count
	if count < old_size:
		slots.resize(count)
	else:
		for i: int in range(old_size, count):
			slots.append(InventorySlot.new())
		for i: int in range(old_size, count):
			slot_changed.emit(i)
	_notify_changed()


func _build_slots() -> void:
	if slots.size() == slot_count:
		return
	slots.clear()
	for i: int in slot_count:
		slots.append(InventorySlot.new())


func _is_valid_index(index: int) -> bool:
	return index >= 0 and index < slots.size()


func _notify_changed() -> void:
	EventBus.inventory_changed.emit(owner_id)
