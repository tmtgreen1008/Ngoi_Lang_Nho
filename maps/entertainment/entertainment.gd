extends InteriorMap
## Trong Khu Giải trí (vào từ cửa Quán Net hoặc Quán Bida ở làng): một gian lớn có ba trạm chơi, Quán Net (bắn mục
## tiêu), Quán Bida (canh lực) và Chiếu Ô ăn quan (đấu với máy). Chơi xong, kết quả (tiền, thời gian trôi qua) được
## MinigameHost áp về thế giới chính. Ra cửa (thảm đỏ phía dưới) về lại làng.

const VILLAGE_MAP: String = "res://maps/village/village.tscn"
const STATION_SCENE: PackedScene = preload("res://entities/arcade/arcade_station.tscn")
const AIM_GAME: PackedScene = preload("res://minigames/net_cafe/aim_game.tscn")
const BILLIARDS_GAME: PackedScene = preload("res://minigames/billiards/billiards_game.tscn")
const NET_PC_TEXTURE: Texture2D = preload("res://assets/art/props/net_pc_station.png")
const BILLIARDS_TEXTURE: Texture2D = preload("res://assets/art/props/billiards_table.png")
const O_AN_QUAN_GAME: PackedScene = preload("res://minigames/o_an_quan/o_an_quan_game.tscn")
const O_AN_QUAN_TEXTURE: Texture2D = preload("res://assets/art/props/o_an_quan_mat.png")


func _init() -> void:
	setup_room(Rect2(240, 300, 800, 336))


func _build() -> void:
	build_door(VILLAGE_MAP, &"from_entertainment")

	_add_station(AIM_GAME, "Quán Net", NET_PC_TEXTURE, Vector2(480, 400))
	_add_station(BILLIARDS_GAME, "Quán Bida", BILLIARDS_TEXTURE, Vector2(900, 390))
	_add_station(O_AN_QUAN_GAME, "Chiếu Ô ăn quan", O_AN_QUAN_TEXTURE, Vector2(820, 580))
	add_decor(Decor.BUSH, Vector2(276, 340))
	add_decor(Decor.BUSH, Vector2(1004, 340))


func _add_station(game: PackedScene, station_name: String, texture: Texture2D, feet: Vector2) -> void:
	var station: ArcadeStation = STATION_SCENE.instantiate()
	station.minigame_scene = game
	station.station_name = station_name
	station.texture = texture
	station.position = feet
	add_child(station)
