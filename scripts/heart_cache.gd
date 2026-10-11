extends Area2D
## One-time heart cache used in the Crypt and the expanded Citadel.
@export var item_id := "citadel_heart_01"
@export var message := "Heart found: your lantern restores one heart."

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	if GameState.collected_items.has(item_id):
		queue_free()
		return
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 20.0
	shape.shape = circle
	add_child(shape)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or GameState.collected_items.has(item_id):
		return
	GameState.collected_items.append(item_id)
	GameFeedback.burst(global_position, Color("ead2ff"), 10, 155.0)
	Sfx.play("pickup")
	var upgraded_maximum := int(body.get("max_health")) + 1
	body.set("max_health", upgraded_maximum)
	body.set("health", upgraded_maximum)
	body.emit_signal("health_changed", upgraded_maximum, upgraded_maximum)
	GameState.story_message = message
	GameState.quest_updated.emit()
	SaveManager.save_game()
	queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 13.0, Color("caa5ec"))
	draw_circle(Vector2.ZERO, 6.0, Color("fff0d1"))
	draw_arc(Vector2.ZERO, 19.0, 0.0, TAU, 20, Color("ead2ff", 0.8), 2.0)
