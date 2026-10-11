extends Node2D
## Standalone visual review scene for the Woods clearing; it never writes save data.
@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD

func _enter_tree() -> void:
	GameState.current_room = 2
	GameState.checkpoint = Vector2(2130.0, 399.0)
	GameState.warden_defeated = true
	if not GameState.visited_rooms.has(2):
		GameState.visited_rooms.append(2)
	GameState.shards = 1
	if not GameState.collected_items.has("lantern_shard_woods_01"):
		GameState.collected_items.append("lantern_shard_woods_01")

func _ready() -> void:
	var camera: Camera2D = player.get_node("Camera2D")
	camera.limit_left = 1920
	camera.limit_right = 2880
	camera.offset = Vector2.ZERO
	player.set_physics_process(false)
	hud.visible = false
	if OS.get_cmdline_user_args().has("--capture-review"):
		call_deferred("_capture_review")

func _process(_delta: float) -> void:
	hud.update_status(player)

func _capture_review() -> void:
	await get_tree().create_timer(1.2).timeout
	var image := get_viewport().get_texture().get_image()
	var output_path := "res://docs/terrain/woods-clearing-review.png"
	var error := image.save_png(output_path)
	if error != OK:
		push_error("Woods clearing review screenshot failed: %s" % error_string(error))
	else:
		print("Woods clearing review screenshot: %s" % output_path)
	get_tree().quit()
