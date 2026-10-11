extends Node
## Small allowlisted JSON save. Writes a temporary file, then replaces the current save safely.
const SAVE_PATH := "user://veilfall_save.json"
const TEMP_PATH := "user://veilfall_save.json.tmp"
const BACKUP_PATH := "user://veilfall_save.json.bak"
const SAVE_VERSION := 10

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func clear_save_for_new_game() -> bool:
	for path in [TEMP_PATH, BACKUP_PATH, SAVE_PATH]:
		if not FileAccess.file_exists(path):
			continue
		var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		if error != OK:
			push_error("Veilfall save could not be cleared for a new journey: %s" % error_string(error))
			return false
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("Veilfall save could not be opened; starting with default progress.")
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary) or not (parsed.get("schema_version", 0) in [1, 2, 3, 4, 5, 6, 7, 8, 9, SAVE_VERSION]):
		push_warning("Veilfall save is invalid or from an unsupported version; starting with default progress.")
		return false

	var raw_checkpoint: Variant = parsed.get("checkpoint", [110.0, 399.0])
	if not (raw_checkpoint is Array) or raw_checkpoint.size() != 2:
		push_warning("Veilfall save has an invalid checkpoint; starting with default progress.")
		return false
	if not _is_number(raw_checkpoint[0]) or not _is_number(raw_checkpoint[1]):
		push_warning("Veilfall save has an invalid checkpoint; starting with default progress.")
		return false
	var old_schema := int(parsed.get("schema_version", 0))
	var checkpoint := Vector2(float(raw_checkpoint[0]), float(raw_checkpoint[1]))
	if old_schema <= 5 and checkpoint.x >= 8640.0:
		checkpoint.x += 5760.0
	if checkpoint.x < 0.0 or checkpoint.x > 36240.0 or checkpoint.y < 300.0 or checkpoint.y > 520.0:
		push_warning("Veilfall save checkpoint is out of bounds; starting with default progress.")
		return false

	var raw_shards: Variant = parsed.get("shards", 0)
	if not (raw_shards is int) or raw_shards < 0 or raw_shards > 1:
		raw_shards = 0
	var safe_data := {
		"checkpoint": checkpoint,
		"realm": parsed.get("realm", false) is bool and parsed.get("realm", false),
		"shards": raw_shards,
		"warden_defeated": parsed.get("warden_defeated", false) is bool and parsed.get("warden_defeated", false),
		"foundry_boss_defeated": parsed.get("foundry_boss_defeated", false) is bool and parsed.get("foundry_boss_defeated", false),
		"crypt_boss_defeated": parsed.get("crypt_boss_defeated", false) is bool and parsed.get("crypt_boss_defeated", false),
		"citadel_boss_defeated": parsed.get("citadel_boss_defeated", false) is bool and parsed.get("citadel_boss_defeated", false),
		"echo_warden_defeated": parsed.get("echo_warden_defeated", false) is bool and parsed.get("echo_warden_defeated", false),
		"keeper_upgrade_claimed": parsed.get("keeper_upgrade_claimed", false) is bool and parsed.get("keeper_upgrade_claimed", false),
		"refuge_unlocked": parsed.get("refuge_unlocked", false) is bool and parsed.get("refuge_unlocked", false),
		"shortcut_unlocked": parsed.get("shortcut_unlocked", false) is bool and parsed.get("shortcut_unlocked", false),
		"echo_quest_reward_claimed": parsed.get("echo_quest_reward_claimed", false) is bool and parsed.get("echo_quest_reward_claimed", false),
		"archive_quest_started": parsed.get("archive_quest_started", false) is bool and parsed.get("archive_quest_started", false),
		"visited_rooms": _filter_room_ids(parsed.get("visited_rooms", []), old_schema),
		"collected_items": _filter_strings(parsed.get("collected_items", []), ["lantern_shard_woods_01", "foundry_ember_core", "foundry_cache_01", "crypt_heart_01", "citadel_heart_01", "echo_woods_01", "echo_foundry_01", "echo_crypt_01", "echo_citadel_01", "memory_woods_01", "memory_foundry_01", "memory_crypt_01", "memory_citadel_01", "beacon_crown_01", "relic_woods_01", "relic_foundry_01", "relic_crypt_01", "relic_citadel_01", "reliquary_heart_01", "lore_woods_01", "lore_crypt_01", "lore_citadel_01", "lore_reward_01", "resonant_wick_01"]),
		"unlocked_abilities": _filter_strings(parsed.get("unlocked_abilities", []), ["air_dash", "wall_climb", "lantern_pulse"])
	}
	GameState.restore_progress(safe_data)
	return true

func save_game() -> bool:
	var data := {
		"schema_version": SAVE_VERSION,
		"checkpoint": [GameState.checkpoint.x, GameState.checkpoint.y],
		"room": GameState.current_room,
		"realm": GameState.is_veil,
		"shards": GameState.shards,
		"warden_defeated": GameState.warden_defeated,
		"foundry_boss_defeated": GameState.foundry_boss_defeated,
		"crypt_boss_defeated": GameState.crypt_boss_defeated,
		"citadel_boss_defeated": GameState.citadel_boss_defeated,
		"echo_warden_defeated": GameState.echo_warden_defeated,
		"keeper_upgrade_claimed": GameState.keeper_upgrade_claimed,
		"refuge_unlocked": GameState.refuge_unlocked,
		"shortcut_unlocked": GameState.shortcut_unlocked,
		"echo_quest_reward_claimed": GameState.echo_quest_reward_claimed,
		"archive_quest_started": GameState.archive_quest_started,
		"visited_rooms": GameState.visited_rooms,
		"collected_items": GameState.collected_items,
		"unlocked_abilities": GameState.unlocked_abilities
	}
	var file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Veilfall save could not be written: %s" % error_string(FileAccess.get_open_error()))
		return false
	file.store_string(JSON.stringify(data, "  "))
	file.flush()
	file.close()

	var target := ProjectSettings.globalize_path(SAVE_PATH)
	var temporary := ProjectSettings.globalize_path(TEMP_PATH)
	var backup := ProjectSettings.globalize_path(BACKUP_PATH)
	if FileAccess.file_exists(BACKUP_PATH):
		DirAccess.remove_absolute(backup)
	var had_existing := FileAccess.file_exists(SAVE_PATH)
	if had_existing:
		var backup_error := DirAccess.rename_absolute(target, backup)
		if backup_error != OK:
			push_error("Veilfall save could not protect the previous save: %s" % error_string(backup_error))
			return false
	var replace_error := DirAccess.rename_absolute(temporary, target)
	if replace_error != OK:
		if had_existing:
			DirAccess.rename_absolute(backup, target)
		push_error("Veilfall save could not replace the previous save: %s" % error_string(replace_error))
		return false
	if FileAccess.file_exists(BACKUP_PATH):
		DirAccess.remove_absolute(backup)
	return true

func _filter_strings(value: Variant, allowed: Array[String]) -> Array[String]:
	var result: Array[String] = []
	if not (value is Array):
		return result
	for item in value:
		if item is String and item in allowed and not result.has(item):
			result.append(item)
	return result

func _is_number(value: Variant) -> bool:
	return value is int or value is float

func _filter_room_ids(value: Variant, old_schema: int) -> Array[int]:
	var result: Array[int] = []
	if not (value is Array):
		return result
	for room in value:
		if room is int and room >= 0 and room <= (9 if old_schema <= 5 else (15 if old_schema == 6 else (20 if old_schema == 7 else (25 if old_schema == 8 else (34 if old_schema == 9 else 37))))):
			var migrated_room: int = 15 if old_schema <= 5 and room == 9 else room
			if not result.has(migrated_room):
				result.append(migrated_room)
	return result
