extends Area2D
## Pickup required to activate the final door.
var picked: bool = false
var phase: float = 0.0

func _ready() -> void:
    collision_layer = 0
    collision_mask = 2
    var col := CollisionShape2D.new()
    var s := CircleShape2D.new()
    s.radius = 19.0
    col.shape = s
    add_child(col)
    body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
    phase += delta * 3.0
    queue_redraw()

func _on_body_entered(body: Node2D) -> void:
    if picked or not body.is_in_group("player"):
        return
    picked = true
    GameState.collect_shard()
    GameFeedback.burst(global_position, Color("fff0ba"), 10, 155.0)
    queue_free()

func _draw() -> void:
    if picked:
        return
    var bob := sin(phase) * 4.0
    var points := PackedVector2Array([Vector2(0, -18 + bob), Vector2(12, bob), Vector2(0, 18 + bob), Vector2(-12, bob)])
    draw_colored_polygon(points, Color("ffe3a5"))
    draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[0]]), Color("fff9dc"), 2.0)
    draw_arc(Vector2(0, bob), 25, 0, TAU, 24, Color("ffe9ae", 0.38), 2.0)
