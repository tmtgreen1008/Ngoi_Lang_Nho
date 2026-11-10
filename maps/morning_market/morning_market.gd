extends MapBase
## Chợ Quê buổi sáng (mở 5h-11h), ba sạp mỗi sạp một kiểu:
## - Sạp rau chú Năm: hàng ngẫu nhiên mỗi ngày, thu mua nông sản và thực phẩm (x0,6).
## - Sạp trứng thịt cô Ba: chỉ thu mua thực phẩm (trứng, thịt, món nấu sẵn) với giá cao hơn (x0,7).
## - Hàng xén cô Út: mỗi ngày ba loại hạt giống rẻ hơn Tạp Hóa (x0,9), không thu mua.

const HOME_MAP: String = "res://maps/home/home.tscn"
const NPC_SCENE: PackedScene = preload("res://entities/vendor/vendor_npc.tscn")
const VENDOR_DATA: VendorData = preload("res://data/vendors/thuong_lai_rau.tres")
const FOOD_VENDOR: VendorData = preload("res://data/vendors/quan_co_ba.tres")
const SEED_VENDOR: VendorData = preload("res://data/vendors/hang_co_ut.tres")

var vendors: Dictionary = {}  # id cửa hàng -> VendorNPC


func _build() -> void:
	add_spawn(&"default", Vector2(160, 360))
	add_spawn(&"from_home", Vector2(160, 360))
	add_exit(Vector2(30, 360), Vector2(40, 120), HOME_MAP, &"from_market", "Về nhà")

	# Người bán đứng bên trái sạp; sạp chặn lối đi ở phần bàn.
	_add_stall(VENDOR_DATA, Vector2(690, 360), "res://assets/art/props/market_stall.png", Vector2(800, 380))
	_add_stall(FOOD_VENDOR, Vector2(300, 570), "res://assets/art/props/stall_eggs.png", Vector2(412, 604))
	_add_stall(SEED_VENDOR, Vector2(900, 196), "res://assets/art/props/stall_goods.png", Vector2(1012, 226))

	# Cô Lan đi chợ, đứng gần lối vào.
	add_villager("res://data/dialogues/co_lan.tres", 2, Vector2(470, 320))

	add_decor(Decor.JAR, Vector2(300, 200))
	add_decor(Decor.BANANA, Vector2(170, 190))
	add_decor(Decor.BAMBOO, Vector2(1130, 200))
	add_decor(Decor.BUSH, Vector2(1130, 420))
	add_decor(Decor.JAR, Vector2(1040, 540))


func _add_stall(data: VendorData, npc_pos: Vector2, stall_texture: String, stall_feet: Vector2) -> void:
	var npc: VendorNPC = NPC_SCENE.instantiate()
	npc.vendor_data = data
	npc.position = npc_pos
	add_child(npc)
	add_prop(stall_texture, stall_feet, 1, 20.0)
	vendors[data.id] = npc
