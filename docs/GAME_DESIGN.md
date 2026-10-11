# VEILFALL: THE LAST LIGHT — Game Design Blueprint

## One-line pitch
A handcrafted 2D action Metroidvania where a lantern bearer switches between the Living World and the Veil to reshape routes, solve traversal challenges and reclaim the four beacons of Valedorn.

## Identity
- **Player:** Kael, an apprentice lantern bearer.
- **Setting:** Valedorn, a kingdom lost between two realities.
- **Genre:** PC-first, single-player, exploration/action Metroidvania.
- **Style:** Readable 32px-informed 2D painted/pixel-art hybrid; parallax layered environments.
- **Pillars:** responsive movement; dual-world exploration; memorable boss fights; fair discovery.
- **Estimated target length:** 2–4 hours (ambitious, not guaranteed).
- **No launch scope:** multiplayer, crafting, procedural generation, live service, open-world simulation.

## The Veil Shift rule
Press Q (or Tab) to switch between reality states. In early levels, certain spectral platforms are intangible in the Living World and solid in the Veil. Later, realm-sensitive puzzles and enemies deepen this without requiring entirely duplicate levels. Switching mid-jump should feel immediate; it is a core mechanic, not a costly cooldown.

## World structure
- **Lantern Refuge (hub):** shop, quest-giver, map board and ability upgrades.
- **Whispering Woods:** lost paths, traversal tutorials. Unlock: Veil Shift.
- **Ashen Foundry:** pistons, hot hazards, moving platform combinations. Unlock: Air Dash.
- **Drowned Crypt:** vertical ruins, water hazards and secret galleries. Unlock: Wall Climb.
- **Veil Citadel:** final challenges testing mastered powers and central antagonist.

Connections are *nonlinear with gating*: each acquired ability reopens side routes in prior regions. Include 35–45 small handcrafted rooms total, subject to playtesting.

## Main loop
Explore -> discover a path/lock -> learn its rule -> overcome enemies/platforming -> unlock shortcut/checkpoint -> earn ability or shard -> return to hub/previous routes -> progress toward beacon.

## Controls (PC keyboard)
A/D or arrows: horizontal; Space/W/Up: jump; J or mouse left: sword; Q/Tab: shift reality; R: restart from checkpoint during prototype.

## Game features by version
### Prototype / M1
Three contiguous test-room sections, a player controller (run/jump/coyote/buffer), simple sword attack, 3 patrol enemies, instant realm switching and spectral collision platforms, a checkpoint, a shard, a final gate, HUD, fall respawn, and a winning state. **Session only**, no permanent saves and no final art.
### Vertical slice / M2
The original Whispering Woods tiles, Kael poses, forest ambience, Veil Warden miniboss, and versioned room/save foundation are retained. Phase 4 adds the hub, second region, one NPC upgrade quest, a secret cache, Ashling enemies, Furnace Sentinel boss, and Air Dash.

**Remaining M2 work:** add a complete enemy family and basic map discovery. Final player and boss sprite sheets replace the procedural art after the slice is playtested.
### Phase 4 content slice (current build)
The initial six-room slice covered the three-room Whispering Woods route, Lantern Refuge, and two Ashen Foundry rooms. Mira asks Kael to defeat the Furnace Sentinel; its ember core unlocks Air Dash, then Mira trades it for one permanent health slot. A Veil-only upper path hides a one-time healing cache. Progress is persisted with a v1-to-v2 save migration.

That initial slice shipped the first two bosses: the Veil Warden (charge/recovery) and Furnace Sentinel (hammer rush/recovery). This slice intentionally covers one new region and its main progression loop. It does not claim the full game is complete.

### Phase 6 content expansion
The Drowned Crypt is now connected after an Air Dash gate in the Ashen Foundry. Its Sunken Gallery is a two-level route with a Crypt Leech enemy, a checkpoint, and a high heart cache that can be reached after Wall Climb unlocks. The Bell Sanctum contains the Drowned Abbot, whose bell wind-up signals a fast tidal rush and recovery window. Defeating the Abbot unlocks Wall Climb; save schema v3 preserves the boss flag and cache across reloads.

### Phase 7 content expansion (current build)
The Veil Citadel adds two rooms behind a Wall Climb gate. The Starless Gallery is a vertical realm-shifting challenge ending at a lantern altar, which grants Lantern Pulse (L / RB, six-second cooldown, close-range area damage). The Veil Throne has its own checkpoint and the final Sovereign boss. It alternates a marked rift burst with a fast blade rush; the exposed core is vulnerable to sword strikes, while Lantern Pulse can interrupt its other phases. Defeating it completes the story. Save schema v4 reads v1–v3 saves and persists the fourth boss and Lantern Pulse.

### Phase 8 exploration systems (current build)
The M key / controller Back opens a pause-the-game room map. Its fog of war records discovered rooms and persists them in save schema v5. Four Echo Sigils are placed in the Woods Bridge, Foundry Entry, Sunken Gallery, and Starless Gallery. After the Sovereign falls, Mira offers an optional return quest: collect any three and she binds the Refuge and Citadel waystones into a two-way fast-travel shortcut. The sigils, quest reward, shortcut, and room discoveries persist across v1–v4 save migration.

### Phase 9 Citadel expansion (current build)
The connected route now has sixteen rooms. Six new Citadel rooms lead from the Starless Gallery to the Veil Throne: Citadel Approach, Chime Gallery, Lens Archive, Shattered Nave, Beacon Engine, and Sovereign Approach. Rift Moths telegraph diving attacks; Veil Archers charge readable bolts; Lantern Pulse opens chime barriers; a hidden Beacon Engine cache grants another maximum-health slot. Save schema v6 relocates old Citadel checkpoint and map data to the moved throne room while preserving earlier room IDs.

### Phase 10 Echo Depths
The optional five-room Echo Depths opens after the Sovereign is defeated and all four Echo Sigils are collected. It adds a branching postgame challenge with a checkpointed threshold, Mirror Causeway, Silent Archive, Shard Garden, and the Echo Warden arena. The Warden alternates a marked strike and a rushing attack, leaving a readable recovery window. Its defeat permanently improves Lantern Pulse range, damage, and cooldown. Save schema v7 adds the optional boss flag and preserves all Phase 9 room IDs.

### Phase 11 Beacon Memories
Four short ability-gated side chambers branch from the Warden clearing, Foundry arena, Bell Sanctum, and Starless Gallery. Each holds a persistent regional memory. The Refuge portal opens when all four are found and leads to the Beacon Crucible, where the final crown grants one maximum-health slot. The rooms preserve the existing IDs 0–20; schemas v1–v7 migrate into schema v8, which tracks rooms 0–25 and the new collectibles. This phase adds replayable region revisits and a clear postgame completion objective without adding another boss or a new movement ability.

### Phase 12 Regional Relics (current build)
The Woods Canopy, Foundry Flue, Crypt Gallery, and Citadel Observatory each lead through a two-room challenge route. Air Dash, the Sentinel defeat, Wall Climb, and Lantern Pulse open the four entrances. Each route includes a combat or realm traversal beat and ends with a persistent regional relic. Collect all four to open the Refuge Reliquary Archive and claim another permanent heart. The expanded map contains 35 rooms total; save schema v9 preserves the Phase 11 room IDs and collectible state.

### Phase 13 Archive Secrets (current build)
The Refuge Scribe offers an optional folio quest that unlocks hidden chambers in the Woods, Crypt, and Citadel. One chamber requires Veil Shift, one Wall Climb, and one Lantern Pulse. Three persistent folios complete the quest and grant a permanent 25-unit Pulse range increase, stacking with Echo Warden mastery. The map now covers 38 rooms. Save schema v10 persists quest activation, folios, and reward state while preserving all 0–37 room IDs.

### Phase 5 release preparation (implemented, runtime verification pending)
Keyboard and gamepad controls are mapped through Godot input actions. A focusable pause menu offers checkpoint respawn, master volume, fullscreen, and reduced-flashing options. Settings persist separately from progression saves. A Windows export and playtest checklist is included; no Windows binary or successful runtime export is claimed until tested in Godot with export templates installed.

### Remaining production work
Grow each region from the current 38-room route toward the 35–45-room target with shortcuts, secrets, map discovery, additional NPCs/quests, further upgrades, localization-ready strings, and final sprite/audio work. Release QA still needs hands-on Godot/controller testing and a Windows export. Expand only after each region's traversal and combat are proven fun.
### Release / M6
Balancing, performance profiles, controller support, bug fixing, Windows export and packaging.

## Current vertical-slice playtest
1. Cross each gap using Veil Shift and activate the center checkpoint.
2. Reach the Veil Warden in the final stretch. Its red eye and arc signal the charge; attack during recovery.
3. Defeat it, collect its shard, then enter the gate.
4. Confirm the ambience, boss bar, shard gate condition, death respawn, and R replay all work in Godot 4.7.
5. Cross into all three rooms in both directions and confirm the camera bounds and room fade update cleanly.
6. Activate the checkpoint, defeat the Warden, collect the shard, close and reopen the game, and confirm that progress persists.

## M2 slice acceptance checks
- The atlas imports as crisp nearest-filtered pixel art and appears on solid ground blocks.
- Kael's idle and run cycles animate without changing his collision shape; attacks still hit enemies.
- Veil Shift still changes the background palette and spectral platform collision immediately.
- The Warden's telegraph is distinguishable from its charge and recovery; seven hits defeat it.
- The shard appears after victory, can be collected, and unlocks the gate.
- The ambient loop plays quietly without clipping or abrupt loop seams.
- Loading an invalid or unsupported JSON save falls back to the default state without crashing.

## Technical architecture
Use Godot 4.7 / Godot 4.x + GDScript. Make re-usable scenes, custom Resources for immutable balancing data, signals for runtime events, and one autoload for session/run state. Later persist only an allowlisted save DTO rather than serialized whole nodes.

Suggested production structure:
```
res://
  scenes/
    boot/main.tscn
    actors/player.tscn
    enemies/patrol_enemy.tscn
    interactables/checkpoint.tscn
    rooms/woods/woods_01.tscn
    ui/hud.tscn
  scripts/
    actors/player_controller.gd
    combat/health_component.gd
    combat/hitbox.gd
    combat/hurtbox.gd
    systems/realm_manager.gd
    systems/game_state.gd
    systems/save_manager.gd
    rooms/room_transition.gd
  resources/
    enemies/*.tres
    abilities/*.tres
  assets/
    characters/ enemies/ tilesets/ backgrounds/ ui/ audio/
  tests/
```

## Input design rules
- Player: `CharacterBody2D` and `move_and_slide` in `_physics_process`.
- Enemies: reusable character scenes with patrol, detection and readable hit reaction.
- Terrain: production `TileMapLayer` nodes (not deprecated TileMap), collision layers set explicitly.
- Spectral platforms: collision toggled by a central realm signal with a `set_deferred` safe path.
- Collision layer plan: 1 world, 2 player, 4 enemies. Player attack Area2D mask 4.
- Keep gameplay state separate from rendering; art can be replaced without changing collisions.

## Acceptance criteria for M1
1. Project opens in Godot 4.x, no critical script parse or missing-resource errors.
2. A/D moves and Space jumps, including short-hop, coyote and buffered input.
3. Basic attack can defeat each enemy; enemies can hurt Kael; he has 4 health and respawns after death.
4. Q switches immediately; spectral platforms are solid only in the Veil. Falling sends Kael back to the checkpoint.
5. Crossing the first gap leads to a checkpoint. The checkpoint survives death for this session.
6. Player can reach and collect the golden shard, then enter the exit gate.
7. Win UI appears; pressing R reloads a fresh run.
8. Run at 960x540 on Windows using the GL Compatibility renderer.

## Non-goals for M1
No final animation, permanent save, audio, touch/mobile, controller remapping, fancy inventory, bosses, or refined camera transitions. Keep these outside the first milestone so gameplay iteration is fast.
