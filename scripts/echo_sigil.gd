extends Area2D
## Permanent collectible for Mira's exploration quest.
@export var item_id: String = "echo_woods_01"
var float_time := 0.0

func _ready() -> void:
    collision_layer = 0
    collision_mask = 2
    if GameState.collected_items.has(item_id):
        queue_free()
        return
    var shape := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = 18.0
    shape.shape = circle
    add_child(shape)
    body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
    float_time += delta
    queue_redraw()

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        GameState.collect_echo_sigil(item_id)
    GameFeedback.burst(global_position, Color("b8f1eb"), 10, 155.0)
        queue_free()

func _draw() -> void:
    var bob := sin(float_time * 3.0) * 3.0
    draw_colored_polygon(PackedVector2Array([Vector2(0, -14 + bob), Vector2(10, bob), Vector2(0, 14 + bob), Vector2(-10, bob)]), Color("98d9dc"))
    draw_colored_polygon(PackedVector2Array([Vector2(0, -8 + bob), Vector2(4, bob), Vector2(0, 8 + bob), Vector2(-4, bob)]), Color("f3f6d4"))
    draw_arc(Vector2(0, bob), 17.0, 0.0, TAU, 24, Color("b8f1eb", 0.68), 2.0)
