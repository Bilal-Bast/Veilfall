extends Node
## Small allowlisted local settings file, separate from game progression saves.
signal keyboard_bindings_changed
const SETTINGS_PATH := "user://veilfall_settings.cfg"
const DEFAULT_KEYBOARD_BINDINGS := {
    "move_left": [KEY_A, KEY_LEFT],
    "move_right": [KEY_D, KEY_RIGHT],
    "jump": [KEY_SPACE, KEY_W, KEY_UP],
    "attack": [KEY_J],
    "shift_realm": [KEY_Q, KEY_TAB],
    "restart": [KEY_R],
    "air_dash": [KEY_K, KEY_SHIFT],
    "lantern_pulse": [KEY_L],
    "interact": [KEY_E],
    "world_map": [KEY_M],
    "journal": [KEY_N],
    "pause": [KEY_ESCAPE]
}
var master_volume: float = 0.8
var fullscreen: bool = false
var reduce_flashing: bool = false
var keyboard_bindings: Dictionary = {}

func _ready() -> void:
    _load_settings()
    _apply_settings()
    _apply_keyboard_bindings()

func set_master_volume(value: float, persist: bool = true) -> void:
    master_volume = clampf(value, 0.0, 1.0)
    _apply_volume()
    if persist:
        _save_settings()

func set_fullscreen(enabled: bool, persist: bool = true) -> void:
    fullscreen = enabled
    _apply_display()
    if persist:
        _save_settings()

func set_reduce_flashing(enabled: bool, persist: bool = true) -> void:
    reduce_flashing = enabled
    if persist:
        _save_settings()

func get_keyboard_binding(action: String) -> int:
    if not DEFAULT_KEYBOARD_BINDINGS.has(action):
        return 0
    return int(keyboard_bindings.get(action, DEFAULT_KEYBOARD_BINDINGS[action][0]))

func get_keyboard_binding_name(action: String) -> String:
    var keycode := get_keyboard_binding(action)
    return OS.get_keycode_string(keycode) if keycode > 0 else "Unbound"

func get_keyboard_binding_conflict(action: String, keycode: int) -> String:
    for other_action in DEFAULT_KEYBOARD_BINDINGS:
        if other_action == action or not InputMap.has_action(other_action):
            continue
        for event in InputMap.action_get_events(other_action):
            if event is InputEventKey and (event as InputEventKey).physical_keycode == keycode:
                return String(other_action)
    return ""

func set_keyboard_binding(action: String, keycode: int) -> bool:
    if not DEFAULT_KEYBOARD_BINDINGS.has(action) or keycode <= 0:
        return false
    if not get_keyboard_binding_conflict(action, keycode).is_empty():
        return false
    keyboard_bindings[action] = keycode
    _apply_keyboard_bindings()
    _save_settings()
    keyboard_bindings_changed.emit()
    return true

func reset_keyboard_bindings() -> void:
    keyboard_bindings.clear()
    _apply_keyboard_bindings()
    _save_settings()
    keyboard_bindings_changed.emit()

func _load_settings() -> void:
    var config := ConfigFile.new()
    if config.load(SETTINGS_PATH) != OK:
        return
    var volume: Variant = config.get_value("audio", "master_volume", master_volume)
    var full: Variant = config.get_value("display", "fullscreen", fullscreen)
    var reduce: Variant = config.get_value("accessibility", "reduce_flashing", reduce_flashing)
    var bindings: Variant = config.get_value("controls", "keyboard_bindings", {})
    if volume is int or volume is float:
        master_volume = clampf(float(volume), 0.0, 1.0)
    if full is bool:
        fullscreen = full
    if reduce is bool:
        reduce_flashing = reduce
    if bindings is Dictionary:
        var candidates: Dictionary = {}
        for action in DEFAULT_KEYBOARD_BINDINGS:
            var keycode: Variant = bindings.get(action, null)
            if keycode is int and keycode > 0:
                candidates[action] = keycode
        for action in candidates:
            var keycode := int(candidates[action])
            var is_taken := false
            for other_action in DEFAULT_KEYBOARD_BINDINGS:
                if other_action == action:
                    continue
                var other_keys: Array = [int(candidates.get(other_action, DEFAULT_KEYBOARD_BINDINGS[other_action][0]))]
                var other_defaults: Array = DEFAULT_KEYBOARD_BINDINGS[other_action]
                for alternate_index in range(1, other_defaults.size()):
                    other_keys.append(int(other_defaults[alternate_index]))
                if other_keys.has(keycode):
                    is_taken = true
                    break
            if not is_taken:
                keyboard_bindings[action] = keycode

func _apply_settings() -> void:
    _apply_volume()
    _apply_display()

func _apply_keyboard_bindings() -> void:
    for action in DEFAULT_KEYBOARD_BINDINGS:
        if not InputMap.has_action(action):
            continue
        for event in InputMap.action_get_events(action):
            if event is InputEventKey:
                InputMap.action_erase_event(action, event)
        var custom_key := get_keyboard_binding(action)
        var default_keys: Array = DEFAULT_KEYBOARD_BINDINGS[action]
        var keycodes: Array = [custom_key]
        for alternate_index in range(1, default_keys.size()):
            var alternate_key := int(default_keys[alternate_index])
            if alternate_key != custom_key:
                keycodes.append(alternate_key)
        for keycode in keycodes:
            var key_event := InputEventKey.new()
            key_event.physical_keycode = int(keycode)
            InputMap.action_add_event(action, key_event)

func _apply_volume() -> void:
    var master_bus := AudioServer.get_bus_index("Master")
    if master_bus >= 0:
        AudioServer.set_bus_volume_db(master_bus, linear_to_db(maxf(master_volume, 0.001)))

func _apply_display() -> void:
    var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
    DisplayServer.window_set_mode(mode)

func _save_settings() -> void:
    var config := ConfigFile.new()
    config.set_value("audio", "master_volume", master_volume)
    config.set_value("display", "fullscreen", fullscreen)
    config.set_value("accessibility", "reduce_flashing", reduce_flashing)
    config.set_value("controls", "keyboard_bindings", keyboard_bindings)
    var error := config.save(SETTINGS_PATH)
    if error != OK:
        push_warning("Veilfall settings could not be saved: %s" % error_string(error))
