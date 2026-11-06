extends Node
## EconomyManager (Autoload): tiền của người chơi.
##
## Mọi thay đổi tiền đi qua [method spend] / [method earn] để EventBus.money_changed
## luôn được phát và HUD/ShopUI tự cập nhật.

## Số tiền ban đầu của ván mới.
@export_range(0, 1000000, 1) var starting_money: int = 100

var money: int = 0


func _ready() -> void:
	money = starting_money


func can_afford(amount: int) -> bool:
	return amount >= 0 and money >= amount


## Trừ [param amount] đồng. Trả về false (và không đổi gì) nếu không đủ tiền.
func spend(amount: int) -> bool:
	if amount < 0 or not can_afford(amount):
		return false
	_change(-amount)
	return true


## Cộng [param amount] đồng.
func earn(amount: int) -> void:
	if amount > 0:
		_change(amount)


func get_save_data() -> Dictionary:
	return {"money": money}


func load_save_data(data: Dictionary) -> void:
	var old: int = money
	money = maxi(0, int(data.get("money", starting_money)))
	EventBus.money_changed.emit(money, money - old)


func _change(delta: int) -> void:
	money += delta
	EventBus.money_changed.emit(money, delta)
