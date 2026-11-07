class_name MinigameHost
extends Node
## Chạy mini-game ở trên cùng thế giới và áp kết quả khi xong.
##
## Luồng: nghe EventBus.minigame_requested -> kiểm tra đủ tiền, thu phí -> dừng đồng hồ
## -> hiện mini-game -> khi nghe minigame_finished thì cộng tiền thưởng, cho thời gian
## trôi qua, bật lại đồng hồ (nếu trước đó đang chạy) và báo kết quả cho người chơi.

var _active: MinigameBase = null
var _layer: CanvasLayer
var _fee_paid: int = 0
var _clock_was_running: bool = false


func _ready() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 30
	add_child(_layer)
	EventBus.minigame_requested.connect(_on_requested)
	EventBus.minigame_finished.connect(_on_finished)


func is_active() -> bool:
	return _active != null


func _on_requested(scene_path: String) -> void:
	if _active != null or SceneManager.is_transitioning:
		return
	var packed: PackedScene = load(scene_path) as PackedScene
	var game: MinigameBase = packed.instantiate() as MinigameBase if packed != null else null
	if game == null:
		push_error("MinigameHost: khong nap duoc mini-game '%s'" % scene_path)
		return
	if not EconomyManager.can_afford(game.entry_fee):
		EventBus.notice_requested.emit("Không đủ tiền: cần %d đ." % game.entry_fee, &"error")
		game.free()
		return

	EconomyManager.spend(game.entry_fee)
	_fee_paid = game.entry_fee
	_clock_was_running = TimeManager.is_running()
	TimeManager.pause()
	_active = game
	_layer.add_child(game)
	EventBus.minigame_started.emit(game.minigame_id)


func _on_finished(minigame_id: StringName, result: Dictionary) -> void:
	if _active == null or _active.minigame_id != minigame_id:
		return
	var game: MinigameBase = _active
	_active = null
	var money: int = int(result.get("money", 0))
	var minutes: int = int(result.get("minutes", 0))
	EconomyManager.earn(money)
	if minutes > 0:
		TimeManager.advance_minutes(minutes)
	if _clock_was_running:
		TimeManager.start()
	game.queue_free()
	EventBus.notice_requested.emit(_summary(game.title, money, minutes), &"success" if money > _fee_paid else &"info")


func _summary(title: String, money: int, minutes: int) -> String:
	var net: int = money - _fee_paid
	var text: String = "%s: nhận %d đ (phí %d đ, lời %+d đ)" % [title, money, _fee_paid, net]
	if minutes > 0:
		text += ", mất %d phút." % minutes
	return text
