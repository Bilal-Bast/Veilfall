# Phase 12 — Regional Relics

## Player objective
Return to the four regions with later abilities. Each branch is two rooms long: an approach with a traversal/combat challenge and a relic chamber. Bring the four relics to the Refuge and enter the Reliquary Archive for a permanent heart upgrade.

| Branch | Host | Gate | Rooms | Relic |
|---|---|---|---:|---|
| Whispering Woods | Warden's Clearing | Air Dash | 26–27: Canopy Approach, Rootheart Vault | `relic_woods_01` |
| Ashen Foundry | Furnace Sentinel arena | Sentinel defeated | 28–29: Foundry Flue, Meltworks | `relic_foundry_01` |
| Drowned Crypt | Sunken Gallery | Wall Climb | 30–31: Crypt Gallery, Tide Annex | `relic_crypt_01` |
| Veil Citadel | Starless Gallery | Wall Climb, then a Pulse barrier | 32–33: Observatory Gate, Astral Causeway | `relic_citadel_01` |
| Refuge | Lantern Refuge | All four relics | 34: Reliquary Archive | `reliquary_heart_01`, +1 maximum health |

## Implementation notes
- Existing room IDs 0–25 remain unchanged. Nine rooms use IDs 26–34.
- The four branch approaches reuse existing enemy families and introduce no new boss or movement ability.
- The map draws explicit portal links and reports discoveries, Echo Sigils, Beacon Memories, and Regional Relics.
- Save schema v9 reads schemas v1–v8, accepts room IDs 0–34, and persists all four relic IDs and the Reliquary Heart. Older finale migrations remain unchanged.
- Maximum health is reconstructed from the saved heart item when the player is created.

## Playtest checklist
1. Open the project in Godot 4.7 and press F5. Check for script parse errors before playing.
2. Confirm the world map reports 35 rooms and old rooms 0–25 retain their previous names and links.
3. With Air Dash, enter Canopy Approach from the Warden's Clearing, beat the patrol, reach Rootheart Vault, and collect the Verdant Relic.
4. Defeat the Sentinel, enter Foundry Flue, pass through Meltworks, and collect the Ember Relic.
5. Unlock Wall Climb, revisit the Crypt, pass the crawler route, and collect the Drowned Relic in Tide Annex.
6. Enter the Observatory with Wall Climb, use Lantern Pulse to clear the barrier, then collect the Starless Relic in Astral Causeway.
7. At 4/4 relics, enter the Reliquary Archive from the Refuge and claim the heart.
8. Save/reload in a new room and verify checkpoint, visited rooms, relics, and maximum health persist.
9. Load a copy of a schema v8 save and verify old progress remains, with zero Phase 12 relics by default.

## Scope
Nine optional rooms bringing the project to the 35-room lower end of its original 35–45-room target. Two rooms per region, four collectibles, and one health reward; no new boss, traversal ability, or external dependency.
