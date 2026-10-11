extends Node2D
## Lightweight screen-space presentation effects shared by combat and exploration.
const MAX_PARTICLES := 180
var _particles: Array[Dictionary] = []
var _camera: Camera2D
var _camera_home_offset := Vector2.ZERO
var _shake_left := 0.0
var _shake_duration := 0.0
var _shake_power := 0.0
var _overlay: ColorRect
var _realm_tween: Tween

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    z_index = 100
    var layer := CanvasLayer.new()
    layer.layer = 100
    add_child(layer)
    _overlay = ColorRect.new()
    _overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _overlay.color = Color(0.0, 0.0, 0.0, 0.0)
    layer.add_child(_overlay)
    GameState.realm_changed.connect(_on_realm_changed)

func burst(world_position: Vector2, tint: Color, count: int = 6, power: float = 150.0) -> void:
    if SettingsManager.reduce_flashing:
        count = maxi(1, count / 2)
        power *= 0.72
        tint.a *= 0.68
    var available := mini(count, MAX_PARTICLES - _particles.size())
    if available <= 0:
        return
    for i in range(available):
        var angle := TAU * (float(i) / float(available)) + randf_range(-0.18, 0.18)
        var speed := power * randf_range(0.62, 1.0)
        _particles.append({
            "position": world_position,
            "velocity": Vector2.RIGHT.rotated(angle) * speed,
            "life": randf_range(0.20, 0.34),
            "duration": 0.34,
            "size": randf_range(1.5, 3.0),
            "color": tint
        })
    queue_redraw()

func shake(power: float = 2.0, duration: float = 0.12) -> void:
    if SettingsManager.reduce_flashing:
        power *= 0.28
    _shake_power = maxf(_shake_power, power)
    _shake_duration = maxf(_shake_duration, duration)
    _shake_left = maxf(_shake_left, duration)

func _process(delta: float) -> void:
    for i in range(_particles.size() - 1, -1, -1):
        var particle: Dictionary = _particles[i]
        var life := float(particle["life"]) - delta
        if life <= 0.0:
            _particles.remove_at(i)
            continue
        particle["life"] = life
        particle["position"] = Vector2(particle["position"]) + Vector2(particle["velocity"]) * delta
        particle["velocity"] = Vector2(particle["velocity"]) * pow(0.12, delta)
    if not _particles.is_empty():
        queue_redraw()
    _update_camera_shake(delta)

func _update_camera_shake(delta: float) -> void:
    if not is_instance_valid(_camera):
        _camera = get_viewport().get_camera_2d()
        if is_instance_valid(_camera):
            _camera_home_offset = _camera.offset
    if not is_instance_valid(_camera):
        return
    if _shake_left > 0.0:
        _shake_left = maxf(0.0, _shake_left - delta)
        var fade := _shake_left / maxf(_shake_duration, 0.001)
        var offset := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake_power * fade
        _camera.offset = _camera_home_offset + offset
        if _shake_left <= 0.0:
            _camera.offset = _camera_home_offset
            _shake_power = 0.0
            _shake_duration = 0.0

func _on_realm_changed(is_veil: bool) -> void:
    var player := get_tree().get_first_node_in_group("player") as Node2D
    if is_instance_valid(player):
        var tint := Color("c7a5ef") if is_veil else Color("ffe0a0")
        burst(player.global_position, tint, 14, 190.0)
    if SettingsManager.reduce_flashing:
        _transition_overlay(Color("c6b8e6", 0.11), 0.16, 0.32)
    else:
        _transition_overlay(Color("d4c1ff", 0.24) if is_veil else Color("ffe5b3", 0.21), 0.07, 0.28)

func _transition_overlay(tint: Color, fade_in: float, fade_out: float) -> void:
    if is_instance_valid(_realm_tween) and _realm_tween.is_running():
        _realm_tween.kill()
    _overlay.color = Color(tint.r, tint.g, tint.b, 0.0)
    _realm_tween = create_tween()
    _realm_tween.tween_property(_overlay, "color", tint, fade_in)
    _realm_tween.tween_property(_overlay, "color:a", 0.0, fade_out)

func _draw() -> void:
    for particle in _particles:
        var duration := float(particle["duration"])
        var alpha := clampf(float(particle["life"]) / maxf(duration, 0.001), 0.0, 1.0)
        var tint: Color = particle["color"]
        tint.a *= alpha
        var position: Vector2 = particle["position"]
        var velocity: Vector2 = particle["velocity"]
        draw_line(position - velocity.normalized() * 4.0, position, tint, 1.5, true)
        draw_circle(position, float(particle["size"]) * alpha, tint)
