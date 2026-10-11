# Phase 14 — Audio and Feedback Pass

## Goal
Give important actions a clear, original sound while keeping the current room layouts and control scheme intact. Effects are short synthesized PCM WAVs authored for this project; no external audio packs or runtime plugins are required.

## What changed

- Added the `Sfx` autoload as a small polyphonic one-shot player with an eight-voice cap. Streams are preloaded, freed when finished, and play on the Master bus so the existing saved master-volume setting applies.
- Added original cues for sword swing, sword hit, realm shift, pickup, checkpoint, portal travel, player damage, and Lantern Pulse.
- Connected cues to realm changes, confirmed sword hits (once per swing), player damage, Pulse casts, permanent and healing pickups, checkpoint activation, boss rewards, and successful portal travel.
- Kept the existing Whispering Woods ambience loop in `main.gd` unchanged.

## Audio cue sheet

| Cue | Sound character | Trigger |
| --- | --- | --- |
| `sword_swing` | Brief airy sweep | Attack begins |
| `hit` | Low, soft impact | First enemy hit in a sword swing |
| `realm_shift` | Rising two-tone shimmer | Living World / Veil switch |
| `pickup` | Three-note glass chime | Shards, sigils, memories, relics, folios, and caches |
| `checkpoint` | Warm ascending chord | Checkpoint, boss clear, or major reward |
| `portal` | Hollow spectral sweep | Memory door or fast-travel teleport |
| `hurt` | Short descending pulse | Player takes damage |
| `lantern_pulse` | Expanding tonal shimmer | Lantern Pulse cast |

## Verification checklist

1. Start at low and high Master volume; check ambience and effects respond together.
2. Attack without hitting an enemy, then hit one and several enemies; the swing should play every time and impact should play once per swing.
3. Switch realities repeatedly and cast Lantern Pulse; effects must not be cut off by overlapping playback.
4. Take a hit, activate a new checkpoint, and collect one item of each persistent pickup family.
5. Use an unlocked memory door and Refuge/Citadel shortcut; sealed portals should remain silent.
6. Defeat a boss and claim a quest reward; confirm the reward chord is audible and progression still saves.
7. Quit and relaunch; confirm SFX behavior still works with saved settings.

## Runtime status

Static checks can confirm WAV validity and resource references. Run the checklist in Godot 4.7 to evaluate actual mix, perceived loudness, and gameplay timing. Godot is not installed in the current build environment, so interactive playback verification was not possible here.
