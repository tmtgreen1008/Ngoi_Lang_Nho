class_name ArcadeStation
extends Node2D
## Trạm chơi mini-game (máy tính ở Quán Net, bàn bida...). Người chơi bấm E thì
## phát EventBus.minigame_requested; MinigameHost lo phần còn lại.

@export var minigame_scene: PackedScene
@export var station_name: String = "Máy chơi"
@export var body_color: Color = Color(0.3, 0.5, 0.85)
@export var body_size: Vector2 = Vector2(120, 60)

@onready var interactable: InteractableComponent = $Interactable
@onready var _name_label: Label = $NameLabel


func _ready() -> void:
	_name_label.text = station_name
	_name_label.position.y = body_size.y / 2.0 + 6.0
	interactable.prompt_text = "Chơi %s" % station_name
	if minigame_scene != null:
		# Đọc phí từ chính mini-game để lời nhắc luôn khớp (không lặp số ở hai nơi).
		var probe: MinigameBase = minigame_scene.instantiate() as MinigameBase
		if probe != null:
			interactable.prompt_text = "Chơi %s (phí %d đ)" % [station_name, probe.entry_fee]
			probe.free()
	interactable.interacted.connect(_on_interacted)
	queue_redraw()


func _on_interacted(_interactor: Node) -> void:
	if minigame_scene != null:
		EventBus.minigame_requested.emit(minigame_scene.resource_path)


func _draw() -> void:
	draw_rect(Rect2(-body_size / 2.0, body_size), body_color)
	draw_rect(Rect2(-body_size / 2.0, body_size), Color(1, 1, 1, 0.25), false, 2.0)
