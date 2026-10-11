extends CharacterBody2D
## A stationary ranged sentinel with a clear charge tell before each bolt.
const BOLT = preload("res://scripts/veil_bolt.gd")
var health := 3
var cooldown := 1.0
var charge_left := 0.0
var shot_pending := false
var direction := -1
var player: Node2D

func _ready() -> void:
	add_to_group("enemies")
	collision_layer = 4
	collision_mask = 0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(34, 48)
	shape.shape = rect
	add_child(shape)

func _physics_process(delta: float) -> void:
	cooldown = maxf(0.0, cooldown - delta)
	charge_left = maxf(0.0, charge_left - delta)
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D
	if is_instance_valid(player):
		direction = 1 if player.global_position.x > global_position.x else -1
		var distance := global_position.distance_to(player.global_position)
		if distance < 430.0 and cooldown <= 0.0 and charge_left <= 0.0:
			charge_left = 0.72
			cooldown = 2.45
			shot_pending = true
		if shot_pending and charge_left <= 0.0:
			var bolt = BOLT.new()
			bolt.set_heading(global_position + Vector2(direction * 28.0, 0.0), player.global_position)
			get_tree().current_scene.add_child(bolt)
			shot_pending = false
	queue_redraw()

func take_damage(amount: int, knock_direction: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()
		return
	position.x += 12.0 * knock_direction

func _draw() -> void:
	var color := Color("e8d7ff") if charge_left > 0.0 else Color("594c76")
	draw_colored_polygon(PackedVector2Array([Vector2(-17, 23), Vector2(-14, -14), Vector2(-7, -24), Vector2(8, -24), Vector2(16, -12), Vector2(14, 23)]), color)
	draw_rect(Rect2(-11, -34, 22, 8), Color("a18aca"))
	draw_circle(Vector2(direction * 7.0, -8), 3.5, Color("ffe5ad"))
	if charge_left > 0.0:
		draw_line(Vector2(direction * 15.0, -5), Vector2(direction * 50.0, -5), Color("c4a9ef", 0.8), 3.0)
