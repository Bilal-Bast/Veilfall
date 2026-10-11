extends CharacterBody2D
## Basic patrolling enemy. Only grounded patrol is in Milestone 1.
var patrol_left: float = 0.0
var patrol_right: float = 0.0
var direction: int = 1
var health: int = 2
var stun_left: float = 0.0
var player
var body_shape: CollisionShape2D

func configure(at: Vector2, left: float, right: float) -> void:
    position = at
    patrol_left = left
    patrol_right = right

func _ready() -> void:
    add_to_group("enemies")
    collision_layer = 4
    collision_mask = 1
    body_shape = CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = Vector2(29, 27)
    body_shape.shape = rect
    add_child(body_shape)
    player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
    stun_left = maxf(0.0, stun_left - delta)
    velocity.y += 1100.0 * delta
    if stun_left <= 0.0:
        if position.x >= patrol_right:
            direction = -1
        elif position.x <= patrol_left:
            direction = 1
        velocity.x = 63.0 * direction
    else:
        velocity.x = move_toward(velocity.x, 0.0, delta * 700.0)
    move_and_slide()
    if not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player")
    if is_instance_valid(player) and global_position.distance_to(player.global_position) < 33.0:
        player.take_damage(1, global_position.x)
    queue_redraw()

func take_damage(amount: int, knock_direction: int) -> void:
    health -= amount
    if health <= 0:
        queue_free()
        return
    stun_left = 0.23
    velocity.x = 165.0 * knock_direction
    velocity.y = -130.0

func _draw() -> void:
    var skin := Color("e8a66b") if stun_left <= 0.0 else Color("ffe3a2")
    draw_circle(Vector2(0, -2), 16.0, Color("553a4c"))
    draw_circle(Vector2(0, -3), 12.0, skin)
    draw_circle(Vector2(-5, -7), 2.5, Color("1b2735"))
    draw_circle(Vector2(5, -7), 2.5, Color("1b2735"))
    draw_line(Vector2(-8, 5), Vector2(9, 5), Color("68374c"), 2.0)
    draw_line(Vector2(-13, 8), Vector2(-21, 15), Color("d38755"), 3.0)
    draw_line(Vector2(13, 8), Vector2(21, 15), Color("d38755"), 3.0)
