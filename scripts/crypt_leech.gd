extends CharacterBody2D
## A drowned crawler that patrols dry ledges and lunges when Kael comes close.
var patrol_left := 0.0
var patrol_right := 0.0
var direction := 1
var health := 3
var lunge_left := 0.0
var cooldown := 0.0
var player: Node2D

func configure(at: Vector2, left: float, right: float) -> void:
    position = at
    patrol_left = left
    patrol_right = right

func _ready() -> void:
    add_to_group("enemies")
    collision_layer = 4
    collision_mask = 1
    var shape := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = Vector2(38, 28)
    shape.shape = rect
    add_child(shape)

func _physics_process(delta: float) -> void:
    cooldown = maxf(0.0, cooldown - delta)
    lunge_left = maxf(0.0, lunge_left - delta)
    if not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as Node2D
    if is_instance_valid(player) and cooldown <= 0.0 and absf(player.global_position.x - global_position.x) < 125.0:
        direction = 1 if player.global_position.x > global_position.x else -1
        lunge_left = 0.22
        cooldown = 1.65
    if lunge_left > 0.0:
        velocity.x = direction * 270.0
    else:
        if position.x < patrol_left:
            direction = 1
        elif position.x > patrol_right:
            direction = -1
        velocity.x = direction * 45.0
    velocity.y += 1100.0 * delta
    move_and_slide()
    if is_instance_valid(player) and global_position.distance_to(player.global_position) < 39.0:
        player.call("take_damage", 1, global_position.x)
    queue_redraw()

func take_damage(amount: int, knock_direction: int) -> void:
    health -= amount
    if health <= 0:
        queue_free()
        return
    velocity.x = 170.0 * knock_direction
    velocity.y = -115.0

func _draw() -> void:
    var body := Color("4c7180") if lunge_left <= 0.0 else Color("9ed7d5")
    draw_colored_polygon(PackedVector2Array([Vector2(-22, 9), Vector2(-16, -8), Vector2(-5, -15), Vector2(12, -13), Vector2(21, 1), Vector2(14, 13), Vector2(-14, 14)]), body)
    draw_circle(Vector2(8 * direction, -5), 3.0, Color("f6dc9d"))
    draw_line(Vector2(-12, 11), Vector2(-20, 18), Color("a4b8a7"), 3.0)
    draw_line(Vector2(12, 11), Vector2(20, 18), Color("a4b8a7"), 3.0)
