extends CharacterBody2D
## Ashling: a short-range Foundry patrol with a quick lunge tell.
var left_edge := 0.0
var right_edge := 0.0
var direction := 1
var health := 2
var lunge_left := 0.0
var attack_cooldown := 0.0
var player: Node2D

func configure(at: Vector2, left: float, right: float) -> void:
    position = at
    left_edge = left
    right_edge = right

func _ready() -> void:
    add_to_group("enemies")
    collision_layer = 4
    collision_mask = 1
    var shape := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = Vector2(32, 30)
    shape.shape = rect
    add_child(shape)

func _physics_process(delta: float) -> void:
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    lunge_left = maxf(0.0, lunge_left - delta)
    if not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as Node2D
    if is_instance_valid(player) and attack_cooldown <= 0.0 and absf(player.global_position.x - global_position.x) < 105.0:
        direction = 1 if player.global_position.x > global_position.x else -1
        lunge_left = 0.16
        attack_cooldown = 1.35
    if lunge_left > 0.0:
        velocity.x = direction * 240.0
    else:
        if position.x <= left_edge:
            direction = 1
        if position.x >= right_edge:
            direction = -1
        velocity.x = direction * 52.0
    velocity.y += 1100.0 * delta
    move_and_slide()
    if is_instance_valid(player) and global_position.distance_to(player.global_position) < 36.0:
        player.take_damage(1, global_position.x)
    queue_redraw()

func take_damage(amount: int, knock_direction: int) -> void:
    health -= amount
    if health <= 0:
        queue_free()
        return
    velocity.x = 150.0 * knock_direction
    velocity.y = -100.0

func _draw() -> void:
    var glow := Color("ffc06d") if lunge_left <= 0.0 else Color("fff0a6")
    draw_colored_polygon(PackedVector2Array([Vector2(-18, 11), Vector2(-13, -7), Vector2(0, -18), Vector2(15, -8), Vector2(19, 9), Vector2(11, 17), Vector2(-13, 17)]), Color("633b48"))
    draw_circle(Vector2(-5, -5), 2.5, glow)
    draw_circle(Vector2(7, -5), 2.5, glow)
    draw_line(Vector2(-12, 12), Vector2(-21, 18), Color("b66549"), 3.0)
    draw_line(Vector2(12, 12), Vector2(20, 18), Color("b66549"), 3.0)
