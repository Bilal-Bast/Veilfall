# Phase 7 — Veil Citadel and the Final Encounter

## Added
- Two connected Veil Citadel rooms, gated by Wall Climb from the Drowned Crypt.
- Starless Gallery: spectral platforms, a climbable spire, a checkpoint, and the Lantern Altar.
- Lantern Pulse: unlocked at the altar; press **L** or controller **RB** for a close-range three-damage burst. It has a six-second cooldown.
- Veil Throne: a dedicated checkpoint and the Veil Sovereign, the fourth and final boss.
- The Sovereign alternates an aimed rift warning/burst and a blade rush. Sword attacks damage its exposed recovery; Lantern Pulse can interrupt from nearby during other states. The attack tempo increases below half health.
- Defeating the Sovereign opens the ending panel and persists the final-boss flag. Reloading returns to the saved world checkpoint so the cleared world remains explorable.
- Save schema v4 migrates v1–v3 saves and preserves the fourth boss flag and unlocked ability.

## Playtest path
1. Start from a save with Wall Climb unlocked, or complete the Woods, Foundry, and Crypt.
2. Cross the right gate from the Bell Sanctum and activate the Starless Gallery checkpoint.
3. Climb the spire, use the Veil platforms, and touch the altar. Press L/RB near an enemy to confirm the burst and cooldown.
4. Enter the Veil Throne and activate its checkpoint.
5. Step into range. Leave the marked rift line before it fires; jump the blade rush; strike the Sovereign while its core is exposed.
6. Use Lantern Pulse as a high-impact interrupt when close, especially after the second phase begins.
7. Defeat the Sovereign, confirm the ending, close and reopen the game, then verify that the final room is clear and the saved world remains playable.

## Validation note
The project files and scene references can be statically checked in this workspace. A Godot executable is not installed here, so engine parsing, controller input, and in-game encounter balance still need a hands-on run in Godot 4.7.
