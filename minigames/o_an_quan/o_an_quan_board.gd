class_name OAnQuanBoard
extends RefCounted
## Luật chơi Ô ăn quan (trò chơi dân gian), tách khỏi giao diện để kiểm thử được.
##
## Bàn có 12 ô đánh số vòng quanh: ô 0 là ô quan bên trái, ô 1-5 là hàng dưới (của người chơi, trái sang phải),
## ô 6 là ô quan bên phải, ô 7-11 là hàng trên (của máy, phải sang trái). Đi theo chiều +1 là 1→2→…→6→7→…→11→0.
## Ban đầu mỗi ô dân có [constant START_STONES] quân dân, mỗi ô quan có 1 quan (đáng [constant QUAN_VALUE] điểm).
##
## Một nước đi: bốc hết dân ở một ô của mình, rải lần lượt mỗi ô một quân theo chiều đã chọn. Rải xong:
## - ô kế tiếp có quân và là ô dân: bốc tiếp ô đó rải tiếp;
## - ô kế tiếp là ô quan còn quân: hết lượt;
## - ô kế tiếp trống: ăn hết quân ở ô sau nó (nếu có), rồi nếu lại gặp "ô trống, ô có quân" thì ăn tiếp; không thì hết lượt.
## Đầu lượt mà cả 5 ô của mình trống thì phải lấy 5 quân đã ăn rải lại mỗi ô một quân (không đủ thì ván kết thúc).
## Ván kết thúc khi cả hai ô quan đều trống ("hết quan, tàn dân, thu quân"): dân còn lại ở hàng nào về bên đó.

const SQUARES: int = 12
const QUAN_SQUARES: Array[int] = [0, 6]
const START_STONES: int = 5
const QUAN_VALUE: int = 10
const PLAYER: int = 0
const AI: int = 1
## Chặn vòng lặp vô hạn trong một nước đi (không xảy ra với luật trên, chỉ để an toàn).
const MAX_STEPS: int = 500
## Sau chừng này lượt mà chưa hết quan thì ván cũng kết thúc (tính điểm như bình thường).
const MAX_TURNS: int = 120

## Số quân dân ở từng ô (kể cả dân rơi vào ô quan).
var stones: PackedInt32Array = []
## Quan còn nằm ở ô quan trái (chỉ số 0) và phải (chỉ số 1) hay không.
var quan: Array[bool] = [true, true]
var scores: Array[int] = [0, 0]
var current: int = PLAYER
var turns: int = 0
var over: bool = false


func _init() -> void:
	reset()


func reset() -> void:
	stones.resize(SQUARES)
	for i: int in SQUARES:
		stones[i] = 0 if QUAN_SQUARES.has(i) else START_STONES
	quan = [true, true]
	scores = [0, 0]
	current = PLAYER
	turns = 0
	over = false


func clone() -> OAnQuanBoard:
	var copy := OAnQuanBoard.new()
	copy.stones = stones.duplicate()
	copy.quan = quan.duplicate()
	copy.scores = scores.duplicate()
	copy.current = current
	copy.turns = turns
	copy.over = over
	return copy


## Các ô dân của [param player] (theo thứ tự chỉ số).
static func row_of(player: int) -> Array[int]:
	return [1, 2, 3, 4, 5] if player == PLAYER else [7, 8, 9, 10, 11]


func has_quan(square: int) -> bool:
	return QUAN_SQUARES.has(square) and quan[QUAN_SQUARES.find(square)]


## Điểm đang nằm ở [param square] (dân + quan).
func value_of(square: int) -> int:
	return stones[square] + (QUAN_VALUE if has_quan(square) else 0)


func is_empty(square: int) -> bool:
	return value_of(square) == 0


## Tổng điểm trên bàn và đã ăn (luôn bằng 70 nếu luật đúng).
func total_points() -> int:
	var total: int = scores[0] + scores[1]
	for i: int in SQUARES:
		total += value_of(i)
	return total


## Các nước đi hợp lệ của [param player]: mảng [ô, chiều] với chiều là -1 hoặc +1.
func legal_moves(player: int) -> Array:
	var moves: Array = []
	if over:
		return moves
	for square: int in row_of(player):
		if stones[square] > 0:
			moves.append([square, -1])
			moves.append([square, 1])
	return moves


## Đầu lượt: nếu 5 ô của người đến lượt đều trống thì rải lại mỗi ô 1 quân từ điểm đã ăn. Không đủ 5 điểm thì
## ván kết thúc. Trả về true nếu đã rải lại.
func refill_if_needed() -> bool:
	if over:
		return false
	for square: int in row_of(current):
		if stones[square] > 0:
			return false
	if scores[current] < 5:
		_finish()
		return false
	scores[current] -= 5
	for square: int in row_of(current):
		stones[square] = 1
	return true


## Đi một nước: bốc ô [param square] của người đến lượt, rải theo [param direction] (-1 hoặc +1).
## Trả về {"ok": bool, "captured": điểm ăn được, "sown": số quân đã rải, "last": ô rải cuối}.
## Xong nước thì đổi lượt (hoặc kết thúc ván).
func play(square: int, direction: int) -> Dictionary:
	var result: Dictionary = {"ok": false, "captured": 0, "sown": 0, "last": square}
	if over or absi(direction) != 1 or not row_of(current).has(square) or stones[square] <= 0:
		return result
	result["ok"] = true
	var position: int = square
	var hand: int = stones[square]
	stones[square] = 0
	var steps: int = 0
	while steps < MAX_STEPS:
		steps += 1
		# Rải hết quân trên tay.
		while hand > 0:
			position = posmod(position + direction, SQUARES)
			stones[position] += 1
			hand -= 1
			result["sown"] = int(result["sown"]) + 1
		result["last"] = position
		var next: int = posmod(position + direction, SQUARES)
		if is_empty(next):
			# Ô trống: ăn ô sau nó, có thể ăn liên tiếp nhiều lần.
			var check: int = next
			while is_empty(check):
				var target: int = posmod(check + direction, SQUARES)
				if is_empty(target):
					break
				result["captured"] = int(result["captured"]) + _capture(target)
				check = posmod(target + direction, SQUARES)
			break
		if QUAN_SQUARES.has(next):
			break  # Gặp ô quan còn quân: hết lượt.
		# Ô dân có quân: bốc lên rải tiếp.
		hand = stones[next]
		stones[next] = 0
		position = next
	turns += 1
	if _both_quan_squares_empty() or turns >= MAX_TURNS:
		_finish()
	else:
		current = 1 - current
	return result


## Người thắng: PLAYER, AI, hoặc -1 nếu hoà (chỉ có nghĩa khi ván đã kết thúc).
func winner() -> int:
	if scores[PLAYER] == scores[AI]:
		return -1
	return PLAYER if scores[PLAYER] > scores[AI] else AI


## Nước đi máy chọn cho người đến lượt: nước ăn được nhiều điểm nhất; hoà thì bốc ngẫu nhiên bằng [param rng].
## Trả về [ô, chiều] hoặc [] nếu không có nước nào.
func choose_move(rng: RandomNumberGenerator) -> Array:
	var best: Array = []
	var best_score: int = -1
	for move: Array in legal_moves(current):
		var trial: OAnQuanBoard = clone()
		var mover: int = current
		var before: int = trial.scores[mover]
		trial.play(int(move[0]), int(move[1]))
		var gain: int = trial.scores[mover] - before
		if gain > best_score:
			best_score = gain
			best = [move]
		elif gain == best_score:
			best.append(move)
	if best.is_empty():
		return []
	return best[rng.randi_range(0, best.size() - 1)]


## Ăn hết quân ở [param square] cho người đang đi. Trả về số điểm ăn được.
func _capture(square: int) -> int:
	var gained: int = value_of(square)
	stones[square] = 0
	if QUAN_SQUARES.has(square):
		quan[QUAN_SQUARES.find(square)] = false
	scores[current] += gained
	return gained


func _both_quan_squares_empty() -> bool:
	return is_empty(QUAN_SQUARES[0]) and is_empty(QUAN_SQUARES[1])


## Kết thúc ván: dân còn ở hàng nào về bên đó. Nếu ván dừng vì hết số lượt mà ô quan còn quân thì phần đó chia đôi
## (lẻ thì người chơi nhận phần hơn), để tổng điểm vẫn đủ 70.
func _finish() -> void:
	for player: int in [PLAYER, AI]:
		for square: int in row_of(player):
			scores[player] += stones[square]
			stones[square] = 0
	var leftover: int = 0
	for square: int in QUAN_SQUARES:
		leftover += value_of(square)
		stones[square] = 0
	quan = [false, false]
	scores[AI] += leftover / 2
	scores[PLAYER] += leftover - leftover / 2
	over = true
