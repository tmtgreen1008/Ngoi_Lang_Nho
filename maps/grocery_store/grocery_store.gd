extends InteriorMap
## Trong Tiệm Tạp Hóa (vào từ cửa tiệm ở làng): bà chủ đứng sau quầy bán nhu yếu phẩm cố định (mở 6h-21h, giờ do
## VendorData quyết định). Ra cửa (thảm đỏ phía dưới) về lại làng, ngay trước cửa tiệm.

const VILLAGE_MAP: String = "res://maps/village/village.tscn"
const NPC_SCENE: PackedScene = preload("res://entities/vendor/vendor_npc.tscn")
const VENDOR_DATA: VendorData = preload("res://data/vendors/tap_hoa.tres")


func _init() -> void:
	setup_room(Rect2(320, 272, 640, 264))


func _build() -> void:
	build_door(VILLAGE_MAP, &"from_grocery")

	# Thêm NPC TRƯỚC quầy để quầy che phần thân dưới: bà đứng sau quầy.
	var npc: VendorNPC = NPC_SCENE.instantiate()
	npc.vendor_data = VENDOR_DATA
	npc.position = Vector2(640, 330)
	add_child(npc)
	add_prop("res://assets/art/props/grocery_counter.png", Vector2(640, 380), 1, 16.0)

	# Chum đựng hàng ở bốn góc phòng.
	add_decor(Decor.JAR, Vector2(356, 316))
	add_decor(Decor.JAR, Vector2(924, 316))
	add_decor(Decor.JAR, Vector2(356, 516))
	add_decor(Decor.JAR, Vector2(924, 516))
