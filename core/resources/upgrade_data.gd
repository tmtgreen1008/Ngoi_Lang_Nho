class_name UpgradeData
extends Resource
## Dữ liệu một nâng cấp (file .tres trong data/upgrades/): tên, mô tả, giá từng cấp và giá trị hiệu lực ở mỗi cấp.
##
## Cấp 0 là mặc định (chưa mua). [member costs] có N phần tử = N cấp để mua; [member values] có N+1 phần tử,
## phần tử i là giá trị hiệu lực ở cấp i (vd. số hàng của vườn). Chỉ chứa dữ liệu; mua bán do UpgradeManager lo,
## áp hiệu lực do từng hệ thống (vườn, công cụ, chuồng, túi đồ) lo qua EventBus.

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
## Giá mua từng cấp (đồng): costs[0] mua lên cấp 1.
@export var costs: PackedInt32Array = []
## Giá trị ở từng cấp, kể cả cấp 0.
@export var values: PackedInt32Array = []
## Định dạng hiển thị giá trị, vd "%d hàng" hoặc "%d ô mỗi lần".
@export var value_format: String = "%d"


func max_level() -> int:
	return costs.size()


## Giá trị hiệu lực ở [param level] (kẹp trong khoảng hợp lệ).
func value_at(level: int) -> int:
	return values[clampi(level, 0, values.size() - 1)]


## Giá mua để lên cấp [param next_level] (1..max_level), hoặc -1 nếu không có.
func cost_for(next_level: int) -> int:
	if next_level < 1 or next_level > costs.size():
		return -1
	return costs[next_level - 1]


func format_value(level: int) -> String:
	return value_format % value_at(level)


func is_valid() -> bool:
	return id != &"" and not display_name.is_empty() and not costs.is_empty() and values.size() == costs.size() + 1
