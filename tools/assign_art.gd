extends SceneTree
## Gắn ảnh đã xử lý (assets/art/...) vào các file dữ liệu .tres: icon vật phẩm, ảnh cây lúa,
## ảnh người bán. Chạy một lần sau tools/process_assets.sh (chạy lại cũng được):
##   godot --headless --path . -s tools/assign_art.gd
##
## Thứ tự icon trong sheet item_icons.png (lưới 5x2, ô 32x32), trùng prompt số 6 ở
## docs/ASSET_PROMPTS.md.

const ICON_SHEET: String = "res://assets/art/icons/item_icons.png"
const ICON_CELL: int = 32
const ICON_COLUMNS: int = 5
const ICON_ORDER: Array[String] = [
	"lua", "hat_giong_lua", "mi_tom", "cam_ga", "xa_phong",
	"rau_muong", "ca_chua", "bap_cai", "trung_ga", "dua_leo",
]
const RICE_SHEET: String = "res://assets/art/crops/rice_stages.png"
const VENDOR_SHEETS: Dictionary = {
	"res://data/vendors/tap_hoa.tres": "res://assets/art/characters/npc_ba_tu.png",
	"res://data/vendors/thuong_lai_rau.tres": "res://assets/art/characters/npc_chu_nam.png",
}


func _initialize() -> void:
	var failures: int = 0
	var sheet: Texture2D = load(ICON_SHEET)
	for index: int in ICON_ORDER.size():
		var path: String = _find_item(ICON_ORDER[index])
		if path.is_empty():
			push_error("Khong tim thay vat pham %s" % ICON_ORDER[index])
			failures += 1
			continue
		var item: Resource = load(path)
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2((index % ICON_COLUMNS) * ICON_CELL, (index / ICON_COLUMNS) * ICON_CELL, ICON_CELL, ICON_CELL)
		item.set("icon", atlas)
		if ICON_ORDER[index] == "hat_giong_lua":
			item.set("growth_sheet", load(RICE_SHEET))
		failures += _save(item, path)

	for vendor_path: String in VENDOR_SHEETS:
		var vendor: Resource = load(vendor_path)
		vendor.set("npc_sheet", load(VENDOR_SHEETS[vendor_path]))
		failures += _save(vendor, vendor_path)
	print("ASSIGN ", "OK" if failures == 0 else "%d loi" % failures)
	quit(failures)


func _find_item(item_id: String) -> String:
	for directory: String in ["res://data/items", "res://data/crops"]:
		var path: String = "%s/%s.tres" % [directory, item_id]
		if FileAccess.file_exists(path):
			return path
	return ""


func _save(resource: Resource, path: String) -> int:
	var error: int = ResourceSaver.save(resource, path)
	if error != OK:
		push_error("Khong luu duoc %s (loi %d)" % [path, error])
		return 1
	return 0
