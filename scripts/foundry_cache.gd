extends Area2D
## One-time hidden cache in the Foundry's Veil-only upper route.
const ITEM_ID := "foundry_cache_01"

func _ready() -> void:
    collision_layer = 0
    collision_mask = 2
    if GameState.collected_items.has(ITEM_ID):
        queue_free()
        return
    var shape := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = 18.0
    shape.shape = circle
    add_child(shape)
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if not body.is_in_group("player") or GameState.collected_items.has(ITEM_ID):
        return
    GameState.collected_items.append(ITEM_ID)
    GameFeedback.burst(global_position, Color("ffca75"), 10, 155.0)
    Sfx.play("pickup")
    var maximum_health := int(body.get("max_health"))
    var current_health := int(body.get("health"))
    body.set("health", mini(maximum_health, current_health + 1))
    body.emit_signal("health_changed", body.get("health"), maximum_health)
    GameState.story_message = "Hidden cache found: the ember salve restores one heart."
    GameState.quest_updated.emit()
    SaveManager.save_game()
    queue_free()

func _draw() -> void:
    draw_rect(Rect2(-11, -9, 22, 18), Color("53394a"))
    draw_rect(Rect2(-11, -9, 22, 18), Color("ffca75"), false, 2.0)
    draw_circle(Vector2(0, 0), 4.0, Color("fff0b5"))
