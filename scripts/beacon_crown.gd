extends Area2D
## Final one-time reward in the Beacon Crucible.
const ITEM_ID := "beacon_crown_01"

func _process(_delta: float) -> void:
    queue_redraw()

func _ready() -> void:
    collision_layer = 0
    collision_mask = 2
    if GameState.collected_items.has(ITEM_ID):
        queue_free()
        return
    var shape := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = 24.0
    shape.shape = circle
    add_child(shape)
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if not body.is_in_group("player") or GameState.collected_items.has(ITEM_ID) or GameState.beacon_memory_count() < 4:
        return
    GameState.collected_items.append(ITEM_ID)
    GameFeedback.burst(global_position, Color("ffe7a2"), 10, 155.0)
    Sfx.play("pickup")
    var upgraded_maximum := int(body.get("max_health")) + 1
    body.set("max_health", upgraded_maximum)
    body.set("health", upgraded_maximum)
    body.emit_signal("health_changed", upgraded_maximum, upgraded_maximum)
    GameState.story_message = "The Beacon Crown rekindles the last light. Maximum health increased."
    GameState.quest_updated.emit()
    SaveManager.save_game()
    queue_free()

func _draw() -> void:
    var awake := GameState.beacon_memory_count() >= 4
    var crown_color := Color("f4d57b") if awake else Color("6b7180")
    draw_colored_polygon(PackedVector2Array([Vector2(-14, -8), Vector2(-9, 10), Vector2(9, 10), Vector2(14, -8), Vector2(5, -2), Vector2(0, -14), Vector2(-5, -2)]), crown_color)
    draw_circle(Vector2.ZERO, 5.0, Color("fff5c8") if awake else Color("8b8f9b"))
    draw_arc(Vector2.ZERO, 22.0, 0.0, TAU, 28, Color("ffe7a2", 0.85) if awake else Color("818697", 0.7), 2.0)
