extends Node
## AudioManager (Autoload): phát hiệu ứng âm thanh. Nghe EventBus (cùng cách HUD, ShopUI hoạt động), nên
## hệ thống khác không cần biết âm thanh tồn tại: nhặt đồ, cuốc đất, mua bán, sang ngày... tự có tiếng.
##
## - Âm thanh sinh bằng mã ([SfxSynth]); thả file assets/audio/sfx/<id>.wav hoặc .ogg để thay thế.
## - Mọi nút bấm (BaseButton) tự có tiếng click nhờ lắng nghe node_added.
## - Phím M bật/tắt tiếng. Khi chạy bài test (-s) tiếng bị tắt ở loa nhưng vẫn đếm lượt phát.

const BUS_NAME: StringName = &"SFX"
const SFX_DIR: String = "res://assets/audio/sfx/"
const VOICES: int = 8
## Một âm phát lại trong khoảng này (ms) thì bỏ qua, để không chồng chéo khi sự kiện dồn dập.
const MIN_REPEAT_MSEC: int = 40
## Thông báo (notice) chỉ có tiếng riêng nếu không có âm nào vừa phát trong khoảng này (ms).
const NOTICE_QUIET_MSEC: int = 200

## Tắt tiếng do người chơi (phím M).
var muted: bool = false
## Số lượt phát từng âm kể từ lúc khởi động (id -> số lần); dùng cho kiểm thử.
var play_counts: Dictionary = {}
var last_played: StringName = &""

var _streams: Dictionary = {}  # id -> AudioStream
var _voices: Array[AudioStreamPlayer] = []
var _next_voice: int = 0
var _last_msec: Dictionary = {}  # id -> thời điểm phát gần nhất
var _last_any_msec: int = -100000
var _last_day: int = 1
var _rng := RandomNumberGenerator.new()
var _silent_speakers: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # Vẫn có tiếng khi menu tạm dừng mở.
	_rng.randomize()
	# Chạy test (godot -s ...): không phát ra loa, chỉ đếm.
	_silent_speakers = OS.get_cmdline_args().has("-s") or OS.get_cmdline_args().has("--script")
	_ensure_bus()
	for id: StringName in SfxSynth.SOUND_IDS:
		_streams[id] = _load_stream(id)
	for i: int in VOICES:
		var voice := AudioStreamPlayer.new()
		voice.bus = BUS_NAME
		add_child(voice)
		_voices.append(voice)
	_last_day = TimeManager.day
	_connect_events()
	get_tree().node_added.connect(_on_node_added)


## Có đủ công thức/âm thanh cho [param id] không.
func has_sound(id: StringName) -> bool:
	return _streams.get(id) != null


## Phát âm [param id]. [param pitch_spread] > 0 thì đổi cao độ ngẫu nhiên quanh 1.0 (± giá trị này).
## Trả về true nếu thực sự phát (không bị tắt tiếng, không phát lặp quá sát).
func play(id: StringName, volume_db: float = 0.0, pitch_spread: float = 0.0) -> bool:
	var stream: AudioStream = _streams.get(id)
	if stream == null or muted:
		return false
	var now: int = Time.get_ticks_msec()
	if now - int(_last_msec.get(id, -100000)) < MIN_REPEAT_MSEC:
		return false
	_last_msec[id] = now
	_last_any_msec = now
	play_counts[id] = int(play_counts.get(id, 0)) + 1
	last_played = id
	var voice: AudioStreamPlayer = _voices[_next_voice]
	_next_voice = (_next_voice + 1) % VOICES
	voice.stream = stream
	voice.volume_db = volume_db
	voice.pitch_scale = 1.0 + _rng.randf_range(-pitch_spread, pitch_spread)
	voice.play()
	return true


## Bật/tắt tiếng.
func set_muted(value: bool) -> void:
	muted = value
	_apply_bus_mute()
	if muted:
		for voice: AudioStreamPlayer in _voices:
			voice.stop()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_M:
		set_muted(not muted)
		EventBus.notice_requested.emit("Âm thanh: %s" % ("TẮT" if muted else "BẬT"), &"info")
		get_viewport().set_input_as_handled()


# --- Nối sự kiện ---------------------------------------------------------------------------


func _connect_events() -> void:
	EventBus.player_stepped.connect(func() -> void: play(&"step", -8.0, 0.12))
	EventBus.item_picked.connect(func(_item: ItemData, _amount: int) -> void: play(&"pickup", -2.0, 0.05))
	EventBus.transaction_completed.connect(func(_item: ItemData, _amount: int, _total: int, is_buying: bool) -> void: play(&"coin" if is_buying else &"sell"))
	EventBus.tile_tilled.connect(func(_cell: Vector2i) -> void: play(&"dig", 0.0, 0.08))
	EventBus.crop_planted.connect(func(_cell: Vector2i, _crop: CropItemData) -> void: play(&"plant", 0.0, 0.08))
	EventBus.crop_harvested.connect(func(_cell: Vector2i, _crop: CropItemData) -> void: play(&"harvest"))
	EventBus.crop_withered.connect(func(_cell: Vector2i, _crop: CropItemData) -> void: play(&"wither", -6.0))
	EventBus.animal_fed.connect(func(_id: StringName) -> void: play(&"feed", 0.0, 0.1))
	EventBus.shop_opened.connect(func(_vendor: Resource) -> void: play(&"bell"))
	EventBus.shop_closed.connect(func(_vendor: Resource) -> void: play(&"shop_close", -4.0))
	EventBus.day_changed.connect(_on_day_changed)
	EventBus.season_changed.connect(func(_season: int, _year: int) -> void: play(&"season"))
	EventBus.interaction_started.connect(func(_target: Node) -> void: play(&"tick"))
	EventBus.scene_change_requested.connect(func(_path: String, _spawn: StringName) -> void: play(&"whoosh", -6.0))
	EventBus.minigame_started.connect(func(_id: StringName) -> void: play(&"minigame_start"))
	EventBus.minigame_finished.connect(_on_minigame_finished)
	EventBus.game_saved.connect(func() -> void: play(&"save"))
	EventBus.game_loaded.connect(func() -> void: play(&"save"))
	EventBus.notice_requested.connect(_on_notice)


func _on_day_changed(day: int) -> void:
	# day_changed cũng được phát lại khi nạp game (cùng ngày); chỉ có tiếng khi thật sự sang ngày mới.
	if day > _last_day:
		play(&"day", -2.0)
	_last_day = day


func _on_minigame_finished(_id: StringName, result: Dictionary) -> void:
	play(&"win" if int(result.get("money", 0)) > 0 else &"lose")


func _on_notice(_text: String, kind: StringName) -> void:
	if Time.get_ticks_msec() - _last_any_msec < NOTICE_QUIET_MSEC:
		return  # Việc vừa làm đã có tiếng riêng (vd. cho ăn, thu hoạch).
	if kind == &"error":
		play(&"error")
	elif kind == &"success":
		play(&"success")


func _on_node_added(node: Node) -> void:
	if node is BaseButton and not (node as BaseButton).pressed.is_connected(_on_button_pressed):
		(node as BaseButton).pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	play(&"click", -4.0)


# --- Nội bộ --------------------------------------------------------------------------------


func _load_stream(id: StringName) -> AudioStream:
	for extension: String in ["ogg", "wav"]:
		var path: String = "%s%s.%s" % [SFX_DIR, id, extension]
		if ResourceLoader.exists(path):
			return load(path) as AudioStream
	return SfxSynth.build(id)


## Tạo bus "SFX" (nối vào Master) nếu chưa có; mọi voice phát qua bus này.
func _ensure_bus() -> void:
	if AudioServer.get_bus_index(BUS_NAME) == -1:
		AudioServer.add_bus()
		var index: int = AudioServer.bus_count - 1
		AudioServer.set_bus_name(index, BUS_NAME)
		AudioServer.set_bus_send(index, &"Master")
		AudioServer.set_bus_volume_db(index, -4.0)
	_apply_bus_mute()


func _apply_bus_mute() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index(BUS_NAME), muted or _silent_speakers)
