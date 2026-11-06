class_name ShopUI
extends PanelContainer
## Giao diện cửa hàng DUY NHẤT dùng cho mọi Vendor. Hàng hóa, giá và giờ mở cửa
## đều lấy từ VendorData của VendorComponent được truyền vào [method open].
##
## UI không tự sửa tiền hay kho đồ: mọi giao dịch gọi VendorComponent.buy()/sell()
## rồi hiển thị lỗi trả về. UI tự vẽ lại khi nghe EventBus (tiền, kho, giờ).

@onready var _title_label: Label = $Margin/VBox/TitleLabel
@onready var _info_label: Label = $Margin/VBox/InfoLabel
@onready var _tabs: TabContainer = $Margin/VBox/Tabs
@onready var _buy_list: VBoxContainer = $Margin/VBox/Tabs/BuyTab/BuyList
@onready var _sell_list: VBoxContainer = $Margin/VBox/Tabs/SellTab/SellList
@onready var _message_label: Label = $Margin/VBox/MessageLabel
@onready var _close_button: Button = $Margin/VBox/CloseButton

var _vendor: VendorComponent
var _buyer: InventoryComponent


func _ready() -> void:
	_tabs.set_tab_title(0, "Mua")
	_tabs.set_tab_title(1, "Bán")
	_close_button.pressed.connect(close)
	EventBus.money_changed.connect(func(_amount: int, _delta: int) -> void: _refresh())
	EventBus.inventory_changed.connect(func(_owner: StringName) -> void: _refresh())
	EventBus.time_ticked.connect(func(_h: int, _m: int) -> void: _refresh())
	EventBus.shop_open_requested.connect(_on_shop_open_requested)
	hide()


## Esc (ui_cancel) đóng cửa hàng đang mở.
func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _on_shop_open_requested(vendor: Node, buyer: Node) -> void:
	if vendor is VendorComponent and buyer is InventoryComponent:
		open(vendor, buyer)


## Mở cửa hàng của [param vendor] cho người chơi có kho [param buyer].
func open(vendor: VendorComponent, buyer: InventoryComponent) -> void:
	if _vendor != null:
		close()  # Đổi sang cửa hàng khác: đóng cửa hàng cũ để EventBus.shop_closed được phát.
	_vendor = vendor
	_buyer = buyer
	_vendor.stock_changed.connect(_refresh)
	_message_label.text = ""
	show()
	_refresh()
	EventBus.shop_opened.emit(vendor.data)


func close() -> void:
	if _vendor == null:
		return
	if _vendor.stock_changed.is_connected(_refresh):
		_vendor.stock_changed.disconnect(_refresh)
	var data: VendorData = _vendor.data
	_vendor = null
	_buyer = null
	hide()
	EventBus.shop_closed.emit(data)


func _refresh() -> void:
	if _vendor == null or not visible:
		return
	var data: VendorData = _vendor.data
	var is_open: bool = _vendor.is_open()
	_title_label.text = data.display_name
	_info_label.text = "%s  |  Mở cửa %s-%s giờ  |  Tiền: %d đ" % [
		"ĐANG MỞ" if is_open else "ĐÃ ĐÓNG CỬA",
		_format_hour(data.open_hour),
		_format_hour(data.close_hour),
		EconomyManager.money,
	]
	_rebuild_buy_list(is_open)
	_rebuild_sell_list(is_open)


func _rebuild_buy_list(is_open: bool) -> void:
	_clear(_buy_list)
	var data: VendorData = _vendor.data
	for entry: VendorStockEntry in _vendor.stock:
		var price: int = data.get_buy_price(entry.item)
		var stock_text: String = "" if entry.is_unlimited() else "còn %d" % entry.amount
		var row: HBoxContainer = _make_row(entry.item.display_name, "%d đ  %s" % [price, stock_text])
		for count: int in [1, 5]:
			var can_buy: bool = is_open and entry.has_stock(count) and EconomyManager.can_afford(price * count)
			row.add_child(_make_button("Mua %d" % count, can_buy, _on_buy_pressed.bind(entry.item, count)))
		_buy_list.add_child(row)
	if _vendor.stock.is_empty():
		_buy_list.add_child(_make_hint("Hôm nay không có hàng."))


func _rebuild_sell_list(is_open: bool) -> void:
	_clear(_sell_list)
	var data: VendorData = _vendor.data
	if not data.buys_from_player:
		_sell_list.add_child(_make_hint("Cửa hàng này không thu mua đồ."))
		return
	var seen: Dictionary = {}
	for slot: InventorySlot in _buyer.slots:
		if slot.is_empty() or seen.has(slot.item.id) or not data.accepts(slot.item):
			continue
		seen[slot.item.id] = true
		var owned: int = _buyer.count_of(slot.item)
		var price: int = data.get_sell_price(slot.item)
		var row: HBoxContainer = _make_row(slot.item.display_name, "%d đ  (có %d)" % [price, owned])
		row.add_child(_make_button("Bán 1", is_open, _on_sell_pressed.bind(slot.item, 1)))
		row.add_child(_make_button("Bán hết", is_open, _on_sell_pressed.bind(slot.item, owned)))
		_sell_list.add_child(row)
	if seen.is_empty():
		_sell_list.add_child(_make_hint("Bạn không có món nào cửa hàng thu mua."))


func _on_buy_pressed(item: ItemData, count: int) -> void:
	var error: String = _vendor.buy(item, count, _buyer)
	_message_label.text = error if not error.is_empty() else "Đã mua %d %s." % [count, item.display_name]


func _on_sell_pressed(item: ItemData, count: int) -> void:
	var error: String = _vendor.sell(item, count, _buyer)
	_message_label.text = error if not error.is_empty() else "Đã bán %d %s." % [count, item.display_name]


func _make_row(name_text: String, detail_text: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var name_label := Label.new()
	name_label.text = name_text
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)
	var detail_label := Label.new()
	detail_label.text = detail_text
	detail_label.custom_minimum_size.x = 130
	row.add_child(detail_label)
	return row


func _make_button(text: String, enabled: bool, on_pressed: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.disabled = not enabled
	button.pressed.connect(on_pressed)
	return button


func _make_hint(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.modulate = Color(1, 1, 1, 0.6)
	return label


func _clear(container: Node) -> void:
	for child: Node in container.get_children():
		container.remove_child(child)
		child.queue_free()


## 5.0 -> "5", 21.5 -> "21:30".
static func _format_hour(hour_float: float) -> String:
	var hours: int = int(hour_float)
	var minutes: int = roundi((hour_float - hours) * 60.0)
	return str(hours) if minutes == 0 else "%d:%02d" % [hours, minutes]
