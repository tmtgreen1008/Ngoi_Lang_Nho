class_name UiTheme
extends RefCounted
## Giao diện chung kiểu giấy và gỗ: khung giấy 9-slice, nút 3 trạng thái, icon HUD.
## Ảnh lấy từ assets/art/ui/ (panel_paper.png, buttons.png, hud_icons.png).
##
## Gắn [method get_theme] vào GỐC của một khối giao diện nền giấy (cửa hàng, menu, mini-game,
## các bảng HUD): panel.theme = UiTheme.get_theme()
## Chữ trong khối đó tự đổi sang nâu đậm cho đọc được trên giấy. Chữ đặt thẳng lên nền game
## (không có bảng giấy) thì phải trắng viền đen.

## Icon trong sheet hud_icons.png (lưới 4 cột x 2 hàng, ô 32x32), theo thứ tự ảnh.
enum HudIcon { COIN, CLOCK, SPRING, SUMMER, AUTUMN, WINTER, KEY_E }

const PANEL_PATH: String = "res://assets/art/ui/panel_paper.png"
const BUTTONS_PATH: String = "res://assets/art/ui/buttons.png"
const HUD_ICONS_PATH: String = "res://assets/art/ui/hud_icons.png"
const SLOTS_PATH: String = "res://assets/art/ui/slots.png"
const SLOT_CELL: int = 64
## Số thứ tự ô trong ui/slots.png.
const SLOT_NORMAL: int = 0
const SLOT_HOVER: int = 1
const SLOT_SELECTED: int = 2
const SLOT_LOCKED: int = 3
const SLOT_HOTBAR: int = 4
const SLOT_HOTBAR_SELECTED: int = 5
const HUD_ICON_CELL: int = 32
const HUD_ICON_COLUMNS: int = 4
## Chiều cao mỗi trạng thái trong sheet nút; chiều rộng lấy từ ảnh.
const BUTTON_STATE_HEIGHT: int = 20

const INK := Color("#2A1F1A")
const INK_SOFT := Color("#4E3320")
const PAPER_LIGHT := Color("#FFF8E7")
const ACCENT_RED := Color("#B5472F")

const SUCCESS_GREEN := Color("#2F5D34")

static var _theme: Theme


## Màu chữ của thông báo trên nền giấy theo loại: &"success" xanh lá đậm, &"error" đỏ,
## còn lại (&"info") nâu đậm.
static func notice_color(kind: StringName) -> Color:
	match kind:
		&"success":
			return SUCCESS_GREEN
		&"error":
			return ACCENT_RED
	return INK


## Theme dùng chung (tạo một lần).
static func get_theme() -> Theme:
	if _theme == null:
		_theme = _build()
	return _theme


## Texture của icon HUD.
static func hud_icon(icon: HudIcon) -> Texture2D:
	var atlas := AtlasTexture.new()
	atlas.atlas = load(HUD_ICONS_PATH)
	atlas.region = Rect2((icon % HUD_ICON_COLUMNS) * HUD_ICON_CELL, (icon / HUD_ICON_COLUMNS) * HUD_ICON_CELL, HUD_ICON_CELL, HUD_ICON_CELL)
	return atlas


## Icon mùa ứng với giá trị TimeManager.Season (0 Xuân, 1 Hạ, 2 Thu, 3 Đông).
static func season_icon(season: int) -> Texture2D:
	return hud_icon(([HudIcon.SPRING, HudIcon.SUMMER, HudIcon.AUTUMN, HudIcon.WINTER] as Array)[clampi(season, 0, 3)])


## Khung giấy gọn cho HUD trên nền game: viền 24px giữ nguyên, lề nội dung nhỏ để bảng thấp.
static func hud_panel_style() -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = load(PANEL_PATH)
	style.set_texture_margin_all(24)
	style.content_margin_left = 22
	style.content_margin_right = 22
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style


## Khung ô kho từ ui/slots.png (lưới 4x2, ô 64x64). [param cell] là số thứ tự ô trong sheet:
## 0 thường, 1 trỏ chuột, 2 đang chọn, 3 khoá, 4 thanh nhanh, 5 thanh nhanh đang chọn.
static func slot_style(cell: int) -> StyleBoxTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = load(SLOTS_PATH)
	# Khung vẽ nhỏ hơn ô 64x64 (có viền trong suốt): cắt sát phần có hình để khung lấp đầy ô giao diện.
	var cell_rect := Rect2i((cell % 4) * SLOT_CELL, (cell / 4) * SLOT_CELL, SLOT_CELL, SLOT_CELL)
	var used: Rect2i = atlas.atlas.get_image().get_region(cell_rect).get_used_rect()
	atlas.region = Rect2(cell_rect.position + used.position, used.size)
	var style := StyleBoxTexture.new()
	style.texture = atlas
	style.set_texture_margin_all(14)
	style.set_content_margin_all(6)
	return style


static func _build() -> Theme:
	var theme := Theme.new()

	# Khung giấy: góc 24px giữ nguyên (chứa cả những chấm nhỏ ở góc), cạnh và giữa co giãn.
	var panel := StyleBoxTexture.new()
	panel.texture = load(PANEL_PATH)
	panel.set_texture_margin_all(24)
	panel.set_content_margin_all(14)
	theme.set_stylebox("panel", "PanelContainer", panel)
	theme.set_stylebox("panel", "Panel", panel)

	# Nút: ba hàng trong sheet là bình thường, di chuột, nhấn.
	var normal := _button_style(0)
	var hover := _button_style(1)
	var pressed := _button_style(2)
	var disabled := _button_style(0)
	disabled.modulate_color = Color(1, 1, 1, 0.55)
	theme.set_stylebox("normal", "Button", normal)
	theme.set_stylebox("hover", "Button", hover)
	theme.set_stylebox("pressed", "Button", pressed)
	theme.set_stylebox("disabled", "Button", disabled)
	theme.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	theme.set_color("font_color", "Button", INK)
	theme.set_color("font_hover_color", "Button", INK)
	theme.set_color("font_pressed_color", "Button", PAPER_LIGHT)
	theme.set_color("font_focus_color", "Button", INK)
	theme.set_color("font_disabled_color", "Button", INK_SOFT)

	# Chữ trên giấy.
	theme.set_color("font_color", "Label", INK)

	# Thẻ (tab): thẻ chọn dùng kiểu "di chuột" sáng hơn, nội dung thẻ là một dải giấy sẫm nhẹ.
	theme.set_stylebox("tab_selected", "TabContainer", _button_style(1))
	theme.set_stylebox("tab_unselected", "TabContainer", _button_style(0))
	theme.set_stylebox("tab_hovered", "TabContainer", _button_style(1))
	theme.set_stylebox("tab_disabled", "TabContainer", _button_style(0))
	var tab_panel := StyleBoxFlat.new()
	tab_panel.bg_color = Color(0.65, 0.49, 0.32, 0.22)
	tab_panel.set_corner_radius_all(4)
	tab_panel.set_content_margin_all(6)
	theme.set_stylebox("panel", "TabContainer", tab_panel)
	theme.set_font_size("font_size", "TabContainer", 16)
	theme.set_color("font_selected_color", "TabContainer", INK)
	theme.set_color("font_unselected_color", "TabContainer", INK_SOFT)
	theme.set_color("font_hovered_color", "TabContainer", INK)
	return theme


static func _button_style(state_row: int) -> StyleBoxTexture:
	var sheet: Texture2D = load(BUTTONS_PATH)
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	atlas.region = Rect2(0, state_row * BUTTON_STATE_HEIGHT, sheet.get_width(), BUTTON_STATE_HEIGHT)
	var style := StyleBoxTexture.new()
	style.texture = atlas
	style.texture_margin_left = 8
	style.texture_margin_right = 8
	style.texture_margin_top = 6
	style.texture_margin_bottom = 6
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	return style
