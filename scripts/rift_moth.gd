extends CharacterBody2D
## A hovering Citadel predator that telegraphs a quick horizontal dive.
var patrol_left := 0.0
var patrol_right := 0.0
var direction := 1
var health := 3
var windup_left := 0.0
var dive_left := 0.0
var cooldown := 0.6
var dive_pending := false
var player: Node2D

func configure(at: Vector2, left: float, right: float) -> void:
	position = at
	patrol_left = left
	patrol_right = right

func _ready() -> void:
	add_to_group("enemies")
	collision_layer = 4
	collision_mask = 2
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 20.0
	shape.shape = circle
	add_child(shape)

func _physics_process(delta: float) -> void:
	cooldown = maxf(0.0, cooldown - delta)
	windup_left = maxf(0.0, windup_left - delta)
	dive_left = maxf(0.0, dive_left - delta)
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D
	if is_instance_valid(player) and cooldown <= 0.0 and windup_left <= 0.0 and dive_left <= 0.0 and global_position.distance_to(player.global_position) < 260.0:
		direction = 1 if player.global_position.x > global_position.x else -1
		windup_left = 0.48
		cooldown = 2.1
		dive_pending = true
	if windup_left > 0.0:
		velocity = Vector2.ZERO
	elif dive_left <= 0.0 and dive_pending:
		dive_left = 0.24
		dive_pending = false
		velocity = Vector2(direction * 350.0, 125.0)
	elif dive_left > 0.0:
		velocity.y += 520.0 * delta
	else:
		if position.x < patrol_left: direction = 1
		if position.x > patrol_right: direction = -1
		velocity = Vector2(direction * 42.0, sin(Time.get_ticks_msec() / 240.0) * 16.0)
	move_and_slide()
	if is_instance_valid(player) and global_position.distance_to(player.global_position) < 34.0:
		player.call("take_damage", 1, global_position.x)
	queue_redraw()

func take_damage(amount: int, knock_direction: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()
		return
	velocity = Vector2(knock_direction * 150.0, -90.0)

func _draw() -> void:
	var tint := Color("f5cc8d") if windup_left > 0.0 else Color("776d9e")
	draw_colored_polygon(PackedVector2Array([Vector2(-23, 0), Vector2(-38, -18), Vector2(-15, -12), Vector2(0, -25), Vector2(15, -12), Vector2(38, -18), Vector2(23, 0), Vector2(16, 16), Vector2(-16, 16)]), tint)
	draw_line(Vector2(-14, 5), Vector2(-26, 18), Color("b9a8d8"), 3.0)
	draw_line(Vector2(14, 5), Vector2(26, 18), Color("b9a8d8"), 3.0)
	draw_circle(Vector2(6 * direction, -5), 3.0, Color("fff0bf"))
	if windup_left > 0.0:
		draw_arc(Vector2.ZERO, 31.0, 0.0, TAU, 24, Color("ffcf8b", 0.9), 2.0)
