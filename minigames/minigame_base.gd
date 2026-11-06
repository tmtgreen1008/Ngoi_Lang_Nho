class_name MinigameBase
extends Control
## Lớp nền cho mọi mini-game: khung giao diện chung (tiêu đề, phí, nút Thoát) và
## cách trả kết quả về scene chính.
##
## Mini-game KHÔNG tự sửa tiền hay thời gian: khi xong nó gọi [method finish] và
## MinigameHost áp kết quả ({"money": tiền thưởng, "minutes": phút trôi qua, ...}).
## Phí vào cửa do MinigameHost thu trước khi mini-game hiện ra.
##
## Lớp con ghi đè [method _setup] để dựng giao diện vào [member content].

## Mã định danh, dùng trong EventBus.minigame_finished.
@export var minigame_id: StringName = &""
@export var title: String = "Mini-game"
## Phí vào cửa (đồng), thu trước khi chơi.
@export_range(0, 1000, 1) var entry_fee: int = 0
## Số phút trong game trôi qua nếu đã chơi thật.
@export_range(0, 600, 5) var minutes_cost: int = 60

## Đã bắt đầu chơi thật (qua [method mark_played]). Chưa chơi mà thoát thì được hoàn phí.
var played: bool = false
## Vùng nội dung để lớp con thêm giao diện vào.
var content: VBoxContainer

var _finished: bool = false


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_frame()
	_setup()


## Lớp con ghi đè: dựng giao diện mini-game vào [member content].
func _setup() -> void:
	pass


## Gọi khi vòng chơi thật sự bắt đầu.
func mark_played() -> void:
	played = true


## Kết thúc và trả kết quả. [param money_won] là tiền thưởng nhận về (chưa trừ phí).
## [param extra] là các chỉ số thêm, hợp nhất vào kết quả. Chỉ có tác dụng một lần.
func finish(money_won: int, extra: Dictionary = {}) -> void:
	if _finished:
		return
	_finished = true
	var result: Dictionary = {
		"money": maxi(0, money_won),
		"minutes": minutes_cost if played else 0,
	}
	result.merge(extra, true)
	EventBus.minigame_finished.emit(minigame_id, result)


## Người chơi thoát: chưa chơi thì hoàn phí, đã chơi dở thì mất phần thưởng.
## Lớp con có thể ghi đè để dừng vòng chơi trước (rồi gọi super).
func quit() -> void:
	finish(0 if played else entry_fee)


func _build_frame() -> void:
	var background := ColorRect.new()
	background.color = Color(0.08, 0.1, 0.16, 1.0)  # Đục hoàn toàn để không lộ map phía sau.
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(880, 560)
	panel.theme = UiTheme.get_theme()
	center.add_child(panel)
	var margin := MarginContainer.new()
	for side: String in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	var title_label := Label.new()
	title_label.text = title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 26)
	box.add_child(title_label)

	var info_label := Label.new()
	info_label.text = "Phí vào cửa: %d đ   |   Thời gian: khoảng %d phút" % [entry_fee, minutes_cost]
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.modulate = Color(1, 1, 1, 0.7)
	box.add_child(info_label)

	content = VBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 10)
	box.add_child(content)

	var quit_button := Button.new()
	quit_button.text = "Thoát"
	quit_button.pressed.connect(quit)
	box.add_child(quit_button)
