extends StaticBody2D
## A clear, non-damaging progression gate controlled by an unlocked ability.
@export var required_ability: String = "air_dash"
var gate_shape: CollisionShape2D

func _ready() -> void:
    collision_layer = 1
    collision_mask = 0
    gate_shape = CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = Vector2(44, 150)
    gate_shape.shape = rect
    add_child(gate_shape)
    GameState.quest_updated.connect(_refresh)
    GameState.room_changed.connect(func(_room): _refresh())
    _refresh()

func _refresh(_unused = null) -> void:
    gate_shape.set_deferred("disabled", required_ability in GameState.unlocked_abilities)
    queue_redraw()

func _draw() -> void:
    var open := required_ability in GameState.unlocked_abilities
    var tint := Color("91ccb9", 0.20) if open else Color("876a7b", 0.95)
    draw_rect(Rect2(-22, -75, 44, 150), tint)
    draw_rect(Rect2(-22, -75, 44, 150), Color("d1c5cf"), false, 3.0)
    var label := "AIR DASH" if required_ability == "air_dash" else "WALL CLIMB"
    draw_string(ThemeDB.fallback_font, Vector2(-48, -88), label if not open else "OPEN", HORIZONTAL_ALIGNMENT_CENTER, 96.0, 12, Color("ffe2a6"))
