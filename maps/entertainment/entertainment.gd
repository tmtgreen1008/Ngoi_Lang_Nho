extends MapBase
## Khu Giải trí: hai trạm chơi, Quán Net (bắn mục tiêu) và Quán Bida (canh lực).
## Chơi xong, kết quả (tiền, thời gian trôi qua) được MinigameHost áp về thế giới chính.

const HOME_MAP: String = "res://maps/home/home.tscn"
const STATION_SCENE: PackedScene = preload("res://entities/arcade/arcade_station.tscn")
const AIM_GAME: PackedScene = preload("res://minigames/net_cafe/aim_game.tscn")
const BILLIARDS_GAME: PackedScene = preload("res://minigames/billiards/billiards_game.tscn")


func _build() -> void:
	add_spawn(&"default", Vector2(160, 360))
	add_spawn(&"from_home", Vector2(160, 360))
	add_exit(Vector2(30, 360), Vector2(40, 120), HOME_MAP, &"from_entertainment", "Về nhà")

	_add_station(AIM_GAME, "Quán Net", Vector2(480, 330), Color(0.25, 0.45, 0.85))
	_add_station(BILLIARDS_GAME, "Quán Bida", Vector2(900, 330), Color(0.15, 0.5, 0.3))


func _add_station(game: PackedScene, station_name: String, pos: Vector2, color: Color) -> void:
	var station: ArcadeStation = STATION_SCENE.instantiate()
	station.minigame_scene = game
	station.station_name = station_name
	station.body_color = color
	station.position = pos
	add_child(station)
