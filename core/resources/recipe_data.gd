class_name RecipeData
extends Resource
## Công thức nấu ăn (file .tres trong data/recipes/, sinh bằng tools/make_food_data.sh): nguyên liệu và món làm ra.
## Chỉ chứa dữ liệu và vài hàm kiểm tra với kho đồ; việc nấu (trừ nguyên liệu, thêm món, trôi thời gian) do
## CookingUI lo.

const DATA_DIR: String = "res://data/recipes"

@export var id: StringName = &""
## Món làm ra (ItemData id) và số lượng mỗi lần nấu.
@export var output_item_id: StringName = &""
@export_range(1, 20, 1) var output_amount: int = 1
## Nguyên liệu: id vật phẩm và số lượng tương ứng (hai mảng cùng độ dài).
@export var ingredient_ids: Array[StringName] = []
@export var ingredient_amounts: PackedInt32Array = []
## Số phút trong game trôi qua mỗi lần nấu.
@export_range(0, 240, 5) var cook_minutes: int = 30


func is_valid() -> bool:
	return id != &"" and output_item_id != &"" and not ingredient_ids.is_empty() and ingredient_ids.size() == ingredient_amounts.size()


func get_output() -> ItemData:
	return ItemDatabase.get_item(output_item_id)


## Nguyên liệu đầu tiên còn thiếu trong [param inventory], dạng "Tên (cần n, có m)"; chuỗi rỗng nếu đủ.
func get_missing(inventory: InventoryComponent) -> String:
	for i: int in ingredient_ids.size():
		var item: ItemData = ItemDatabase.get_item(ingredient_ids[i])
		if item == null:
			return "Thiếu dữ liệu nguyên liệu %s" % ingredient_ids[i]
		var have: int = inventory.count_of(item) if inventory != null else 0
		if have < ingredient_amounts[i]:
			return "%s (cần %d, có %d)" % [item.display_name, ingredient_amounts[i], have]
	return ""


## Lý do chưa nấu được với [param inventory]; chuỗi rỗng nghĩa là nấu được.
func get_block_reason(inventory: InventoryComponent) -> String:
	if inventory == null:
		return "Không có túi đồ."
	var missing: String = get_missing(inventory)
	if not missing.is_empty():
		return "Thiếu %s." % missing
	var output: ItemData = get_output()
	if output == null:
		return "Lỗi dữ liệu: không có món này."
	# Nguyên liệu sẽ rời túi trước khi món vào, nhưng kiểm tra chỗ trống ngay bây giờ cho chắc (món là loại mới).
	if not inventory.can_add(output, output_amount):
		return "Túi đồ đã đầy."
	return ""


## Nấu một lần: trừ nguyên liệu, thêm món vào [param inventory]. Trả về lỗi hoặc "" nếu thành công.
## Không đụng tới thời gian hay âm thanh (bên gọi lo).
func cook(inventory: InventoryComponent) -> String:
	var reason: String = get_block_reason(inventory)
	if not reason.is_empty():
		return reason
	for i: int in ingredient_ids.size():
		inventory.remove_item(ItemDatabase.get_item(ingredient_ids[i]), ingredient_amounts[i])
	inventory.add_item(get_output(), output_amount)
	return ""


## Dòng mô tả nguyên liệu, vd "2 Lúa, 1 Đậu".
func describe_ingredients() -> String:
	var parts: PackedStringArray = []
	for i: int in ingredient_ids.size():
		var item: ItemData = ItemDatabase.get_item(ingredient_ids[i])
		parts.append("%d %s" % [ingredient_amounts[i], item.display_name if item != null else String(ingredient_ids[i])])
	return ", ".join(parts)


## Nạp mọi công thức trong data/recipes, sắp theo giá món tăng dần (món rẻ, dễ nấu lên đầu).
static func load_all() -> Array[RecipeData]:
	var recipes: Array[RecipeData] = []
	for file_name: String in DirAccess.get_files_at(DATA_DIR):
		var clean_name: String = file_name.trim_suffix(".remap")
		if not clean_name.ends_with(".tres"):
			continue
		var recipe: RecipeData = load(DATA_DIR.path_join(clean_name)) as RecipeData
		if recipe != null and recipe.is_valid():
			recipes.append(recipe)
	recipes.sort_custom(func(a: RecipeData, b: RecipeData) -> bool:
		var pa: int = a.get_output().base_price if a.get_output() != null else 0
		var pb: int = b.get_output().base_price if b.get_output() != null else 0
		return pa < pb or (pa == pb and String(a.id) < String(b.id)))
	return recipes
