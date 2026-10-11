# Phase 9 — The Citadel's Chime Route

## Added
- Expanded the route from ten rooms to sixteen by adding Citadel Approach, Chime Gallery, Lens Archive, Shattered Nave, Beacon Engine, and Sovereign Approach before the existing Veil Throne.
- Added Rift Moths, which pause and glow before diving, and Veil Archers, which charge slow projectiles before firing.
- Added two Pulse barriers. Lantern Pulse within range folds each barrier away for the current game session.
- Added an optional maximum-health cache in Beacon Engine.
- Expanded the field map to sixteen discovered-room cards and extended the room camera and Citadel backdrop.
- Save schema v6 migrates older Citadel checkpoints from room 9 to room 15 and moves the old discovered-room entry accordingly. Earlier room numbers stay unchanged.

## Playtest path
1. Load a Phase 8 save with a Citadel checkpoint and confirm Kael appears in Veil Throne, not the new Approach room.
2. Confirm the old discovered map marks Veil Throne as visited and preserves all earlier discoveries.
3. Travel left from the Citadel Gallery into Citadel Approach, then continue right through the six new rooms.
4. Observe the Rift Moth's glow before its dive and the Veil Archer's charge before its bolt; evade each tell and attack during recovery.
5. Use Lantern Pulse near the barriers in Lens Archive and Shattered Nave, then cross through the opening.
6. Climb the Beacon Engine platforms and collect its optional heart. Confirm maximum health increases once and remains increased after restarting.
7. Reach Sovereign Approach and continue into the relocated throne. Confirm the existing boss and both waystones still work.

## Validation note
Static source and packaging checks can validate room IDs, resource paths, save migration bounds, and referenced assets. Godot is not installed in this workspace, so scene parsing, collision behavior, room traversal, and playtesting need the user's Godot editor.
