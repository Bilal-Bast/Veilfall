# VEILFALL: THE LAST LIGHT
**Godot 4.7 release-candidate project — all four regions, optional Echo Depths, original SFX, visual feedback, and a title screen**

This project extends the working first playable into a 38-room route across all four regions, plus the optional Echo Depths, Beacon Memory, Regional Relic, and Archive Secret branches. It uses stock Godot nodes, original project assets, and no plugins or third-party runtime dependencies.

## Open and run
1. Extract the ZIP to a folder, for example `C:\Users\bilal\github\veilfall`.
2. Open **Godot 4.7** > Import > select `project.godot`.
3. Press **F5** to open the title screen. Choose **Continue** for an existing save or **New Journey** to start fresh.
4. Cross the Woods, defeat the Veil Warden, collect its shard, pass through Lantern Refuge, speak with Mira, challenge the Furnace Sentinel, defeat the Drowned Abbot, then climb through the expanded Veil Citadel and face the Sovereign. Find all four Echo Sigils to unlock the optional Echo Depths.

## Keyboard
- `A / D` or arrow keys: move
- `Space`, `W` or Up arrow: jump (tap for a shorter jump)
- `J` or left mouse: sword attack
- `Q` or `Tab`: switch realities
- `K` or Left Shift: Air Dash (unlocks after defeating the Furnace Sentinel)
- Hold movement toward a wall + `Space`: Wall Climb (unlocks after the Drowned Abbot)
- `L`: Lantern Pulse (unlocks at the Citadel altar; 6-second base cooldown, reduced by Echo Warden mastery and the Scribe’s Resonant Wick)
- `M`: open/close the discovered-room map
- `N`: open/close the Field Journal (objective, expedition progress, side-story counts, controls)
- Keyboard bindings can be changed in **Options → Keyboard Controls** or **Pause → Keyboard Controls**. Controller and mouse defaults stay available.
- `E`: talk with Mira or enter an unlocked memory doorway
- `R`: respawn at the checkpoint
- `Esc`: pause, adjust settings, or respawn
- Controller: left stick/D-pad move; A jump; X attack; Y Veil Shift; B Air Dash; LB interact; RB Lantern Pulse; Back map; Start pause

## Current playable content
- The Woods now open into **Lantern Refuge**, a small safe hub with a persistent checkpoint and Mira, an NPC quest giver.
- The hub connects directly to the opening of the **Ashen Foundry**, adding two authored room scenes.
- The Foundry has Ashling lunge enemies, a Veil-only upper route with a one-time healing cache, and a Furnace Sentinel boss with a bright hammer wind-up, rushing strike, and recovery window.
- Defeating the Sentinel unlocks **Air Dash**. Returning to Mira with its ember core grants one permanent maximum-health upgrade.
- New progress is saved: Sentinel defeat, Air Dash, Mira's upgrade, the Refuge passage, and cache collection.
- Save schema v6 migrates existing v1–v5 saves with safe defaults; old Citadel checkpoints and discovered-room data move to the relocated finale.
- The eight earlier connected rooms retain the original Woods art, ambience, room transitions, camera bounds, and checkpoint behavior.
- The Drowned Crypt adds a climb-focused Sunken Gallery, the Drowned Abbot bell-rush boss, a checkpointed Bell Sanctum, and a hidden post-boss heart cache reachable with Wall Climb.
- The Veil Citadel adds a vertical spectral gallery, a Lantern Pulse altar, a Wall Climb gate, a throne checkpoint, and the Veil Sovereign with alternating rift and blade attacks.
- Phase 9 expands the Citadel with six connected rooms: Approach, Chime Gallery, Lens Archive, Shattered Nave, Beacon Engine, and Sovereign Approach. Rift Moths dive after a visible tell; Veil Archers fire slow charged bolts; Lantern Pulse opens chime barriers; an optional beacon heart raises maximum health.
- Phase 10 adds five optional Echo Depths rooms. The route opens after the Sovereign is defeated and all four sigils are collected. An Echo Warden guards a permanent Lantern Pulse mastery upgrade.
- Phase 11 adds four short, ability-gated Memory chambers branching from old regions and a Beacon Crucible in the Refuge. Gather four memories to awaken the final crown and gain one permanent heart.
- Phase 12 reaches 35 rooms with two challenge rooms in each region and a Reliquary Archive in the Refuge. Four persistent regional relics open a final heart upgrade.
- Phase 13 adds three hidden archive chambers and a Refuge Scribe quest. Three folios unlock a permanent Lantern Pulse range increase.
- Phase 14 adds eight original synthesized sound effects with a capped polyphonic audio manager, wired to combat, Veil Shift, Pulse, pickups, checkpoints, boss rewards, and portal travel. Effects honor the existing Master volume setting.
- Phase 15 adds an accessibility-aware visual feedback manager for realm shifts, combat impacts, damage, Pulse, and pickups, with capped code-drawn particles and camera shake.
- Phase 16 adds the title screen, Continue/New Journey flow with save-replacement confirmation, and pre-game access to saved options.
- Phase 17 adds a standard-library integrity checker and a Windows Desktop x86_64 export preset with embedded game data. Runtime playtesting and Windows export are still pending.
- Phase 18 adds the Field Journal overlay with the live objective, discovered-room and boss progress, traversal abilities, optional quest counters, and a controls guide. Open it with N or from the pause menu; it reads existing progress without changing save data.
- Phase 19 improves the discovered-room map with room-type markers, region colors, and boss status markers. Markers appear only after discovery, preserving fog of war.
- Phase 20 adds a persistent keyboard-rebinding screen reachable from the title options and pause menu. It rejects duplicate bindings, supports restoring defaults, and keeps controller/mouse mappings and progression saves separate.
- The discovered-room map fills in as you explore. Four Echo Sigils are tucked across earlier rooms; bring three to Mira after the final boss to open a persistent Refuge–Citadel shortcut.

Phase 5 release-prep work now adds controller mappings, a focusable pause menu, saved master volume/fullscreen/reduced-flashing settings, and a Windows export checklist. The current build still needs hands-on controller and Windows export verification.

The current route has 21 original route rooms plus seventeen optional challenge rooms, five bosses, two traversal abilities, Lantern Pulse, and several short progression loops. The project now has 38 rooms; the remaining room target is 35–45. More side quests, final art, and hands-on release testing remain planned.

## Suggested content playtest
1. Load an existing save or start fresh; cross the Woods, beat the Warden, collect the shard, and pass the gate.
2. Activate the Refuge checkpoint and talk with Mira using E.
3. In the Foundry, test the lunge enemy and switch to the Veil to reach the upper cache.
4. Activate the arena checkpoint, defeat the Sentinel by attacking through its recovery, and confirm Air Dash unlocks.
5. Return to Mira for the permanent health upgrade. Close and reopen the project and confirm the ability, cache, bosses, health upgrade, and checkpoint persist.
6. Use K or Left Shift in midair to dash once per jump; confirm it refreshes after landing.
7. Defeat the Drowned Abbot, confirm Wall Climb unlocks, then revisit the Sunken Gallery and reach its high heart cache.
8. Climb through the Crypt's right gate, reach the Citadel altar, and confirm Lantern Pulse damages nearby enemies with its cooldown.
9. Explore all six new Citadel rooms. Pulse the chime barriers, learn the Moth and Archer attack tells, and find the optional heart in Beacon Engine.
10. Activate the throne checkpoint. Evade the Sovereign's marked rift and blade rush, then attack during its exposed recovery. Defeat it and confirm the ending appears.
11. Revisit Mira, collect three Echo Sigils across earlier regions, claim the waystone link, and travel from the Refuge to the Citadel and back.
12. Collect the fourth Echo Sigil, defeat the Sovereign, then press R to return to the world. Enter the new portal from the Refuge or Citadel and clear the Echo Warden.
13. Confirm Lantern Pulse mastery persists after restarting, then press M/Back and verify the map shows 35 rooms with discoveries preserved.
14. Revisit the Woods, Foundry, Crypt, and Citadel after their gates open. Enter each memory door, take its fragment, and return through the east arch. Check Mira’s count after each pickup.
15. With all four memories, enter the Refuge’s western door. Claim the Beacon Crown, verify the extra heart, leave, restart, and confirm the health upgrade remains.
16. Follow `docs/PHASE14_AUDIO_FEEDBACK.md` to check sound triggers, Master-volume behavior, and overlapping effect playback.
17. Follow `docs/PHASE15_VISUAL_FEEDBACK.md` to check realm transitions, impact effects, camera recovery, and the Reduce Flashing option.
18. Follow `docs/PHASE16_TITLE_SCREEN.md` to verify new/continue flows, save confirmation, settings continuity, and controller focus.
19. Follow `docs/PHASE17_RELEASE_CANDIDATE.md` for the static check, Godot parse, Windows export, and release playtest.
20. Follow `docs/PHASE18_FIELD_JOURNAL.md` to verify objective updates, progress counters, pause-menu access, and return-to-pause behavior.
21. Follow `docs/PHASE19_MAP_MARKERS.md` to verify discovered-room markers, boss status, region colors, and fog-of-war behavior.
22. Follow `docs/PHASE20_KEYBOARD_CONTROLS.md` to verify rebinding, conflict feedback, saved settings, reset defaults, and controller fallback.

## Files
- `scenes/title_screen.tscn`: boot scene and front-end
- `scenes/main.tscn`: gameplay scene
- `scenes/world.tscn`: current handcrafted test route
- `scenes/rooms/*.tscn`: twenty-one authored route scenes plus seventeen dynamically composed side rooms
- `scenes/player.tscn`: player, camera, and hitbox
- `scenes/hud.tscn`: HUD
- `scripts/*.gd`: mechanics, NPC quests, five boss encounters, enemies, abilities, and interactables
- `assets/tilesets/whispering_woods.png`: original 4-tile, 32×32 atlas
- `assets/backgrounds/regions/`: six illustrated region backdrops
- `assets/characters/kael_idle.png`: transparent Kael idle sprite
- `assets/audio/music/` and `assets/audio/ambience/`: six synthesized regional loops in each folder
- `assets/audio/whispering_woods_ambience.wav`: original ambient loop
- `assets/audio/sfx/*.wav`: eight original gameplay sound effects
- `scripts/sfx.gd`: pooled one-shot audio manager
- `scripts/game_feedback.gd`: capped particles, camera shake, and realm-shift tint
- `scripts/journal.gd`: Field Journal overlay with live objective and progress summaries
- `scripts/keybind_menu.gd`: reusable keyboard remapping screen for title and pause menus
- `tools/verify_project.py`: standard-library project-integrity check
- `tools/build_phase21_assets.py`: reproducible background, sprite-matte, music, and ambience asset generation
- `export_presets.cfg`: Windows Desktop x86_64 export preset
- `docs/GAME_DESIGN.md`: game vision, architecture, and milestones
- `docs/PHASE5_RELEASE_CHECKLIST.md`: controller, settings, save migration, and Windows build QA
- `docs/PHASE6_DROWNED_CRYPT.md`: Crypt playthrough and Wall Climb checks
- `docs/PHASE7_VEIL_CITADEL.md`: final region, ability, boss, and ending checks
- `docs/PHASE8_EXPLORATION.md`: fog-of-war map, sigil quest, and shortcut checks
- `docs/PHASE9_CITADEL_EXPANSION.md`: six-room Citadel expansion, combat tells, puzzle gates, and save migration
- `docs/PHASE10_ECHO_DEPTHS.md`: postgame access, optional boss, Pulse mastery, and migration checks
- `docs/PHASE11_BEACON_MEMORIES.md`: regional memory quest, final reward, and v8 save migration checks
- `docs/PHASE12_REGIONAL_RELICS.md`: nine-room expansion, relic routes, final archive, and v9 save migration checks
- `docs/PHASE13_ARCHIVE_SECRETS.md`: hidden folios, Scribe quest, Pulse reward, and v10 migration checks
- `docs/PHASE14_AUDIO_FEEDBACK.md`: cue sheet and audio integration playtest
- `docs/PHASE15_VISUAL_FEEDBACK.md`: reduced-flashing visual effects and feedback playtest
- `docs/PHASE16_TITLE_SCREEN.md`: title screen, save, and settings-entry checks
- `docs/PHASE17_RELEASE_CANDIDATE.md`: integrity audit, export command, and final QA
- `docs/PHASE18_FIELD_JOURNAL.md`: Field Journal feature and focused UI playtest
- `docs/PHASE19_MAP_MARKERS.md`: map marker meanings, boss status, and exploration checks
- `docs/PHASE20_KEYBOARD_CONTROLS.md`: keyboard rebinding and settings persistence checks
- `docs/PHASE21_ART_AUDIO_CONTENT.md`: art/audio integration, Scribe upgrade, and focused playtest

## Settings behavior
The title screen and pause menu both expose audio volume, fullscreen, and reduced-flashing preferences. These save separately to `user://veilfall_settings.cfg`; they do not overwrite progression.

## Save behavior
Progress is written locally to Godot's `user://veilfall_save.json` using versioned, allowlisted JSON. Version 10 reads version 1–9 saves and supplies defaults for newer content. A bad or unsupported save is ignored in favor of the default start. The save contains checkpoint position, realm, boss flags, discovered rooms, collected item IDs, shortcut and quest state, and unlocked abilities; it stores no passwords or network data.

## Scope
The current build is 21 original route rooms plus seventeen optional chambers, five boss encounters, a discovered-room map, two NPC quest loops, four Echo Sigils, four Beacon Memories, four permanent health upgrades, two traversal abilities, Lantern Pulse mastery, and fast-travel shortcuts. Phase 21 adds illustrated backdrops for every region, a pixel-art Kael idle sprite, region-colored platforms, twelve original regional audio loops, and the Scribe’s Resonant Wick follow-up upgrade. Kael still needs run/jump/attack animation frames; enemies, bosses, NPC portraits, and regional foreground tile atlases still need final art. Godot runtime and export checks remain outstanding.

## References
- [Godot 4.7 CharacterBody2D tutorial](https://docs.godotengine.org/en/4.7/tutorials/physics/using_character_body_2d.html)
- [Godot 4.7 TileMapLayer API](https://docs.godotengine.org/en/4.7/classes/class_tilemaplayer.html)
