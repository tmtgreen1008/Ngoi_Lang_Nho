#!/usr/bin/env bash
# Sinh dữ liệu món ăn (data/items/<id>.tres) và công thức nấu (data/recipes/<id>.tres) từ bảng dưới đây. Chạy lại được.
# Giá món (base_price, cô Ba thu mua x0,7) cao hơn tổng giá bán nguyên liệu sống khoảng 15-30% để bù công nấu;
# tests/test_cooking.gd kiểm tra khoảng này và việc không có chênh lệch giá.
# Thể lực hồi khi ăn một món (energy) = giá / 3, tối đa 100: ăn món đắt hồi nhiều sức hơn nhưng mất khoản tiền bán.
# Cột: id | tên | sheet icon (a/b) | ô icon (0-11) | giá | nguyên liệu (id:số lượng, cách nhau dấu phẩy) | số phút nấu
set -euo pipefail
cd "$(dirname "$0")/.."
TABLE='com_trang|Cơm trắng|a|0|52|lua:2|20
trung_op_la|Trứng ốp la|a|7|30|trung_ga:2|15
rau_muong_xao|Rau muống xào|a|8|72|rau_muong:3,ot:1|20
che_ngo|Chè ngô|a|9|100|ngo:2|30
xoi|Xôi đậu|a|4|100|lua:3,dau:1|30
mi_tom_trung|Mì tôm trứng|b|10|39|mi_tom:1,trung_ga:1,rau_muong:1|15
chao_thit|Cháo thịt|b|0|189|lua:2,thit_lon:1|40
banh_chung|Bánh chưng|a|2|293|lua:4,dau:2,thit_lon:1|60
cha_gio|Chả giò|a|11|197|thit_lon:1,ca_rot:1,trung_vit:1|40
sua_dau_nanh|Sữa đậu nành|b|7|94|dau:4|30'
while IFS='|' read -r id name sheet icon price ingredients minutes; do
	col=$((icon % 4 * 32)); row=$((icon / 4 * 32))
	cat > "data/items/${id}.tres" <<TRES
[gd_resource type="Resource" script_class="ItemData" format=3]

[ext_resource type="Script" path="res://core/resources/item_data.gd" id="1_item"]
[ext_resource type="Texture2D" path="res://assets/art/icons/food_${sheet}.png" id="2_icons"]

[sub_resource type="AtlasTexture" id="AtlasTexture_icon"]
atlas = ExtResource("2_icons")
region = Rect2(${col}, ${row}, 32, 32)

[resource]
script = ExtResource("1_item")
id = &"${id}"
display_name = "${name}"
description = "Món nấu sẵn, bán cho cô Ba ở chợ được giá hơn nguyên liệu sống."
icon = SubResource("AtlasTexture_icon")
category = 2
base_price = ${price}
energy = $(( price / 3 > 100 ? 100 : price / 3 ))
TRES
	ids=""; amounts=""
	IFS=',' read -ra parts <<< "$ingredients"
	for part in "${parts[@]}"; do
		ids="${ids}${ids:+, }&\"${part%%:*}\""
		amounts="${amounts}${amounts:+, }${part##*:}"
	done
	cat > "data/recipes/${id}.tres" <<TRES
[gd_resource type="Resource" script_class="RecipeData" format=3]

[ext_resource type="Script" path="res://core/resources/recipe_data.gd" id="1_recipe"]

[resource]
script = ExtResource("1_recipe")
id = &"${id}"
output_item_id = &"${id}"
output_amount = 1
ingredient_ids = Array[StringName]([${ids}])
ingredient_amounts = PackedInt32Array(${amounts})
cook_minutes = ${minutes}
TRES
done <<< "$TABLE"
echo "Xong."
