extends Node
## Small polyphonic one-shot player. All effects use Master so SettingsManager applies volume.
const CUES := {
    "sword_swing": preload("res://assets/audio/sfx/sword_swing.wav"),
    "hit": preload("res://assets/audio/sfx/hit.wav"),
    "realm_shift": preload("res://assets/audio/sfx/realm_shift.wav"),
    "pickup": preload("res://assets/audio/sfx/pickup.wav"),
    "checkpoint": preload("res://assets/audio/sfx/checkpoint.wav"),
    "portal": preload("res://assets/audio/sfx/portal.wav"),
    "hurt": preload("res://assets/audio/sfx/hurt.wav"),
    "lantern_pulse": preload("res://assets/audio/sfx/lantern_pulse.wav")
}

var _active_count := 0
const MAX_SIMULTANEOUS := 8

func play(cue: String, volume_db: float = 0.0, pitch: float = 1.0) -> void:
    if not CUES.has(cue) or _active_count >= MAX_SIMULTANEOUS:
        return
    var player := AudioStreamPlayer.new()
    player.stream = CUES[cue]
    player.volume_db = volume_db
    player.pitch_scale = pitch
    add_child(player)
    _active_count += 1
    player.finished.connect(_on_player_finished.bind(player))
    player.play()

func _on_player_finished(player: AudioStreamPlayer) -> void:
    _active_count = maxi(0, _active_count - 1)
    player.queue_free()
