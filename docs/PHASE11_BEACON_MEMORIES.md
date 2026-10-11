# Phase 11 — Beacon Memories

## Player objective
Return to four earlier regions after their progression gates open. Each memory chamber contains one fragment and a return arch. Bring all four fragments to the Refuge, enter the Beacon Crucible, and claim the Beacon Crown for one permanent heart.

| Chamber | Host room | Unlock | Reward |
|---|---|---|---|
| Verdant Memory | Warden's Clearing | Defeat the Veil Warden | `memory_woods_01` |
| Ember Memory | Furnace Sentinel | Defeat the Furnace Sentinel | `memory_foundry_01` |
| Drowned Memory | Bell Sanctum | Defeat the Drowned Abbot | `memory_crypt_01` |
| Starless Memory | Starless Gallery | Unlock Lantern Pulse | `memory_citadel_01` |
| Beacon Crucible | Lantern Refuge | Find all four memories | `beacon_crown_01` and +1 maximum health |

## Implementation notes
- Existing story rooms retain IDs 0–20. Five side-room instances use IDs 21–25.
- Portals are interaction-based (`E`) and checkpoint the destination. Memory gates re-evaluate progression flags at runtime.
- The map draws the existing route and five explicit portal links; undiscovered rooms remain fogged.
- Save schema v8 expands checkpoint bounds, accepted schema versions, room IDs, and the item allowlist. Schemas 1–7 remain readable; the v1–v5 finale room migration remains unchanged.
- Memory collectibles and the Crown persist in the existing item list. The Crown's health increase is reconstructed from saved collection state on player creation.

## Playtest checklist
1. Open the latest project in Godot 4.7 and press F5.
2. In the Warden's Clearing, interact with the sealed west-side arch before the Warden is defeated; verify it remains sealed.
3. Defeat the Warden and enter Verdant Memory. Collect the fragment, take the return arch, and confirm the Refuge/Mira counter reports 1/4.
4. Repeat in the Foundry, Crypt, and Citadel. Verify the corresponding bosses or Lantern Pulse gate controls each portal.
5. Open the map and verify the discovered room count, named memory rooms, and portal connections update.
6. At 4/4, enter the Beacon Crucible from the Refuge. Claim the Crown and confirm one additional heart.
7. Save and reload in each new area. Verify checkpoint, visited rooms, memory fragments, and Crown health persist.
8. Test a copy of a schema v7 save: it should load with the old state intact and no new memories collected.

## Scope
Five compact replay chambers and one permanent health reward; no new boss, ability, enemy family, or external dependency. This grows the project from 21 story rooms to 26 total rooms while keeping the full target at 35–45 handcrafted rooms.
