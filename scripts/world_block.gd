extends StaticBody2D
## A solid block or a solid-in-the-Veil spectral platform.
const WOODS_ATLAS = preload("res://assets/tilesets/whispering_woods.png")
var dimensions: Vector2 = Vector2(160, 24)
var spectral: bool = false
var foundry_style: bool = false
var region_style := "woods"
var collision: CollisionShape2D

func configure(at: Vector2, size: Vector2, in_veil: bool = false) -> void:
    position = at
    dimensions = size
    spectral = in_veil

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    collision_layer = 1
    collision_mask = 0
    collision = CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = dimensions
    collision.shape = shape
    add_child(collision)
    GameState.realm_changed.connect(_on_realm_changed)
    _on_realm_changed(GameState.is_veil)

func _on_realm_changed(active: bool) -> void:
    if spectral:
        collision.set_deferred("disabled", not active)
    queue_redraw()

func _draw() -> void:
    var r := Rect2(-dimensions / 2.0, dimensions)
    if spectral:
        var alpha := 0.94 if GameState.is_veil else 0.20
        var spectral_tint := Color("f09b78", alpha) if region_style == "foundry" else (Color("65c7d1", alpha) if region_style == "crypt" else (Color("b4a1ef", alpha) if region_style == "citadel" else Color(0.45, 0.72, 1.0, alpha)))
        var spectral_edge := Color("ffd19a", alpha) if region_style == "foundry" else (Color("b8f7ec", alpha) if region_style == "crypt" else (Color("f1e5ff", alpha) if region_style == "citadel" else Color(0.80, 0.94, 1.0, alpha)))
        draw_rect(r, spectral_tint)
        draw_rect(Rect2(r.position, Vector2(dimensions.x, 5)), spectral_edge)
        draw_rect(r, Color(0.9, 0.9, 1.0, alpha), false, 2.0)
    elif region_style == "foundry" or foundry_style:
        draw_rect(r, Color("493641"))
        draw_rect(Rect2(r.position, Vector2(dimensions.x, 5)), Color("d07958"))
        for x in range(16, int(dimensions.x), 48):
            draw_line(Vector2(r.position.x + x, r.position.y + 8), Vector2(r.position.x + x, r.end.y - 3), Color("76505a"), 2.0)
        draw_rect(r, Color("241f31", 0.7), false, 2.0)
    elif region_style == "crypt":
        draw_rect(r, Color("263b4a"))
        draw_rect(Rect2(r.position, Vector2(dimensions.x, 5)), Color("71aeb3"))
        for x in range(24, int(dimensions.x), 48):
            draw_line(Vector2(r.position.x + x, r.position.y + 8), Vector2(r.position.x + x, r.end.y - 2), Color("3b5a67"), 2.0)
        draw_rect(r, Color("101d2b", 0.72), false, 2.0)
    elif region_style == "citadel":
        draw_rect(r, Color("37314e"))
        draw_rect(Rect2(r.position, Vector2(dimensions.x, 5)), Color("aaa0d5"))
        draw_line(Vector2(r.position.x + 4, r.position.y + 10), Vector2(r.end.x - 4, r.position.y + 10), Color("6e638d"), 2.0)
        draw_rect(r, Color("19172d", 0.76), false, 2.0)
    elif region_style == "echo":
        draw_rect(r, Color("244b55"))
        draw_rect(Rect2(r.position, Vector2(dimensions.x, 5)), Color("91d9c9"))
        for x in range(20, int(dimensions.x), 64):
            draw_line(Vector2(r.position.x + x, r.position.y + 8), Vector2(r.position.x + x - 9, r.end.y - 3), Color("547d87"), 2.0)
        draw_rect(r, Color("182e3a", 0.7), false, 2.0)
    else:
        var cols := ceili(dimensions.x / 32.0)
        var rows := ceili(dimensions.y / 32.0)
        for row in range(rows):
            for col in range(cols):
                var cell := Vector2(col * 32.0, row * 32.0)
                var cell_size := Vector2(minf(32.0, dimensions.x - cell.x), minf(32.0, dimensions.y - cell.y))
                var source_x := 0 if row == 0 else 32
                var source := Rect2(source_x, 0, cell_size.x, cell_size.y)
                var destination := Rect2(r.position + cell, cell_size)
                draw_texture_rect_region(WOODS_ATLAS, destination, source)
        draw_rect(r, Color("182027", 0.65), false, 2.0)
