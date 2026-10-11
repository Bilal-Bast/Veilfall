extends Control
## Compact fog-of-war map for the thirty-eight-room route.
const ROOM_NAMES := ["Lantern Path", "Broken Bridge", "Warden's Clearing", "Lantern Refuge", "Cinder Walk", "Furnace Sentinel", "Sunken Gallery", "Bell Sanctum", "Starless Gallery", "Citadel Approach", "Chime Gallery", "Lens Archive", "Shattered Nave", "Beacon Engine", "Sovereign Approach", "Veil Throne", "Echo Threshold", "Mirror Causeway", "Silent Archive", "Shard Garden", "Echo Warden", "Verdant Memory", "Ember Memory", "Drowned Memory", "Starless Memory", "Beacon Crucible", "Canopy Approach", "Rootheart Vault", "Foundry Flue", "Meltworks", "Crypt Gallery", "Tide Annex", "Observatory Gate", "Astral Causeway", "Reliquary Archive", "Veil Almanac", "Drowned Register", "Starless Testament"]

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    process_mode = Node.PROCESS_MODE_ALWAYS

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color(0.018, 0.025, 0.055, 0.92))
    draw_rect(Rect2(28, 24, 904, 492), Color("172334"))
    draw_rect(Rect2(28, 24, 904, 492), Color("71859a"), false, 2.0)
    draw_string(ThemeDB.fallback_font, Vector2(58, 61), "VALEDORN  •  FIELD MAP", HORIZONTAL_ALIGNMENT_LEFT, 500.0, 22, Color("ffe2a6"))
    draw_string(ThemeDB.fallback_font, Vector2(58, 84), "Discovered rooms reveal route markers for bosses, memories, challenges, and rewards", HORIZONTAL_ALIGNMENT_LEFT, 760.0, 13, Color("b8c8d8"))
    for i in range(20):
        if GameState.visited_rooms.has(i) and GameState.visited_rooms.has(i + 1):
            draw_line(_room_center(i), _room_center(i + 1), Color("8296a9", 0.75), 5.0, true)
    for edge in [Vector2i(2, 21), Vector2i(5, 22), Vector2i(7, 23), Vector2i(8, 24), Vector2i(3, 25), Vector2i(2, 26), Vector2i(26, 27), Vector2i(5, 28), Vector2i(28, 29), Vector2i(6, 30), Vector2i(30, 31), Vector2i(8, 32), Vector2i(32, 33), Vector2i(3, 34), Vector2i(1, 35), Vector2i(6, 36), Vector2i(11, 37)]:
        if GameState.visited_rooms.has(edge.x) and GameState.visited_rooms.has(edge.y):
            draw_line(_room_center(edge.x), _room_center(edge.y), Color("b89fca", 0.85), 4.0, true)
    for i in range(ROOM_NAMES.size()):
        var center := _room_center(i)
        var card := Rect2(center - Vector2(94, 15), Vector2(188, 30))
        var discovered := GameState.visited_rooms.has(i)
        var current := GameState.current_room == i
        var region_color := _region_color(i)
        var fill := Color("655540") if current else (Color("33475b") if discovered else Color("202b3b"))
        var border := Color("ffe2a6") if current else (region_color if discovered else Color("3e4b5a"))
        draw_rect(card, fill)
        draw_rect(card, border, false, 2.0 if discovered or current else 1.0)
        if discovered:
            draw_rect(Rect2(card.position, Vector2(4, card.size.y)), region_color, true)
        var label := ROOM_NAMES[i] if discovered else "???"
        var marker := _room_marker(i) if discovered else ""
        var marker_color := Color("d8e8f3")
        if marker == "B!":
            marker_color = Color("f18b89")
        elif marker == "B+":
            marker_color = Color("9fd6ad")
        elif marker != "":
            marker_color = Color("d6c38e")
        draw_string(ThemeDB.fallback_font, center + Vector2(-86, 5), marker, HORIZONTAL_ALIGNMENT_LEFT, 24.0, 9, marker_color)
        draw_string(ThemeDB.fallback_font, center + Vector2(-61, 5), label, HORIZONTAL_ALIGNMENT_LEFT, 148.0, 11, Color("f0eadc") if discovered else Color("9ba7b2"))
        if current:
            draw_string(ThemeDB.fallback_font, center + Vector2(-61, 16), "YOU ARE HERE", HORIZONTAL_ALIGNMENT_LEFT, 148.0, 8, Color("ffe2a6"))
    draw_string(ThemeDB.fallback_font, Vector2(58, 474), "MARKERS  B! active boss  B+ defeated  H hub  E echo  M memory  C challenge  F folio  R reward", HORIZONTAL_ALIGNMENT_LEFT, 820.0, 10, Color("b8c8d8"))
    draw_string(ThemeDB.fallback_font, Vector2(58, 496), "ROOMS %d/38  ECHO %d/4  MEM %d/4  RELICS %d/4  FOLIOS %d/3" % [GameState.visited_rooms.size(), GameState.echo_sigil_count(), GameState.beacon_memory_count(), GameState.region_relic_count(), GameState.lore_page_count()], HORIZONTAL_ALIGNMENT_LEFT, 670.0, 11, Color("d5e3ee"))
    draw_string(ThemeDB.fallback_font, Vector2(720, 496), "M / BACK TO CLOSE", HORIZONTAL_ALIGNMENT_RIGHT, 190.0, 12, Color("ffe2a6"))

func _room_center(room_id: int) -> Vector2:
    var row := floori(float(room_id) / 4.0)
    var offset := room_id % 4
    var column := offset if row % 2 == 0 else 3 - offset
    return Vector2(155.0 + float(column) * 215.0, 118.0 + float(row) * 35.0)

func _room_marker(room_id: int) -> String:
    if room_id in [2, 5, 7, 15, 20]:
        return "B+" if _boss_defeated(room_id) else "B!"
    if room_id == 3:
        return "H"
    if room_id >= 16 and room_id <= 19:
        return "E"
    if room_id >= 21 and room_id <= 24:
        return "M"
    if room_id >= 26 and room_id <= 33:
        return "C"
    if room_id >= 35 and room_id <= 37:
        return "F"
    if room_id == 25 or room_id == 34:
        return "R"
    return ""

func _boss_defeated(room_id: int) -> bool:
    match room_id:
        2: return GameState.warden_defeated
        5: return GameState.foundry_boss_defeated
        7: return GameState.crypt_boss_defeated
        15: return GameState.citadel_boss_defeated
        20: return GameState.echo_warden_defeated
    return false

func _region_color(room_id: int) -> Color:
    if room_id <= 2: return Color("78a879")
    if room_id == 3: return Color("e2c27b")
    if room_id <= 5: return Color("d5815f")
    if room_id <= 7: return Color("5e9da9")
    if room_id <= 15: return Color("9d86ba")
    if room_id <= 20: return Color("8e83d1")
    if room_id <= 25: return Color("e1bd76")
    if room_id <= 33: return Color("82ae82")
    if room_id == 34: return Color("d7b36f")
    return Color("8e9bac")
