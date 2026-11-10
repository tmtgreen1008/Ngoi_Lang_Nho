class_name OAnQuanGame
extends MinigameBase
## Mini-game Ô ăn quan: người chơi (hàng dưới) đấu với máy (hàng trên). Luật nằm ở [OAnQuanBoard]; file này lo
## giao diện: vẽ bàn và quân, nút chọn chiều rải ở từng ô của người chơi, lượt của máy (chờ một nhịp rồi đi).
##
## Thắng được [member win_payout] đồng, hoà được hoàn phí, thua không được gì.

@export_range(0, 1000, 1) var win_payout: int = 30
## Số giây máy "suy nghĩ" trước khi đi.
@export_range(0.0, 3.0, 0.1) var ai_delay: float = 0.8

const BOARD_TEXTURE: Texture2D = preload("res://assets/art/minigames/o_an_quan_board.png")
const PIECES_TEXTURE: Texture2D = preload("res://assets/art/minigames/o_an_quan_pieces.png")
## Bàn vẽ phóng 3 lần (ảnh 222x111, mỗi pixel ảnh ứng với 8 pixel ảnh gốc).
const BOARD_SCALE: float = 3.0
const SOURCE_PX: float = 8.0
const PIECE_CELL: int = 32
## Khung trong sheet quân: dân trắng, dân xanh, quan.
enum Piece { WHITE, BLUE, QUAN }
## Tâm các cột ô dân và hai ô quan trong ảnh gốc (pixel ảnh gốc 1774x887).
const COLUMN_X: Array[float] = [462.0, 675.0, 888.0, 1100.0, 1312.0]
const ROW_Y_TOP: float = 322.0
const ROW_Y_BOTTOM: float = 542.0
const QUAN_LEFT := Vector2(235.0, 432.0)
const QUAN_RIGHT := Vector2(1540.0, 432.0)
## Số quân dân vẽ tối đa trong một ô (nhiều hơn thì chỉ hiện con số).
const MAX_DRAWN: int = 9

var board := OAnQuanBoard.new()
var is_playing: bool = false
## Bộ sinh số ngẫu nhiên của máy (kiểm thử đặt seed cố định).
var rng := RandomNumberGenerator.new()

var _board_view: Control
var _status_label: Label
var _score_label: Label
var _start_button: Button
var _move_buttons: Dictionary = {}  # [ô, chiều] -> Button
var _ai_timer: Timer


func _init() -> void:
	minigame_id = &"o_an_quan"
	title = "Chiếu Ô ăn quan"
	entry_fee = 10
	minutes_cost = 60


func _setup() -> void:
	rng.randomize()
	_score_label = Label.new()
	_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_score_label.add_theme_font_size_override("font_size", 18)
	content.add_child(_score_label)

	var holder := CenterContainer.new()
	holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(holder)
	_board_view = Control.new()
	_board_view.custom_minimum_size = Vector2(BOARD_TEXTURE.get_size()) * BOARD_SCALE
	_board_view.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_board_view.draw.connect(_draw_board)
	holder.add_child(_board_view)
	# Hai nút chọn chiều rải (trái / phải) ở mỗi ô của người chơi.
	for square: int in OAnQuanBoard.row_of(OAnQuanBoard.PLAYER):
		for direction: int in [-1, 1]:
			var button := Button.new()
			button.text = "◀" if direction < 0 else "▶"
			button.focus_mode = Control.FOCUS_NONE
			button.custom_minimum_size = Vector2(30, 24)
			button.size = Vector2(30, 24)
			button.add_theme_font_size_override("font_size", 13)
			button.position = square_center(square) + Vector2(-32.0 if direction < 0 else 2.0, 12.0)
			button.tooltip_text = "Rải quân ô này sang %s" % ("trái" if direction < 0 else "phải")
			button.pressed.connect(play_player_move.bind(square, direction))
			_board_view.add_child(button)
			_move_buttons[[square, direction]] = button

	_status_label = Label.new()
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status_label.custom_minimum_size = Vector2(0, 48)
	content.add_child(_status_label)
	_start_button = Button.new()
	_start_button.text = "Bắt đầu"
	_start_button.pressed.connect(_on_start_pressed)
	content.add_child(_start_button)

	_ai_timer = Timer.new()
	_ai_timer.one_shot = true
	_ai_timer.timeout.connect(play_ai_move)
	add_child(_ai_timer)
	_status_label.text = "Hàng dưới là của bạn. Chọn một ô rồi bấm ◀ hoặc ▶ để rải quân; rải xong gặp ô trống thì ăn ô kế sau nó. Quan đáng %d điểm." % OAnQuanBoard.QUAN_VALUE
	_refresh()


## Tâm của ô [param square] trên bàn vẽ (toạ độ trong _board_view).
static func square_center(square: int) -> Vector2:
	var source: Vector2
	if square == 0:
		source = QUAN_LEFT
	elif square == 6:
		source = QUAN_RIGHT
	elif square <= 5:
		source = Vector2(COLUMN_X[square - 1], ROW_Y_BOTTOM)
	else:
		source = Vector2(COLUMN_X[11 - square], ROW_Y_TOP)
	return source / SOURCE_PX * BOARD_SCALE


func start_round() -> void:
	board.reset()
	is_playing = true
	mark_played()
	_start_button.disabled = true
	_status_label.text = "Lượt của bạn."
	_refresh()


## Người chơi rải ô [param square] theo [param direction]. Trả về true nếu nước đi hợp lệ.
func play_player_move(square: int, direction: int) -> bool:
	if not is_playing or board.over or board.current != OAnQuanBoard.PLAYER:
		return false
	var result: Dictionary = board.play(square, direction)
	if not result["ok"]:
		return false
	EventBus.sfx_requested.emit(&"stone")
	_status_label.text = "Bạn rải %d quân%s." % [result["sown"], _capture_text(result)]
	_after_move()
	return true


## Máy đi một nước (gọi sau khi chờ [member ai_delay], hoặc trực tiếp trong kiểm thử).
func play_ai_move() -> bool:
	if not is_playing or board.over or board.current != OAnQuanBoard.AI:
		return false
	var move: Array = board.choose_move(rng)
	if move.is_empty():
		return false
	var result: Dictionary = board.play(int(move[0]), int(move[1]))
	EventBus.sfx_requested.emit(&"stone")
	_status_label.text = "Máy rải %d quân%s. Lượt của bạn." % [result["sown"], _capture_text(result)]
	_after_move()
	return true


## Tiền thưởng theo kết quả ván: thắng [member win_payout], hoà hoàn phí, thua 0.
func get_payout() -> int:
	if not board.over:
		return 0
	match board.winner():
		OAnQuanBoard.PLAYER:
			return win_payout
		-1:
			return entry_fee
	return 0


func quit() -> void:
	is_playing = false
	_ai_timer.stop()
	super.quit()


func _capture_text(result: Dictionary) -> String:
	return ", ăn được %d điểm" % int(result["captured"]) if int(result["captured"]) > 0 else ""


## Sau mỗi nước: rải lại nếu hàng của người đến lượt trống, kết thúc ván nếu hết quan, hoặc chuyển lượt.
func _after_move() -> void:
	if not board.over and board.refill_if_needed():
		_status_label.text += " %s hết quân ở hàng mình nên lấy 5 điểm rải lại." % ("Bạn" if board.current == OAnQuanBoard.PLAYER else "Máy")
	_refresh()
	if board.over:
		_end_round()
	elif board.current == OAnQuanBoard.AI:
		if ai_delay > 0.0:
			_ai_timer.start(ai_delay)
		else:
			play_ai_move()


func _end_round() -> void:
	is_playing = false
	var outcome: String = "Hoà"
	match board.winner():
		OAnQuanBoard.PLAYER:
			outcome = "Bạn thắng"
		OAnQuanBoard.AI:
			outcome = "Máy thắng"
	_status_label.text = "Hết quan, tàn dân! %s: %d - %d. Thưởng %d đ." % [outcome, board.scores[OAnQuanBoard.PLAYER], board.scores[OAnQuanBoard.AI], get_payout()]
	_start_button.text = "Nhận kết quả"
	_start_button.disabled = false


func _on_start_pressed() -> void:
	if board.over and played:
		finish(get_payout(), {"player": board.scores[OAnQuanBoard.PLAYER], "ai": board.scores[OAnQuanBoard.AI]})
	else:
		start_round()


func _refresh() -> void:
	_score_label.text = "Bạn: %d điểm   |   Máy: %d điểm" % [board.scores[OAnQuanBoard.PLAYER], board.scores[OAnQuanBoard.AI]]
	var players_turn: bool = is_playing and not board.over and board.current == OAnQuanBoard.PLAYER
	for key: Array in _move_buttons:
		var button: Button = _move_buttons[key]
		button.disabled = not players_turn or board.stones[int(key[0])] <= 0
	_board_view.queue_redraw()


func _draw_board() -> void:
	_board_view.draw_texture_rect(BOARD_TEXTURE, Rect2(Vector2.ZERO, _board_view.custom_minimum_size), false)
	var font: Font = ThemeDB.fallback_font
	for square: int in OAnQuanBoard.SQUARES:
		var center: Vector2 = square_center(square)
		var is_quan_square: bool = OAnQuanBoard.QUAN_SQUARES.has(square)
		if board.has_quan(square):
			_draw_piece(Piece.QUAN, center + Vector2(0, -18))
		var count: int = board.stones[square]
		var shown: int = mini(count, MAX_DRAWN)
		for i: int in shown:
			# Xếp quân thành lưới 3 cột quanh tâm ô (ô quan thì dồn xuống dưới quan).
			var offset := Vector2((i % 3 - 1) * 15.0, (i / 3 - 1) * 12.0 - 14.0)
			if is_quan_square:
				offset.y += 34.0
			_draw_piece(Piece.BLUE if (i + square) % 3 == 0 else Piece.WHITE, center + offset)
		# Con số ở góc ô: ô của máy phía trên, ô của mình phía trên nút bấm.
		var label_pos: Vector2 = center + Vector2(20.0, -24.0)
		if is_quan_square:
			label_pos = center + Vector2(-8.0, 52.0)
		_board_view.draw_string_outline(font, label_pos, str(board.value_of(square)), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, 4, Color("#2A1F1A"))
		_board_view.draw_string(font, label_pos, str(board.value_of(square)), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color.WHITE)


func _draw_piece(piece: Piece, center: Vector2) -> void:
	# Bỏ 2 pixel mép hai bên ô ảnh để không dính pixel của quân bên cạnh trong sheet.
	var source := Rect2(piece * PIECE_CELL + 2, 0, PIECE_CELL - 4, PIECE_CELL)
	_board_view.draw_texture_rect_region(PIECES_TEXTURE, Rect2(center - Vector2(PIECE_CELL / 2.0 - 2.0, PIECE_CELL - 6.0), Vector2(PIECE_CELL - 4, PIECE_CELL)), source)
