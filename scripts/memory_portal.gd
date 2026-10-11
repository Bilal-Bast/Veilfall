extends Area2D
## Realm-memory doorway; its requirement is checked on interaction, never on overlap.
@export var destination := Vector2.ZERO
@export var requirement := "always"
@export var sealed_hint := "The memory remains sealed."
var nearby := false

func _ready() -> void:
    collision_layer = 0
    collision_mask = 2
    var shape := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = 44.0
    shape.shape = circle
    add_child(shape)
    body_entered.connect(func(body):
        if body.is_in_group("player"):
            nearby = true
    )
    body_exited.connect(func(body):
        if body.is_in_group("player"):
            nearby = false
    )

func _process(_delta: float) -> void:
    if nearby and Input.is_action_just_pressed("interact"):
        if not _is_open():
            GameState.story_message = sealed_hint
        else:
            var player = get_tree().get_first_node_in_group("player")
            if is_instance_valid(player):
                player.global_position = destination
                player.velocity = Vector2.ZERO
                Sfx.play("portal")
                GameState.checkpoint = destination
                GameState.checkpoint_changed.emit(destination)
                GameState.set_current_room(GameState.room_for_x(destination.x))
                SaveManager.save_game()
            GameState.story_message = "The lantern carries you into a hidden chamber."
        GameState.quest_updated.emit()
    queue_redraw()

func _is_open() -> bool:
    match requirement:
        "warden": return GameState.warden_defeated
        "foundry": return GameState.foundry_boss_defeated
        "crypt": return GameState.crypt_boss_defeated
        "pulse": return GameState.unlocked_abilities.has("lantern_pulse")
        "memories": return GameState.beacon_memory_count() >= 4
        "air_dash": return GameState.unlocked_abilities.has("air_dash")
        "wall_climb": return GameState.unlocked_abilities.has("wall_climb")
        "relics": return GameState.region_relic_count() >= 4
        "lore_veil": return GameState.archive_quest_started and GameState.is_veil
        "lore_climb": return GameState.archive_quest_started and GameState.unlocked_abilities.has("wall_climb")
        "lore_pulse": return GameState.archive_quest_started and GameState.unlocked_abilities.has("lantern_pulse")
        _: return true

func _draw() -> void:
    var open := _is_open()
    var tint := Color("f1d891", 0.95) if open else Color("788096", 0.72)
    draw_arc(Vector2.ZERO, 28.0, 0.0, TAU, 36, tint, 4.0)
    draw_arc(Vector2.ZERO, 19.0, 0.0, TAU, 32, Color("d8c2f2", 0.72), 2.0)
    draw_circle(Vector2.ZERO, 7.0, Color("fff0ba") if open else Color("414756"))
    if nearby:
        draw_string(ThemeDB.fallback_font, Vector2(-71, -46), "E  ENTER" if open else "E  SEALED", HORIZONTAL_ALIGNMENT_CENTER, 142.0, 12, Color("fff0bb"))
