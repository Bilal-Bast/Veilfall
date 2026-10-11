extends Node2D
## Optional Refuge quest giver for the lost archive folios.
var nearby := false

func _ready() -> void:
    var area := Area2D.new()
    area.collision_layer = 0
    area.collision_mask = 2
    var shape := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = 66.0
    shape.shape = circle
    area.add_child(shape)
    add_child(area)
    area.body_entered.connect(func(body):
        if body.is_in_group("player"):
            nearby = true
    )
    area.body_exited.connect(func(body):
        if body.is_in_group("player"):
            nearby = false
    )

func _process(_delta: float) -> void:
    if nearby and Input.is_action_just_pressed("interact"):
        if not GameState.archive_quest_started:
            GameState.start_archive_quest()
            GameState.story_message = "SCRIBE: Search the Broken Bridge in Veil, the Crypt with Wall Climb, and Lens Archive with Pulse."
        elif GameState.lore_page_count() >= 3 and not GameState.collected_items.has("lore_reward_01"):
            GameState.collected_items.append("lore_reward_01")
            Sfx.play("checkpoint", -2.0, 1.12)
            GameState.story_message = "SCRIBE: The folios are whole. Your Lantern Pulse now reaches farther."
            SaveManager.save_game()
        elif GameState.collected_items.has("lore_reward_01") and GameState.echo_warden_defeated and not GameState.collected_items.has("resonant_wick_01"):
            GameState.collected_items.append("resonant_wick_01")
            Sfx.play("checkpoint", -2.0, 1.16)
            GameState.story_message = "SCRIBE: The Warden guarded the last verse. Take this Resonant Wick; it will hasten your Lantern Pulse."
            SaveManager.save_game()
        elif GameState.collected_items.has("resonant_wick_01"):
            GameState.story_message = "SCRIBE: My pages are whole, and the Resonant Wick keeps their final cadence."
        elif GameState.collected_items.has("lore_reward_01"):
            GameState.story_message = "SCRIBE: The old words travel with you. Your Pulse carries their light. Return after the Echo Warden falls; one verse remains."
        elif GameState.lore_page_count() == 0:
            GameState.story_message = "SCRIBE: Search the Broken Bridge in Veil, the Crypt with Wall Climb, and Lens Archive with Pulse."
        else:
            GameState.story_message = "SCRIBE: The Bridge, Crypt, and Lens Archive hide my folios (%d/3 found)." % GameState.lore_page_count()
        GameState.quest_updated.emit()
    queue_redraw()

func _draw() -> void:
    draw_circle(Vector2(0, -19), 11.0, Color("d7c8a8"))
    draw_colored_polygon(PackedVector2Array([Vector2(-16, -14), Vector2(0, -34), Vector2(16, -14), Vector2(15, 21), Vector2(-15, 21)]), Color("675d79"))
    draw_line(Vector2(-10, -2), Vector2(10, -2), Color("c6b38d"), 2.0)
    draw_line(Vector2(-10, 4), Vector2(7, 4), Color("c6b38d"), 2.0)
    draw_rect(Rect2(9, 2, 8, 12), Color("edcd86"))
    if nearby:
        var hint := "E  SPEAK"
        if GameState.archive_quest_started and GameState.lore_page_count() >= 3 and not GameState.collected_items.has("lore_reward_01"):
            hint = "E  RESTORE"
        elif GameState.collected_items.has("lore_reward_01") and GameState.echo_warden_defeated and not GameState.collected_items.has("resonant_wick_01"):
            hint = "E  CLAIM WICK"
        draw_string(ThemeDB.fallback_font, Vector2(-49, -48), hint, HORIZONTAL_ALIGNMENT_CENTER, 98.0, 13, Color("fff0bb"))
