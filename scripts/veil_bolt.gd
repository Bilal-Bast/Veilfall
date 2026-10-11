extends Area2D
## Slow, readable projectile fired by the Veil Archer.
var heading := Vector2.LEFT
var speed := 235.0
var life := 3.2

func set_heading(from: Vector2, target: Vector2) -> void:
	global_position = from
	heading = (target - from).normalized()

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 9.0
	shape.shape = circle
	add_child(shape)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += heading * speed * delta
	life -= delta
	if life <= 0.0:
		queue_free()
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.call("take_damage", 1, global_position.x)
		queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 8.0, Color("916fd1", 0.7))
	draw_circle(Vector2.ZERO, 4.0, Color("e8dcff"))
