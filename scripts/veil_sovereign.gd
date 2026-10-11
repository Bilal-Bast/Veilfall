extends CharacterBody2D
## Final boss: alternating aimed rift bursts and blade rushes with clear recovery windows.
const MAX_HEALTH := 12
const GRAVITY := 1100.0
var health := MAX_HEALTH
var phase := "approach"
var phase_left := 0.0
var facing := -1
var flash_left := 0.0
var contact_cooldown := 0.0
var attack_style := "rift"
var target_x := 0.0
var attack_hit := false
var player: Node2D

func _ready() -> void:
    collision_layer = 4
    collision_mask = 1
    add_to_group("enemies")
    add_to_group("bosses")
    var shape := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = Vector2(76, 92)
    shape.shape = rect
    add_child(shape)
    if GameState.citadel_boss_defeated:
        queue_free()
        return
    player = get_tree().get_first_node_in_group("player") as Node2D

func _physics_process(delta: float) -> void:
    if GameState.won:
        velocity = Vector2.ZERO
        return
    if not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as Node2D
    if not is_instance_valid(player):
        return
    phase_left = maxf(0.0, phase_left - delta)
    flash_left = maxf(0.0, flash_left - delta)
    contact_cooldown = maxf(0.0, contact_cooldown - delta)
    var dx := player.global_position.x - global_position.x
    var dy := absf(player.global_position.y - global_position.y)
    if absf(dx) < 320.0 and not GameState.boss_engaged:
        GameState.boss_engaged = true
        GameState.set_boss_health(health, MAX_HEALTH, "VEIL SOVEREIGN")
    if absf(dx) > 2.0:
        facing = 1 if dx > 0.0 else -1
    var enraged := health <= MAX_HEALTH / 2
    match phase:
        "approach":
            velocity.x = facing * (66.0 if not enraged else 92.0) if absf(dx) > 112.0 else 0.0
            if absf(dx) < 260.0:
                attack_hit = false
                if attack_style == "rift":
                    phase = "rift_windup"
                    phase_left = 0.78 if not enraged else 0.58
                    target_x = player.global_position.x
                else:
                    phase = "blade_windup"
                    phase_left = 0.72 if not enraged else 0.52
        "rift_windup":
            velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
            if phase_left <= 0.0:
                phase = "rift_burst"
                phase_left = 0.16
                if absf(player.global_position.x - target_x) < 54.0 and dy < 125.0:
                    player.call("take_damage", 1, target_x)
        "blade_windup":
            velocity.x = move_toward(velocity.x, 0.0, 950.0 * delta)
            if phase_left <= 0.0:
                phase = "blade_rush"
                phase_left = 0.42 if not enraged else 0.52
                velocity.x = facing * (475.0 if not enraged else 575.0)
        "blade_rush":
            if not attack_hit and absf(dx) < 76.0 and dy < 82.0 and contact_cooldown <= 0.0:
                player.call("take_damage", 1, global_position.x)
                attack_hit = true
                contact_cooldown = 1.0
            if phase_left <= 0.0:
                _enter_exposed()
        "rift_burst":
            if phase_left <= 0.0:
                _enter_exposed()
        "exposed":
            velocity.x = move_toward(velocity.x, 0.0, 1100.0 * delta)
            if phase_left <= 0.0:
                phase = "approach"
                attack_style = "blade" if attack_style == "rift" else "rift"
    velocity.y += GRAVITY * delta
    move_and_slide()
    position.x = clampf(position.x, 215.0, 805.0)
    if is_on_wall() and phase == "blade_rush":
        _enter_exposed()
    if contact_cooldown <= 0.0 and phase != "blade_rush" and phase != "rift_burst" and global_position.distance_to(player.global_position) < 53.0:
        player.call("take_damage", 1, global_position.x)
        contact_cooldown = 1.0
    queue_redraw()

func _enter_exposed() -> void:
    phase = "exposed"
    phase_left = 0.92
    velocity.x = 0.0

func take_damage(amount: int, knock_direction: int) -> void:
    if health <= 0 or (phase != "exposed" and amount < 3):
        return
    health = maxi(0, health - amount)
    flash_left = 0.16
    velocity.x = 75.0 * knock_direction
    GameState.set_boss_health(health, MAX_HEALTH, "VEIL SOVEREIGN")
    if health == 0:
        GameState.mark_citadel_boss_defeated()
        queue_free()

func _draw() -> void:
    var body_color := Color("fff0c8") if flash_left > 0.0 else (Color("a16b9b") if health <= MAX_HEALTH / 2 else Color("4d456f"))
    draw_colored_polygon(PackedVector2Array([Vector2(-32, -43), Vector2(-22, -55), Vector2(20, -55), Vector2(34, -33), Vector2(30, 32), Vector2(18, 43), Vector2(-25, 43), Vector2(-35, 19)]), body_color)
    draw_colored_polygon(PackedVector2Array([Vector2(-27, -42), Vector2(-38, -67), Vector2(-10, -53), Vector2(0, -77), Vector2(10, -53), Vector2(39, -68), Vector2(28, -38)]), Color("c7a875"))
    draw_circle(Vector2(-13, -18), 4.0, Color("a6edeb"))
    draw_circle(Vector2(13, -18), 4.0, Color("a6edeb"))
    draw_line(Vector2(20 * facing, -6), Vector2(41 * facing, 33), Color("c9d1e6"), 7.0)
    draw_line(Vector2(41 * facing, 33), Vector2(48 * facing, 43), Color("ffe9b0"), 4.0)
    if phase == "rift_windup":
        var local_target := target_x - global_position.x
        draw_line(Vector2(local_target, -310), Vector2(local_target, 6), Color("b69eea", 0.65), 5.0)
        draw_arc(Vector2(0, -60), 47.0, 0.0, TAU, 32, Color("e3c6ff", 0.85), 3.0)
    elif phase == "blade_windup":
        draw_arc(Vector2(25 * facing, -9), 53.0, -0.85 if facing > 0 else 2.28, 0.85 if facing > 0 else 4.0, 24, Color("ffb774", 0.9), 4.0)
    elif phase == "blade_rush":
        draw_line(Vector2(-42 * facing, 14), Vector2(-88 * facing, 26), Color("c8a6ea", 0.65), 6.0)
    elif phase == "exposed":
        draw_arc(Vector2(0, -8), 56.0, 0.0, TAU, 36, Color("a8e5d2", 0.85), 4.0)
