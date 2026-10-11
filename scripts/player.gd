extends CharacterBody2D
const KAEL_IDLE = preload("res://assets/characters/kael_idle.png")
## Player movement, basic sword slash and defensive state.
signal health_changed(current: int, maximum: int)

const MOVE_SPEED := 245.0
const ACCEL := 1650.0
const FRICTION := 2100.0
const JUMP_SPEED := -420.0
const GRAVITY := 1100.0
const COYOTE_SECONDS := 0.105
const JUMP_BUFFER_SECONDS := 0.125
const DASH_SPEED := 560.0
const DASH_SECONDS := 0.17

var max_health: int = 4
var health: int = 4
var facing: int = 1
var coyote_left: float = 0.0
var jump_buffer_left: float = 0.0
var invulnerable_left: float = 0.0
var attack_cooldown: float = 0.0
var attack_left: float = 0.0
var hurt_flash_left: float = 0.0
var animation_time: float = 0.0
var hit_this_swing: Dictionary = {}
var hit_sound_this_swing := false
var dash_left: float = 0.0
var dash_used: bool = false
var pulse_cooldown: float = 0.0
var pulse_left: float = 0.0

@onready var attack_area: Area2D = $AttackArea
@onready var attack_collision: CollisionShape2D = $AttackArea/CollisionShape2D

func _ready() -> void:
    add_to_group("player")
    max_health += 1 if GameState.keeper_upgrade_claimed else 0
    for heart_id in ["crypt_heart_01", "citadel_heart_01", "beacon_crown_01", "reliquary_heart_01"]:
        if GameState.collected_items.has(heart_id):
            max_health += 1
    health = max_health
    health_changed.emit(health, max_health)

func _physics_process(delta: float) -> void:
    animation_time += delta
    if GameState.won:
        velocity = Vector2.ZERO
        return
    invulnerable_left = maxf(0.0, invulnerable_left - delta)
    hurt_flash_left = maxf(0.0, hurt_flash_left - delta)
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    attack_left = maxf(0.0, attack_left - delta)
    dash_left = maxf(0.0, dash_left - delta)
    pulse_cooldown = maxf(0.0, pulse_cooldown - delta)
    pulse_left = maxf(0.0, pulse_left - delta)

    if Input.is_action_just_pressed("shift_realm"):
        GameState.switch_realm()
    if Input.is_action_just_pressed("restart"):
        respawn()
        return

    var axis := Input.get_axis("move_left", "move_right")
    if absf(axis) > 0.05:
        facing = 1 if axis > 0.0 else -1
        velocity.x = move_toward(velocity.x, axis * MOVE_SPEED, ACCEL * delta)
    else:
        velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

    if is_on_floor():
        coyote_left = COYOTE_SECONDS
        dash_used = false
    else:
        coyote_left = maxf(0.0, coyote_left - delta)
    if Input.is_action_just_pressed("jump"):
        jump_buffer_left = JUMP_BUFFER_SECONDS
    else:
        jump_buffer_left = maxf(0.0, jump_buffer_left - delta)
    if jump_buffer_left > 0.0 and coyote_left > 0.0:
        velocity.y = JUMP_SPEED
        jump_buffer_left = 0.0
        coyote_left = 0.0
    if Input.is_action_just_pressed("air_dash") and "air_dash" in GameState.unlocked_abilities and not is_on_floor() and not dash_used:
        dash_used = true
        dash_left = DASH_SECONDS
        velocity = Vector2(DASH_SPEED * facing, 0.0)
    var wall_gripping := "wall_climb" in GameState.unlocked_abilities and is_on_wall() and not is_on_floor() and absf(axis) > 0.1 and axis * get_wall_normal().x < 0.0
    if dash_left > 0.0:
        velocity = Vector2(DASH_SPEED * facing, 0.0)
    elif wall_gripping:
        velocity.y = -175.0 if Input.is_action_pressed("jump") else minf(velocity.y, 75.0)
    else:
        velocity.y += GRAVITY * delta
    if dash_left <= 0.0 and Input.is_action_just_released("jump") and velocity.y < -160.0:
        velocity.y *= 0.55

    if Input.is_action_just_pressed("attack") and attack_cooldown <= 0.0:
        attack_cooldown = 0.33
        attack_left = 0.14
        hit_this_swing.clear()
        hit_sound_this_swing = false
        Sfx.play("sword_swing", -2.0, randf_range(0.94, 1.06))
        GameFeedback.burst(global_position + Vector2(24.0 * facing, -3.0), Color("fff0c8"), 4, 120.0)
    if Input.is_action_just_pressed("lantern_pulse") and pulse_cooldown <= 0.0 and "lantern_pulse" in GameState.unlocked_abilities:
        _cast_lantern_pulse()
    attack_collision.position.x = 33.0 * facing
    move_and_slide()
    if attack_left > 0.0:
        _damage_enemies()
    if position.y > 660.0:
        respawn()
    queue_redraw()

func _damage_enemies() -> void:
    for body in attack_area.get_overlapping_bodies():
        if body.is_in_group("enemies") and not hit_this_swing.has(body.get_instance_id()):
            hit_this_swing[body.get_instance_id()] = true
            if not hit_sound_this_swing:
                Sfx.play("hit", -1.0, randf_range(0.94, 1.06))
                GameFeedback.burst(body.global_position, Color("ffe1a1"), 7, 175.0)
                GameFeedback.shake(1.4, 0.09)
                hit_sound_this_swing = true
            if body.has_method("take_damage"):
                body.call("take_damage", 1, facing)

func _cast_lantern_pulse() -> void:
    pulse_cooldown = (3.5 if GameState.echo_warden_defeated else 5.0) if GameState.collected_items.has("resonant_wick_01") else (4.5 if GameState.echo_warden_defeated else 6.0)
    pulse_left = 0.30
    Sfx.play("lantern_pulse")
    GameFeedback.burst(global_position, Color("bce9ef"), 14, 205.0)
    GameState.lantern_pulse_cast.emit(global_position)
    var pulse_range := (165.0 if GameState.echo_warden_defeated else 145.0) + (25.0 if GameState.collected_items.has("lore_reward_01") else 0.0)
    var pulse_damage := 4 if GameState.echo_warden_defeated else 3
    for body in get_tree().get_nodes_in_group("enemies"):
        if not is_instance_valid(body) or global_position.distance_to(body.global_position) > pulse_range:
            continue
        if body.has_method("take_damage"):
            body.call("take_damage", pulse_damage, 1 if body.global_position.x >= global_position.x else -1)

func take_damage(amount: int, from_x: float) -> void:
    if invulnerable_left > 0.0 or GameState.won:
        return
    health -= amount
    Sfx.play("hurt")
    GameFeedback.burst(global_position, Color("ef9a9d"), 10, 185.0)
    GameFeedback.shake(4.0, 0.16)
    health_changed.emit(health, max_health)
    invulnerable_left = 1.1
    hurt_flash_left = 0.22
    velocity.x = (1 if global_position.x > from_x else -1) * 210.0
    velocity.y = -160.0
    if health <= 0:
        respawn()

func respawn() -> void:
    GameState.set_current_room(GameState.room_for_x(GameState.checkpoint.x))
    global_position = GameState.checkpoint
    velocity = Vector2.ZERO
    health = max_health
    invulnerable_left = 1.3
    health_changed.emit(health, max_health)
    queue_redraw()

func _draw() -> void:
    if not SettingsManager.reduce_flashing and invulnerable_left > 0.0 and int(invulnerable_left * 14.0) % 2 == 0:
        return
    var moving := absf(velocity.x) > 24.0 and is_on_floor()
    var bob := sin(animation_time * (12.0 if moving else 3.5)) * (1.4 if moving else 0.7)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2(float(facing), 1.0))
    var kael_rect := Rect2(Vector2(-25.0, -39.0 + bob), Vector2(50.0, 59.0))
    var tint := Color("f5d8a5") if hurt_flash_left > 0.0 and not SettingsManager.reduce_flashing else Color.WHITE
    draw_texture_rect(KAEL_IDLE, kael_rect, false, tint)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    if attack_left > 0.0:
        var arc_center := Vector2(17.0 * facing, -3.0 + bob)
        draw_arc(arc_center, 31.0, -PI * 0.55 if facing > 0 else PI * 0.45, PI * 0.55 if facing > 0 else PI * 1.55, 22, Color("fff0c8", 0.92), 5.0)
        draw_line(Vector2(8 * facing, -5 + bob), Vector2(29 * facing, 6 + bob), Color("fff0c8"), 3.0)
    if pulse_left > 0.0:
        var radius := 45.0 + (0.30 - pulse_left) * 300.0
        draw_arc(Vector2.ZERO, radius, 0.0, TAU, 44, Color("fff0ba", 0.88), 4.0)
        draw_arc(Vector2.ZERO, radius * 0.72, 0.0, TAU, 36, Color("a8e5ed", 0.68), 2.0)
