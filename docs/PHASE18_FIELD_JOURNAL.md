# Phase 18 — Field Journal

The Field Journal gives players a quick in-game summary of the active objective, exploration and boss progress, unlocked traversal abilities, optional keepsakes, and controls.

## Access

- Press **N** during play to pause and open the journal.
- Open **Esc → Field Journal** to review it while paused. Closing returns to the pause menu.
- Press **N**, **Esc**, or activate **CLOSE** to leave the journal.
- The discovered-room map and journal close each other when opened.

## Verification checklist

1. Start a new journey and press N. Confirm the current route objective and initial progress counters appear.
2. Move to another room and confirm the objective follows the HUD's live quest text.
3. Collect a sigil, memory, relic, or folio; reopen the journal and confirm the matching count updates.
4. Defeat bosses and unlock traversal abilities; confirm their journal summaries update.
5. Open the pause menu, enter the journal, close it, and confirm the pause menu remains open and focused.
6. Open the map and journal in turn; confirm only one overlay is active and gameplay resumes when each is closed.
7. Save, restart, and confirm the journal reflects the loaded progress without any save migration.

## Implementation notes

The overlay reads the existing `GameState` counters and current HUD objective. It adds a `journal` input action bound to N and a pause-menu button. It does not introduce persistent fields or change the save schema. Godot runtime interaction and controller focus should be checked in-editor as part of release QA.
