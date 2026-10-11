extends CharacterBody2D
## Third boss: bell wind-up, a long tidal rush, then a safe recovery window.
const MAX_HEALTH := 10
const GRAVITY := 1100.0
var health := MAX_HEALTH
var arena_left := 0.0
var arena_right := 0.0
var facing := -1
var phase := "approach"
var phase_left := 0.0
var contact_cooldown := 0.0
var flash_left := 0.0
var player: Node2D
var strike_hit := false

func configure(at: Vector2, left: float, right: float) -> void:
    position = at
    arena_left = left
    arena_right = right

func _ready() -> void:
    collision_layer = 4
    collision_mask = 1
    add_to_group("enemies")
    add_to_group("bosses")
    var shape := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = Vector2(62, 76)
    shape.shape = rect
    add_child(shape)
    if GameState.crypt_boss_defeated:
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
    if absf(dx) < 290.0 and not GameState.boss_engaged:
        GameState.boss_engaged = true
        GameState.set_boss_health(health, MAX_HEALTH, "DROWNED ABBOT")
    if absf(dx) > 2.0:
        facing = 1 if dx > 0.0 else -1
    match phase:
        "approach":
            velocity.x = facing * 48.0 if absf(dx) > 120.0 else 0.0
            if absf(dx) < 245.0:
                phase = "bell_windup"
                phase_left = 1.0
                strike_hit = false
        "bell_windup":
            velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
            if phase_left <= 0.0:
                phase = "tidal_rush"
                phase_left = 0.46
                velocity.x = facing * 530.0
        "tidal_rush":
            if not strike_hit and absf(player.global_position.x - global_position.x) < 82.0 and contact_cooldown <= 0.0:
                player.call("take_damage", 1, global_position.x)
                strike_hit = true
                contact_cooldown = 1.0
            if phase_left <= 0.0:
                phase = "recovery"
                phase_left = 1.15
                velocity.x = 0.0
        "recovery":
            velocity.x = move_toward(velocity.x, 0.0, 1000.0 * delta)
            if phase_left <= 0.0:
                phase = "approach"
    velocity.y += GRAVITY * delta
    move_and_slide()
    position.x = clampf(position.x, arena_left, arena_right)
    if is_on_wall() and phase == "tidal_rush":
        phase = "recovery"
        phase_left = 1.15
        velocity.x = 0.0
    if contact_cooldown <= 0.0 and phase != "tidal_rush" and global_position.distance_to(player.global_position) < 51.0:
        player.call("take_damage", 1, global_position.x)
        contact_cooldown = 1.0
    queue_redraw()

func take_damage(amount: int, knock_direction: int) -> void:
    if health <= 0:
        return
    health = maxi(0, health - amount)
    flash_left = 0.14
    if phase != "bell_windup":
        phase = "recovery"
        phase_left = 0.65
    velocity.x = 95.0 * knock_direction
    velocity.y = -75.0
    GameState.set_boss_health(health, MAX_HEALTH, "DROWNED ABBOT")
    if health == 0:
        GameState.mark_crypt_boss_defeated()
        queue_free()

func _draw() -> void:
    var body_color := Color("eff9e0") if flash_left > 0.0 else Color("526f77")
    draw_colored_polygon(PackedVector2Array([Vector2(-26, -34), Vector2(21, -34), Vector2(31, -13), Vector2(27, 29), Vector2(-28, 29), Vector2(-33, -10)]), body_color)
    draw_colored_polygon(PackedVector2Array([Vector2(-23, -27), Vector2(0, -48), Vector2(24, -26)]), Color("344959"))
    draw_circle(Vector2(-11, -18), 3.0, Color("b8f1df"))
    draw_circle(Vector2(11, -18), 3.0, Color("b8f1df"))
    draw_line(Vector2(17 * facing, -4), Vector2(32 * facing, 19), Color("a8c2bf"), 5.0)
    draw_circle(Vector2(36 * facing, 22), 9.0, Color("d8bd81"))
    if phase == "bell_windup":
        draw_arc(Vector2(36 * facing, 22), 25.0, 0.0, TAU, 24, Color("a5eff0", 0.95), 4.0)
        draw_arc(Vector2(36 * facing, 22), 38.0, 0.0, TAU, 32, Color("72b9cd", 0.55), 2.0)
    elif phase == "tidal_rush":
        draw_line(Vector2(-38 * facing, 8), Vector2(-70 * facing, 20), Color("91d6dd", 0.7), 5.0)
