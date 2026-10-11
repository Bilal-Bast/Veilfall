extends Control
## Keyboard- and controller-focusable title screen with guarded save replacement.
var menu_panel: PanelContainer
var options_panel: PanelContainer
var continue_button: Button
var new_game_button: Button
var status_label: Label
var options_volume: HSlider
var options_controls_button: Button
var keyboard_menu: Control
var new_game_dialog: ConfirmationDialog

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _build_screen()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel") and options_panel != null and options_panel.visible:
        _hide_options()
        get_viewport().set_input_as_handled()

func _draw() -> void:
    var bounds := Rect2(Vector2.ZERO, size)
    draw_rect(bounds, Color("101629"))
    draw_rect(Rect2(0, 0, size.x, size.y * 0.56), Color("20243c", 0.72))
    draw_circle(Vector2(size.x * 0.72, size.y * 0.43), 190.0, Color("a281c7", 0.12))
    draw_circle(Vector2(size.x * 0.72, size.y * 0.43), 94.0, Color("f3d49c", 0.14))
    for i in range(26):
        var x := float((i * 137 + 43) % int(maxf(size.x, 1.0)))
        var y := float((i * 83 + 25) % int(maxf(size.y * 0.66, 1.0)))
        var radius := 1.0 if i % 5 == 0 else 1.7
        draw_circle(Vector2(x, y), radius, Color("e4e1fa", 0.54 if i % 3 == 0 else 0.24))
    for i in range(11):
        var x := float(i * 112 - 30)
        var height := float(75 + (i * 41) % 120)
        var silhouette := Color("101a29", 0.86) if i % 2 == 0 else Color("191a31", 0.82)
        draw_colored_polygon(PackedVector2Array([Vector2(x - 72, size.y), Vector2(x + 24, size.y - height), Vector2(x + 118, size.y)]), silhouette)
    draw_line(Vector2(0, size.y - 2), Vector2(size.x, size.y - 2), Color("e6c991", 0.34), 3.0)

func _build_screen() -> void:
    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    center.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(center)

    menu_panel = _make_panel(center, Vector2(430, 445))
    var menu := VBoxContainer.new()
    menu.add_theme_constant_override("separation", 8)
    menu_panel.add_child(menu)
    _add_spacer(menu, 6)
    var title := _make_label(menu, "VEILFALL", 48, Color("ffe1a3"))
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.custom_minimum_size.y = 56
    var subtitle := _make_label(menu, "THE LAST LIGHT", 19, Color("d7d4e4"))
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var pitch := _make_label(menu, "Two realms. Four beacons. One light left.", 14, Color("b7c6d7"))
    pitch.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    pitch.custom_minimum_size.y = 34
    _add_spacer(menu, 2)

    continue_button = _make_button(menu, "CONTINUE")
    continue_button.disabled = not SaveManager.has_save()
    continue_button.pressed.connect(_continue_game)
    new_game_button = _make_button(menu, "NEW JOURNEY")
    new_game_button.pressed.connect(_request_new_game)
    var options_button := _make_button(menu, "OPTIONS")
    options_button.pressed.connect(_show_options)
    var quit_button := _make_button(menu, "QUIT")
    quit_button.pressed.connect(func(): get_tree().quit())
    status_label = _make_label(menu, "", 12, Color("efb2a8"))
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status_label.custom_minimum_size.y = 22
    _add_spacer(menu, 0)
    var footer := _make_label(menu, "Keyboard and controller bindings are available in Options.", 11, Color("99a8ba"))
    footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

    options_panel = _make_panel(center, Vector2(430, 420))
    options_panel.visible = false
    var options := VBoxContainer.new()
    options.add_theme_constant_override("separation", 10)
    options_panel.add_child(options)
    var options_title := _make_label(options, "OPTIONS", 34, Color("ffe1a3"))
    options_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    options_title.custom_minimum_size.y = 52
    var volume_text := _make_label(options, "MASTER VOLUME", 15, Color("d7e2ed"))
    volume_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    options_volume = HSlider.new()
    var volume := options_volume
    volume.min_value = 0.0
    volume.max_value = 1.0
    volume.step = 0.05
    volume.value = SettingsManager.master_volume
    volume.focus_mode = Control.FOCUS_ALL
    volume.custom_minimum_size = Vector2(300, 28)
    volume.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    volume.value_changed.connect(func(value: float): SettingsManager.set_master_volume(value))
    options.add_child(volume)
    var fullscreen := CheckButton.new()
    fullscreen.text = "Fullscreen"
    fullscreen.button_pressed = SettingsManager.fullscreen
    fullscreen.focus_mode = Control.FOCUS_ALL
    fullscreen.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    fullscreen.toggled.connect(func(enabled: bool): SettingsManager.set_fullscreen(enabled))
    options.add_child(fullscreen)
    var reduce_flashing := CheckButton.new()
    reduce_flashing.text = "Reduce flashing and motion"
    reduce_flashing.button_pressed = SettingsManager.reduce_flashing
    reduce_flashing.focus_mode = Control.FOCUS_ALL
    reduce_flashing.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    reduce_flashing.toggled.connect(func(enabled: bool): SettingsManager.set_reduce_flashing(enabled))
    options.add_child(reduce_flashing)
    options_controls_button = _make_button(options, "KEYBOARD CONTROLS")
    options_controls_button.pressed.connect(_open_keyboard_controls)
    var options_help := _make_label(options, "These preferences are saved on this device.", 12, Color("aab9ca"))
    options_help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    options_help.custom_minimum_size.y = 28
    var back := _make_button(options, "BACK")
    back.pressed.connect(_hide_options)

    new_game_dialog = ConfirmationDialog.new()
    new_game_dialog.title = "Start a new journey?"
    new_game_dialog.dialog_text = "Your existing Veilfall save will be replaced. This cannot be undone."
    new_game_dialog.ok_button_text = "Start New Journey"
    new_game_dialog.confirmed.connect(_start_new_game)
    add_child(new_game_dialog)

    keyboard_menu = load("res://scripts/keybind_menu.gd").new()
    keyboard_menu.visible = false
    keyboard_menu.connect("close_requested", _close_keyboard_controls)
    add_child(keyboard_menu)

    if continue_button.disabled:
        new_game_button.grab_focus()
    else:
        continue_button.grab_focus()

func _make_panel(parent: Control, minimum_size: Vector2) -> PanelContainer:
    var panel := PanelContainer.new()
    panel.custom_minimum_size = minimum_size
    var style := StyleBoxFlat.new()
    style.bg_color = Color("141f31", 0.94)
    style.border_color = Color("9d8ab4", 0.72)
    style.set_border_width_all(2)
    style.set_corner_radius_all(12)
    style.content_margin_left = 38.0
    style.content_margin_right = 38.0
    style.content_margin_top = 22.0
    style.content_margin_bottom = 22.0
    panel.add_theme_stylebox_override("panel", style)
    parent.add_child(panel)
    return panel

func _make_label(parent: Control, text: String, font_size: int, tint: Color) -> Label:
    var label := Label.new()
    label.text = text
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", tint)
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(label)
    return label

func _make_button(parent: Control, text: String) -> Button:
    var button := Button.new()
    button.text = text
    button.custom_minimum_size = Vector2(280, 38)
    button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    button.focus_mode = Control.FOCUS_ALL
    button.add_theme_font_size_override("font_size", 16)
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color("25364a")
    normal.border_color = Color("687f96")
    normal.set_border_width_all(1)
    normal.set_corner_radius_all(6)
    var hover := normal.duplicate() as StyleBoxFlat
    hover.bg_color = Color("334a60")
    hover.border_color = Color("e3c78e")
    var pressed := normal.duplicate() as StyleBoxFlat
    pressed.bg_color = Color("172536")
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("focus", hover)
    button.add_theme_stylebox_override("pressed", pressed)
    button.add_theme_color_override("font_color", Color("f2e4c6"))
    button.add_theme_color_override("font_hover_color", Color("fff1cb"))
    parent.add_child(button)
    return button

func _add_spacer(parent: Control, height: float) -> void:
    var spacer := Control.new()
    spacer.custom_minimum_size.y = height
    spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(spacer)

func _continue_game() -> void:
    if SaveManager.has_save():
        get_tree().change_scene_to_file("res://scenes/main.tscn")

func _request_new_game() -> void:
    if SaveManager.has_save():
        new_game_dialog.popup_centered(Vector2i(470, 210))
    else:
        _start_new_game()

func _start_new_game() -> void:
    if not SaveManager.clear_save_for_new_game():
        status_label.text = "Could not replace the save. Check file permissions and try again."
        return
    get_tree().change_scene_to_file("res://scenes/main.tscn")

func _show_options() -> void:
    menu_panel.visible = false
    options_panel.visible = true
    options_volume.grab_focus()

func _hide_options() -> void:
    options_panel.visible = false
    menu_panel.visible = true
    if continue_button.disabled:
        new_game_button.grab_focus()
    else:
        continue_button.grab_focus()

func _open_keyboard_controls() -> void:
    options_panel.visible = false
    keyboard_menu.call("open_menu")

func _close_keyboard_controls() -> void:
    keyboard_menu.visible = false
    options_panel.visible = true
    options_controls_button.grab_focus()
