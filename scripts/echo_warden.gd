extends CharacterBody2D
## Optional postgame boss: alternates a marked echo strike and a fast crossing rush.
const MAX_HEALTH := 9
const GRAVITY := 1100.0
var health := MAX_HEALTH
var phase := "approach"
var phase_left := 0.0
var facing := -1
var target_x := 0.0
var attack_style := "mark"
var contact_cooldown := 0.0
var attack_hit := false
var flash_left := 0.0
var player: Node2D

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	add_to_group("enemies")
	add_to_group("bosses")
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(66, 88)
	shape.shape = rect
	add_child(shape)
	if GameState.echo_warden_defeated:
		queue_free()
		return
	player = get_tree().get_first_node_in_group("player") as Node2D

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D
	if not is_instance_valid(player):
		return
	phase_left = maxf(0.0, phase_left - delta)
	contact_cooldown = maxf(0.0, contact_cooldown - delta)
	flash_left = maxf(0.0, flash_left - delta)
	var dx := player.global_position.x - global_position.x
	var dy := absf(player.global_position.y - global_position.y)
	if absf(dx) < 360.0 and not GameState.boss_engaged:
		GameState.boss_engaged = true
		GameState.set_boss_health(health, MAX_HEALTH, "ECHO WARDEN")
	if absf(dx) > 2.0:
		facing = 1 if dx > 0.0 else -1
	var enraged := health <= 4
	match phase:
		"approach":
			velocity.x = facing * (66.0 if not enraged else 92.0) if absf(dx) > 115.0 else 0.0
			if absf(dx) < 280.0:
				attack_hit = false
				if attack_style == "mark":
					phase = "mark_windup"
					phase_left = 0.72 if not enraged else 0.54
					target_x = player.global_position.x
				else:
					phase = "rush_windup"
					phase_left = 0.68 if not enraged else 0.48
		"mark_windup":
			velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
			if phase_left <= 0.0:
				phase = "mark_burst"
				phase_left = 0.18
				if absf(player.global_position.x - target_x) < 54.0 and dy < 125.0:
					player.call("take_damage", 1, target_x)
		"rush_windup":
			velocity.x = move_toward(velocity.x, 0.0, 950.0 * delta)
			if phase_left <= 0.0:
				phase = "rush"
				phase_left = 0.40 if not enraged else 0.50
				velocity.x = facing * (440.0 if not enraged else 540.0)
		"rush":
			if not attack_hit and absf(dx) < 74.0 and dy < 86.0 and contact_cooldown <= 0.0:
				player.call("take_damage", 1, global_position.x)
				attack_hit = true
				contact_cooldown = 1.0
			if phase_left <= 0.0:
				_enter_exposed()
		"mark_burst":
			if phase_left <= 0.0:
				_enter_exposed()
		"exposed":
			velocity.x = move_toward(velocity.x, 0.0, 1100.0 * delta)
			if phase_left <= 0.0:
				phase = "approach"
				attack_style = "rush" if attack_style == "mark" else "mark"
	velocity.y += GRAVITY * delta
	move_and_slide()
	position.x = clampf(position.x, 115.0, 845.0)
	if is_on_wall() and phase == "rush":
		_enter_exposed()
	if contact_cooldown <= 0.0 and phase not in ["rush", "mark_burst"] and global_position.distance_to(player.global_position) < 50.0:
		player.call("take_damage", 1, global_position.x)
		contact_cooldown = 1.0
	queue_redraw()

func _enter_exposed() -> void:
	phase = "exposed"
	phase_left = 0.9
	velocity.x = 0.0

func take_damage(amount: int, knock_direction: int) -> void:
	if health <= 0 or (phase != "exposed" and amount < 4):
		return
	health = maxi(0, health - amount)
	flash_left = 0.16
	velocity.x = 75.0 * knock_direction
	GameState.set_boss_health(health, MAX_HEALTH, "ECHO WARDEN")
	if health == 0:
		GameState.mark_echo_warden_defeated()
		queue_free()

func _draw() -> void:
	var body := Color("fff0c8") if flash_left > 0.0 else (Color("82bcb2") if health <= 4 else Color("526d80"))
	draw_colored_polygon(PackedVector2Array([Vector2(-29, -39), Vector2(-20, -52), Vector2(20, -52), Vector2(30, -30), Vector2(25, 33), Vector2(15, 41), Vector2(-24, 39), Vector2(-32, 14)]), body)
	draw_colored_polygon(PackedVector2Array([Vector2(-25, -37), Vector2(-38, -64), Vector2(-9, -52), Vector2(0, -76), Vector2(9, -52), Vector2(37, -64), Vector2(25, -35)]), Color("9cd4c9"))
	draw_circle(Vector2(-12, -15), 4.0, Color("f5e6b2"))
	draw_circle(Vector2(12, -15), 4.0, Color("f5e6b2"))
	draw_line(Vector2(18 * facing, -3), Vector2(38 * facing, 31), Color("c7d9d3"), 6.0)
	if phase == "mark_windup":
		var mark_x := target_x - global_position.x
		draw_line(Vector2(mark_x, -300), Vector2(mark_x, 10), Color("a5eff0", 0.7), 5.0)
		draw_arc(Vector2(0, -58), 43.0, 0.0, TAU, 30, Color("c8fff0", 0.9), 3.0)
	elif phase == "rush_windup":
		draw_arc(Vector2(24 * facing, -7), 52.0, -0.8 if facing > 0 else 2.3, 0.8 if facing > 0 else 3.9, 24, Color("ffdf9b", 0.9), 4.0)
	elif phase == "exposed":
		draw_arc(Vector2.ZERO, 54.0, 0.0, TAU, 36, Color("a8e5d2", 0.9), 4.0)
