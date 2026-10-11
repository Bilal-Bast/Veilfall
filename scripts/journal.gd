extends Control
## Pause-friendly Field Journal. Progress is read live from GameState; no save schema changes.
signal close_requested

var current_objective_label: Label
var close_button: Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	current_objective_label = Label.new()
	current_objective_label.position = Vector2(82, 154)
	current_objective_label.size = Vector2(355, 90)
	current_objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	current_objective_label.add_theme_font_size_override("font_size", 15)
	current_objective_label.add_theme_color_override("font_color", Color("e5edf4"))
	current_objective_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(current_objective_label)
	close_button = Button.new()
	close_button.name = "CloseJournalButton"
	close_button.text = "CLOSE  [N / Esc]"
	close_button.position = Vector2(730, 452)
	close_button.size = Vector2(168, 38)
	close_button.focus_mode = Control.FOCUS_ALL
	close_button.pressed.connect(func(): close_requested.emit())
	add_child(close_button)
	refresh_progress()

func set_current_objective(value: String) -> void:
	if is_instance_valid(current_objective_label):
		current_objective_label.text = value

func grab_close_focus() -> void:
	if is_instance_valid(close_button):
		close_button.grab_focus()

func refresh_progress() -> void:
	queue_redraw()

func _draw() -> void:
	if not visible:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.012, 0.018, 0.04, 0.88), true)
	draw_rect(Rect2(48, 30, 864, 480), Color("172334"), true)
	draw_rect(Rect2(48, 30, 864, 480), Color("8297ac"), false, 2.0)
	draw_rect(Rect2(65, 45, 830, 2), Color("d9bd7f"), true)
	var font := ThemeDB.fallback_font
	if font == null:
		return
	draw_string(font, Vector2(80, 90), "FIELD JOURNAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 29, Color("ffe2a6"))
	draw_string(font, Vector2(80, 118), "VALDORN • FIELD NOTES", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("a9bdcf"))
	draw_rect(Rect2(70, 135, 390, 290), Color("202f42"), true)
	draw_rect(Rect2(478, 135, 410, 290), Color("202f42"), true)
	draw_string(font, Vector2(86, 160), "CURRENT OBJECTIVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("ffe2a6"))
	draw_string(font, Vector2(86, 272), "EXPEDITION", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("ffe2a6"))
	draw_string(font, Vector2(86, 298), "Rooms discovered: %d / 38" % GameState.visited_rooms.size(), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("e5edf4"))
	draw_string(font, Vector2(86, 326), "Major bosses: %d / 5" % _bosses_defeated(), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("e5edf4"))
	draw_string(font, Vector2(86, 354), "Abilities: %s" % _ability_summary(), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("c7d6e4"))
	draw_string(font, Vector2(494, 160), "OPTIONAL STORIES & RELICS", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("ffe2a6"))
	draw_string(font, Vector2(500, 199), "Echo Sigils", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("e5edf4"))
	draw_string(font, Vector2(817, 199), "%d / 4" % GameState.echo_sigil_count(), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("b9d9ec"))
	draw_string(font, Vector2(500, 235), "Beacon Memories", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("e5edf4"))
	draw_string(font, Vector2(817, 235), "%d / 4" % GameState.beacon_memory_count(), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("b9d9ec"))
	draw_string(font, Vector2(500, 271), "Regional Relics", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("e5edf4"))
	draw_string(font, Vector2(817, 271), "%d / 4" % GameState.region_relic_count(), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("b9d9ec"))
	draw_string(font, Vector2(500, 307), "Scribe Folios", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("e5edf4"))
	draw_string(font, Vector2(817, 307), "%d / 3" % GameState.lore_page_count(), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("b9d9ec"))
	draw_string(font, Vector2(500, 353), "CONTROLS", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("ffe2a6"))
	draw_string(font, Vector2(500, 377), "%s/%s move • %s jump • %s attack • %s realm" % [SettingsManager.get_keyboard_binding_name("move_left"), SettingsManager.get_keyboard_binding_name("move_right"), SettingsManager.get_keyboard_binding_name("jump"), SettingsManager.get_keyboard_binding_name("attack"), SettingsManager.get_keyboard_binding_name("shift_realm")], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("c7d6e4"))
	draw_string(font, Vector2(500, 397), "%s dash • %s pulse • %s map • %s interact • %s journal" % [SettingsManager.get_keyboard_binding_name("air_dash"), SettingsManager.get_keyboard_binding_name("lantern_pulse"), SettingsManager.get_keyboard_binding_name("world_map"), SettingsManager.get_keyboard_binding_name("interact"), SettingsManager.get_keyboard_binding_name("journal")], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("c7d6e4"))
	draw_string(font, Vector2(500, 417), "Pause: %s • Gamepad: A jump / X attack / Y shift / Start pause" % SettingsManager.get_keyboard_binding_name("pause"), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("c7d6e4"))
	draw_string(font, Vector2(80, 448), "The map records rooms as you discover them. Side-story counts update when you collect their keepsakes.", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("9fb1c2"))

func _bosses_defeated() -> int:
	var count := 0
	for defeated in [GameState.warden_defeated, GameState.foundry_boss_defeated, GameState.crypt_boss_defeated, GameState.citadel_boss_defeated, GameState.echo_warden_defeated]:
		if defeated:
			count += 1
	return count

func _ability_summary() -> String:
	var labels: Array[String] = []
	for ability in ["veil_shift", "air_dash", "wall_climb", "lantern_pulse"]:
		if GameState.unlocked_abilities.has(ability):
			var display_name: String = str(ability)
			match ability:
				"veil_shift": display_name = "Veil Shift"
				"air_dash": display_name = "Air Dash"
				"wall_climb": display_name = "Wall Climb"
				"lantern_pulse": display_name = "Lantern Pulse"
			labels.append(display_name)
	return ", ".join(labels)
