# Phase 15 — Visual Feedback Polish

## Goal
Make core actions feel easier to read and more responsive without replacing the current art, adding plugins, or introducing heavy particle emitters.

## What changed

- Added `GameFeedback`, a small autoload that owns short-lived world-space particles, camera shake, and the realm-change screen tint.
- Realm shifts now create a soft, brief tint and lantern-colored burst around Kael.
- Sword swings add a small motion accent; the first confirmed hit per swing adds impact sparks and a subtle camera nudge.
- Damage adds a red particle burst and stronger short shake. Lantern Pulse and one-time pickups now have distinct light bursts.
- All bursts have a hard total particle cap. Effects are code-drawn and expire quickly; no textures, plugins, or per-effect scene instances are needed.
- With **Reduce Flashing** enabled, screen tints are slower and dimmer, shake is reduced, and particle count, brightness, and speed are lowered.

## Verification checklist

1. Switch realms in an open area; check that the tint fades smoothly and the particle ring stays around Kael as the camera follows.
2. Swing in empty space, hit one enemy, then hit multiple enemies in one swing. The first hit gets the impact accent; visual feedback should not compound for each overlapping target.
3. Take damage and confirm the player remains readable during the shorter camera shake.
4. Cast Lantern Pulse and collect a shard, sigil, memory, relic, folio, and cache; verify the bursts remain short and do not leave stale particles.
5. Turn on **Reduce Flashing** in pause settings and repeat realm shift, combat, and pickup checks.
6. Pause during active feedback and resume; confirm camera offset always returns to its original value.
7. Explore a room with many enemies and effects; confirm the particle cap prevents runaway effect creation.

## Runtime status

Resource/reference checks are available in the build environment. Godot is not installed here, so camera behavior, drawing order, pause interaction, and perceived intensity still need the checklist run in Godot 4.7.
