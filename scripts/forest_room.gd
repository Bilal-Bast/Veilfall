extends Node2D
## Reusable room scene for the handcrafted Whispering Woods route.
const BLOCK = preload("res://scripts/world_block.gd")
const ENEMY = preload("res://scripts/enemy.gd")
const CHECKPOINT = preload("res://scripts/checkpoint.gd")
const SHARD = preload("res://scripts/shard.gd")
const GATE = preload("res://scripts/exit_gate.gd")
const WARDEN = preload("res://scripts/warden_boss.gd")
const KEEPER = preload("res://scripts/lantern_keeper.gd")
const FOUNDRY_ENEMY = preload("res://scripts/foundry_enemy.gd")
const SENTINEL = preload("res://scripts/foundry_sentinel.gd")
const CRYPT_LEECH = preload("res://scripts/crypt_leech.gd")
const ABBOT = preload("res://scripts/drowned_abbot.gd")
const ABILITY_GATE = preload("res://scripts/ability_gate.gd")
const SOVEREIGN = preload("res://scripts/veil_sovereign.gd")
const RIFT_MOTH = preload("res://scripts/rift_moth.gd")
const VEIL_ARCHER = preload("res://scripts/veil_archer.gd")
const ECHO_WARDEN = preload("res://scripts/echo_warden.gd")

@export_range(0, 37) var room_id: int = 0

func _ready() -> void:
    match room_id:
        0:
            _build_entry_room()
        1:
            _build_bridge_room()
        2:
            _build_clearing_room()
        3:
            _build_refuge()
        4:
            _build_foundry_entry()
        5:
            _build_foundry_arena()
        6:
            _build_crypt_entry()
        7:
            _build_crypt_sanctum()
        8:
            _build_citadel_gallery()
        9:
            _build_citadel_approach()
        10:
            _build_chime_gallery()
        11:
            _build_lens_archive()
        12:
            _build_shattered_nave()
        13:
            _build_beacon_engine()
        14:
            _build_sovereign_approach()
        15:
            _build_citadel_throne()
        16:
            _build_echo_threshold()
        17:
            _build_mirror_causeway()
        18:
            _build_silent_archive()
        19:
            _build_shard_garden()
        20:
            _build_echo_warden_arena()
        21:
            _build_memory_room("memory_woods_01", "Verdant Memory", Vector2(2460, 399))
        22:
            _build_memory_room("memory_foundry_01", "Ember Memory", Vector2(5180, 399))
        23:
            _build_memory_room("memory_crypt_01", "Drowned Memory", Vector2(7100, 399))
        24:
            _build_memory_room("memory_citadel_01", "Starless Memory", Vector2(8060, 399))
        25:
            _build_beacon_crucible()
        26:
            _build_expansion_entrance("canopy")
        27:
            _build_expansion_relic("relic_woods_01", "Verdant Relic", Vector2(2460, 399))
        28:
            _build_expansion_entrance("foundry")
        29:
            _build_expansion_relic("relic_foundry_01", "Ember Relic", Vector2(5180, 399))
        30:
            _build_expansion_entrance("crypt")
        31:
            _build_expansion_relic("relic_crypt_01", "Drowned Relic", Vector2(6140, 399))
        32:
            _build_expansion_entrance("citadel")
        33:
            _build_expansion_relic("relic_citadel_01", "Starless Relic", Vector2(8060, 399))
        34:
            _build_reliquary()
        35:
            _build_archive_secret("lore_woods_01", "The Veil Almanac", Vector2(1360, 399))
        36:
            _build_archive_secret("lore_crypt_01", "The Drowned Register", Vector2(6160, 399))
        37:
            _build_archive_secret("lore_citadel_01", "The Starless Testament", Vector2(10920, 399))

func _make_block(at: Vector2, size: Vector2, spectral: bool = false) -> void:
    var block = BLOCK.new()
    block.configure(at, size, spectral)
    block.region_style = _region_style()
    block.foundry_style = block.region_style == "foundry"
    add_child(block)

func _region_style() -> String:
    if room_id in [4, 5, 22, 28, 29]:
        return "foundry"
    if room_id in [6, 7, 23, 30, 31, 36]:
        return "crypt"
    if room_id in [8, 9, 10, 11, 12, 13, 14, 15, 24, 32, 33, 37]:
        return "citadel"
    if room_id in [16, 17, 18, 19, 20]:
        return "echo"
    return "woods"

func _make_enemy(at: Vector2, left: float, right: float) -> void:
    var enemy = ENEMY.new()
    enemy.configure(at, left, right)
    add_child(enemy)

func _make_foundry_enemy(at: Vector2, left: float, right: float) -> void:
    var enemy = FOUNDRY_ENEMY.new()
    enemy.configure(at, left, right)
    add_child(enemy)

func _build_entry_room() -> void:
    _make_block(Vector2(425, 480), Vector2(850, 120))
    _make_block(Vector2(350, 342), Vector2(155, 20))
    _make_block(Vector2(685, 320), Vector2(140, 20))
    _make_block(Vector2(926, 394), Vector2(150, 22), true)
    _make_enemy(Vector2(520, 402), 470, 760)

func _build_bridge_room() -> void:
    _make_block(Vector2(1510 - 960, 480), Vector2(660, 120))
    _make_block(Vector2(1078 - 960, 363), Vector2(150, 22), true)
    _make_block(Vector2(1625 - 960, 336), Vector2(170, 20))
    _make_block(Vector2(1900 - 960, 392), Vector2(150, 22), true)
    _make_enemy(Vector2(1520 - 960, 402), 1370 - 960, 1710 - 960)
    var checkpoint = CHECKPOINT.new()
    checkpoint.position = Vector2(1270 - 960, 365)
    add_child(checkpoint)
    _add_echo_sigil("echo_woods_01", Vector2(665, 302))
    _add_memory_portal(Vector2(320, 395), Vector2(35 * 960 + 120, 399), "lore_veil", "The Scribe's folio arch answers only in the Veil, after accepting the quest.")

func _build_clearing_room() -> void:
    _make_block(Vector2(2490 - 1920, 480), Vector2(780, 120))
    _make_block(Vector2(2850 - 1920, 300), Vector2(35, 480))
    _make_block(Vector2(2050 - 1920, 372), Vector2(150, 22), true)
    _make_block(Vector2(2380 - 1920, 334), Vector2(155, 20))
    _make_enemy(Vector2(2220 - 1920, 402), 2140 - 1920, 2310 - 1920)
    if GameState.warden_defeated:
        if not GameState.collected_items.has("lantern_shard_woods_01"):
            var shard = SHARD.new()
            shard.position = Vector2(2460 - 1920, 323)
            add_child(shard)
    else:
        var warden = WARDEN.new()
        warden.configure(Vector2(2460 - 1920, 391), 2360 - 1920, 2590 - 1920)
        add_child(warden)
    var gate = GATE.new()
    gate.position = Vector2(2730 - 1920, 370)
    add_child(gate)
    _add_memory_portal(Vector2(210, 395), Vector2(21 * 960 + 120, 399), "warden", "The clearing's memory opens after the Warden falls.")
    _add_memory_portal(Vector2(360, 395), Vector2(26 * 960 + 120, 399), "air_dash", "The canopy route needs Air Dash.")

func _build_refuge() -> void:
    _make_block(Vector2(480, 480), Vector2(960, 120))
    _make_block(Vector2(160, 355), Vector2(170, 20))
    _make_block(Vector2(800, 355), Vector2(170, 20))
    var checkpoint = CHECKPOINT.new()
    checkpoint.position = Vector2(330, 365)
    add_child(checkpoint)
    var keeper = KEEPER.new()
    keeper.position = Vector2(590, 393)
    add_child(keeper)
    var scribe = load("res://scripts/archive_scribe.gd").new()
    scribe.position = Vector2(430, 393)
    add_child(scribe)
    var echo_portal = load("res://scripts/echo_portal.gd").new()
    echo_portal.position = Vector2(760, 395)
    echo_portal.destination = Vector2(15480, 399)
    add_child(echo_portal)
    _make_block(Vector2(480, 260), Vector2(210, 18))
    var refuge_waystone = load("res://scripts/shortcut_gate.gd").new()
    refuge_waystone.position = Vector2(900, 395)
    refuge_waystone.destination = Vector2(14540, 399)
    add_child(refuge_waystone)
    _add_memory_portal(Vector2(100, 395), Vector2(25 * 960 + 120, 399), "memories", "Mira's beacon chamber needs all four regional memories (%d/4)." % GameState.beacon_memory_count())
    _add_memory_portal(Vector2(270, 395), Vector2(34 * 960 + 120, 399), "relics", "The Reliquary needs four regional relics (%d/4)." % GameState.region_relic_count())

func _build_foundry_entry() -> void:
    _make_block(Vector2(440, 480), Vector2(880, 120))
    _make_block(Vector2(435, 365), Vector2(130, 20))
    _make_block(Vector2(690, 365), Vector2(130, 20), true)
    _make_foundry_enemy(Vector2(540, 402), 395, 670)
    # A tucked-away cache is visible and reachable only while the spectral bridge is solid.
    var cache_script := load("res://scripts/foundry_cache.gd")
    var cache = cache_script.new()
    cache.position = Vector2(770, 328)
    add_child(cache)
    _add_echo_sigil("echo_foundry_01", Vector2(690, 330))

func _build_foundry_arena() -> void:
    _make_block(Vector2(500, 480), Vector2(920, 120))
    _make_block(Vector2(260, 365), Vector2(130, 20))
    _make_block(Vector2(760, 365), Vector2(130, 20))
    var checkpoint = CHECKPOINT.new()
    checkpoint.position = Vector2(165, 365)
    add_child(checkpoint)
    if not GameState.foundry_boss_defeated:
        var sentinel = SENTINEL.new()
        sentinel.configure(Vector2(580, 391), 345, 800)
        add_child(sentinel)
    var crypt_gate = ABILITY_GATE.new()
    crypt_gate.required_ability = "air_dash"
    crypt_gate.position = Vector2(940, 345)
    add_child(crypt_gate)
    _add_memory_portal(Vector2(120, 395), Vector2(22 * 960 + 120, 399), "foundry", "The forge memory opens when the Furnace Sentinel is defeated.")
    _add_memory_portal(Vector2(300, 395), Vector2(28 * 960 + 120, 399), "foundry", "The Foundry Flue opens after the Furnace Sentinel falls.")

func _build_crypt_entry() -> void:
    _make_block(Vector2(480, 480), Vector2(960, 120))
    _make_block(Vector2(160, 365), Vector2(180, 20))
    _make_block(Vector2(365, 315), Vector2(150, 20))
    _make_block(Vector2(545, 365), Vector2(155, 20))
    _make_block(Vector2(725, 315), Vector2(32, 210))
    _make_block(Vector2(855, 190), Vector2(160, 20))
    var checkpoint = CHECKPOINT.new()
    checkpoint.position = Vector2(140, 365)
    add_child(checkpoint)
    var leech = CRYPT_LEECH.new()
    leech.configure(Vector2(430, 287), 320, 515)
    add_child(leech)
    var cache = load("res://scripts/crypt_cache.gd").new()
    cache.position = Vector2(850, 155)
    add_child(cache)
    _add_echo_sigil("echo_crypt_01", Vector2(800, 153))
    _add_memory_portal(Vector2(120, 395), Vector2(30 * 960 + 120, 399), "wall_climb", "The reliquary route needs Wall Climb.")
    _add_memory_portal(Vector2(310, 395), Vector2(36 * 960 + 120, 399), "lore_climb", "The Scribe's crypt folio arch needs Wall Climb and an active quest.")

func _build_crypt_sanctum() -> void:
    _make_block(Vector2(500, 480), Vector2(920, 120))
    _make_block(Vector2(270, 365), Vector2(140, 20))
    _make_block(Vector2(735, 365), Vector2(140, 20))
    var checkpoint = CHECKPOINT.new()
    checkpoint.position = Vector2(135, 365)
    add_child(checkpoint)
    if not GameState.crypt_boss_defeated:
        var abbot = ABBOT.new()
        abbot.configure(Vector2(610, 390), 360, 835)
        add_child(abbot)
    var citadel_gate = ABILITY_GATE.new()
    citadel_gate.required_ability = "wall_climb"
    citadel_gate.position = Vector2(940, 345)
    add_child(citadel_gate)
    _add_memory_portal(Vector2(120, 395), Vector2(23 * 960 + 120, 399), "crypt", "The crypt memory opens when the Drowned Abbot is defeated.")

func _build_citadel_gallery() -> void:
    _make_block(Vector2(480, 480), Vector2(960, 120))
    _make_block(Vector2(300, 365), Vector2(150, 20), true)
    _make_block(Vector2(480, 270), Vector2(34, 260))
    _make_block(Vector2(600, 315), Vector2(145, 20))
    _make_block(Vector2(790, 230), Vector2(140, 20), true)
    var checkpoint = CHECKPOINT.new()
    checkpoint.position = Vector2(140, 365)
    add_child(checkpoint)
    var shrine = load("res://scripts/lantern_shrine.gd").new()
    shrine.position = Vector2(790, 190)
    add_child(shrine)
    _add_echo_sigil("echo_citadel_01", Vector2(610, 280))
    _add_memory_portal(Vector2(120, 395), Vector2(24 * 960 + 120, 399), "pulse", "The Citadel memory needs Lantern Pulse.")
    _add_memory_portal(Vector2(270, 395), Vector2(32 * 960 + 120, 399), "wall_climb", "The observatory route needs Wall Climb.")

func _build_citadel_throne() -> void:
    _make_block(Vector2(500, 480), Vector2(920, 120))
    _make_block(Vector2(285, 365), Vector2(150, 20), true)
    _make_block(Vector2(725, 365), Vector2(150, 20), true)
    var checkpoint = CHECKPOINT.new()
    checkpoint.position = Vector2(135, 365)
    add_child(checkpoint)
    if not GameState.citadel_boss_defeated:
        var boss = SOVEREIGN.new()
        boss.position = Vector2(620, 390)
        add_child(boss)
    var citadel_waystone = load("res://scripts/shortcut_gate.gd").new()
    citadel_waystone.position = Vector2(860, 395)
    citadel_waystone.destination = Vector2(3820, 399)
    add_child(citadel_waystone)
    var echo_portal = load("res://scripts/echo_portal.gd").new()
    echo_portal.position = Vector2(740, 395)
    echo_portal.destination = Vector2(15480, 399)
    add_child(echo_portal)

func _build_citadel_approach() -> void:
    _make_block(Vector2(480, 480), Vector2(920, 120))
    _make_block(Vector2(225, 350), Vector2(150, 20), true)
    _make_block(Vector2(500, 286), Vector2(170, 20))
    _make_block(Vector2(770, 350), Vector2(150, 20), true)
    var checkpoint = CHECKPOINT.new()
    checkpoint.position = Vector2(150, 365)
    add_child(checkpoint)
    var moth = RIFT_MOTH.new()
    moth.configure(Vector2(610, 250), 400, 820)
    add_child(moth)

func _build_chime_gallery() -> void:
    _make_block(Vector2(480, 480), Vector2(920, 120))
    _make_block(Vector2(200, 360), Vector2(150, 20), true)
    _make_block(Vector2(430, 300), Vector2(150, 20))
    _make_block(Vector2(670, 240), Vector2(150, 20), true)
    _make_block(Vector2(850, 330), Vector2(120, 20))
    var archer = VEIL_ARCHER.new()
    archer.position = Vector2(715, 202)
    add_child(archer)
    var checkpoint = CHECKPOINT.new()
    checkpoint.position = Vector2(120, 365)
    add_child(checkpoint)

func _build_lens_archive() -> void:
    _make_block(Vector2(480, 480), Vector2(920, 120))
    _make_block(Vector2(210, 365), Vector2(150, 20))
    _make_block(Vector2(450, 300), Vector2(150, 20), true)
    _make_block(Vector2(695, 365), Vector2(150, 20))
    var moth = RIFT_MOTH.new()
    moth.configure(Vector2(515, 250), 420, 760)
    add_child(moth)
    _add_pulse_gate(Vector2(915, 355))
    _add_memory_portal(Vector2(150, 395), Vector2(37 * 960 + 120, 399), "lore_pulse", "The Scribe's final folio arch needs Lantern Pulse and an active quest.")

func _build_shattered_nave() -> void:
    _make_block(Vector2(480, 480), Vector2(920, 120))
    _make_block(Vector2(220, 360), Vector2(145, 20), true)
    _make_block(Vector2(480, 290), Vector2(150, 20))
    _make_block(Vector2(735, 360), Vector2(145, 20), true)
    _add_pulse_gate(Vector2(915, 355))
    var archer = VEIL_ARCHER.new()
    archer.position = Vector2(610, 244)
    add_child(archer)

func _build_beacon_engine() -> void:
    _make_block(Vector2(480, 480), Vector2(920, 120))
    _make_block(Vector2(180, 365), Vector2(145, 20))
    _make_block(Vector2(410, 310), Vector2(145, 20), true)
    _make_block(Vector2(655, 250), Vector2(145, 20))
    _make_block(Vector2(825, 190), Vector2(145, 20), true)
    var cache = load("res://scripts/heart_cache.gd").new()
    cache.item_id = "citadel_heart_01"
    cache.message = "Citadel heart found: the beacon's light restores one heart."
    cache.position = Vector2(825, 150)
    add_child(cache)
    var checkpoint = CHECKPOINT.new()
    checkpoint.position = Vector2(120, 365)
    add_child(checkpoint)
    var moth = RIFT_MOTH.new()
    moth.configure(Vector2(535, 230), 350, 740)
    add_child(moth)

func _build_sovereign_approach() -> void:
    _make_block(Vector2(480, 480), Vector2(920, 120))
    _make_block(Vector2(310, 365), Vector2(155, 20), true)
    _make_block(Vector2(650, 325), Vector2(155, 20), true)
    var checkpoint = CHECKPOINT.new()
    checkpoint.position = Vector2(130, 365)
    add_child(checkpoint)
    if not GameState.citadel_boss_defeated:
        var archer = VEIL_ARCHER.new()
        archer.position = Vector2(650, 282)
        add_child(archer)

func _add_pulse_gate(at: Vector2) -> void:
    var gate = load("res://scripts/pulse_gate.gd").new()
    gate.position = at
    add_child(gate)

func _build_echo_threshold() -> void:
    _make_block(Vector2(480, 480), Vector2(920, 120))
    _make_block(Vector2(285, 365), Vector2(150, 20), true)
    _make_block(Vector2(650, 315), Vector2(150, 20))
    var checkpoint = CHECKPOINT.new()
    checkpoint.position = Vector2(120, 365)
    add_child(checkpoint)
    var archer = VEIL_ARCHER.new()
    archer.position = Vector2(690, 267)
    add_child(archer)
    var return_portal = load("res://scripts/echo_portal.gd").new()
    return_portal.position = Vector2(840, 395)
    return_portal.destination = Vector2(3800, 399)
    add_child(return_portal)

func _build_mirror_causeway() -> void:
    _make_block(Vector2(480, 480), Vector2(920, 120))
    _make_block(Vector2(170, 370), Vector2(130, 20), true)
    _make_block(Vector2(375, 300), Vector2(140, 20))
    _make_block(Vector2(590, 235), Vector2(140, 20), true)
    _make_block(Vector2(805, 315), Vector2(130, 20))
    var moth = RIFT_MOTH.new()
    moth.configure(Vector2(565, 205), 390, 770)
    add_child(moth)

func _build_silent_archive() -> void:
    _make_block(Vector2(480, 480), Vector2(920, 120))
    _make_block(Vector2(205, 360), Vector2(140, 20))
    _make_block(Vector2(430, 295), Vector2(140, 20), true)
    _make_block(Vector2(665, 230), Vector2(140, 20))
    _make_block(Vector2(840, 330), Vector2(140, 20), true)
    var archer = VEIL_ARCHER.new()
    archer.position = Vector2(630, 186)
    add_child(archer)
    _make_enemy(Vector2(330, 402), 260, 420)

func _build_shard_garden() -> void:
    _make_block(Vector2(480, 480), Vector2(920, 120))
    _make_block(Vector2(170, 365), Vector2(150, 20), true)
    _make_block(Vector2(390, 315), Vector2(150, 20))
    _make_block(Vector2(610, 265), Vector2(150, 20), true)
    _make_block(Vector2(810, 210), Vector2(150, 20))
    var moth = RIFT_MOTH.new()
    moth.configure(Vector2(490, 215), 330, 730)
    add_child(moth)

func _build_echo_warden_arena() -> void:
    _make_block(Vector2(480, 480), Vector2(920, 120))
    _make_block(Vector2(285, 365), Vector2(150, 20), true)
    _make_block(Vector2(675, 365), Vector2(150, 20), true)
    var checkpoint = CHECKPOINT.new()
    checkpoint.position = Vector2(125, 365)
    add_child(checkpoint)
    if not GameState.echo_warden_defeated:
        var boss = ECHO_WARDEN.new()
        boss.position = Vector2(620, 390)
        add_child(boss)
    var return_portal = load("res://scripts/echo_portal.gd").new()
    return_portal.position = Vector2(835, 395)
    return_portal.destination = Vector2(3800, 399)
    add_child(return_portal)

func _add_memory_portal(at: Vector2, destination: Vector2, requirement: String, hint: String) -> void:
    var portal = load("res://scripts/memory_portal.gd").new()
    portal.position = at
    portal.destination = destination
    portal.requirement = requirement
    portal.sealed_hint = hint
    add_child(portal)

func _build_memory_room(item_id: String, title: String, return_to: Vector2) -> void:
    _make_block(Vector2(480, 480), Vector2(920, 120))
    _make_block(Vector2(270, 380), Vector2(150, 20))
    _make_block(Vector2(480, 350), Vector2(150, 20), true)
    _make_block(Vector2(700, 380), Vector2(150, 20))
    var checkpoint = CHECKPOINT.new()
    checkpoint.position = Vector2(110, 365)
    add_child(checkpoint)
    var memory = load("res://scripts/beacon_memory.gd").new()
    memory.item_id = item_id
    memory.memory_name = title
    memory.position = Vector2(480, 300)
    add_child(memory)
    _add_memory_portal(Vector2(840, 395), return_to, "always", "")

func _build_beacon_crucible() -> void:
    _make_block(Vector2(480, 480), Vector2(920, 120))
    _make_block(Vector2(250, 365), Vector2(150, 20))
    _make_block(Vector2(480, 345), Vector2(170, 20))
    _make_block(Vector2(710, 365), Vector2(150, 20))
    var checkpoint = CHECKPOINT.new()
    checkpoint.position = Vector2(120, 365)
    add_child(checkpoint)
    var crown = load("res://scripts/beacon_crown.gd").new()
    crown.position = Vector2(480, 295)
    add_child(crown)
    _add_memory_portal(Vector2(840, 395), Vector2(3 * 960 + 220, 399), "always", "")

func _build_expansion_entrance(region: String) -> void:
    _make_block(Vector2(480, 480), Vector2(920, 120))
    _make_block(Vector2(230, 385), Vector2(140, 20), region == "canopy" or region == "citadel")
    _make_block(Vector2(465, 350), Vector2(150, 20), region == "canopy" or region == "crypt")
    _make_block(Vector2(700, 385), Vector2(140, 20), region == "citadel")
    var checkpoint = CHECKPOINT.new()
    checkpoint.position = Vector2(125, 365)
    add_child(checkpoint)
    if region == "canopy":
        _make_enemy(Vector2(540, 402), 430, 730)
        _add_memory_portal(Vector2(840, 395), Vector2(27 * 960 + 120, 399), "always", "")
    elif region == "foundry":
        _make_foundry_enemy(Vector2(545, 402), 420, 730)
        _add_memory_portal(Vector2(840, 395), Vector2(29 * 960 + 120, 399), "always", "")
    elif region == "crypt":
        var leech = CRYPT_LEECH.new()
        leech.configure(Vector2(550, 287), 430, 720)
        add_child(leech)
        _add_memory_portal(Vector2(840, 395), Vector2(31 * 960 + 120, 399), "always", "")
    else:
        var archer = VEIL_ARCHER.new()
        archer.position = Vector2(620, 280)
        add_child(archer)
        _add_memory_portal(Vector2(120, 395), Vector2(8 * 960 + 360, 399), "always", "")
        _add_pulse_gate(Vector2(730, 355))
        _add_memory_portal(Vector2(840, 395), Vector2(33 * 960 + 120, 399), "always", "")

func _build_expansion_relic(item_id: String, title: String, return_to: Vector2) -> void:
    _make_block(Vector2(480, 480), Vector2(920, 120))
    _make_block(Vector2(245, 375), Vector2(140, 20), room_id == 27 or room_id == 33)
    _make_block(Vector2(480, 350), Vector2(150, 20), room_id == 27 or room_id == 31)
    _make_block(Vector2(715, 375), Vector2(140, 20), room_id == 33)
    var checkpoint = CHECKPOINT.new()
    checkpoint.position = Vector2(120, 365)
    add_child(checkpoint)
    if room_id == 29:
        _make_foundry_enemy(Vector2(330, 402), 250, 430)
    elif room_id == 31:
        var leech = CRYPT_LEECH.new()
        leech.configure(Vector2(650, 275), 560, 770)
        add_child(leech)
    elif room_id == 33:
        var moth = RIFT_MOTH.new()
        moth.configure(Vector2(620, 255), 470, 760)
        add_child(moth)
    var relic = load("res://scripts/region_relic.gd").new()
    relic.item_id = item_id
    relic.relic_name = title
    relic.position = Vector2(480, 300)
    add_child(relic)
    _add_memory_portal(Vector2(840, 395), return_to, "always", "")

func _build_reliquary() -> void:
    _make_block(Vector2(480, 480), Vector2(920, 120))
    _make_block(Vector2(260, 365), Vector2(150, 20), true)
    _make_block(Vector2(480, 345), Vector2(170, 20))
    _make_block(Vector2(700, 365), Vector2(150, 20), true)
    var checkpoint = CHECKPOINT.new()
    checkpoint.position = Vector2(120, 365)
    add_child(checkpoint)
    var heart = load("res://scripts/reliquary_heart.gd").new()
    heart.position = Vector2(480, 295)
    add_child(heart)
    _add_memory_portal(Vector2(840, 395), Vector2(3 * 960 + 220, 399), "always", "")

func _build_archive_secret(item_id: String, title: String, return_to: Vector2) -> void:
    _make_block(Vector2(480, 480), Vector2(920, 120))
    _make_block(Vector2(275, 385), Vector2(145, 20), room_id == 35)
    _make_block(Vector2(500, 350), Vector2(155, 20), room_id == 35)
    _make_block(Vector2(735, 385), Vector2(145, 20), room_id == 37)
    var checkpoint = CHECKPOINT.new()
    checkpoint.position = Vector2(115, 365)
    add_child(checkpoint)
    if room_id == 35:
        _make_enemy(Vector2(570, 402), 470, 730)
    elif room_id == 36:
        var leech = CRYPT_LEECH.new()
        leech.configure(Vector2(600, 278), 500, 760)
        add_child(leech)
    else:
        var archer = VEIL_ARCHER.new()
        archer.position = Vector2(640, 280)
        add_child(archer)
        _add_pulse_gate(Vector2(735, 340))
    var folio = load("res://scripts/lore_folio.gd").new()
    folio.item_id = item_id
    folio.folio_title = title
    folio.position = Vector2(500 if room_id != 37 else 800, 300)
    add_child(folio)
    _add_memory_portal(Vector2(840, 395), return_to, "always", "")

func _add_echo_sigil(item_id: String, at: Vector2) -> void:
    var sigil = load("res://scripts/echo_sigil.gd").new()
    sigil.item_id = item_id
    sigil.position = at
    add_child(sigil)
