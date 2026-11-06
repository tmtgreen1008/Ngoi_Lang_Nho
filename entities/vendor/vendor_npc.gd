class_name VendorNPC
extends Node2D
## NPC bán hàng: ghép VendorComponent (kho hàng) với InteractableComponent (tương tác).
##
## NPC không biết ShopUI: khi người chơi tương tác nó chỉ phát
## EventBus.shop_open_requested; ShopUI tự lắng nghe và mở. Cùng một scene này
## dùng cho bà chủ tạp hóa lẫn thương lái ở chợ, chỉ khác [member vendor_data].

@export var vendor_data: VendorData
@export var body_color: Color = Color(0.85, 0.55, 0.3)

@onready var vendor: VendorComponent = $Vendor
@onready var interactable: InteractableComponent = $Interactable
@onready var _name_label: Label = $NameLabel


func _ready() -> void:
	vendor.data = vendor_data
	if vendor_data != null:
		_name_label.text = vendor_data.display_name
		interactable.prompt_text = "Nói chuyện với %s" % vendor_data.display_name
	interactable.interacted.connect(_on_interacted)
	queue_redraw()


func _on_interacted(interactor: Node) -> void:
	var buyer: Node = interactor.get("inventory")
	if buyer != null:
		EventBus.shop_open_requested.emit(vendor, buyer)


func _draw() -> void:
	draw_circle(Vector2(0, 0), 13.0, body_color)
	draw_circle(Vector2(0, -5), 5.0, Color(0.95, 0.8, 0.65))
