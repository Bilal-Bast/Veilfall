extends CanvasLayer
## Native, responsive prototype HUD. Replace with UI scenes in production.
var top_label: Label
var quest_label: Label
var helper_label: Label
var win_panel: ColorRect
var win_title: Label
var win_text: Label
var boss_label: Label
var boss_bar: ProgressBar
var room_label: Label
var transition_overlay: ColorRect
var story_message_seen: String = ""
var story_message_left: float = 0.0
var pause_scrim: ColorRect
var pause_panel: ColorRect
var paused_by_menu: bool = false
var map_overlay: Control
var map_open: bool = false
var journal_overlay: Control
var journal_open: bool = false
var journal_return_to_pause: bool = false
var journal_pause_button: Button
var keyboard_menu: Control
var keyboard_pause_button: Button
var keyboard_return_to_pause: bool = false
var controls_hint_label: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var backdrop := ColorRect.new()
	backdrop.color = Color(0.025, 0.045, 0.09, 0.88)
	backdrop.set_anchors_preset(Control.PRESET_TOP_WIDE)
	backdrop.offset_bottom = 57.0
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(backdrop)

	top_label = _create_label(root, Vector2(18, 8), 22, Color("ffe2a6"))
	quest_label = _create_label(root, Vector2(18, 36), 13, Color("ceddec"))
	helper_label = _create_label(root, Vector2(20, 506), 14, Color("ffffff"))
	helper_label.add_theme_font_size_override("font_size", 11)
	helper_label.text = _compact_keyboard_hints()

	boss_label = _create_label(root, Vector2(360, 63), 13, Color("f3d4a5"))
	boss_label.text = GameState.active_boss_name
	boss_label.visible = false
	boss_bar = ProgressBar.new()
	boss_bar.position = Vector2(360, 83)
	boss_bar.size = Vector2(240, 13)
	boss_bar.min_value = 0
	boss_bar.max_value = 7
	boss_bar.value = 7
	boss_bar.show_percentage = false
	boss_bar.visible = false
	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color = Color("201e32")
	bar_bg.border_color = Color("8b758d")
	bar_bg.set_border_width_all(1)
	bar_bg.set_corner_radius_all(3)
	var bar_fill := StyleBoxFlat.new()
	bar_fill.bg_color = Color("bb6575")
	bar_fill.set_corner_radius_all(3)
	boss_bar.add_theme_stylebox_override("background", bar_bg)
	boss_bar.add_theme_stylebox_override("fill", bar_fill)
	root.add_child(boss_bar)

	win_panel = ColorRect.new()
	win_panel.color = Color(0.04, 0.07, 0.16, 0.94)
	win_panel.position = Vector2(195, 145)
	win_panel.size = Vector2(570, 255)
	win_panel.visible = false
	win_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(win_panel)
	win_title = _create_label(win_panel, Vector2(32, 35), 38, Color("ffe7a5"))
	win_text = _create_label(win_panel, Vector2(32, 112), 20, Color("d8eaf8"))
	win_title.size = Vector2(506, 54)
	win_text.size = Vector2(506, 128)
	win_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	win_title.text = "THE LAST LIGHT"
	win_text.text = "The Veil Sovereign has fallen. The four beacons shine again.\nValedorn is free to wake from its long night.\n\nPress R to return to the world."

	room_label = _create_label(root, Vector2(330, 125), 20, Color("ffe2a6"))
	room_label.size = Vector2(300, 36)
	room_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	room_label.visible = false
	transition_overlay = ColorRect.new()
	transition_overlay.color = Color(0.01, 0.015, 0.035, 0.0)
	transition_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_overlay.visible = false
	root.add_child(transition_overlay)
	root.move_child(room_label, root.get_child_count() - 1)
	map_overlay = load("res://scripts/world_map.gd").new()
	map_overlay.visible = false
	root.add_child(map_overlay)
	journal_overlay = load("res://scripts/journal.gd").new()
	journal_overlay.visible = false
	root.add_child(journal_overlay)
	journal_overlay.connect("close_requested", _close_journal)
	_build_pause_menu(root)
	keyboard_menu = load("res://scripts/keybind_menu.gd").new()
	keyboard_menu.visible = false
	keyboard_menu.connect("close_requested", _close_keyboard_controls)
	root.add_child(keyboard_menu)
	SettingsManager.keyboard_bindings_changed.connect(_on_keyboard_bindings_changed)

func _build_pause_menu(root: Control) -> void:
	pause_scrim = ColorRect.new()
	pause_scrim.color = Color(0.015, 0.02, 0.04, 0.78)
	pause_scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_scrim.visible = false
	root.add_child(pause_scrim)

	pause_panel = ColorRect.new()
	pause_panel.color = Color("172334")
	pause_panel.position = Vector2(265, 32)
	pause_panel.size = Vector2(430, 476)
	pause_scrim.add_child(pause_panel)
	var title := _create_label(pause_panel, Vector2(0, 18), 30, Color("ffe2a6"))
	title.text = "PAUSED"
	title.size = Vector2(430, 42)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var resume_button := _make_menu_button(pause_panel, Vector2(100, 62), "RESUME")
	resume_button.pressed.connect(func(): toggle_pause(false))
	var restart_button := _make_menu_button(pause_panel, Vector2(100, 107), "RESPAWN AT CHECKPOINT")
	restart_button.pressed.connect(_respawn_and_resume)
	journal_pause_button = _make_menu_button(pause_panel, Vector2(100, 152), "FIELD JOURNAL")
	journal_pause_button.pressed.connect(_open_journal_from_pause)
	keyboard_pause_button = _make_menu_button(pause_panel, Vector2(100, 197), "KEYBOARD CONTROLS")
	keyboard_pause_button.pressed.connect(_open_keyboard_controls)

	var volume_label := _create_label(pause_panel, Vector2(54, 246), 15, Color("d4e1ed"))
	volume_label.text = "MASTER VOLUME"
	var volume_slider := HSlider.new()
	volume_slider.position = Vector2(54, 270)
	volume_slider.size = Vector2(322, 28)
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step = 0.05
	volume_slider.value = SettingsManager.master_volume
	volume_slider.focus_mode = Control.FOCUS_ALL
	volume_slider.value_changed.connect(func(value: float): SettingsManager.set_master_volume(value))
	pause_panel.add_child(volume_slider)

	var fullscreen_toggle := CheckButton.new()
	fullscreen_toggle.text = "Fullscreen"
	fullscreen_toggle.position = Vector2(50, 308)
	fullscreen_toggle.button_pressed = SettingsManager.fullscreen
	fullscreen_toggle.toggled.connect(func(enabled: bool): SettingsManager.set_fullscreen(enabled))
	pause_panel.add_child(fullscreen_toggle)

	var flashing_toggle := CheckButton.new()
	flashing_toggle.text = "Reduce flashing"
	flashing_toggle.position = Vector2(50, 345)
	flashing_toggle.button_pressed = SettingsManager.reduce_flashing
	flashing_toggle.toggled.connect(func(enabled: bool): SettingsManager.set_reduce_flashing(enabled))
	pause_panel.add_child(flashing_toggle)

	controls_hint_label = _create_label(pause_panel, Vector2(22, 386), 10, Color("afc1d2"))
	controls_hint_label.size = Vector2(386, 72)
	controls_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls_hint_label.text = _keyboard_hints()

func toggle_world_map() -> void:
	if paused_by_menu:
		return
	if journal_open:
		_close_journal()
	map_open = not map_open
	map_overlay.visible = map_open
	get_tree().paused = map_open or journal_open
	if map_open:
		map_overlay.queue_redraw()

func _make_menu_button(parent: Control, pos: Vector2, title: String) -> Button:
	var button := Button.new()
	button.text = title
	button.position = pos
	button.size = Vector2(230, 42)
	button.focus_mode = Control.FOCUS_ALL
	parent.add_child(button)
	return button

func toggle_pause(force_paused: Variant = null) -> void:
	if not (force_paused is bool):
		if map_open:
			map_open = false
			map_overlay.visible = false
			get_tree().paused = false
			return
		if journal_open:
			_close_journal()
			return
	if force_paused is bool:
		paused_by_menu = force_paused
	else:
		paused_by_menu = not paused_by_menu
	get_tree().paused = paused_by_menu or map_open or journal_open
	pause_scrim.visible = paused_by_menu
	if paused_by_menu:
		var first_button := pause_panel.get_child(1) as Button
		first_button.grab_focus()
	else:
		get_viewport().gui_release_focus()

func _respawn_and_resume() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if is_instance_valid(player):
		player.call("respawn")
	toggle_pause(false)

func _process(delta: float) -> void:
	if not keyboard_menu.visible:
		if Input.is_action_just_pressed("world_map") and not paused_by_menu:
			toggle_world_map()
		if Input.is_action_just_pressed("journal") and not paused_by_menu:
			toggle_journal()
	if map_open:
		map_overlay.queue_redraw()
	if journal_open:
		journal_overlay.queue_redraw()
	if GameState.story_message != story_message_seen:
		story_message_seen = GameState.story_message
		story_message_left = 4.5 if story_message_seen != "" else 0.0
	story_message_left = maxf(0.0, story_message_left - delta)

func _create_label(parent: Control, pos: Vector2, font_size: int, tint: Color) -> Label:
	var label := Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func update_status(player) -> void:
	if not is_instance_valid(top_label) or not is_instance_valid(player):
		return
	var hearts := ""
	for i in range(player.max_health):
		hearts += "♥ " if i < player.health else "♡ "
	var realm := "VEIL" if GameState.is_veil else "LIVING"
	top_label.text = "VEILFALL  •  %s    |    %s    |    SHARDS %d/1" % [hearts, realm, GameState.shards]
	if GameState.current_room == 0:
		quest_label.text = "01 • Reach the abyss. Shift realities to make the ghost bridge solid."
	elif GameState.current_room == 1:
		quest_label.text = "02 • Touch the checkpoint lantern and cross the next abyss."
	elif GameState.current_room == 2 and GameState.boss_engaged and GameState.boss_health > 0:
		quest_label.text = "03 • The Veil Warden is near. Bait its charge, then strike during recovery."
	elif GameState.current_room == 2 and GameState.boss_max_health > 0 and GameState.boss_health == 0 and GameState.shards < 1:
		quest_label.text = "03 • The Warden dropped a shard. Collect it, then reach the ancient gate."
	elif GameState.current_room == 2 and GameState.shards < 1:
		quest_label.text = "03 • Find the Veil Warden in the forest clearing."
	elif GameState.current_room == 2:
		quest_label.text = "04 • Shard recovered! Pass the gate to reach Lantern Refuge."
	elif GameState.current_room == 3:
		quest_label.text = "REFUGE • Speak with Mira (E). She needs the Furnace Sentinel's ember core."
		if GameState.foundry_boss_defeated and not GameState.keeper_upgrade_claimed:
			quest_label.text = "REFUGE • Mira can trade the Sentinel's ember core for one heart upgrade."
		elif GameState.beacon_memory_count() >= 4 and not GameState.collected_items.has("beacon_crown_01"):
			quest_label.text = "REFUGE • All four Beacon Memories answer. Enter the Crucible through the western arch."
		elif GameState.region_relic_count() >= 4:
			quest_label.text = "REFUGE • Four regional relics answer. The Reliquary Archive is open beside Mira."
		elif GameState.collected_items.has("beacon_crown_01"):
			quest_label.text = "REFUGE • Seek four Regional Relics in the new challenge routes (%d/4)." % GameState.region_relic_count()
		elif GameState.citadel_boss_defeated and GameState.echo_sigil_count() >= 4:
			quest_label.text = "REFUGE • All four sigils answer. Enter the Echo Depths through the new portal."
		elif GameState.citadel_boss_defeated and not GameState.shortcut_unlocked:
			quest_label.text = "REFUGE • Mira needs three Echo Sigils to bind the Citadel waystone (%d/3)." % GameState.echo_sigil_count()
		elif GameState.shortcut_unlocked:
			if GameState.collected_items.has("beacon_crown_01"):
				quest_label.text = "REFUGE • Seek regional relics in the expanded challenge paths (%d/4)." % GameState.region_relic_count()
			else:
				quest_label.text = "REFUGE • Seek four Beacon Memories across the regions (%d/4)." % GameState.beacon_memory_count()
		elif GameState.keeper_upgrade_claimed:
			quest_label.text = "REFUGE • Health reinforced. The Foundry's east passage leads to the Sentinel."
		if GameState.archive_quest_started and GameState.lore_page_count() < 3:
			quest_label.text = "SCRIBE'S QUEST • Find the three hidden folios (%d/3); speak with the Scribe to start or claim it." % GameState.lore_page_count()
		elif GameState.archive_quest_started and not GameState.collected_items.has("lore_reward_01"):
			quest_label.text = "SCRIBE'S QUEST • All folios found. Speak with the Scribe to strengthen Lantern Pulse."
		elif GameState.collected_items.has("lore_reward_01"):
			quest_label.text = "REFUGE • The Scribe's folios have strengthened Lantern Pulse."
	elif GameState.current_room == 4:
		quest_label.text = "ASHEN FOUNDRY • Shift to the Veil for the cache and look for an Echo Sigil."
	elif GameState.current_room == 5 and GameState.boss_engaged and GameState.boss_health > 0:
		quest_label.text = "BOSS • Evade the hammer rush after its bright wind-up; strike during recovery."
	elif GameState.current_room == 5 and GameState.foundry_boss_defeated:
		quest_label.text = "SENTINEL FALLEN • Air Dash unlocked. The north passage leads into the Drowned Crypt."
	elif GameState.current_room == 5:
		quest_label.text = "ASHEN FOUNDRY • Find the Furnace Sentinel in the sealed arena."
	elif GameState.current_room == 6 and GameState.crypt_boss_defeated:
		quest_label.text = "DROWNED CRYPT • Wall Climb unlocked. Search the high ledge for the hidden heart."
	elif GameState.current_room == 6:
		quest_label.text = "DROWNED CRYPT • Cross the flooded hall and reach the bell sanctum."
	elif GameState.current_room == 7 and not GameState.crypt_boss_defeated:
		quest_label.text = "BELL SANCTUM • Read the Abbot's bell wind-up, evade its rush, and strike during recovery."
	elif GameState.current_room == 7:
		quest_label.text = "THE BELL IS SILENT • Wall Climb is yours. Return to the Crypt's high ledges."
	elif GameState.current_room == 8 and not GameState.unlocked_abilities.has("lantern_pulse"):
		quest_label.text = "VEIL CITADEL • Climb the broken spire and reach the lantern altar."
	elif GameState.current_room == 8:
		quest_label.text = "VEIL CITADEL • Lantern Pulse is ready (L / RB). Cross the chime route to the throne."
	elif GameState.current_room >= 9 and GameState.current_room < 15:
		quest_label.text = "VEIL CITADEL • Thread the chime halls. Lantern Pulse breaks the sealed barriers."
	elif GameState.current_room == 15 and GameState.boss_engaged and GameState.boss_health > 0:
		quest_label.text = "FINAL BOSS • Evade the marked rift, leap over the blade rush, then strike its exposed core."
	elif GameState.current_room == 15 and GameState.citadel_boss_defeated and GameState.echo_sigil_count() >= 4:
		quest_label.text = "THE VEIL SOVEREIGN IS GONE • All four sigils open the Echo Depths portal."
	elif GameState.current_room == 15 and GameState.citadel_boss_defeated:
		quest_label.text = "THE VEIL SOVEREIGN IS GONE • The last light has returned to Valedorn."
	elif GameState.current_room >= 16 and GameState.current_room < 20:
		quest_label.text = "ECHO DEPTHS • Cross the mirror path and reach the ancient guardian."
	elif GameState.current_room == 20 and GameState.boss_engaged and GameState.boss_health > 0:
		quest_label.text = "ECHO WARDEN • Avoid its marked strike and rush; attack during the pale recovery."
	elif GameState.current_room == 20 and GameState.echo_warden_defeated:
		quest_label.text = "ECHO WARDEN DEFEATED • Lantern Pulse is stronger and recharges faster."
	elif GameState.current_room == 20:
		quest_label.text = "ECHO DEPTHS • The ancient guardian stirs beyond the veil."
	elif GameState.current_room >= 21 and GameState.current_room <= 24:
		quest_label.text = "BEACON MEMORIES • Gather the fragment in this chamber, then return through the western arch (%d/4)." % GameState.beacon_memory_count()
	elif GameState.current_room == 25 and not GameState.collected_items.has("beacon_crown_01"):
		quest_label.text = "BEACON CRUCIBLE • The four memories have awakened the Beacon Crown. Claim its final blessing."
	elif GameState.current_room == 25:
		quest_label.text = "THE LAST LIGHT • The Beacon Crown is yours. Return to the Refuge or continue exploring."
	elif GameState.current_room >= 26 and GameState.current_room <= 33:
		quest_label.text = "REGIONAL CHALLENGE • Search the connected rooms for their relic (%d/4 collected)." % GameState.region_relic_count()
	elif GameState.current_room == 34 and not GameState.collected_items.has("reliquary_heart_01"):
		quest_label.text = "RELIQUARY ARCHIVE • Claim the heart awakened by the four regional relics."
	elif GameState.current_room == 34:
		quest_label.text = "RELICS REUNITED • The Reliquary Heart is yours."
	elif GameState.current_room >= 35 and GameState.current_room <= 37:
		quest_label.text = "SCRIBE'S QUEST • Recover the hidden folio (%d/3) and return to the Refuge." % GameState.lore_page_count()
	else:
		quest_label.text = "VEIL THRONE • Watch the Sovereign's warnings and punish its exposed core."
	if story_message_left > 0.0 and GameState.story_message != "":
		quest_label.text = GameState.story_message
	if is_instance_valid(journal_overlay):
		journal_overlay.call("set_current_objective", quest_label.text)
	boss_label.text = GameState.active_boss_name
	boss_label.visible = GameState.boss_engaged and GameState.boss_health > 0
	boss_bar.visible = GameState.boss_engaged and GameState.boss_health > 0
	boss_bar.value = GameState.boss_health
	boss_bar.max_value = maxi(1, GameState.boss_max_health)
	if GameState.won:
		win_panel.visible = true
		helper_label.text = "R return to the world"

func toggle_journal() -> void:
	if journal_open:
		_close_journal()
		return
	if map_open:
		map_open = false
		map_overlay.visible = false
	journal_return_to_pause = false
	journal_open = true
	journal_overlay.visible = true
	journal_overlay.call("refresh_progress")
	get_tree().paused = true
	journal_overlay.call("grab_close_focus")

func _open_journal_from_pause() -> void:
	paused_by_menu = false
	pause_scrim.visible = false
	journal_return_to_pause = true
	journal_open = true
	journal_overlay.visible = true
	journal_overlay.call("refresh_progress")
	get_tree().paused = true
	journal_overlay.call("grab_close_focus")

func _open_keyboard_controls() -> void:
	paused_by_menu = false
	pause_scrim.visible = false
	keyboard_return_to_pause = true
	keyboard_menu.call("open_menu")
	get_tree().paused = true

func _close_keyboard_controls() -> void:
	keyboard_menu.visible = false
	if keyboard_return_to_pause:
		keyboard_return_to_pause = false
		paused_by_menu = true
		pause_scrim.visible = true
		if is_instance_valid(keyboard_pause_button):
			keyboard_pause_button.grab_focus()
	get_tree().paused = paused_by_menu or map_open or journal_open

func _on_keyboard_bindings_changed() -> void:
	helper_label.text = _compact_keyboard_hints()
	if is_instance_valid(controls_hint_label):
		controls_hint_label.text = _keyboard_hints()

func _keyboard_hints() -> String:
	if not is_instance_valid(SettingsManager):
		return ""
	return "Keys: %s/%s move  •  %s jump  •  %s attack  •  %s shift\n%s dash  •  %s pulse  •  %s interact  •  %s map  •  %s journal\nPause: %s  •  Controller: left stick/D-pad move • A jump • X attack • Y shift\nB dash • LB interact • RB pulse • Back map • Start pause • Wall Climb: wall + jump" % [
		SettingsManager.get_keyboard_binding_name("move_left"),
		SettingsManager.get_keyboard_binding_name("move_right"),
		SettingsManager.get_keyboard_binding_name("jump"),
		SettingsManager.get_keyboard_binding_name("attack"),
		SettingsManager.get_keyboard_binding_name("shift_realm"),
		SettingsManager.get_keyboard_binding_name("air_dash"),
		SettingsManager.get_keyboard_binding_name("lantern_pulse"),
		SettingsManager.get_keyboard_binding_name("interact"),
		SettingsManager.get_keyboard_binding_name("world_map"),
		SettingsManager.get_keyboard_binding_name("journal"),
		SettingsManager.get_keyboard_binding_name("pause")
	]

func _compact_keyboard_hints() -> String:
	if not is_instance_valid(SettingsManager):
		return ""
	return "%s/%s move  •  %s jump  •  %s attack  •  %s realm  •  %s dash  •  %s pulse  •  %s interact  •  %s map  •  %s journal" % [
		SettingsManager.get_keyboard_binding_name("move_left"),
		SettingsManager.get_keyboard_binding_name("move_right"),
		SettingsManager.get_keyboard_binding_name("jump"),
		SettingsManager.get_keyboard_binding_name("attack"),
		SettingsManager.get_keyboard_binding_name("shift_realm"),
		SettingsManager.get_keyboard_binding_name("air_dash"),
		SettingsManager.get_keyboard_binding_name("lantern_pulse"),
		SettingsManager.get_keyboard_binding_name("interact"),
		SettingsManager.get_keyboard_binding_name("world_map"),
		SettingsManager.get_keyboard_binding_name("journal")
	]

func _close_journal() -> void:
	journal_open = false
	journal_overlay.visible = false
	if journal_return_to_pause:
		paused_by_menu = true
		pause_scrim.visible = true
		journal_return_to_pause = false
		if is_instance_valid(journal_pause_button):
			journal_pause_button.grab_focus()
	else:
		paused_by_menu = false
		get_viewport().gui_release_focus()
	get_tree().paused = paused_by_menu or map_open

func play_room_transition(room_id: int) -> void:
	var names := ["LANTERN PATH", "THE BROKEN BRIDGE", "THE WARDEN'S CLEARING", "LANTERN REFUGE", "CINDER WALK", "THE FURNACE SENTINEL", "SUNKEN GALLERY", "THE BELL SANCTUM", "STARLESS GALLERY", "CITADEL APPROACH", "CHIME GALLERY", "LENS ARCHIVE", "SHATTERED NAVE", "BEACON ENGINE", "SOVEREIGN APPROACH", "THE VEIL THRONE", "ECHO THRESHOLD", "MIRROR CAUSEWAY", "SILENT ARCHIVE", "SHARD GARDEN", "ECHO WARDEN", "VERDANT MEMORY", "EMBER MEMORY", "DROWNED MEMORY", "STARLESS MEMORY", "BEACON CRUCIBLE", "CANOPY APPROACH", "ROOTHEART VAULT", "FOUNDRY FLUE", "MELTWORKS", "CRYPT GALLERY", "TIDE ANNEX", "OBSERVATORY GATE", "ASTRAL CAUSEWAY", "RELIQUARY ARCHIVE", "VEIL ALMANAC", "DROWNED REGISTER", "STARLESS TESTAMENT"]
	var region := "ARCHIVE SECRETS" if room_id >= 35 else ("REGIONAL CHALLENGES" if room_id >= 26 and room_id <= 33 else ("RELIQUARY" if room_id == 34 else ("BEACON MEMORIES" if room_id >= 21 else ("ECHO DEPTHS" if room_id >= 16 else ("VEIL CITADEL" if room_id >= 8 else ("DROWNED CRYPT" if room_id >= 6 else ("ASHEN FOUNDRY" if room_id >= 4 else ("LANTERN REFUGE" if room_id == 3 else "WHISPERING WOODS"))))))))
	room_label.text = "%s  •  %s" % [region, names[clampi(room_id, 0, names.size() - 1)]]
	room_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	transition_overlay.color = Color(0.01, 0.015, 0.035, 0.0)
	transition_overlay.visible = true
	room_label.visible = true
	var tween := create_tween()
	tween.tween_property(transition_overlay, "color:a", 0.72, 0.10)
	tween.parallel().tween_property(room_label, "modulate:a", 1.0, 0.18)
	tween.tween_property(transition_overlay, "color:a", 0.0, 0.20)
	tween.tween_interval(0.45)
	tween.tween_property(room_label, "modulate:a", 0.0, 0.35)
	tween.tween_callback(func():
		transition_overlay.visible = false
		room_label.visible = false
	)
