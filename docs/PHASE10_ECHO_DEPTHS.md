# Phase 10 — Echo Depths

## Added
- Added five optional postgame rooms after the Veil Throne: Echo Threshold, Mirror Causeway, Silent Archive, Shard Garden, and Echo Warden Arena.
- Echo portals in Lantern Refuge and the Citadel open only after the Veil Sovereign is defeated and all four Echo Sigils are collected. A return portal at the threshold and arena leads back to the Refuge.
- Added the Echo Warden, an optional boss that alternates a marked strike and a fast rush, with clear wind-ups and punish windows.
- Defeating the Warden permanently improves Lantern Pulse: wider range, more damage, and a shorter cooldown.
- Extended the discovered-room map and camera to 21 rooms without changing the existing 0–15 room IDs.
- Save schema v7 persists the optional boss victory and accepts schema v1–v6 saves. The earlier Phase 9 throne migration remains intact.

## Playtest path
1. Load a Phase 9 save and confirm the checkpoint, map discoveries, bosses, abilities, and collected items remain intact.
2. Confirm the Echo portals are sealed before the Sovereign is defeated or before all four Echo Sigils are collected.
3. Defeat the Sovereign, press R to reload into the saved world, and collect all four sigils if needed.
4. Enter from either the Refuge or Citadel portal. Confirm the threshold checkpoint updates and is used on respawn.
5. Cross the Mirror Causeway and Silent Archive, then climb through the Shard Garden to the arena.
6. Read and evade the Warden's marked strike and rushing attack; attack during its exposed recovery.
7. Defeat the Warden, return to the Refuge, and confirm Lantern Pulse has improved range, damage, and cooldown.
8. Restart and confirm the boss flag, checkpoint, and Pulse mastery persist. Open the map and verify room discoveries out of 21.

## Validation note
Static checks can verify the 21 room IDs, portal destinations, resource references, map bounds, and v1–v6 save compatibility. Godot is not installed in this workspace, so scene parsing, controller input, and runtime combat still need a playtest in Godot.
