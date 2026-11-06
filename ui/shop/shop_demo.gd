extends Control
## Scene demo cửa hàng: hai nút mở Tiệm Tạp Hóa và Sạp rau ở Chợ, dùng CHUNG một ShopUI.
## Nút "+1 giờ" / "Ngủ qua ngày" để thử giờ đóng/mở cửa và hàng ngẫu nhiên mỗi ngày.

const SHOP_UI_SCENE: PackedScene = preload("res://ui/shop/shop_ui.tscn")
const GROCERY_DATA: VendorData = preload("res://data/vendors/tap_hoa.tres")
const MARKET_DATA: VendorData = preload("res://data/vendors/thuong_lai_rau.tres")

var player_inventory: InventoryComponent
var grocery: VendorComponent
var market: VendorComponent
var shop_ui: ShopUI

var _status_label: Label


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	TimeManager.pause()  # Demo tự điều khiển giờ bằng nút để dễ thử.

	player_inventory = InventoryComponent.new()
	player_inventory.owner_id = &"player"
	player_inventory.slot_count = 16
	add_child(player_inventory)
	player_inventory.add_item(ItemDatabase.get_item(&"lua"), 12)
	player_inventory.add_item(ItemDatabase.get_item(&"trung_ga"), 4)

	grocery = _make_vendor(GROCERY_DATA)
	market = _make_vendor(MARKET_DATA)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 10)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(root)

	_status_label = Label.new()
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.add_theme_font_size_override("font_size", 18)
	root.add_child(_status_label)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 8)
	root.add_child(buttons)
	_add_button(buttons, "Tiệm Tạp Hóa", func() -> void: shop_ui.open(grocery, player_inventory))
	_add_button(buttons, "Sạp rau (Chợ)", func() -> void: shop_ui.open(market, player_inventory))
	_add_button(buttons, "+1 giờ", func() -> void: TimeManager.advance_minutes(60))
	_add_button(buttons, "Ngủ qua ngày", func() -> void: TimeManager.sleep_until_morning())

	shop_ui = SHOP_UI_SCENE.instantiate()
	shop_ui.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	root.add_child(shop_ui)

	EventBus.money_changed.connect(func(_a: int, _d: int) -> void: _update_status())
	EventBus.time_ticked.connect(func(_h: int, _m: int) -> void: _update_status())
	_update_status()


func _make_vendor(data: VendorData) -> VendorComponent:
	var vendor := VendorComponent.new()
	vendor.data = data
	add_child(vendor)
	return vendor


func _add_button(parent: Node, text: String, on_pressed: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.pressed.connect(on_pressed)
	parent.add_child(button)


func _update_status() -> void:
	_status_label.text = "Ngày %d  %s   |   Tiền: %d đ" % [
		TimeManager.day, TimeManager.get_time_string(), EconomyManager.money,
	]
