extends Area2D
## Optional endgame portal. It opens after the Sovereign falls and all four Echo Sigils are found.
@export var destination := Vector2.ZERO
var nearby := false

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 48.0
	shape.shape = circle
	add_child(shape)
	body_entered.connect(func(body):
		if body.is_in_group("player"):
			nearby = true
	)
	body_exited.connect(func(body):
		if body.is_in_group("player"):
			nearby = false
	)

func _process(_delta: float) -> void:
	if nearby and Input.is_action_just_pressed("interact"):
		if not _is_unlocked():
			GameState.story_message = "The Echo Depths need the Sovereign's defeat and all four Echo Sigils (%d/4)." % GameState.echo_sigil_count()
		else:
			var player = get_tree().get_first_node_in_group("player")
			if is_instance_valid(player):
				player.global_position = destination
				player.velocity = Vector2.ZERO
				Sfx.play("portal")
				GameState.checkpoint = destination
				GameState.checkpoint_changed.emit(destination)
				GameState.set_current_room(GameState.room_for_x(destination.x))
				SaveManager.save_game()
			GameState.story_message = "The fourth sigil opens an ancient path through the Echo Depths."
		GameState.quest_updated.emit()
	queue_redraw()

func _is_unlocked() -> bool:
	return GameState.citadel_boss_defeated and GameState.echo_sigil_count() >= 4

func _draw() -> void:
	var open := _is_unlocked()
	var tint := Color("a8e5d2", 0.9) if open else Color("8f7eaa", 0.7)
	draw_arc(Vector2.ZERO, 31.0, 0.0, TAU, 40, tint, 5.0)
	draw_arc(Vector2.ZERO, 20.0, 0.0, TAU, 32, Color("e8d8ff", 0.65), 2.0)
	draw_circle(Vector2.ZERO, 8.0, Color("fff0ba") if open else Color("51465d"))
	if nearby:
		draw_string(ThemeDB.fallback_font, Vector2(-87, -51), "E  ENTER" if open else "E  SEALED", HORIZONTAL_ALIGNMENT_CENTER, 174.0, 12, Color("fff0bb"))
