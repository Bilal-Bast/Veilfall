extends StaticBody2D
## A Veil barrier that folds away when Lantern Pulse reaches it.
var open := false
var collision: CollisionShape2D

func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	collision = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(34.0, 130.0)
	collision.shape = rect
	add_child(collision)
	GameState.lantern_pulse_cast.connect(_on_pulse)

func _on_pulse(origin: Vector2) -> void:
	if not open and origin.distance_to(global_position) <= 190.0:
		open = true
		collision.set_deferred("disabled", true)
		GameState.story_message = "The chime barrier folds away in the lantern's pulse."
		GameState.quest_updated.emit()
		queue_redraw()

func _draw() -> void:
	if open:
		draw_arc(Vector2.ZERO, 29.0, 0.0, TAU, 30, Color("b8e9eb", 0.5), 2.0)
		return
	draw_rect(Rect2(-17, -65, 34, 130), Color("38304e"))
	draw_rect(Rect2(-13, -60, 26, 120), Color("8b73b2", 0.8))
	draw_line(Vector2(-9, -50), Vector2(9, 50), Color("d4c6ef"), 3.0)
	draw_string(ThemeDB.fallback_font, Vector2(-35, -77), "PULSE", HORIZONTAL_ALIGNMENT_CENTER, 70.0, 11, Color("ffe5af"))
