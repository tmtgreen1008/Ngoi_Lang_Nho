extends Node2D
## Map thử nghiệm: Player đi lại giữa hai NPC bán hàng (Tạp hóa và Chợ), bấm E để mua bán.
## Dùng để thử Player + InteractableComponent + ShopUI + HUD cùng nhau;
## các map thật (home, grocery_store, morning_market) sẽ thay thế scene này.

const PLAYER_SCENE: PackedScene = preload("res://entities/player/player.tscn")
const NPC_SCENE: PackedScene = preload("res://entities/vendor/vendor_npc.tscn")
const SHOP_UI_SCENE: PackedScene = preload("res://ui/shop/shop_ui.tscn")
const GROCERY_DATA: VendorData = preload("res://data/vendors/tap_hoa.tres")
const MARKET_DATA: VendorData = preload("res://data/vendors/thuong_lai_rau.tres")

const WORLD_SIZE: Vector2 = Vector2(1280, 720)

var player: Player
var grocery_npc: VendorNPC
var market_npc: VendorNPC
var shop_ui: ShopUI


func _ready() -> void:
	_build_walls()

	grocery_npc = _add_npc(GROCERY_DATA, Vector2(300, 360), Color(0.85, 0.55, 0.3))
	market_npc = _add_npc(MARKET_DATA, Vector2(980, 360), Color(0.5, 0.75, 0.4))

	player = PLAYER_SCENE.instantiate()
	player.position = WORLD_SIZE / 2.0
	add_child(player)
	player.inventory.add_item(ItemDatabase.get_item(&"lua"), 12)
	player.inventory.add_item(ItemDatabase.get_item(&"trung_ga"), 4)

	add_child(Hud.new())

	var ui_layer := CanvasLayer.new()
	ui_layer.layer = 20
	add_child(ui_layer)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(center)
	shop_ui = SHOP_UI_SCENE.instantiate()
	center.add_child(shop_ui)


func _add_npc(data: VendorData, pos: Vector2, color: Color) -> VendorNPC:
	var npc: VendorNPC = NPC_SCENE.instantiate()
	npc.vendor_data = data
	npc.body_color = color
	npc.position = pos
	add_child(npc)
	return npc


## Bốn bức tường vô hình quanh màn hình để Player không đi ra ngoài.
func _build_walls() -> void:
	var thickness: float = 40.0
	var rects: Array[Rect2] = [
		Rect2(-thickness, -thickness, WORLD_SIZE.x + thickness * 2, thickness),
		Rect2(-thickness, WORLD_SIZE.y, WORLD_SIZE.x + thickness * 2, thickness),
		Rect2(-thickness, 0, thickness, WORLD_SIZE.y),
		Rect2(WORLD_SIZE.x, 0, thickness, WORLD_SIZE.y),
	]
	for rect: Rect2 in rects:
		var body := StaticBody2D.new()
		var shape := CollisionShape2D.new()
		var box := RectangleShape2D.new()
		box.size = rect.size
		shape.shape = box
		body.position = rect.position + rect.size / 2.0
		body.add_child(shape)
		add_child(body)
