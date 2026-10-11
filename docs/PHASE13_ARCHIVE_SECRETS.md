# Phase 13 — Archive Secrets

## Player objective
Speak to the Scribe in Lantern Refuge to start the optional folio quest. Find three hidden archive chambers, collect each folio, then return to the Scribe for a permanent Lantern Pulse range upgrade.

| Secret | Host room | Door condition | Folio |
|---|---|---|---|
| Veil Almanac | Broken Bridge | Quest started and Veil active | `lore_woods_01` |
| Drowned Register | Sunken Gallery | Quest started and Wall Climb unlocked | `lore_crypt_01` |
| Starless Testament | Lens Archive | Quest started and Lantern Pulse unlocked | `lore_citadel_01` |
| Scribe's reward | Lantern Refuge | All three folios | `lore_reward_01`; +25 Pulse range |

## Implementation notes
- Existing room IDs 0–34 remain unchanged; secret rooms use IDs 35–37.
- The Scribe quest activation persists as `archive_quest_started`. Folios and the reward persist in the existing collected item list.
- Lantern Pulse range gains 25 units after the reward, stacking with Echo Warden mastery.
- The fog-of-war map now contains 38 entries and three explicit secret links.
- Save schema v10 accepts schemas v1–v9, validates checkpoints through the new room range, and persists the quest flag and new item IDs.

## Playtest checklist
1. Open in Godot 4.7 and press F5. Check for script parse errors.
2. In the Refuge, find the Scribe and accept the quest. Confirm progress reads 0/3.
3. At the Broken Bridge, try the sealed arch before accepting the quest. It should stay shut. Accept the quest, switch to Veil, enter the chamber, collect the Veil Almanac, and return.
4. In Sunken Gallery, use Wall Climb to open the Crypt secret. Collect the Drowned Register and return.
5. In Lens Archive, use Lantern Pulse to open the Citadel secret. Collect the Starless Testament and return.
6. Confirm the map reveals all three rooms and shows 3/3 folios.
7. Speak to the Scribe and claim the reward. Compare Pulse reach before and after; verify it gains 25 units.
8. Save and reload. Confirm quest activation, folios, reward, discovered rooms, and Pulse range persist.
9. Load a copy of a schema v9 save and confirm it remains valid with the Scribe quest inactive by default.

## Scope
Three hidden rooms, three lore pickups, one quest giver, and one small permanent combat upgrade. The route now contains 38 rooms, within the original 35–45-room target. No new boss or traversal ability is added.
