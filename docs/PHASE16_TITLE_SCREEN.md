# Phase 16 — Title Screen and Save Entry

## Goal
Give the game a clear, controller-friendly start screen and let players choose whether to continue their current journey or intentionally begin again.

## What changed

- Added a code-drawn title scene as the project boot scene, with Continue, New Journey, Options, and Quit.
- Continue is disabled when there is no save. Selecting it opens the existing gameplay scene, whose current load path restores the save as before.
- New Journey starts directly when no save exists. If a save exists, a confirmation explains that the current journey will be replaced.
- Added a save-file presence check and a guarded clear operation. Temporary and backup files are cleared before the main save, so a filesystem error during cleanup leaves the main save intact.
- Added title-screen options for master volume, fullscreen, and Reduce Flashing. They use the same persistent settings as the in-game pause menu.
- Buttons and settings controls support keyboard/controller focus. Escape returns from Options to the title menu.

## Verification checklist

1. Launch with no save: Continue is disabled; New Journey starts the Woods and creates progress normally.
2. Quit and relaunch: Continue is enabled and loads the saved checkpoint and progression.
3. Select New Journey with a save present, then cancel; verify Continue still restores the previous progress.
4. Select New Journey again and confirm; verify gameplay starts from the Woods and old progress does not return after relaunch.
5. Trigger a filesystem permission failure while clearing a temporary or backup file; check that the main save has not yet been removed.
6. Change each setting on the title screen, start the game, open pause settings, and confirm the values match and persist after relaunch.
7. Navigate the title and Options using keyboard and a controller. Confirm focus remains visible and Escape returns from Options.

## Runtime status

The title, save flow, and setting references pass static checks. Godot is not installed in this environment, so input focus, responsive layout, save replacement, and actual scene changes still need runtime verification in Godot 4.7.
