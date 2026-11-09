extends MapBase
## Khu Giải trí: hai trạm chơi, Quán Net (bắn mục tiêu) và Quán Bida (canh lực).
## Chơi xong, kết quả (tiền, thời gian trôi qua) được MinigameHost áp về thế giới chính.

const HOME_MAP: String = "res://maps/home/home.tscn"
const STATION_SCENE: PackedScene = preload("res://entities/arcade/arcade_station.tscn")
const AIM_GAME: PackedScene = preload("res://minigames/net_cafe/aim_game.tscn")
const BILLIARDS_GAME: PackedScene = preload("res://minigames/billiards/billiards_game.tscn")
const NET_PC_TEXTURE: Texture2D = preload("res://assets/art/props/net_pc_station.png")
const BILLIARDS_TEXTURE: Texture2D = preload("res://assets/art/props/billiards_table.png")


func _build() -> void:
	add_spawn(&"default", Vector2(160, 360))
	add_spawn(&"from_home", Vector2(160, 360))
	add_exit(Vector2(30, 360), Vector2(40, 120), HOME_MAP, &"from_entertainment", "Về nhà")

	_add_station(AIM_GAME, "Quán Net", NET_PC_TEXTURE, Vector2(480, 400))
	_add_station(BILLIARDS_GAME, "Quán Bida", BILLIARDS_TEXTURE, Vector2(900, 390))
	# Anh Hai (chủ quán) đứng giữa hai quán.
	add_villager("res://data/dialogues/anh_hai.tres", 3, Vector2(690, 340))
	add_decor(Decor.BUSH, Vector2(300, 200))
	add_decor(Decor.BUSH, Vector2(1040, 220))


func _add_station(game: PackedScene, station_name: String, texture: Texture2D, feet: Vector2) -> void:
	var station: ArcadeStation = STATION_SCENE.instantiate()
	station.minigame_scene = game
	station.station_name = station_name
	station.texture = texture
	station.position = feet
	add_child(station)
