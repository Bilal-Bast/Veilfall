extends Node
## Room-aware regional soundtrack and ambience with short crossfades.

const MUSIC_STREAMS: Array[AudioStreamWAV] = [
	preload("res://assets/audio/music/whispering_woods.wav"),
	preload("res://assets/audio/music/lantern_refuge.wav"),
	preload("res://assets/audio/music/ashen_foundry.wav"),
	preload("res://assets/audio/music/drowned_crypt.wav"),
	preload("res://assets/audio/music/veil_citadel.wav"),
	preload("res://assets/audio/music/echo_depths.wav")
]
const AMBIENCE_STREAMS: Array[AudioStreamWAV] = [
	preload("res://assets/audio/ambience/whispering_woods.wav"),
	preload("res://assets/audio/ambience/lantern_refuge.wav"),
	preload("res://assets/audio/ambience/ashen_foundry.wav"),
	preload("res://assets/audio/ambience/drowned_crypt.wav"),
	preload("res://assets/audio/ambience/veil_citadel.wav"),
	preload("res://assets/audio/ambience/echo_depths.wav")
]

var _music_players: Array[AudioStreamPlayer] = []
var _ambience_players: Array[AudioStreamPlayer] = []
var _music_index := 0
var _ambience_index := 0
var _current_region := -1
var _game_active := false
var _music_tween: Tween
var _ambience_tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(2):
		var music := AudioStreamPlayer.new()
		music.name = "RegionalMusic%d" % i
		music.volume_db = -48.0
		add_child(music)
		_music_players.append(music)
		var ambience := AudioStreamPlayer.new()
		ambience.name = "RegionalAmbience%d" % i
		ambience.volume_db = -48.0
		add_child(ambience)
		_ambience_players.append(ambience)
	GameState.room_changed.connect(_on_room_changed)

func start_game_audio() -> void:
	_game_active = true
	_current_region = -1
	_on_room_changed(GameState.current_room)

func stop_game_audio() -> void:
	_game_active = false
	for player in _music_players + _ambience_players:
		player.stop()

func _on_room_changed(room_id: int) -> void:
	if not _game_active:
		return
	var region := _region_for_room(room_id)
	if region == _current_region:
		return
	_current_region = region
	_crossfade(MUSIC_STREAMS[region], -16.0, true)
	_crossfade(AMBIENCE_STREAMS[region], -21.0, false)

func _crossfade(stream: AudioStreamWAV, target_db: float, is_music: bool) -> void:
	var active := _music_players if is_music else _ambience_players
	var next_index := 1 - (_music_index if is_music else _ambience_index)
	var incoming := active[next_index]
	var outgoing := active[1 - next_index]
	var tween_to_stop: Tween = _music_tween if is_music else _ambience_tween
	if tween_to_stop != null and tween_to_stop.is_running():
		tween_to_stop.kill()
	if outgoing.playing:
		var fade_out := create_tween()
		fade_out.tween_property(outgoing, "volume_db", -48.0, 0.8)
		fade_out.tween_callback(outgoing.stop)
	incoming.stop()
	incoming.stream = stream
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	incoming.volume_db = -48.0
	incoming.play()
	var fade_in := create_tween()
	fade_in.tween_property(incoming, "volume_db", target_db, 1.1)
	if is_music:
		_music_index = next_index
		_music_tween = fade_in
	else:
		_ambience_index = next_index
		_ambience_tween = fade_in

func _region_for_room(room_id: int) -> int:
	if room_id in [3, 25, 34]:
		return 1 # Lantern Refuge
	if room_id in [4, 5, 22, 28, 29]:
		return 2 # Ashen Foundry
	if room_id in [6, 7, 23, 30, 31, 36]:
		return 3 # Drowned Crypt
	if room_id in [8, 9, 10, 11, 12, 13, 14, 15, 24, 32, 33, 37]:
		return 4 # Veil Citadel
	if room_id in [16, 17, 18, 19, 20]:
		return 5 # Echo Depths
	return 0 # Whispering Woods
