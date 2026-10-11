# Phase 6 — Drowned Crypt Content Slice

## Added
- Two connected Drowned Crypt rooms after the Ashen Foundry's Air Dash gate.
- The Sunken Gallery: a dry route, Crypt Leech patrol, checkpoint, climbable wall, and permanent maximum-health heart upgrade on a high ledge.
- The Bell Sanctum: a separate checkpoint and the Drowned Abbot boss.
- Wall Climb unlocks when the Abbot falls. Face a wall and hold movement into it; hold Jump to climb, or release Jump to cling and slow the descent.
- Save schema v3 migrates existing v1/v2 saves and persists the Abbot defeat, Wall Climb, and Crypt heart.

## Playtest path
1. Load a Phase 5 save with the Furnace Sentinel defeated, or start a new run and complete the Woods and Foundry first.
2. Cross the Foundry's right-side gate after Air Dash unlocks; enter the Sunken Gallery.
3. Activate its checkpoint, pass the Leech, and reach the Bell Sanctum.
4. Watch for the Abbot's glowing bell rings. Evade its rush and attack during recovery.
5. Return to the Gallery after victory. Climb the tall wall to the high ledge and collect the permanent heart upgrade.
6. Restart the game to confirm the Crypt boss, ability, cache, and checkpoint persist.

## Current scope boundary
This adds one region slice, not the whole game. The Veil Citadel and fourth boss remain. Godot runtime and controller tests are still required before this can be called release-ready.
