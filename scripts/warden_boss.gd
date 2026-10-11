extends CharacterBody2D
## First vertical-slice boss: a readable wind-up, short charge, and recovery loop.
const SHARD = preload("res://scripts/shard.gd")
const MAX_HEALTH := 7
const GRAVITY := 1100.0

var health := MAX_HEALTH
var patrol_left := 0.0
var patrol_right := 0.0
var facing := -1
var phase := "approach"
var phase_left := 0.0
var contact_cooldown := 0.0
var flash_left := 0.0
var player: Node2D

func configure(at: Vector2, left: float, right: float) -> void:
    position = at
    patrol_left = left
    patrol_right = right

func _ready() -> void:
    add_to_group("enemies")
    add_to_group("bosses")
    collision_layer = 4
    collision_mask = 1
    var body_shape := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = Vector2(48, 58)
    body_shape.shape = rect
    add_child(body_shape)
    player = get_tree().get_first_node_in_group("player") as Node2D

func _physics_process(delta: float) -> void:
    if GameState.won:
        velocity.x = 0.0
        return
    phase_left = maxf(0.0, phase_left - delta)
    contact_cooldown = maxf(0.0, contact_cooldown - delta)
    flash_left = maxf(0.0, flash_left - delta)
    if not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as Node2D
    if not is_instance_valid(player):
        return
    var distance_x := player.global_position.x - global_position.x
    if absf(distance_x) < 210.0 and not GameState.boss_engaged:
        GameState.boss_engaged = true
        GameState.set_boss_health(health, MAX_HEALTH, "VEIL WARDEN")
    if absf(distance_x) > 3.0:
        facing = 1 if distance_x > 0.0 else -1
    match phase:
        "approach":
            velocity.x = facing * 82.0 if absf(distance_x) > 86.0 else 0.0
            if absf(distance_x) < 210.0:
                phase = "windup"
                phase_left = 0.72
        "windup":
            velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
            if phase_left <= 0.0:
                phase = "charge"
                phase_left = 0.36
                velocity.x = facing * 390.0
        "charge":
            if phase_left <= 0.0:
                phase = "recover"
                phase_left = 0.82
                velocity.x = 0.0
        "recover":
            velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
            if phase_left <= 0.0:
                phase = "approach"
    velocity.y += GRAVITY * delta
    move_and_slide()
    position.x = clampf(position.x, patrol_left, patrol_right)
    if is_on_wall() and phase == "charge":
        phase = "recover"
        phase_left = 0.82
        velocity.x = 0.0
    if contact_cooldown <= 0.0 and global_position.distance_to(player.global_position) < 46.0:
        player.take_damage(1, global_position.x)
        contact_cooldown = 1.0
    queue_redraw()

func take_damage(amount: int, knock_direction: int) -> void:
    if health <= 0:
        return
    health = maxi(0, health - amount)
    flash_left = 0.16
    if phase != "windup":
        phase = "recover"
        phase_left = 0.5
    velocity.x = 115.0 * knock_direction
    velocity.y = -90.0
    GameState.set_boss_health(health, MAX_HEALTH)
    if health == 0:
        GameState.mark_warden_defeated()
        _drop_shard()
        queue_free()

func _drop_shard() -> void:
    var shard = SHARD.new()
    shard.position = position + Vector2(0.0, -68.0)
    get_parent().add_child(shard)

func _draw() -> void:
    var tint := Color("fff2c8") if flash_left > 0.0 else Color("5c4e71")
    var body := PackedVector2Array([
        Vector2(-17, -25), Vector2(-25, -11), Vector2(-22, 17),
        Vector2(-15, 28), Vector2(14, 28), Vector2(23, 14),
        Vector2(22, -12), Vector2(13, -27)
    ])
    draw_colored_polygon(body, tint)
    draw_polyline(PackedVector2Array([body[0], body[1], body[2], body[3], body[4], body[5], body[6], body[7], body[0]]), Color("201e36"), 3.0, true)
    draw_colored_polygon(PackedVector2Array([Vector2(-15, -22), Vector2(-29, -37), Vector2(-11, -33)]), Color("9d7180"))
    draw_colored_polygon(PackedVector2Array([Vector2(15, -22), Vector2(29, -37), Vector2(11, -33)]), Color("9d7180"))
    draw_rect(Rect2(-13, -12, 8, 4), Color("ffcb78") if phase != "windup" else Color("ff715f"))
    draw_rect(Rect2(5, -12, 8, 4), Color("ffcb78") if phase != "windup" else Color("ff715f"))
    draw_line(Vector2(8 * facing, -3), Vector2(25 * facing, 18), Color("c4b4d2"), 4.0)
    draw_line(Vector2(25 * facing, 18), Vector2(34 * facing, 30), Color("f2d89d"), 3.0)
    if phase == "windup":
        draw_arc(Vector2(21 * facing, -1), 37.0, -0.8 if facing > 0 else 2.3, 0.8 if facing > 0 else 3.9, 20, Color("ff715f", 0.9), 3.0)
    elif phase == "charge":
        draw_line(Vector2(-10 * facing, 5), Vector2(-39 * facing, 11), Color("c6a5e8", 0.62), 3.0)
