extends Node2D
## Refuge quest giver: trade the Foundry ember core for one permanent health upgrade.
var nearby: bool = false
var player: Variant

func _ready() -> void:
    var area := Area2D.new()
    area.collision_layer = 0
    area.collision_mask = 2
    var shape := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = 72.0
    shape.shape = circle
    area.add_child(shape)
    add_child(area)
    area.body_entered.connect(func(body):
        if body.is_in_group("player"):
            nearby = true
            player = body
    )
    area.body_exited.connect(func(body):
        if body.is_in_group("player"):
            nearby = false
    )

func _process(_delta: float) -> void:
    if nearby and Input.is_action_just_pressed("interact"):
        if not GameState.keeper_upgrade_claimed and GameState.foundry_boss_defeated and GameState.claim_keeper_upgrade():
            if is_instance_valid(player):
                player.max_health += 1
                player.health = player.max_health
                player.health_changed.emit(player.health, player.max_health)
            GameState.story_message = "MIRA: The ember has hardened your light. Your heart can bear one more wound."
        elif GameState.citadel_boss_defeated and not GameState.shortcut_unlocked:
            if GameState.claim_echo_quest_reward():
                pass
            else:
                GameState.story_message = "MIRA: Find three Echo Sigils in the old rooms (%d/3). I can bind them into a Refuge–Citadel waystone." % GameState.echo_sigil_count()
        elif GameState.shortcut_unlocked:
            if GameState.region_relic_count() >= 4:
                GameState.story_message = "MIRA: The regional relics have awakened the Reliquary Archive beside me."
            elif GameState.collected_items.has("beacon_crown_01"):
                GameState.story_message = "MIRA: Four relics remain across the expanded paths (%d/4)." % GameState.region_relic_count()
            elif GameState.beacon_memory_count() >= 4:
                GameState.story_message = "MIRA: All four memories are restored. The Beacon Crucible is open beside the Refuge entrance."
            else:
                GameState.story_message = "MIRA: Seek the four preserved memories in the Woods, Foundry, Crypt, and Citadel (%d/4)." % GameState.beacon_memory_count()
        elif GameState.keeper_upgrade_claimed:
            GameState.story_message = "MIRA: Keep the flame close, Kael. The Veil Sovereign still waits in the Citadel."
        elif GameState.foundry_boss_defeated:
            GameState.story_message = "MIRA: Bring me the Sentinel's ember core. It can strengthen your light."
        else:
            GameState.story_message = "MIRA: The Foundry's Sentinel holds the ember core. Bring it back, and I can reinforce your light."
        GameState.quest_updated.emit()
    queue_redraw()

func _draw() -> void:
    draw_circle(Vector2(0, -19), 11.0, Color("edc99b"))
    draw_colored_polygon(PackedVector2Array([Vector2(-15, -16), Vector2(0, -34), Vector2(15, -16), Vector2(19, 22), Vector2(-19, 22)]), Color("536f70"))
    draw_line(Vector2(12, -2), Vector2(23, 19), Color("a9855c"), 3.0)
    draw_circle(Vector2(24, 19), 5.0, Color("ffd487"))
    if nearby:
        var hint := "E  LISTEN"
        if GameState.foundry_boss_defeated and not GameState.keeper_upgrade_claimed:
            hint = "E  UPGRADE"
        elif GameState.citadel_boss_defeated and not GameState.shortcut_unlocked:
            hint = "E  SIGILS"
        elif GameState.shortcut_unlocked:
            hint = "E  RELICS" if GameState.collected_items.has("beacon_crown_01") else "E  MEMORIES"
        elif GameState.keeper_upgrade_claimed:
            hint = "E  SPEAK"
        draw_string(ThemeDB.fallback_font, Vector2(-50, -49), hint, HORIZONTAL_ALIGNMENT_CENTER, 100.0, 14, Color("fff0bb"))
