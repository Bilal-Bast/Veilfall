extends Area2D
## One-time lore pickup for the Scribe's three-folio quest.
@export var item_id := "lore_woods_01"
@export var folio_title := "The Veil Almanac"

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
    if not body.is_in_group("player") or not GameState.archive_quest_started:
        return
    GameState.collect_lore_page(item_id)
    GameFeedback.burst(global_position, Color("e7d7b0"), 10, 155.0)
    GameState.story_message = "%s recovered (%d/3)." % [folio_title, GameState.lore_page_count()]
    GameState.quest_updated.emit()
    queue_free()

func _draw() -> void:
    draw_rect(Rect2(-10, -13, 20, 26), Color("d9c7a0"))
    draw_rect(Rect2(-7, -8, 14, 2), Color("695b4c"))
    draw_rect(Rect2(-7, -2, 12, 2), Color("695b4c"))
    draw_rect(Rect2(-7, 4, 14, 2), Color("695b4c"))
    draw_arc(Vector2.ZERO, 20.0, 0.0, TAU, 24, Color("e7d7b0", 0.82), 2.0)
