extends Node
## Scene gốc của game: dựng "world" (chứa map hiện tại và Player), HUD và ShopUI một lần,
## rồi nhờ SceneManager nạp map đầu tiên. Player, HUD và ShopUI sống suốt ván chơi,
## chỉ map bị thay mỗi lần chuyển.

const PLAYER_SCENE: PackedScene = preload("res://entities/player/player.tscn")
const SHOP_UI_SCENE: PackedScene = preload("res://ui/shop/shop_ui.tscn")
const START_MAP: String = "res://maps/home/home.tscn"

var world: Node2D
var player: Player
var shop_ui: ShopUI


func _ready() -> void:
	world = Node2D.new()
	world.name = "World"
	add_child(world)

	player = PLAYER_SCENE.instantiate()
	world.add_child(player)
	_give_starting_items()

	add_child(Hud.new())
	add_child(PauseMenu.new())
	add_child(MinigameHost.new())
	var ui_layer := CanvasLayer.new()
	ui_layer.layer = 20
	add_child(ui_layer)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(center)
	shop_ui = SHOP_UI_SCENE.instantiate()
	center.add_child(shop_ui)

	SceneManager.register_world(world, player)
	SceneManager.change_scene(START_MAP)


## Đồ khởi đầu của ván mới (tạm thời; sau này đọc từ dữ liệu).
func _give_starting_items() -> void:
	player.inventory.add_item(ItemDatabase.get_item(&"hat_giong_lua"), 10)
	player.inventory.add_item(ItemDatabase.get_item(&"trung_ga"), 4)
