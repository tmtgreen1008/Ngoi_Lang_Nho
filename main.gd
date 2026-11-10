extends Node
## Scene gốc của game: dựng "world" (chứa map hiện tại và Player), HUD, ShopUI, menu
## và MinigameHost một lần, rồi hiện màn hình chính. Player, HUD và ShopUI sống suốt
## ván chơi, chỉ map bị thay mỗi lần chuyển.
##
## Ván chỉ bắt đầu khi người chơi chọn ở màn hình chính ([method start_new_game] hoặc
## [method continue_game]); trước đó đồng hồ dừng, Player đứng yên và HUD ẩn.

const PLAYER_SCENE: PackedScene = preload("res://entities/player/player.tscn")
const SHOP_UI_SCENE: PackedScene = preload("res://ui/shop/shop_ui.tscn")
const START_MAP: String = "res://maps/home/home.tscn"

var world: Node2D
var player: Player
var shop_ui: ShopUI
var hud: Hud
var start_menu: StartMenu
var pause_menu: PauseMenu
var dialogue_box: DialogueBox
var upgrade_ui: UpgradeUI
var cooking_ui: CookingUI


func _ready() -> void:
	world = Node2D.new()
	world.name = "World"
	add_child(world)

	player = PLAYER_SCENE.instantiate()
	world.add_child(player)

	hud = Hud.new()
	add_child(hud)
	pause_menu = PauseMenu.new()
	pause_menu.in_main_menu = true
	pause_menu.main_menu_requested.connect(return_to_main_menu)
	add_child(pause_menu)
	add_child(MinigameHost.new())
	dialogue_box = DialogueBox.new()
	add_child(dialogue_box)
	upgrade_ui = UpgradeUI.new()
	add_child(upgrade_ui)
	cooking_ui = CookingUI.new()
	add_child(cooking_ui)
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

	# Chờ người chơi chọn ở màn hình chính.
	TimeManager.pause()
	player.movement_locked = true
	hud.hide()
	start_menu = StartMenu.new()
	add_child(start_menu)
	start_menu.new_game_requested.connect(start_new_game)
	start_menu.continue_requested.connect(continue_game)


## Bắt đầu ván mới: đặt lại mọi hệ thống về trạng thái ban đầu rồi vào map nhà.
func start_new_game() -> void:
	# load_save_data({}) đặt về giá trị mặc định (ngày 1 sáng mùa Xuân, tiền khởi đầu).
	TimeManager.load_save_data({})
	EconomyManager.load_save_data({})
	WorldStateManager.clear()
	RelationshipManager.clear()
	UpgradeManager.clear()  # mọi nâng cấp về cấp 0 (túi đồ về 16 ô)
	player.inventory.load_save_data([])
	_give_starting_items()
	_begin_playing()
	SceneManager.change_scene(START_MAP)


## Tiếp tục ván từ bản lưu [param slot]. Lỗi thì quay lại màn hình chính và báo lý do.
func continue_game(slot: StringName) -> void:
	start_menu.hide()
	var error: String = await SaveManager.load_game(slot)
	if error.is_empty():
		_begin_playing()
	else:
		start_menu.open(error)


## Về màn hình chính giữa ván (từ menu tạm dừng): dừng đồng hồ, khoá Player, ẩn HUD rồi hiện menu.
## Ván hiện tại không tự lưu; chọn Ván mới hoặc Tiếp tục để chơi tiếp.
func return_to_main_menu() -> void:
	TimeManager.pause()
	player.movement_locked = true
	hud.hide()
	pause_menu.in_main_menu = true
	start_menu.open()


## Đồ khởi đầu của ván mới (tạm thời; sau này đọc từ dữ liệu).
func _give_starting_items() -> void:
	player.inventory.add_item(ItemDatabase.get_item(&"hat_giong_lua"), 10)
	player.inventory.add_item(ItemDatabase.get_item(&"trung_ga"), 4)


func _begin_playing() -> void:
	start_menu.hide()
	pause_menu.in_main_menu = false
	hud.show()
	player.movement_locked = false
	TimeManager.start()
