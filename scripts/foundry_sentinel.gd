extends CharacterBody2D
## Furnace Sentinel: hammer wind-up, ground-rushing strike, and punishable recovery.
const MAX_HEALTH := 9
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
var attack_hit := false

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
    rect.size = Vector2(58, 70)
    shape.shape = rect
    add_child(shape)
    if GameState.foundry_boss_defeated:
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
    if absf(dx) < 270.0 and not GameState.boss_engaged:
        GameState.boss_engaged = true
        GameState.set_boss_health(health, MAX_HEALTH, "FURNACE SENTINEL")
    if absf(dx) > 2.0:
        facing = 1 if dx > 0.0 else -1
    match phase:
        "approach":
            velocity.x = facing * 58.0 if absf(dx) > 112.0 else 0.0
            if absf(dx) < 230.0:
                phase = "windup"
                phase_left = 0.9
                attack_hit = false
        "windup":
            velocity.x = move_toward(velocity.x, 0.0, 1000.0 * delta)
            if phase_left <= 0.0:
                phase = "strike"
                phase_left = 0.34
                velocity.x = facing * 470.0
        "strike":
            if not attack_hit and absf(player.global_position.x - global_position.x) < 78.0 and contact_cooldown <= 0.0:
                player.call("take_damage", 1, global_position.x)
                contact_cooldown = 1.0
                attack_hit = true
            if phase_left <= 0.0:
                phase = "recover"
                phase_left = 1.0
                velocity.x = 0.0
        "recover":
            velocity.x = move_toward(velocity.x, 0.0, 1100.0 * delta)
            if phase_left <= 0.0:
                phase = "approach"
    velocity.y += GRAVITY * delta
    move_and_slide()
    position.x = clampf(position.x, arena_left, arena_right)
    if contact_cooldown <= 0.0 and phase != "strike" and global_position.distance_to(player.global_position) < 48.0:
        player.call("take_damage", 1, global_position.x)
        contact_cooldown = 1.0
    queue_redraw()

func take_damage(amount: int, knock_direction: int) -> void:
    if health <= 0:
        return
    health = maxi(0, health - amount)
    flash_left = 0.16
    if phase != "windup":
        phase = "recover"
        phase_left = 0.55
    velocity.x = 105.0 * knock_direction
    velocity.y = -70.0
    GameState.set_boss_health(health, MAX_HEALTH, "FURNACE SENTINEL")
    if health == 0:
        GameState.mark_foundry_boss_defeated()
        GameState.story_message = "The Sentinel's core cools. Air Dash is yours; return its ember to Mira."
        queue_free()

func _draw() -> void:
    var body_color := Color("fff0c0") if flash_left > 0.0 else Color("78504f")
    draw_colored_polygon(PackedVector2Array([Vector2(-24, -32), Vector2(22, -32), Vector2(30, -10), Vector2(27, 29), Vector2(-27, 29), Vector2(-31, -9)]), body_color)
    draw_rect(Rect2(-20, -24, 40, 8), Color("3a2d3b"))
    draw_rect(Rect2(-14, -22, 8, 4), Color("ffbd68") if phase != "windup" else Color("fff07b"))
    draw_rect(Rect2(6, -22, 8, 4), Color("ffbd68") if phase != "windup" else Color("fff07b"))
    draw_line(Vector2(18 * facing, -8), Vector2(34 * facing, 18), Color("b4a3a0"), 6.0)
    draw_rect(Rect2(25 * facing - 8, 14, 18, 15), Color("d08358"))
    if phase == "windup":
        draw_arc(Vector2(0, -40), 42, PI, TAU, 24, Color("ffb35f", 0.95), 4.0)
    elif phase == "strike":
        draw_line(Vector2(-35 * facing, 20), Vector2(35 * facing, 20), Color("ff8a55", 0.8), 5.0)
