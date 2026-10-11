# Phase 20 — Keyboard Controls

Players can rebind the game's keyboard actions from **Title Screen → Options → Keyboard Controls** or **Pause → Keyboard Controls**. Changes save automatically to the separate local settings file. Mouse and controller bindings remain unchanged, and keyboard changes do not modify progression saves.

## Rebinding behavior

- Select an action's button and press the desired key.
- A key already assigned to another game action is rejected with the conflicting action named.
- Press Escape while listening to cancel the pending rebind; press Escape outside capture to close the screen.
- **Reset Defaults** restores the original keyboard layout and keeps controller/mouse mappings.
- On-screen gameplay hints and the Field Journal reflect the current key bindings.

## Verification checklist

1. Open the remapping screen from the title options and from the in-game pause menu.
2. Rebind Jump to an unused key and confirm it works immediately and appears in the HUD/Journal hints.
3. Attempt to bind Attack to the same key and confirm the conflict is rejected.
4. Close and relaunch the game; confirm the new key remains assigned.
5. Verify movement's arrow-key alternatives still work and mouse attack still works.
6. Verify controller movement and buttons work before and after remapping.
7. Reset defaults, relaunch, and confirm the original keyboard layout is restored.
8. Confirm a saved progression file is unaffected.

## Implementation notes

`SettingsManager` validates and applies the keyboard bindings through `InputMap` and stores them in the existing settings config. The reusable remapping overlay serves both entry points. Existing save data and its schema are untouched. Godot runtime input and controller testing remains necessary.
