extends Area2D
## The Citadel altar grants Lantern Pulse once, then remains as a landmark.

func _ready() -> void:
    collision_layer = 0
    collision_mask = 2
    var shape := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = 34.0
    shape.shape = circle
    add_child(shape)
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        GameState.unlock_lantern_pulse()

func _draw() -> void:
    draw_rect(Rect2(-7, -6, 14, 30), Color("4b4969"))
    draw_colored_polygon(PackedVector2Array([Vector2(-29, -6), Vector2(0, -44), Vector2(29, -6)]), Color("77739b"))
    draw_circle(Vector2(0, -22), 10.0, Color("ffe6a4"))
    draw_circle(Vector2(0, -22), 5.0, Color("fff9dc"))
    draw_arc(Vector2(0, -22), 20.0, 0.0, TAU, 28, Color("b8e9eb", 0.82), 3.0)
