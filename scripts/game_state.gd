extends Node
## Runtime progression state. SaveManager persists an explicit allowlist of fields.
signal realm_changed(is_veil: bool)
signal checkpoint_changed(world_position: Vector2)
signal shard_count_changed(amount: int)
signal game_won
signal boss_health_changed(current: int, maximum: int)
signal room_changed(room_id: int)
signal quest_updated
signal lantern_pulse_cast(origin: Vector2)

var is_veil: bool = false
var checkpoint: Vector2 = Vector2(110, 399)
var shards: int = 0
var won: bool = false
var boss_health: int = 0
var boss_max_health: int = 0
var boss_engaged: bool = false
var current_room: int = 0
var warden_defeated: bool = false
var foundry_boss_defeated: bool = false
var crypt_boss_defeated: bool = false
var citadel_boss_defeated: bool = false
var echo_warden_defeated: bool = false
var keeper_upgrade_claimed: bool = false
var refuge_unlocked: bool = false
var shortcut_unlocked: bool = false
var echo_quest_reward_claimed: bool = false
var archive_quest_started: bool = false
var visited_rooms: Array[int] = []
var active_boss_name: String = "VEIL WARDEN"
var story_message: String = ""
var collected_items: Array[String] = []
var unlocked_abilities: Array[String] = ["veil_shift"]

func switch_realm() -> void:
    if won:
        return
    is_veil = not is_veil
    Sfx.play("realm_shift")
    realm_changed.emit(is_veil)
    SaveManager.save_game()

func activate_checkpoint(at: Vector2) -> void:
    if checkpoint.distance_to(at) < 4.0:
        return
    checkpoint = at
    Sfx.play("checkpoint")
    set_current_room(room_for_x(at.x), false)
    checkpoint_changed.emit(at)
    SaveManager.save_game()

func collect_shard() -> void:
    if collected_items.has("lantern_shard_woods_01"):
        return
    collected_items.append("lantern_shard_woods_01")
    Sfx.play("pickup")
    shards = 1
    shard_count_changed.emit(shards)
    SaveManager.save_game()

func mark_warden_defeated() -> void:
    if warden_defeated:
        return
    warden_defeated = true
    Sfx.play("checkpoint", -1.0, 1.16)
    SaveManager.save_game()

func mark_foundry_boss_defeated() -> void:
    if foundry_boss_defeated:
        return
    foundry_boss_defeated = true
    Sfx.play("checkpoint", -1.0, 1.16)
    unlocked_abilities.append("air_dash")
    if not collected_items.has("foundry_ember_core"):
        collected_items.append("foundry_ember_core")
    quest_updated.emit()
    SaveManager.save_game()

func claim_keeper_upgrade() -> bool:
    if keeper_upgrade_claimed or not foundry_boss_defeated:
        return false
    keeper_upgrade_claimed = true
    quest_updated.emit()
    SaveManager.save_game()
    return true

func mark_crypt_boss_defeated() -> void:
    if crypt_boss_defeated:
        return
    crypt_boss_defeated = true
    Sfx.play("checkpoint", -1.0, 1.16)
    if not unlocked_abilities.has("wall_climb"):
        unlocked_abilities.append("wall_climb")
    story_message = "The bell falls silent. Wall Climb is yours; the drowned halls can be searched at last."
    quest_updated.emit()
    SaveManager.save_game()

func unlock_lantern_pulse() -> void:
    if unlocked_abilities.has("lantern_pulse"):
        return
    unlocked_abilities.append("lantern_pulse")
    Sfx.play("checkpoint", -2.0, 1.08)
    story_message = "The Citadel altar answers your lantern. Lantern Pulse is yours (L / RB)."
    quest_updated.emit()
    SaveManager.save_game()

func mark_citadel_boss_defeated() -> void:
    if citadel_boss_defeated:
        return
    citadel_boss_defeated = true
    Sfx.play("checkpoint", -1.0, 1.22)
    story_message = "The Veil Sovereign is gone. The last light returns to Valedorn."
    quest_updated.emit()
    SaveManager.save_game()
    finish()

func mark_echo_warden_defeated() -> void:
    if echo_warden_defeated:
        return
    echo_warden_defeated = true
    Sfx.play("checkpoint", -1.0, 1.18)
    story_message = "The Echo Warden falls. Lantern Pulse is mastered: stronger and ready sooner."
    quest_updated.emit()
    SaveManager.save_game()

func collect_echo_sigil(item_id: String) -> void:
    if not ["echo_woods_01", "echo_foundry_01", "echo_crypt_01", "echo_citadel_01"].has(item_id) or collected_items.has(item_id):
        return
    collected_items.append(item_id)
    Sfx.play("pickup")
    story_message = "Echo Sigil found (%d/3). Mira can bind three into a Refuge shortcut." % echo_sigil_count()
    quest_updated.emit()
    SaveManager.save_game()

func echo_sigil_count() -> int:
    var count := 0
    for item in collected_items:
        if item.begins_with("echo_"):
            count += 1
    return count

func collect_beacon_memory(item_id: String) -> void:
    if not ["memory_woods_01", "memory_foundry_01", "memory_crypt_01", "memory_citadel_01"].has(item_id) or collected_items.has(item_id):
        return
    collected_items.append(item_id)
    Sfx.play("pickup")
    story_message = "Beacon memory recovered (%d/4). Return to the Refuge when all four answer." % beacon_memory_count()
    quest_updated.emit()
    SaveManager.save_game()

func beacon_memory_count() -> int:
    var count := 0
    for item in ["memory_woods_01", "memory_foundry_01", "memory_crypt_01", "memory_citadel_01"]:
        if collected_items.has(item):
            count += 1
    return count

func collect_region_relic(item_id: String) -> void:
    if not ["relic_woods_01", "relic_foundry_01", "relic_crypt_01", "relic_citadel_01"].has(item_id) or collected_items.has(item_id):
        return
    collected_items.append(item_id)
    Sfx.play("pickup")
    story_message = "Regional relic recovered (%d/4)." % region_relic_count()
    quest_updated.emit()
    SaveManager.save_game()

func region_relic_count() -> int:
    var count := 0
    for item in ["relic_woods_01", "relic_foundry_01", "relic_crypt_01", "relic_citadel_01"]:
        if collected_items.has(item):
            count += 1
    return count

func start_archive_quest() -> void:
    if archive_quest_started:
        return
    archive_quest_started = true
    story_message = "SCRIBE: Find my three lost folios in the old sealed chambers."
    quest_updated.emit()
    SaveManager.save_game()

func collect_lore_page(item_id: String) -> void:
    if not ["lore_woods_01", "lore_crypt_01", "lore_citadel_01"].has(item_id) or collected_items.has(item_id):
        return
    collected_items.append(item_id)
    Sfx.play("pickup")
    story_message = "Lost folio recovered (%d/3)." % lore_page_count()
    quest_updated.emit()
    SaveManager.save_game()

func lore_page_count() -> int:
    var count := 0
    for item in ["lore_woods_01", "lore_crypt_01", "lore_citadel_01"]:
        if collected_items.has(item):
            count += 1
    return count

func claim_echo_quest_reward() -> bool:
    if shortcut_unlocked or echo_sigil_count() < 3 or not citadel_boss_defeated:
        return false
    echo_quest_reward_claimed = true
    Sfx.play("checkpoint", -2.0, 1.12)
    shortcut_unlocked = true
    story_message = "MIRA: The sigils are bound. The Refuge and Citadel are linked by a safe shortcut."
    quest_updated.emit()
    SaveManager.save_game()
    return true

func unlock_refuge() -> void:
    if refuge_unlocked:
        return
    refuge_unlocked = true
    SaveManager.save_game()

func set_current_room(room_id: int, persist: bool = true) -> void:
    var next_room := clampi(room_id, 0, 37)
    var room_changed_now := next_room != current_room
    var newly_discovered := not visited_rooms.has(next_room)
    if not room_changed_now and not newly_discovered:
        return
    current_room = next_room
    if newly_discovered:
        visited_rooms.append(next_room)
    if room_changed_now:
        boss_engaged = false
        room_changed.emit(current_room)
    if persist:
        SaveManager.save_game()

func room_for_x(world_x: float) -> int:
    return clampi(floori(world_x / 960.0), 0, 37)

func restore_progress(data: Dictionary) -> void:
    is_veil = data.get("realm", false)
    checkpoint = data.get("checkpoint", Vector2(110, 399))
    shards = clampi(data.get("shards", 0), 0, 1)
    warden_defeated = data.get("warden_defeated", false)
    foundry_boss_defeated = data.get("foundry_boss_defeated", false)
    crypt_boss_defeated = data.get("crypt_boss_defeated", false)
    citadel_boss_defeated = data.get("citadel_boss_defeated", false)
    echo_warden_defeated = data.get("echo_warden_defeated", false)
    keeper_upgrade_claimed = data.get("keeper_upgrade_claimed", false)
    refuge_unlocked = data.get("refuge_unlocked", false)
    shortcut_unlocked = data.get("shortcut_unlocked", false)
    echo_quest_reward_claimed = data.get("echo_quest_reward_claimed", shortcut_unlocked)
    archive_quest_started = data.get("archive_quest_started", false)
    visited_rooms.clear()
    for room in data.get("visited_rooms", []):
        if room is int and room >= 0 and room <= 37 and not visited_rooms.has(room):
            visited_rooms.append(room)
    collected_items.clear()
    for item in data.get("collected_items", []):
        if item is String and item in ["lantern_shard_woods_01", "foundry_ember_core", "foundry_cache_01", "crypt_heart_01", "citadel_heart_01", "echo_woods_01", "echo_foundry_01", "echo_crypt_01", "echo_citadel_01", "memory_woods_01", "memory_foundry_01", "memory_crypt_01", "memory_citadel_01", "beacon_crown_01", "relic_woods_01", "relic_foundry_01", "relic_crypt_01", "relic_citadel_01", "reliquary_heart_01", "lore_woods_01", "lore_crypt_01", "lore_citadel_01", "lore_reward_01", "resonant_wick_01"] and not collected_items.has(item):
            collected_items.append(item)
    if shards > 0 and not collected_items.has("lantern_shard_woods_01"):
        collected_items.append("lantern_shard_woods_01")
    unlocked_abilities.clear()
    unlocked_abilities.append("veil_shift")
    for ability in data.get("unlocked_abilities", []):
        if ability is String and ability in ["air_dash", "wall_climb", "lantern_pulse"] and not unlocked_abilities.has(ability):
            unlocked_abilities.append(ability)
    if foundry_boss_defeated and not unlocked_abilities.has("air_dash"):
        unlocked_abilities.append("air_dash")
    if crypt_boss_defeated and not unlocked_abilities.has("wall_climb"):
        unlocked_abilities.append("wall_climb")
    current_room = room_for_x(checkpoint.x)
    if not visited_rooms.has(current_room):
        visited_rooms.append(current_room)
    boss_engaged = false
    active_boss_name = "VEIL WARDEN"
    won = false
    realm_changed.emit(is_veil)
    shard_count_changed.emit(shards)
    room_changed.emit(current_room)

func set_boss_health(current: int, maximum: int, name: String = "VEIL WARDEN") -> void:
    boss_health = maxi(0, current)
    boss_max_health = maxi(0, maximum)
    active_boss_name = name
    boss_health_changed.emit(boss_health, boss_max_health)

func finish() -> void:
    if shards < 1 or won:
        return
    won = true
    game_won.emit()

func reset_session() -> void:
    is_veil = false
    checkpoint = Vector2(110, 399)
    shards = 0
    won = false
    boss_health = 0
    boss_max_health = 0
    boss_engaged = false
    active_boss_name = "VEIL WARDEN"
    current_room = 0
    warden_defeated = false
    foundry_boss_defeated = false
    crypt_boss_defeated = false
    citadel_boss_defeated = false
    echo_warden_defeated = false
    keeper_upgrade_claimed = false
    refuge_unlocked = false
    shortcut_unlocked = false
    echo_quest_reward_claimed = false
    archive_quest_started = false
    visited_rooms.clear()
    visited_rooms.append(0)
    story_message = ""
    collected_items.clear()
    unlocked_abilities = ["veil_shift"]
    realm_changed.emit(false)
    shard_count_changed.emit(0)
    boss_health_changed.emit(0, 0)
