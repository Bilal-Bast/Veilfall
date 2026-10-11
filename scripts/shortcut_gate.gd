extends Area2D
## Paired Refuge/Citadel fast-travel gates, unlocked by Mira's Echo Sigil quest.
@export var destination: Vector2 = Vector2.ZERO
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
        if not GameState.shortcut_unlocked:
            GameState.story_message = "A sealed waystone. Mira needs three Echo Sigils to bind it."
        else:
            var player = get_tree().get_first_node_in_group("player")
            if is_instance_valid(player):
                player.global_position = destination
                player.velocity = Vector2.ZERO
                Sfx.play("portal")
                GameState.set_current_room(GameState.room_for_x(destination.x))
            GameState.story_message = "The waystone carries you between the Refuge and Citadel."
        GameState.quest_updated.emit()
    queue_redraw()

func _draw() -> void:
    var open := GameState.shortcut_unlocked
    var glow := Color("a8e5d2", 0.9) if open else Color("8f7eaa", 0.8)
    draw_arc(Vector2.ZERO, 28.0, 0.0, TAU, 36, glow, 5.0)
    draw_arc(Vector2.ZERO, 18.0, 0.0, TAU, 30, Color("e8d8ff", 0.65), 2.0)
    draw_circle(Vector2.ZERO, 7.0, Color("fff0ba") if open else Color("51465d"))
    if nearby:
        draw_string(ThemeDB.fallback_font, Vector2(-62, -48), "E  TRAVEL" if open else "E  INSPECT", HORIZONTAL_ALIGNMENT_CENTER, 124.0, 13, Color("fff0bb"))
