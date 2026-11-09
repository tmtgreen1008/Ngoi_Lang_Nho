#!/usr/bin/env bash
# Sinh file dữ liệu cho 11 loại cây (hạt giống data/crops/hat_giong_<id>.tres và nông sản mới
# data/items/<id>.tres) từ bảng dưới đây. Chạy lại được; ảnh lấy từ assets/art (xem process_assets.sh).
# Giá nông sản được tính từ lãi mục tiêu mỗi ô mỗi ngày (xem tools/economy_report.gd) và kiểm tra bởi tests/test_economy.gd.
# Cột: id | tên | giá hạt | giá nông sản (base_price, Chợ thu mua x0,6) | số ngày lớn | số nông sản/lần | các mùa (0 Xuân 1 Hạ 2 Thu 3 Đông) | ô icon (0-11) | nông sản đã có sẵn?
set -euo pipefail
cd "$(dirname "$0")/.."
TABLE='ca_chua|Cà chua|20|40|5|3|0,1|1|co
bap_cai|Bắp cải|25|77|6|2|2,3|2|co
dua_leo|Dưa leo|18|34|4|3|1|3|co
rau_muong|Rau muống|8|14|3|4|0,1,2|4|co
ngo|Ngô|22|50|6|3|1,2|5|khong
ca_rot|Cà rốt|15|37|5|3|0,2,3|6|khong
khoai_lang|Khoai lang|20|49|6|3|2,3|7|khong
ot|Ớt|18|25|5|5|1|8|khong
bi_do|Bí đỏ|40|104|7|2|2|9|khong
dua_hau|Dưa hấu|50|119|7|2|1|10|khong
dau|Đậu|15|22|4|4|0,2|11|khong'
while IFS='|' read -r id name seed_price crop_price days amount seasons icon exists; do
	col=$((icon % 4 * 32)); row=$((icon / 4 * 32))
	cat > "data/crops/hat_giong_${id}.tres" <<TRES
[gd_resource type="Resource" script_class="CropItemData" format=3]

[ext_resource type="Script" path="res://core/resources/crop_item_data.gd" id="1_crop"]
[ext_resource type="Texture2D" path="res://assets/art/crops/${id}.png" id="2_growth"]
[ext_resource type="Texture2D" path="res://assets/art/icons/seed_icons.png" id="3_icons"]

[sub_resource type="AtlasTexture" id="AtlasTexture_icon"]
atlas = ExtResource("3_icons")
region = Rect2(${col}, ${row}, 32, 32)

[resource]
script = ExtResource("1_crop")
grow_days = ${days}
harvest_item_id = &"${id}"
harvest_amount = ${amount}
allowed_seasons = Array[int]([${seasons//,/, }])
growth_sheet = ExtResource("2_growth")
id = &"hat_giong_${id}"
display_name = "Hạt giống ${name,}"
description = "Gieo vào đất đã cuốc, thu hoạch sau ${days} ngày."
icon = SubResource("AtlasTexture_icon")
category = 0
base_price = ${seed_price}
TRES
	# Nông sản đã có sẵn (cà chua, bắp cải, dưa leo, rau muống): chỉ cập nhật giá, giữ nguyên icon và mô tả.
	if [ "$exists" = "co" ]; then
		sed -i "s/^base_price = .*/base_price = ${crop_price}/" "data/items/${id}.tres"
	fi
	if [ "$exists" = "khong" ]; then
		cat > "data/items/${id}.tres" <<TRES
[gd_resource type="Resource" script_class="ItemData" format=3]

[ext_resource type="Script" path="res://core/resources/item_data.gd" id="1_item"]
[ext_resource type="Texture2D" path="res://assets/art/icons/veg_icons.png" id="2_icons"]

[sub_resource type="AtlasTexture" id="AtlasTexture_icon"]
atlas = ExtResource("2_icons")
region = Rect2(${col}, ${row}, 32, 32)

[resource]
script = ExtResource("1_item")
id = &"${id}"
display_name = "${name}"
description = "${name} tươi vừa thu hoạch."
icon = SubResource("AtlasTexture_icon")
category = 1
base_price = ${crop_price}
TRES
	fi
done <<< "$TABLE"
echo "Xong."
