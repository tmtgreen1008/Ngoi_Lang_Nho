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

if [ "$#" -eq 0 ]; then set -- ui tools farm player animals; fi
for g in "$@"; do "group_$g"; done
echo "Xong."
