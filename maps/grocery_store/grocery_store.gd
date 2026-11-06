extends MapBase
## Tiệm Tạp Hóa: bà chủ bán nhu yếu phẩm cố định (mở 6h-21h, giờ do VendorData quyết định).

const HOME_MAP: String = "res://maps/home/home.tscn"
const NPC_SCENE: PackedScene = preload("res://entities/vendor/vendor_npc.tscn")
const VENDOR_DATA: VendorData = preload("res://data/vendors/tap_hoa.tres")


func _build() -> void:
	add_spawn(&"default", Vector2(160, 360))
	add_spawn(&"from_home", Vector2(160, 360))
	add_exit(Vector2(30, 360), Vector2(40, 120), HOME_MAP, &"from_grocery", "Về nhà")

	var npc: VendorNPC = NPC_SCENE.instantiate()
	npc.vendor_data = VENDOR_DATA
	npc.body_color = Color(0.85, 0.55, 0.3)
	npc.position = Vector2(640, 300)
	add_child(npc)


func _draw() -> void:
	super._draw()
	# Quầy hàng tạm.
	draw_rect(Rect2(540, 330, 200, 36), Color(0.45, 0.3, 0.18))
