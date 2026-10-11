# Phase 19 — Field Map Markers

The map now identifies points of interest in rooms the player has discovered. Distinct region-color borders help distinguish connected areas, while boss rooms update to show whether their encounter remains active or has been cleared.

## Marker legend

| Marker | Meaning |
| --- | --- |
| `B!` | Boss encounter not yet cleared |
| `B+` | Boss encounter cleared |
| `H` | Lantern Refuge hub |
| `E` | Echo Depths route |
| `M` | Beacon Memory chamber |
| `C` | Regional challenge room |
| `F` | Scribe folio chamber |
| `R` | Reward room |

## Verification checklist

1. Open the map with M and confirm undiscovered rooms remain `???` without point-of-interest markers.
2. Discover the Refuge, an optional route, and a boss room. Confirm the correct markers appear.
3. Clear each boss and reopen the map. Confirm its marker changes from `B!` to `B+`.
4. Visit rooms from different regions and confirm their border accents use distinct colors.
5. Check the route links, room counters, collection totals, and M/Back close hint remain readable.
6. Load an existing save and confirm markers derive from existing room and boss progress; no save migration is needed.

The map reads `GameState` directly. No new persistent fields or save-version changes were introduced. Runtime rendering should be verified at the target window size and with an existing save in Godot.
