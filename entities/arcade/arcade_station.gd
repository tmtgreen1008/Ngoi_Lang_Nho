class_name ArcadeStation
extends Node2D
## Trạm chơi mini-game (máy tính ở Quán Net, bàn bida...). Người chơi bấm E thì
## phát EventBus.minigame_requested; MinigameHost lo phần còn lại.
##
## Gốc toạ độ là CHÂN trạm (giữa đáy ảnh); ảnh vẽ phía trên, một dải sát chân chặn Player.

@export var minigame_scene: PackedScene
@export var station_name: String = "Máy chơi"
## Ảnh trạm (props/net_pc_station.png, props/billiards_table.png...).
@export var texture: Texture2D

@onready var interactable: InteractableComponent = $Interactable
@onready var _name_label: Label = $NameLabel


func _ready() -> void:
	var size: Vector2 = texture.get_size() if texture != null else Vector2(96, 48)
	if texture != null:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.centered = false
		sprite.offset = Vector2(-size.x / 2.0, -size.y)
		add_child(sprite)
		move_child(sprite, 0)  # Ảnh nằm dưới tên và vùng tương tác.
	_add_blocker(size)
	interactable.position = Vector2(0, -size.y / 2.0)
	_name_label.text = station_name
	_name_label.position.y = 6.0
	interactable.prompt_text = "Chơi %s" % station_name
	if minigame_scene != null:
		# Đọc phí từ chính mini-game để lời nhắc luôn khớp (không lặp số ở hai nơi).
		var probe: MinigameBase = minigame_scene.instantiate() as MinigameBase
		if probe != null:
			interactable.prompt_text = "Chơi %s (phí %d đ)" % [station_name, probe.entry_fee]
			probe.free()
	interactable.interacted.connect(_on_interacted)


func _on_interacted(_interactor: Node) -> void:
	if minigame_scene != null:
		EventBus.minigame_requested.emit(minigame_scene.resource_path)


## Dải chặn Player ngay sát chân trạm.
func _add_blocker(size: Vector2) -> void:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(size.x * 0.9, 16.0)
	shape.shape = box
	body.position = Vector2(0, -8.0)
	body.add_child(shape)
	add_child(body)
