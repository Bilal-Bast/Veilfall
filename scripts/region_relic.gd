extends Area2D
## Persistent regional relic used by the Phase 12 exploration branches.
@export var item_id := "relic_woods_01"
@export var relic_name := "Verdant Relic"

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
    GameState.collect_region_relic(item_id)
    GameFeedback.burst(global_position, Color("ffe4a6"), 10, 155.0)
    GameState.story_message = "%s found (%d/4)." % [relic_name, GameState.region_relic_count()]
    GameState.quest_updated.emit()
    queue_free()

func _draw() -> void:
    draw_circle(Vector2.ZERO, 15.0, Color("f4bd83", 0.3))
    draw_colored_polygon(PackedVector2Array([Vector2(0, -14), Vector2(12, -2), Vector2(8, 12), Vector2(-8, 12), Vector2(-12, -2)]), Color("ffe4a6"))
    draw_circle(Vector2.ZERO, 4.0, Color("fff8db"))
    draw_arc(Vector2.ZERO, 21.0, 0.0, TAU, 24, Color("ffe7b8", 0.85), 2.0)
