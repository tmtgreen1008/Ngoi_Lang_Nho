class_name VendorNPC
extends Node2D
## NPC bán hàng: ghép VendorComponent (kho hàng) với InteractableComponent (tương tác).
##
## NPC không biết ShopUI: khi người chơi tương tác nó chỉ phát
## EventBus.shop_open_requested; ShopUI tự lắng nghe và mở. Cùng một scene này
## dùng cho bà chủ tạp hóa lẫn thương lái ở chợ, chỉ khác [member vendor_data]
## (dữ liệu, ảnh và tên đều lấy từ đó).

@export var vendor_data: VendorData

@onready var vendor: VendorComponent = $Vendor
@onready var interactable: InteractableComponent = $Interactable
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _idle_timer: Timer = $IdleTimer
@onready var _name_label: Label = $NameLabel


func _ready() -> void:
	var shadow: Sprite2D = Shadow.create(24.0)
	shadow.position = Vector2(0, 13)
	add_child(shadow)
	move_child(shadow, 0)
	vendor.data = vendor_data
	if vendor_data != null:
		_name_label.text = vendor_data.display_name
		interactable.prompt_text = "Nói chuyện với %s" % vendor_data.display_name
		_sprite.texture = vendor_data.npc_sheet
	# Nhún nhẹ giữa hai khung đứng yên.
	_name_label.add_theme_color_override("font_color", Color.WHITE)
	_name_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_name_label.add_theme_constant_override("outline_size", 4)
	_idle_timer.timeout.connect(func() -> void: _sprite.frame = (_sprite.frame + 1) % _sprite.hframes)
	interactable.interacted.connect(_on_interacted)


func _on_interacted(interactor: Node) -> void:
	# Có lời thoại: mở hộp thoại (Mua bán / Trò chuyện / Tạm biệt); không thì mở thẳng cửa hàng.
	if vendor_data != null and vendor_data.dialogue != null:
		EventBus.npc_talk_requested.emit(self, interactor)
		return
	var buyer: Node = interactor.get("inventory")
	if buyer != null:
		EventBus.shop_open_requested.emit(vendor, buyer)
