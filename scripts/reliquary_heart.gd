extends Area2D
## Final Phase 12 reward, unlocked by the four regional relics.
const ITEM_ID := "reliquary_heart_01"

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
    circle.radius = 25.0
    shape.shape = circle
    add_child(shape)
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if not body.is_in_group("player") or GameState.region_relic_count() < 4 or GameState.collected_items.has(ITEM_ID):
        return
    GameState.collected_items.append(ITEM_ID)
    GameFeedback.burst(global_position, Color("ffac9d"), 10, 155.0)
    Sfx.play("pickup")
    var upgraded_maximum := int(body.get("max_health")) + 1
    body.set("max_health", upgraded_maximum)
    body.set("health", upgraded_maximum)
    body.emit_signal("health_changed", upgraded_maximum, upgraded_maximum)
    GameState.story_message = "The Reliquary Heart answers the four relics. Maximum health increased."
    GameState.quest_updated.emit()
    SaveManager.save_game()
    queue_free()

func _draw() -> void:
    var awake := GameState.region_relic_count() >= 4
    draw_circle(Vector2.ZERO, 17.0, Color("f07c7e", 0.38) if awake else Color("788096", 0.32))
    draw_colored_polygon(PackedVector2Array([Vector2(0, 13), Vector2(-14, -1), Vector2(-12, -9), Vector2(-5, -13), Vector2(0, -8), Vector2(5, -13), Vector2(12, -9), Vector2(14, -1)]), Color("ffac9d") if awake else Color("767d8d"))
    draw_arc(Vector2.ZERO, 23.0, 0.0, TAU, 28, Color("ffe1ad", 0.86) if awake else Color("969bab", 0.58), 2.0)
