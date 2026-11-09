extends MapBase
## Tiệm Tạp Hóa: bà chủ đứng sau quầy bán nhu yếu phẩm cố định (mở 6h-21h, giờ do VendorData quyết định).

const HOME_MAP: String = "res://maps/home/home.tscn"
const NPC_SCENE: PackedScene = preload("res://entities/vendor/vendor_npc.tscn")
const VENDOR_DATA: VendorData = preload("res://data/vendors/tap_hoa.tres")


func _build() -> void:
	add_spawn(&"default", Vector2(160, 360))
	add_spawn(&"from_home", Vector2(160, 360))
	add_exit(Vector2(30, 360), Vector2(40, 120), HOME_MAP, &"from_grocery", "Về nhà")

	# Thêm NPC TRƯỚC quầy để quầy che phần thân dưới: bà đứng sau quầy.
	var npc: VendorNPC = NPC_SCENE.instantiate()
	npc.vendor_data = VENDOR_DATA
	npc.position = Vector2(640, 330)
	add_child(npc)
	add_prop("res://assets/art/props/grocery_counter.png", Vector2(640, 380), 1, 16.0)

	# Chị Hạnh ghé mua đồ, đứng chờ bên trái quầy.
	add_villager("res://data/dialogues/chi_hanh.tres", 0, Vector2(470, 330))

	# Chum đựng hàng ở các góc.
	add_decor(Decor.JAR, Vector2(220, 170))
	add_decor(Decor.JAR, Vector2(1060, 170))
	add_decor(Decor.JAR, Vector2(220, 560))
	add_decor(Decor.JAR, Vector2(1060, 560))
