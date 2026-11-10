extends Node
## AudioManager (Autoload): phát hiệu ứng âm thanh. Nghe EventBus (cùng cách HUD, ShopUI hoạt động), nên
## hệ thống khác không cần biết âm thanh tồn tại: nhặt đồ, cuốc đất, mua bán, sang ngày... tự có tiếng.
##
## - Âm thanh sinh bằng mã ([SfxSynth]); thả file assets/audio/sfx/<id>.wav hoặc .ogg để thay thế.
## - Mọi nút bấm (BaseButton) tự có tiếng click nhờ lắng nghe node_added.
## - Phím M bật/tắt tiếng. Khi chạy bài test (-s) tiếng bị tắt ở loa nhưng vẫn đếm lượt phát.

const BUS_NAME: StringName = &"SFX"
## Mức gốc (dB) của bus hiệu ứng và bus nhạc; âm lượng người chơi chọn cộng vào đây.
const SFX_BASE_DB: float = -4.0
const MUSIC_BASE_DB: float = -14.0
const SETTINGS_PATH: String = "user://settings.cfg"
const TEST_SETTINGS_PATH: String = "user://settings_test.cfg"
const SFX_DIR: String = "res://assets/audio/sfx/"
const VOICES: int = 8
## Một âm phát lại trong khoảng này (ms) thì bỏ qua, để không chồng chéo khi sự kiện dồn dập.
const MIN_REPEAT_MSEC: int = 40
## Thông báo (notice) chỉ có tiếng riêng nếu không có âm nào vừa phát trong khoảng này (ms).
const NOTICE_QUIET_MSEC: int = 200

## Tắt tiếng do người chơi (phím M).
var muted: bool = false
## Âm lượng hiệu ứng và nhạc nền người chơi chọn (0-1).
var sfx_volume: float = 1.0
var music_volume: float = 1.0
## File lưu cài đặt (khi chạy test đổi sang file riêng).
var settings_path: String = SETTINGS_PATH
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
	if _silent_speakers:
		settings_path = TEST_SETTINGS_PATH  # test không đọc/ghi cài đặt thật của người chơi
	else:
		load_settings()
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
	apply_bus_mute()
	if muted:
		for voice: AudioStreamPlayer in _voices:
			voice.stop()
	save_settings()


## Âm lượng hiệu ứng (0-1) và nhạc nền (0-1); lưu lại ngay.
func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	apply_bus_volumes()
	save_settings()


func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	apply_bus_volumes()
	save_settings()


## Đặt âm lượng hai bus theo mức người chơi chọn (tuyến tính 0-1 đổi sang dB trên mức gốc của bus).
func apply_bus_volumes() -> void:
	var levels: Dictionary = {BUS_NAME: [SFX_BASE_DB, sfx_volume], &"Music": [MUSIC_BASE_DB, music_volume]}
	for bus_name: StringName in levels:
		var index: int = AudioServer.get_bus_index(bus_name)
		if index != -1:
			var base: float = levels[bus_name][0]
			var volume: float = levels[bus_name][1]
			AudioServer.set_bus_volume_db(index, base + (linear_to_db(volume) if volume > 0.001 else -80.0))


## Lưu cài đặt âm thanh (tắt tiếng, âm lượng) vào [member settings_path].
func save_settings() -> Error:
	var config := ConfigFile.new()
	config.set_value("audio", "muted", muted)
	config.set_value("audio", "sfx", sfx_volume)
	config.set_value("audio", "music", music_volume)
	return config.save(settings_path)


## Nạp cài đặt đã lưu (thiếu hoặc hỏng thì giữ mặc định). Trả về true nếu có nạp được.
func load_settings() -> bool:
	var config := ConfigFile.new()
	if config.load(settings_path) != OK:
		return false
	muted = bool(config.get_value("audio", "muted", false))
	sfx_volume = clampf(float(config.get_value("audio", "sfx", 1.0)), 0.0, 1.0)
	music_volume = clampf(float(config.get_value("audio", "music", 1.0)), 0.0, 1.0)
	return true


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
	EventBus.sfx_requested.connect(func(id: StringName) -> void: play(id))


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
	apply_bus_volumes()
	apply_bus_mute()


## Áp trạng thái tắt tiếng (do người chơi hoặc khi chạy test) lên bus hiệu ứng và bus nhạc nền.
func apply_bus_mute() -> void:
	for bus_name: StringName in [BUS_NAME, &"Music"]:
		var index: int = AudioServer.get_bus_index(bus_name)
		if index != -1:
			AudioServer.set_bus_mute(index, muted or _silent_speakers)
