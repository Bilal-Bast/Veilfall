extends Area2D
## One-time memory fragment used by the Phase 11 side chambers.
@export var item_id := "memory_woods_01"
@export var memory_name := "Verdant Memory"

func _ready() -> void:
    collision_layer = 0
    collision_mask = 2
    if GameState.collected_items.has(item_id):
        queue_free()
        return
    var shape := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = 22.0
    shape.shape = circle
    add_child(shape)
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if not body.is_in_group("player"):
        return
    GameState.collect_beacon_memory(item_id)
    GameFeedback.burst(global_position, Color("c2fff0"), 10, 155.0)
    GameState.story_message = "%s recovered (%d/4)." % [memory_name, GameState.beacon_memory_count()]
    GameState.quest_updated.emit()
    queue_free()

func _draw() -> void:
    draw_circle(Vector2.ZERO, 14.0, Color("8ad8cf", 0.32))
    draw_colored_polygon(PackedVector2Array([Vector2(0, -13), Vector2(11, 0), Vector2(0, 13), Vector2(-11, 0)]), Color("c2fff0"))
    draw_circle(Vector2.ZERO, 4.0, Color("fff0bb"))
    draw_arc(Vector2.ZERO, 20.0, 0.0, TAU, 24, Color("d9fff2", 0.85), 2.0)
