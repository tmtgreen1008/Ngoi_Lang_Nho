#!/usr/bin/env bash
# Xử lý đợt 3 (ảnh gốc trong assets/art/source/batch3, tên theo số danh mục trong docs/ASSET_CATALOG.md).
# Chạy: bash tools/process_assets_3.sh [nhóm]   (không đối số = chạy mọi nhóm: ui tools farm player animals)
# Godot: mặc định lệnh `godot`; đổi bằng  GODOT=/duong/dan/godot bash tools/process_assets_3.sh
set -euo pipefail
GODOT="${GODOT:-godot}"
cd "$(dirname "$0")/.."
SRC=assets/art/source/batch3
OUT=assets/art

slice() { "$GODOT" --headless --path . -s tools/slice_sheet.gd -- "$@" | grep -E "SLICE"; }

group_ui() {
	# Ô kho / thanh nhanh: 8 ô (4x2), ô 64x64.
	slice in=$SRC/042_slots.png out=$OUT/ui/slots.png cols=4 rows=2 cell=64,64 key=magenta defringe=1
	# Bảng 9-slice: 8 kiểu (4x2), ô 96x96.
	slice in=$SRC/043_panels.png out=$OUT/ui/panels.png cols=4 rows=2 cell=96,96 key=magenta defringe=1
	# Điều khiển nhỏ: 12 ô (4x3), 48x48.
	slice in=$SRC/044_controls.png out=$OUT/ui/controls.png cols=4 rows=3 cell=48,48 key=magenta defringe=1
	# Thanh tiến trình và thể lực: 8 ô (2x4), 192x32.
	slice in=$SRC/045_bars.png out=$OUT/ui/bars.png cols=2 rows=4 cell=192,32 key=magenta defringe=1
	# Icon HUD 2: 12 ô (4x3), 32x32.
	slice in=$SRC/048_hud_icons_2.png out=$OUT/ui/hud_icons_2.png cols=4 rows=3 cell=32,32 key=magenta defringe=1
	# Bộ cửa hàng và hội thoại: 12 ô (4x3), 64x64.
	slice in=$SRC/053_shop_kit.png out=$OUT/ui/shop_kit.png cols=4 rows=3 cell=64,64 key=magenta defringe=1
}

group_tools() {
	# Công cụ cơ bản: 12 ô (4x3), 64x64.
	slice in=$SRC/062_tools_basic.png out=$OUT/icons/tools_basic.png cols=4 rows=3 cell=64,64 key=magenta defringe=1
}

group_farm() {
	# Đất canh tác: 8 ô (4x2), 48x48, làm mượt vì ô lát cần liền mạch.
	slice in=$SRC/080_farmland.png out=$OUT/tiles/farmland.png cols=4 rows=2 cell=48,48 sample=lanczos
	# Bờ nước: 16 ô ghép (4x4), 48x48.
	slice in=$SRC/082_water_shore.png out=$OUT/tiles/water_shore.png cols=4 rows=4 cell=48,48 sample=lanczos
	# Nền và tường trong nhà: 12 ô (4x3), 48x48.
	slice in=$SRC/086_interior.png out=$OUT/tiles/interior.png cols=4 rows=3 cell=48,48 sample=lanczos
	# Hàng rào và cổng: 8 ô (4x2), 64x64.
	# Hàng trên có 5 mảnh (rào, rào góc, cổng đôi, hai cánh cổng), hàng dưới 4 mảnh: cắt riêng từng hàng.
	slice in=$SRC/090_fences.png out=$OUT/props/fences_a.png crop=0,0,1448,543 cols=5 rows=1 cell=64,64 key=magenta defringe=1
	slice in=$SRC/090_fences.png out=$OUT/props/fences_b.png crop=0,543,1448,543 cols=4 rows=1 cell=64,64 key=magenta defringe=1
}

group_player() {
	# Player cuốc đất, tưới cây: 12 khung (3x4). Ô 42x56 để nhân vật cao bằng sheet đi bộ (39px).
	slice in=$SRC/109_player_hoe.png out=$OUT/characters/player_hoe.png cols=3 rows=4 cell=42,56 key=magenta defringe=1
	slice in=$SRC/110_player_water.png out=$OUT/characters/player_water.png cols=3 rows=4 cell=42,56 key=magenta defringe=1
}

group_animals() {
	# Gà và lợn có hoạt ảnh: 12 khung (4x3).
	slice in=$SRC/126_anim_chicken.png out=$OUT/characters/anim_chicken.png cols=4 rows=3 cell=32,32 key=magenta defringe=1
	slice in=$SRC/127_anim_pig.png out=$OUT/characters/anim_pig.png cols=4 rows=3 cell=48,40 key=magenta defringe=1
}

group_animals2() {
	# Vịt, trâu, chó có hoạt ảnh: 12 khung (4x3). Trâu to hơn nên ô 64x48.
	slice in=$SRC/132_anim_duck.png out=$OUT/characters/anim_duck.png cols=4 rows=3 cell=32,32 key=magenta defringe=1
	slice in=$SRC/128_anim_buffalo.png out=$OUT/characters/anim_buffalo.png cols=4 rows=3 cell=64,48 key=magenta defringe=1
	slice in=$SRC/130_anim_dog.png out=$OUT/characters/anim_dog.png cols=4 rows=3 cell=32,32 key=magenta defringe=1
	# Ao nhỏ (nửa phải của ảnh ao), cắt sát; trong game phóng 2 lần làm ao vịt.
	slice in=$SRC/027_pond.png out=$OUT/props/pond_small.png crop=1320,150,663,560 anchor=feet px=9 cell=auto pad=0 key=magenta defringe=1
}

group_market() {
	# Người bán ở chợ: mỗi hàng của ảnh là một người, 2 khung đứng yên 32x48 (hàng 2: cô Ba, hàng 3: cô Út).
	slice in=$SRC/122_shopkeepers.png out=$OUT/characters/npc_co_ba.png crop=0,256,1024,256 cols=2 rows=1 anchor=feet px=6 cell=32,48 key=magenta defringe=1
	slice in=$SRC/122_shopkeepers.png out=$OUT/characters/npc_co_ut.png crop=0,512,1024,256 cols=2 rows=1 anchor=feet px=6 cell=32,48 key=magenta defringe=1
	# Sạp chợ: ảnh 3x2 sạp, cắt riêng sạp trứng gà (giữa, hàng dưới) và sạp hàng xén (phải, hàng dưới).
	slice in=$SRC/030_market_stalls.png out=$OUT/props/stall_eggs.png crop=512,512,512,512 anchor=feet px=3.4 cell=auto pad=0 key=magenta defringe=1
	slice in=$SRC/030_market_stalls.png out=$OUT/props/stall_goods.png crop=1024,512,512,512 anchor=feet px=3.4 cell=auto pad=0 key=magenta defringe=1
}

group_food() {
	# Món ăn: hai sheet 4x3, ô 32x32 (dữ liệu món và công thức sinh bằng tools/make_food_data.sh).
	slice in=$SRC/069_food_a.png out=$OUT/icons/food_a.png cols=4 rows=3 cell=32,32 key=magenta defringe=1
	slice in=$SRC/070_food_b.png out=$OUT/icons/food_b.png cols=4 rows=3 cell=32,32 key=magenta defringe=1
	# Bếp lò (món đầu tiên của ảnh đồ bếp), cắt sát.
	slice in=$SRC/098_interior_kitchen.png out=$OUT/props/stove.png crop=0,0,443,443 anchor=feet px=6.5 cell=auto pad=0 key=magenta defringe=1
}

if [ "$#" -eq 0 ]; then set -- ui tools farm player animals animals2 market food; fi
for g in "$@"; do "group_$g"; done
echo "Xong."
