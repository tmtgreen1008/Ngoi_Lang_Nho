extends Node
## MusicManager (Autoload): nhạc nền theo mùa và theo tình huống, chuyển bản bằng cách mờ dần chéo.
##
## - Mỗi mùa một bản (spring, summer, autumn, winter); đang chơi mini-game thì bản "minigame".
## - Bản nhạc sinh bằng mã ([MusicSynth], dựng lần đầu khi cần rồi lưu đệm); thả file
##   assets/audio/music/<id>.ogg|mp3|wav để thay bằng nhạc thật (tự lặp).
## - Nghe EventBus (season_changed, minigame_started/finished, scene_changed), không ai gọi trực tiếp.
## - Tắt tiếng (phím M) do AudioManager lo; khi chạy test (-s) nhạc không ra loa nhưng vẫn "phát".

const BUS_NAME: StringName = &"Music"
const MUSIC_DIR: String = "res://assets/audio/music/"
const FADE_SECONDS: float = 1.5
const SILENT_DB: float = -60.0

## Bản nhạc đang được yêu cầu (có thể chưa bắt đầu nếu đang mờ dần).
var current_track: StringName = &""
## Số lần đổi bản (để kiểm thử).
var switch_count: int = 0

var _streams: Dictionary = {}  # id -> AudioStream
var _players: Array[AudioStreamPlayer] = []
var _active: int = 0
var _tween: Tween
var _in_minigame: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # Nhạc vẫn chạy khi menu tạm dừng mở.
	_ensure_bus()
	for i: int in 2:
		var player := AudioStreamPlayer.new()
		player.bus = BUS_NAME
		player.volume_db = SILENT_DB
		add_child(player)
		_players.append(player)
	EventBus.season_changed.connect(func(season: int, _year: int) -> void: _refresh(season))
	EventBus.scene_changed.connect(func(_path: String) -> void: _refresh(TimeManager.season))
	EventBus.minigame_started.connect(func(_id: StringName) -> void:
		_in_minigame = true
		_refresh(TimeManager.season))
	EventBus.minigame_finished.connect(func(_id: StringName, _result: Dictionary) -> void:
		_in_minigame = false
		_refresh(TimeManager.season))
	_refresh(TimeManager.season)


## Tên bản nhạc ứng với tình huống hiện tại.
func track_for(season: int) -> StringName:
	if _in_minigame:
		return &"minigame"
	return [&"spring", &"summer", &"autumn", &"winter"][clampi(season, 0, 3)]


## Chuyển sang bản nhạc [param id] (mờ dần chéo). Bỏ qua nếu đang là bản đó hoặc không có bản đó.
func play_track(id: StringName) -> bool:
	if id == current_track:
		return false
	var stream: AudioStream = _get_stream(id)
	if stream == null:
		return false
	current_track = id
	switch_count += 1
	var old_player: AudioStreamPlayer = _players[_active]
	_active = 1 - _active
	var player: AudioStreamPlayer = _players[_active]
	player.stream = stream
	player.volume_db = SILENT_DB
	player.play()
	if _tween != null:
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(player, "volume_db", 0.0, FADE_SECONDS)
	if old_player.playing:
		_tween.tween_property(old_player, "volume_db", SILENT_DB, FADE_SECONDS)
		_tween.chain().tween_callback(old_player.stop)
	return true


## Bản nhạc có đang phát (ở một trong hai bộ phát) không.
func is_playing() -> bool:
	return _players[0].playing or _players[1].playing


func _refresh(season: int) -> void:
	play_track(track_for(season))


## Lấy (hoặc dựng và lưu đệm) bản nhạc [param id]; ưu tiên file trong assets/audio/music/.
func _get_stream(id: StringName) -> AudioStream:
	if _streams.has(id):
		return _streams[id]
	var stream: AudioStream = null
	for extension: String in ["ogg", "mp3", "wav"]:
		var path: String = "%s%s.%s" % [MUSIC_DIR, id, extension]
		if ResourceLoader.exists(path):
			stream = load(path) as AudioStream
			if stream is AudioStreamOggVorbis:
				(stream as AudioStreamOggVorbis).loop = true
			elif stream is AudioStreamMP3:
				(stream as AudioStreamMP3).loop = true
			elif stream is AudioStreamWAV:
				(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
			break
	if stream == null:
		stream = MusicSynth.build(id)
	_streams[id] = stream
	return stream


func _ensure_bus() -> void:
	if AudioServer.get_bus_index(BUS_NAME) == -1:
		AudioServer.add_bus()
		var index: int = AudioServer.bus_count - 1
		AudioServer.set_bus_name(index, BUS_NAME)
		AudioServer.set_bus_send(index, &"Master")
	AudioManager.apply_bus_volumes()
	AudioManager.apply_bus_mute()
