extends MapBase
## Chợ Quê buổi sáng: sạp rau của chú Năm, hàng ngẫu nhiên mỗi ngày (mở 5h-11h).

const HOME_MAP: String = "res://maps/home/home.tscn"
const NPC_SCENE: PackedScene = preload("res://entities/vendor/vendor_npc.tscn")
const VENDOR_DATA: VendorData = preload("res://data/vendors/thuong_lai_rau.tres")


func _build() -> void:
	add_spawn(&"default", Vector2(160, 360))
	add_spawn(&"from_home", Vector2(160, 360))
	add_exit(Vector2(30, 360), Vector2(40, 120), HOME_MAP, &"from_market", "Về nhà")

	# Chú Năm đứng bên trái sạp; sạp chặn lối đi ở phần bàn.
	var npc: VendorNPC = NPC_SCENE.instantiate()
	npc.vendor_data = VENDOR_DATA
	npc.position = Vector2(690, 360)
	add_child(npc)
	add_prop("res://assets/art/props/market_stall.png", Vector2(800, 380), 1, 20.0)

	add_decor(Decor.JAR, Vector2(300, 200))
	add_decor(Decor.BUSH, Vector2(980, 230))
	add_decor(Decor.BAMBOO, Vector2(1120, 200))
	add_decor(Decor.BANANA, Vector2(260, 560))
	add_decor(Decor.JAR, Vector2(1040, 540))
