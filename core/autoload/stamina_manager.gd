extends Node
## StaminaManager (Autoload): thể lực của người chơi.
##
## - Việc đồng áng ở sân nhà tốn sức ([method spend], mức tốn ở [constant COSTS]); hết sức thì không làm được nữa.
## - Ăn đồ có [member ItemData.energy] thì hồi sức ([method restore]); ngủ trên giường hồi đầy.
## - Thức quá nửa đêm (ngày tự kết thúc, không ngủ giường) thì sáng hôm sau chỉ hồi tới [constant TIRED_RATIO] thể lực tối đa.
## - Mọi thay đổi phát EventBus.stamina_changed để HUD cập nhật. Lưu cùng ván chơi qua SaveManager.

const MAX_STAMINA: int = 100
## Không ngủ giường thì sáng hôm sau thể lực chỉ được nâng lên tới phần này của tối đa (đang cao hơn thì giữ nguyên).
const TIRED_RATIO: float = 0.5
## Sức tốn cho mỗi ô khi dùng công cụ (tên trùng FarmToolController.Tool).
const COSTS: Dictionary = {&"hoe": 3, &"seed": 1, &"water": 1, &"harvest": 1, &"fertilize": 1}

var stamina: int = MAX_STAMINA
## Đêm nay đã lên giường ngủ (đặt bởi giường, dùng khi sang ngày mới).
var _slept_in_bed: bool = false


func _ready() -> void:
	EventBus.day_changed.connect(_on_day_changed)


func get_cost(action: StringName) -> int:
	return int(COSTS.get(action, 0))


func can_spend(amount: int) -> bool:
	return amount <= stamina


## Trừ [param amount] thể lực. Trả về false (không đổi gì) nếu không đủ.
func spend(amount: int) -> bool:
	if amount <= 0:
		return true
	if not can_spend(amount):
		return false
	_apply(stamina - amount)
	return true


## Hồi [param amount] thể lực (không vượt quá tối đa). Trả về số thực sự hồi được.
func restore(amount: int) -> int:
	var before: int = stamina
	_apply(stamina + maxi(amount, 0))
	return stamina - before


func is_full() -> bool:
	return stamina >= MAX_STAMINA


## Giường gọi trước khi sang ngày: sáng mai dậy đầy sức.
func go_to_bed() -> void:
	_slept_in_bed = true


## Đặt lại đầy sức (ván mới).
func reset() -> void:
	_slept_in_bed = false
	_apply(MAX_STAMINA)


func get_save_data() -> Dictionary:
	return {"stamina": stamina}


## Bản lưu cũ chưa có mục này thì coi như đầy sức.
func load_save_data(data: Dictionary) -> void:
	_slept_in_bed = false
	_last_day = TimeManager.day
	_apply(int(data.get("stamina", MAX_STAMINA)))


var _last_day: int = 1


func _on_day_changed(day: int) -> void:
	# day_changed cũng được phát lại khi nạp game (cùng ngày): chỉ hồi sức khi thật sự sang ngày mới.
	if day <= _last_day:
		_last_day = day
		return
	_last_day = day
	_apply(MAX_STAMINA if _slept_in_bed else maxi(stamina, int(MAX_STAMINA * TIRED_RATIO)))
	_slept_in_bed = false


func _apply(value: int) -> void:
	var clamped: int = clampi(value, 0, MAX_STAMINA)
	if clamped == stamina:
		EventBus.stamina_changed.emit(stamina, MAX_STAMINA)
		return
	stamina = clamped
	EventBus.stamina_changed.emit(stamina, MAX_STAMINA)
