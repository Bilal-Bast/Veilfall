extends Node2D
## Main game coordinator: save loading, room cameras, transitions, and ambience.
@onready var player = $Player
@onready var hud = $HUD
@onready var camera: Camera2D = $Player/Camera2D

func _enter_tree() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    SaveManager.load_game()

func _ready() -> void:
    RegionAudio.start_game_audio()
    GameState.room_changed.connect(_on_room_changed)
    player.global_position = GameState.checkpoint
    _apply_room_camera(GameState.current_room)

func _on_room_changed(room_id: int) -> void:
    _apply_room_camera(room_id)
    hud.play_room_transition(room_id)

func _apply_room_camera(room_id: int) -> void:
    var left := room_id * 960
    camera.limit_left = left
    camera.limit_right = left + 960

func _process(_delta: float) -> void:
    hud.update_status(player)
    if GameState.won and Input.is_action_just_pressed("restart"):
        get_tree().reload_current_scene()

func _unhandled_input(event: InputEvent) -> void:
    var is_key_echo := event is InputEventKey and (event as InputEventKey).echo
    if event.is_action_pressed("pause") and not is_key_echo:
        hud.toggle_pause()
        get_viewport().set_input_as_handled()

func _exit_tree() -> void:
    RegionAudio.stop_game_audio()
