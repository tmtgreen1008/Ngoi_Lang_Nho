extends MapBase
## Chợ Quê buổi sáng: sạp rau của chú Năm, hàng ngẫu nhiên mỗi ngày (mở 5h-11h).

const HOME_MAP: String = "res://maps/home/home.tscn"
const NPC_SCENE: PackedScene = preload("res://entities/vendor/vendor_npc.tscn")
const VENDOR_DATA: VendorData = preload("res://data/vendors/thuong_lai_rau.tres")


func _build() -> void:
	add_spawn(&"default", Vector2(160, 360))
	add_spawn(&"from_home", Vector2(160, 360))
	add_exit(Vector2(30, 360), Vector2(40, 120), HOME_MAP, &"from_market", "Về nhà")

	var npc: VendorNPC = NPC_SCENE.instantiate()
	npc.vendor_data = VENDOR_DATA
	npc.body_color = Color(0.5, 0.75, 0.4)
	npc.position = Vector2(760, 300)
	add_child(npc)


func _draw() -> void:
	super._draw()
	# Mái sạp tạm.
	draw_rect(Rect2(650, 250, 220, 24), Color(0.75, 0.3, 0.25))
