# Phase 8 — Exploration, Echo Sigils, and the Waystone Shortcut

## Added
- World map opened with **M** or controller **Back**. It pauses gameplay, shows only discovered rooms, marks the current room, and tracks visited rooms across restarts.
- Save schema v5 migrates v1–v4 and persists room discoveries, Echo Sigils, Mira's side-quest reward, and shortcut unlock state.
- Four permanent Echo Sigils are available in Woods Bridge, Foundry Entry, Sunken Gallery, and Starless Gallery. Any three satisfy the quest.
- After the Veil Sovereign falls, Mira in Lantern Refuge binds three sigils and unlocks paired waystones between the Refuge and Veil Throne.
- Press **E** at either linked waystone to travel. Before unlocking, the doors explain the requirement.

## Playtest path
1. Press M/Back in the first room. Confirm that room is discovered while the remaining rooms show as unknown.
2. Visit another room, reopen the map, and verify its name and connecting path appear.
3. Find three Echo Sigils; confirm each disappears after collection and the map counter advances.
4. Defeat the Veil Sovereign, return to Mira, and claim the waystone reward.
5. Use E at the Refuge gate to reach the Citadel, then use the other gate to return.
6. Restart the game and confirm the map, collected sigils, quest reward, and two-way travel remain unlocked.

## Validation note
Static resource and package checks are available in this workspace. Godot is not installed here, so map rendering, controller Back behavior, and portal interaction still require an in-editor playtest.
