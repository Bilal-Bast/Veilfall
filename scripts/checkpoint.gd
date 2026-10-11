extends Area2D
## Activated by entering its area. Respawn location is on the ground beside it.
var activated: bool = false

func _ready() -> void:
    collision_layer = 0
    collision_mask = 2
    monitoring = true
    var col := CollisionShape2D.new()
    var s := RectangleShape2D.new()
    s.size = Vector2(52, 75)
    col.shape = s
    add_child(col)
    body_entered.connect(_on_body_entered)
    activated = global_position.distance_to(GameState.checkpoint) < 4.0

func _on_body_entered(body: Node2D) -> void:
    if not body.is_in_group("player"):
        return
    activated = true
    GameState.activate_checkpoint(Vector2(global_position.x, 399.0))
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(-4, -32, 8, 65), Color("354d62"))
    draw_rect(Rect2(-12, 30, 24, 5), Color("253744"))
    draw_circle(Vector2(0, -37), 12.0, Color("fff1bb") if activated else Color("bb91d9"))
    draw_arc(Vector2(0, -37), 16.0, 0.0, TAU, 24, Color("ffdf91", 0.6) if activated else Color("a789d6", 0.5), 2.0)
