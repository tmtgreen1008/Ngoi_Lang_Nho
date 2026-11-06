#!/usr/bin/env bash
# Xử lý 20 ảnh gốc trong assets/art/source/ thành asset dùng trong game (assets/art/...).
# Chạy lại được bất cứ lúc nào, ví dụ khi thay một ảnh gốc:   bash tools/process_assets.sh
# Godot: mặc định lệnh `godot`; đổi bằng  GODOT=/duong/dan/godot bash tools/process_assets.sh
#
# Cỡ "px" (số pixel nguồn ứng với 1 pixel đầu ra) là cỡ một pixel nghệ thuật của từng ảnh,
# đo bằng khoảng cách các cạnh màu; xem giải thích trong tools/slice_sheet.gd.
set -euo pipefail
GODOT="${GODOT:-godot}"
cd "$(dirname "$0")/.."
SRC=assets/art/source
OUT=assets/art

slice() { "$GODOT" --headless --path . -s tools/slice_sheet.gd -- "$@" | grep -E "SLICE"; }

# Nền đất: lưới 4x2, ô 48x48 (làm mượt vì ô lát cần liền mạch).
slice in=$SRC/01_terrain_tiles.png out=$OUT/tiles/terrain_tiles.png cols=4 rows=2 cell=48,48 sample=lanczos

# Cây lúa 3 giai đoạn, neo gốc vào đáy ô 48x48.
slice in=$SRC/02_rice_stages.png out=$OUT/crops/rice_stages.png cols=3 rows=1 split=auto anchor=feet px=14 cell=48,48 key=magenta defringe=1

# Nhân vật: Player 3 khung x 4 hướng (xuống, trái, phải, lên); NPC 2 khung, neo chân.
slice in=$SRC/03_player_sheet.png out=$OUT/characters/player_sheet.png cols=3 rows=4 cell=32,48 key=magenta defringe=1
slice in=$SRC/04_npc_ba_tu.png out=$OUT/characters/npc_ba_tu.png cols=2 rows=1 anchor=feet px=16 cell=32,48 key=magenta defringe=1
slice in=$SRC/05_npc_chu_nam.png out=$OUT/characters/npc_chu_nam.png cols=2 rows=1 anchor=feet px=16 cell=32,48 key=magenta defringe=1

# Icon 10 vật phẩm: lưới 5x2, ô 32x32 (hiển thị gấp đôi trong ô kho 72px).
slice in=$SRC/06_item_icons.png out=$OUT/icons/item_icons.png cols=5 rows=2 cell=32,32 key=magenta defringe=1

# Đồ vật: cắt sát, cỡ gốc theo từng ảnh (trong game có thể phóng to nguyên lần).
slice in=$SRC/07_house.png out=$OUT/props/house.png anchor=feet px=12 cell=auto pad=0 key=magenta defringe=1
slice in=$SRC/08_bed.png out=$OUT/props/bed.png anchor=feet px=14 cell=auto pad=0 key=magenta defringe=1
slice in=$SRC/09_grocery_counter.png out=$OUT/props/grocery_counter.png anchor=feet px=13 cell=auto pad=0 key=magenta defringe=1
slice in=$SRC/10_market_stall.png out=$OUT/props/market_stall.png anchor=feet px=10 cell=auto pad=0 key=magenta defringe=1
slice in=$SRC/11_net_pc_station.png out=$OUT/props/net_pc_station.png anchor=feet px=9 cell=auto pad=0 key=magenta defringe=1
slice in=$SRC/12_billiards_table.png out=$OUT/props/billiards_table.png anchor=feet px=12 cell=auto pad=0 key=magenta defringe=1
slice in=$SRC/13_decor_sheet.png out=$OUT/props/decor_sheet.png cols=5 rows=1 split=auto anchor=feet px=12 cell=48,48 key=magenta defringe=1

# Giao diện.
slice in=$SRC/14_panel_paper.png out=$OUT/ui/panel_paper.png anchor=feet px=15 cell=auto pad=0 key=magenta defringe=1
slice in=$SRC/15_buttons.png out=$OUT/ui/buttons.png cols=1 rows=3 anchor=feet px=15 cell=auto pad=0 key=magenta defringe=1
slice in=$SRC/16_hud_icons.png out=$OUT/ui/hud_icons.png cols=4 rows=2 cell=32,32 key=magenta defringe=1
slice in=$SRC/17_logo_emblem.png out=$OUT/ui/logo_emblem.png anchor=feet px=12 cell=auto pad=0 key=magenta defringe=1
slice in=$SRC/18_start_background.png out=$OUT/ui/start_background.png cell=1280,720 sample=lanczos

# Mini-game (không khử viền cho bi: có bi màu tím thật).
slice in=$SRC/19_aim_target.png out=$OUT/minigames/aim_target.png anchor=feet px=19 cell=auto pad=0 key=magenta defringe=1
slice in=$SRC/20_billiard_balls.png out=$OUT/minigames/billiard_balls.png cols=6 rows=1 split=auto anchor=feet px=12 cell=auto pad=1 key=magenta
echo "Xong."
