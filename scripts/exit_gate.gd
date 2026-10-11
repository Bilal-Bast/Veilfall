extends Area2D
## Woods-to-Refuge passage: the shard opens the way into the next chapter.
var barrier_shape: CollisionShape2D

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var col := CollisionShape2D.new()
	var s := RectangleShape2D.new()
	s.size = Vector2(52, 92)
	col.shape = s
	add_child(col)
	var barrier := StaticBody2D.new()
	barrier.collision_layer = 1
	barrier.collision_mask = 0
	barrier_shape = CollisionShape2D.new()
	var barrier_rect := RectangleShape2D.new()
	barrier_rect.size = Vector2(42, 120)
	barrier_shape.shape = barrier_rect
	barrier.add_child(barrier_shape)
	add_child(barrier)
	barrier_shape.set_deferred("disabled", GameState.shards > 0)
	GameState.shard_count_changed.connect(_on_shard_changed)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if GameState.shards > 0:
			GameState.unlock_refuge()

func _on_shard_changed(_amount: int) -> void:
	barrier_shape.set_deferred("disabled", GameState.shards > 0)
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(-26, -52, 52, 94), Color("342c50"))
	draw_rect(Rect2(-21, -47, 42, 84), Color("172334"))
	draw_rect(Rect2(-26, -52, 52, 94), Color("8882ae"), false, 4.0)
	var c := Color("f8ca7b") if GameState.shards > 0 else Color("8a658e")
	draw_circle(Vector2(0, -10), 10.0, c)
	draw_arc(Vector2(0, -10), 16.0, 0.0, TAU, 20, c, 2.0)
