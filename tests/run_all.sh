#!/usr/bin/env bash
# Chạy toàn bộ bài test của Hương Quê và in tóm tắt. Mã thoát 0 nếu tất cả đạt.
#
# Dùng:   bash tests/run_all.sh
# Godot:  mặc định lệnh `godot`; đổi bằng  GODOT=/duong/dan/godot bash tests/run_all.sh
#
# Các bài test giao diện cần cửa sổ thật (chụp ảnh, bố cục), nên KHÔNG chạy headless.
# Ảnh chụp lưu ở thư mục dữ liệu người dùng của game: <user data>/test_shots/.
# Test lưu game tạo và tự xoá file trong <user data>/saves/ (slot test, bad, slot1, autosave).

set -u
GODOT="${GODOT:-godot}"
cd "$(dirname "$0")/.."

# Đăng ký các class mới (class_name) trước khi chạy test.
"$GODOT" --headless --path . --import > /dev/null 2>&1

total_checks=0
total_fails=0
failed_tests=()

run_test() {
	local name="$1"
	shift
	local log
	log="$(mktemp)"
	timeout 300 "$GODOT" --path . --resolution 1280x720 -s "tests/${name}.gd" "$@" > "$log" 2>&1
	local code=$?
	local result
	result="$(grep -E '^RESULT ' "$log" | tail -1)"
	if [ -z "$result" ]; then
		result="RESULT ${name}.gd: KHÔNG CÓ KẾT QUẢ (lỗi script hoặc quá giờ, mã thoát ${code})"
		grep -E 'SCRIPT ERROR|Parse Error' "$log" | head -5
		code=1
	fi
	echo "$result"
	# Lỗi script làm bài test dừng giữa chừng nhưng vẫn in RESULT với số kiểm tra đã chạy:
	# coi là trượt để không bỏ sót các kiểm tra phía sau.
	if grep -q 'SCRIPT ERROR' "$log"; then
		grep -E 'SCRIPT ERROR' "$log" | head -5
		code=1
	fi
	if [ "$code" -ne 0 ]; then
		grep -E '^FAIL ' "$log"
		failed_tests+=("${name}${*:+ $*}")
	fi
	local checks fails
	checks="$(echo "$result" | sed -n 's/.*: \([0-9]*\) checks.*/\1/p')"
	fails="$(echo "$result" | sed -n 's/.* \([0-9]*\) failed.*/\1/p')"
	total_checks=$((total_checks + ${checks:-0}))
	total_fails=$((total_fails + ${fails:-0}))
	rm -f "$log"
}

run_test test_time_manager
run_test test_inventory
run_test test_farm_field
run_test test_shop_logic
run_test test_terrain
run_test test_home
run_test test_art
run_test test_inventory_ui
run_test test_shop_ui
run_test test_game_flow
run_test test_livestock
run_test test_crops
run_test test_layering
run_test test_seasons
run_test test_audio
run_test test_music
run_test test_settings
run_test test_dialogue
run_test test_villagers
run_test test_economy
run_test test_upgrades
run_test test_save_load
run_test test_minigames
run_test test_start_menu -- phase=A
run_test test_start_menu -- phase=B
run_test test_start_menu -- phase=C

# Dọn các file lưu do test_start_menu tạo ra.
user_dir="$("$GODOT" --headless --path . -s tests/print_user_dir.gd 2>/dev/null | grep '^USERDIR ' | sed 's/^USERDIR //')"
if [ -n "$user_dir" ]; then
	rm -f "$user_dir/saves/slot1.json" "$user_dir/saves/autosave.json" "$user_dir/saves/bad.json"
fi

echo "----------------------------------------"
echo "Tổng: ${total_checks} kiểm tra, ${total_fails} trượt."
if [ "${#failed_tests[@]}" -gt 0 ]; then
	echo "Bài test lỗi: ${failed_tests[*]}"
	exit 1
fi
echo "TẤT CẢ ĐẠT."
