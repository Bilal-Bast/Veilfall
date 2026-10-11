extends Node2D
## Room host: composes authored and reusable challenge rooms with seamless boundaries.
const ROOM_WIDTH := 960.0
const BACKGROUND_WOODS = preload("res://assets/backgrounds/regions/whispering_woods.jpg")
const BACKGROUND_REFUGE = preload("res://assets/backgrounds/regions/lantern_refuge.jpg")
const BACKGROUND_FOUNDRY = preload("res://assets/backgrounds/regions/ashen_foundry.jpg")
const BACKGROUND_CRYPT = preload("res://assets/backgrounds/regions/drowned_crypt.jpg")
const BACKGROUND_CITADEL = preload("res://assets/backgrounds/regions/veil_citadel.jpg")
const BACKGROUND_ECHO = preload("res://assets/backgrounds/regions/echo_depths.jpg")
const ROOM_SCENES: Array[PackedScene] = [
    preload("res://scenes/rooms/woods_entry.tscn"),
    preload("res://scenes/rooms/woods_bridge.tscn"),
    preload("res://scenes/rooms/woods_clearing.tscn"),
    preload("res://scenes/rooms/lantern_refuge.tscn"),
    preload("res://scenes/rooms/foundry_entry.tscn"),
    preload("res://scenes/rooms/foundry_sentinel.tscn"),
    preload("res://scenes/rooms/crypt_entry.tscn"),
    preload("res://scenes/rooms/crypt_sanctum.tscn"),
    preload("res://scenes/rooms/citadel_gallery.tscn"),
    preload("res://scenes/rooms/citadel_approach.tscn"),
    preload("res://scenes/rooms/chime_gallery.tscn"),
    preload("res://scenes/rooms/lens_archive.tscn"),
    preload("res://scenes/rooms/shattered_nave.tscn"),
    preload("res://scenes/rooms/beacon_engine.tscn"),
    preload("res://scenes/rooms/sovereign_approach.tscn"),
    preload("res://scenes/rooms/citadel_throne.tscn"),
    preload("res://scenes/rooms/echo_threshold.tscn"),
    preload("res://scenes/rooms/mirror_causeway.tscn"),
    preload("res://scenes/rooms/silent_archive.tscn"),
    preload("res://scenes/rooms/shard_garden.tscn"),
    preload("res://scenes/rooms/echo_warden_arena.tscn"),
    preload("res://scenes/rooms/woods_entry.tscn"),
    preload("res://scenes/rooms/woods_entry.tscn"),
    preload("res://scenes/rooms/woods_entry.tscn"),
    preload("res://scenes/rooms/woods_entry.tscn"),
    preload("res://scenes/rooms/woods_entry.tscn"),
    preload("res://scenes/rooms/woods_entry.tscn"),
    preload("res://scenes/rooms/woods_entry.tscn"),
    preload("res://scenes/rooms/woods_entry.tscn"),
    preload("res://scenes/rooms/woods_entry.tscn"),
    preload("res://scenes/rooms/woods_entry.tscn"),
    preload("res://scenes/rooms/woods_entry.tscn"),
    preload("res://scenes/rooms/woods_entry.tscn"),
    preload("res://scenes/rooms/woods_entry.tscn"),
    preload("res://scenes/rooms/woods_entry.tscn"),
    preload("res://scenes/rooms/woods_entry.tscn"),
    preload("res://scenes/rooms/woods_entry.tscn"),
    preload("res://scenes/rooms/woods_entry.tscn")
]

func _ready() -> void:
    GameState.realm_changed.connect(_on_realm_changed)
    for room_index in range(ROOM_SCENES.size()):
        var room = ROOM_SCENES[room_index].instantiate()
        if room_index >= 21:
            room.room_id = room_index
        room.position = Vector2(room_index * ROOM_WIDTH, 0.0)
        add_child(room)

func _physics_process(_delta: float) -> void:
    var player := get_tree().get_first_node_in_group("player") as Node2D
    if is_instance_valid(player):
        GameState.set_current_room(GameState.room_for_x(player.global_position.x))

func _on_realm_changed(_is_veil: bool) -> void:
    queue_redraw()

func _draw() -> void:
    var dark := GameState.is_veil
    var sky := Color("1c1736") if dark else Color("203e52")
    var hill := Color("372951") if dark else Color("315466")
    var farther := Color("291f45") if dark else Color("294957")
    draw_rect(Rect2(-200, -400, ROOM_WIDTH * ROOM_SCENES.size() + 400, 1000), sky)
    draw_rect(Rect2(ROOM_WIDTH * 4.0, -400, ROOM_WIDTH * 2.0, 1000), Color("211e36") if dark else Color("472c3a"))
    draw_rect(Rect2(ROOM_WIDTH * 6.0, -400, ROOM_WIDTH * 2.0, 1000), Color("10172c") if dark else Color("172d40"))
    draw_rect(Rect2(ROOM_WIDTH * 8.0, -400, ROOM_WIDTH * 8.0, 1000), Color("121027") if dark else Color("272640"))
    draw_rect(Rect2(ROOM_WIDTH * 16.0, -400, ROOM_WIDTH * 5.0, 1000), Color("0c1d2a") if dark else Color("1b3c42"))
    draw_rect(Rect2(ROOM_WIDTH * 26.0, -400, ROOM_WIDTH * 2.0, 1000), Color("211c36") if dark else Color("274b51"))
    draw_rect(Rect2(ROOM_WIDTH * 28.0, -400, ROOM_WIDTH * 2.0, 1000), Color("291b35") if dark else Color("52313a"))
    draw_rect(Rect2(ROOM_WIDTH * 30.0, -400, ROOM_WIDTH * 2.0, 1000), Color("111d32") if dark else Color("1e3443"))
    draw_rect(Rect2(ROOM_WIDTH * 32.0, -400, ROOM_WIDTH * 2.0, 1000), Color("17152f") if dark else Color("31314e"))
    draw_rect(Rect2(ROOM_WIDTH * 34.0, -400, ROOM_WIDTH, 1000), Color("241d3d") if dark else Color("47505a"))
    draw_rect(Rect2(ROOM_WIDTH * 35.0, -400, ROOM_WIDTH, 1000), Color("211c36") if dark else Color("274b51"))
    draw_rect(Rect2(ROOM_WIDTH * 36.0, -400, ROOM_WIDTH, 1000), Color("111d32") if dark else Color("1e3443"))
    draw_rect(Rect2(ROOM_WIDTH * 37.0, -400, ROOM_WIDTH, 1000), Color("17152f") if dark else Color("31314e"))
    draw_circle(Vector2(500, 5), 92, Color("ae90d7", 0.3) if dark else Color("f8d69e", 0.30))
    draw_circle(Vector2(500, 5), 49, Color("ceb6ef", 0.7) if dark else Color("ffe3b8", 0.75))
    for i in range(18):
        var tx := float(i * 190 - 160)
        var height := float(170 + i % 4 * 23)
        draw_colored_polygon(PackedVector2Array([Vector2(tx - 200, 445), Vector2(tx + 25, 445 - height), Vector2(tx + 215, 445)]), farther)
    for i in range(26):
        var x := float(i * 120 + 45)
        var h := float(85 + (i * 43) % 80)
        draw_rect(Rect2(x - 12, 420 - h, 24, h), Color("202940") if dark else Color("253d4c"))
        draw_colored_polygon(PackedVector2Array([Vector2(x - 51, 380 - h), Vector2(x, 300 - h), Vector2(x + 51, 380 - h)]), hill)
        draw_colored_polygon(PackedVector2Array([Vector2(x - 43, 420 - h), Vector2(x, 345 - h), Vector2(x + 43, 420 - h)]), hill)
    for x in [0.0, ROOM_WIDTH, ROOM_WIDTH * 2.0, ROOM_WIDTH * 3.0, ROOM_WIDTH * 4.0, ROOM_WIDTH * 5.0]:
        draw_rect(Rect2(x + 28, 250, 14, 170), Color("57445e") if dark else Color("4b6570"))
        draw_rect(Rect2(x + 10, 245, 50, 15), Color("796582") if dark else Color("66818b"))
    draw_arc(Vector2(2710, 310), 86, PI, TAU, 50, Color("af9ac3") if dark else Color("6b8492"), 8)
    draw_rect(Rect2(2622, 306, 15, 114), Color("78627f") if dark else Color("607a88"))
    draw_rect(Rect2(2783, 306, 15, 114), Color("78627f") if dark else Color("607a88"))
    for i in range(8):
        var forge_x := 4020.0 + i * 235.0
        var forge_height := 155.0 + float(i % 3) * 24.0
        draw_colored_polygon(PackedVector2Array([Vector2(forge_x - 95, 450), Vector2(forge_x, 365 - forge_height), Vector2(forge_x + 105, 450)]), Color("642f40") if not dark else Color("3a274f"))
        draw_rect(Rect2(forge_x - 8, 420 - forge_height, 16, forge_height), Color("9a493d") if not dark else Color("543c70"))
    for i in range(14):
        var crypt_x := 5800.0 + i * 137.0
        var spike_height := float(35 + (i * 29) % 72)
        draw_colored_polygon(PackedVector2Array([Vector2(crypt_x - 28, -65), Vector2(crypt_x, -65 + spike_height), Vector2(crypt_x + 30, -65)]), Color("26394b") if not dark else Color("37324f"))
        draw_colored_polygon(PackedVector2Array([Vector2(crypt_x - 34, 420), Vector2(crypt_x, 420 - spike_height), Vector2(crypt_x + 32, 420)]), Color("243d4d") if not dark else Color("302d49"))
    for i in range(38):
        var tower_x := 7720.0 + i * 205.0
        var tower_h := 135.0 + float(i % 4) * 40.0
        draw_rect(Rect2(tower_x, 420 - tower_h, 30, tower_h), Color("25233e") if dark else Color("48475f"))
        draw_colored_polygon(PackedVector2Array([Vector2(tower_x - 24, 420 - tower_h), Vector2(tower_x + 15, 330 - tower_h), Vector2(tower_x + 54, 420 - tower_h)]), Color("373054") if dark else Color("62627c"))
    for i in range(38):
        var star_x := float((i * 269 + 70) % int(ROOM_WIDTH * ROOM_SCENES.size()))
        var star_y := float((i * 53) % 235 - 120)
        draw_circle(Vector2(star_x, star_y), 1.7 if dark else 1.0, Color("e4e1fa", 0.75) if dark else Color("ffefc9", 0.24))
    for i in range(15):
        var firefly_x := float((i * 211 + 90) % int(ROOM_WIDTH * ROOM_SCENES.size()))
        var firefly_y := float(278 + (i * 47) % 120)
        draw_circle(Vector2(firefly_x, firefly_y), 3.0, Color("c2a5ec", 0.55) if dark else Color("f2d48f", 0.62))
        draw_circle(Vector2(firefly_x, firefly_y), 7.0, Color("b7a1da", 0.08) if dark else Color("e6d39a", 0.10))
    for x in [265.0, 760.0, 1370.0, 1830.0, 2310.0, 6030.0, 6550.0, 7100.0]:
        draw_line(Vector2(x, 40), Vector2(x + 7.0, 134), Color("211f35", 0.8) if dark else Color("1e3440", 0.76), 4.0)
        draw_line(Vector2(x + 7.0, 134), Vector2(x + 18.0, 167), Color("211f35", 0.8) if dark else Color("1e3440", 0.76), 3.0)

    # Region illustrations sit behind geometry and characters; veil mode tints each frame.
    for room_index in range(ROOM_SCENES.size()):
        var texture := _background_for_room(room_index)
        var frame := Rect2(room_index * ROOM_WIDTH, -55.0, ROOM_WIDTH, 595.0)
        draw_texture_rect(texture, frame, false, Color(0.76, 0.77, 0.95, 1.0) if dark else Color.WHITE)
        if dark:
            draw_rect(frame, Color(0.08, 0.035, 0.18, 0.30), true)

func _background_for_room(room_id: int) -> Texture2D:
    if room_id == 3 or room_id == 25 or room_id == 34:
        return BACKGROUND_REFUGE
    if room_id in [4, 5, 22, 28, 29]:
        return BACKGROUND_FOUNDRY
    if room_id in [6, 7, 23, 30, 31, 36]:
        return BACKGROUND_CRYPT
    if room_id in [8, 9, 10, 11, 12, 13, 14, 15, 24, 32, 33, 37]:
        return BACKGROUND_CITADEL
    if room_id in [16, 17, 18, 19, 20]:
        return BACKGROUND_ECHO
    return BACKGROUND_WOODS
