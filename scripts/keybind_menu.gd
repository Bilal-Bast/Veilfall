extends Control
## Runtime keyboard remapping. Controller and mouse bindings remain unchanged.
signal close_requested

const ACTION_ORDER := ["move_left", "move_right", "jump", "attack", "shift_realm", "restart", "air_dash", "lantern_pulse", "interact", "world_map", "journal", "pause"]
const ACTION_LABELS := {
    "move_left": "Move Left",
    "move_right": "Move Right",
    "jump": "Jump",
    "attack": "Sword Attack",
    "shift_realm": "Veil Shift",
    "restart": "Respawn",
    "air_dash": "Air Dash",
    "lantern_pulse": "Lantern Pulse",
    "interact": "Interact",
    "world_map": "World Map",
    "journal": "Field Journal",
    "pause": "Pause"
}

var listening_action: String = ""
var binding_buttons: Dictionary = {}
var status_label: Label

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    var backdrop := ColorRect.new()
    backdrop.color = Color(0.008, 0.014, 0.035, 0.92)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(backdrop)
    var panel := PanelContainer.new()
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.offset_left = -360
    panel.offset_top = -250
    panel.offset_right = 360
    panel.offset_bottom = 250
    var panel_style := StyleBoxFlat.new()
    panel_style.bg_color = Color("172334")
    panel_style.border_color = Color("9d8ab4")
    panel_style.set_border_width_all(2)
    panel_style.set_corner_radius_all(10)
    panel_style.content_margin_left = 24.0
    panel_style.content_margin_right = 24.0
    panel_style.content_margin_top = 16.0
    panel_style.content_margin_bottom = 16.0
    panel.add_theme_stylebox_override("panel", panel_style)
    add_child(panel)
    var layout := VBoxContainer.new()
    layout.add_theme_constant_override("separation", 7)
    panel.add_child(layout)
    var title := Label.new()
    title.text = "KEYBOARD CONTROLS"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 26)
    title.add_theme_color_override("font_color", Color("ffe2a6"))
    layout.add_child(title)
    var hint := Label.new()
    hint.text = "Select a binding, then press a key. Controller and mouse controls stay unchanged."
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint.add_theme_font_size_override("font_size", 12)
    hint.add_theme_color_override("font_color", Color("b8c8d8"))
    layout.add_child(hint)
    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(650, 330)
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    layout.add_child(scroll)
    var rows := VBoxContainer.new()
    rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    rows.add_theme_constant_override("separation", 3)
    scroll.add_child(rows)
    for action in ACTION_ORDER:
        var row := HBoxContainer.new()
        row.custom_minimum_size.y = 31
        rows.add_child(row)
        var label := Label.new()
        label.text = ACTION_LABELS[action]
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        label.add_theme_color_override("font_color", Color("e4ebf2"))
        row.add_child(label)
        var button := Button.new()
        button.custom_minimum_size = Vector2(190, 29)
        button.focus_mode = Control.FOCUS_ALL
        button.pressed.connect(_begin_listening.bind(action))
        row.add_child(button)
        binding_buttons[action] = button
    status_label = Label.new()
    status_label.text = "Changes save automatically on this device."
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status_label.add_theme_font_size_override("font_size", 11)
    status_label.add_theme_color_override("font_color", Color("b8c8d8"))
    layout.add_child(status_label)
    var footer := HBoxContainer.new()
    footer.alignment = BoxContainer.ALIGNMENT_CENTER
    footer.add_theme_constant_override("separation", 12)
    layout.add_child(footer)
    var reset_button := Button.new()
    reset_button.text = "RESET DEFAULTS"
    reset_button.custom_minimum_size = Vector2(170, 34)
    reset_button.focus_mode = Control.FOCUS_ALL
    reset_button.pressed.connect(_reset_defaults)
    footer.add_child(reset_button)
    var close_button := Button.new()
    close_button.text = "CLOSE  [Esc]"
    close_button.custom_minimum_size = Vector2(170, 34)
    close_button.focus_mode = Control.FOCUS_ALL
    close_button.pressed.connect(func(): close_requested.emit())
    footer.add_child(close_button)
    refresh_bindings()
    visible = false

func open_menu() -> void:
    listening_action = ""
    refresh_bindings()
    visible = true
    if binding_buttons.has("move_left"):
        (binding_buttons["move_left"] as Button).grab_focus()

func refresh_bindings() -> void:
    for action in ACTION_ORDER:
        if binding_buttons.has(action):
            var button := binding_buttons[action] as Button
            button.text = "Press a key…" if listening_action == action else SettingsManager.get_keyboard_binding_name(action)

func _begin_listening(action: String) -> void:
    listening_action = action
    status_label.text = "Press a key for %s. Escape cancels." % ACTION_LABELS[action]
    refresh_bindings()
    (binding_buttons[action] as Button).grab_focus()

func _input(event: InputEvent) -> void:
    if not visible or not (event is InputEventKey):
        return
    var key_event := event as InputEventKey
    if not key_event.pressed or key_event.echo:
        return
    if key_event.physical_keycode == KEY_ESCAPE:
        if not listening_action.is_empty():
            listening_action = ""
            status_label.text = "Binding cancelled. Changes save automatically."
            refresh_bindings()
        else:
            close_requested.emit()
        get_viewport().set_input_as_handled()
        return
    if listening_action.is_empty():
        return
    var action := listening_action
    listening_action = ""
    var keycode := int(key_event.physical_keycode)
    if keycode <= 0:
        status_label.text = "That key cannot be used. Choose another key."
    elif SettingsManager.set_keyboard_binding(action, keycode):
        status_label.text = "%s is now bound to %s." % [ACTION_LABELS[action], OS.get_keycode_string(keycode)]
    else:
        var conflicting_action := SettingsManager.get_keyboard_binding_conflict(action, keycode)
        status_label.text = "That key is already assigned to %s." % ACTION_LABELS.get(conflicting_action, "another action")
    refresh_bindings()
    (binding_buttons[action] as Button).grab_focus()
    get_viewport().set_input_as_handled()

func _reset_defaults() -> void:
    listening_action = ""
    SettingsManager.reset_keyboard_bindings()
    status_label.text = "Default keyboard controls restored."
    refresh_bindings()
