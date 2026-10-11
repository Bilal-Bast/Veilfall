# Phase 5 — Release Preparation Checklist

> This is the original Phase 5 checklist. For the current 38-room build, use [Phase 17 Release Candidate Preparation](PHASE17_RELEASE_CANDIDATE.md) for updated automated checks, Windows export settings, and outstanding release gates.

This checklist separates implemented code from verification that requires Godot and physical devices.

## Implemented in project
- [x] Keyboard, mouse, analog stick, D-pad, and common gamepad face-button mappings use the same InputMap actions.
- [x] Escape / controller Start pauses gameplay; the pause overlay keeps processing while the world is paused.
- [x] Pause menu supports Resume and checkpoint respawn with keyboard/controller focus navigation.
- [x] Master volume, fullscreen, and reduced-flashing settings save to `user://veilfall_settings.cfg` independently from game progress.
- [x] Reduced-flashing option suppresses the player's hurt blink and flash tint.
- [x] Player, menus, rooms, and saved settings use built-in Godot features; no third-party runtime plug-ins are required.

## Godot editor verification
- [ ] Open `project.godot` in Godot 4.7 and confirm there are no parse, missing-resource, or autoload errors.
- [ ] Test keyboard and mouse controls across all eight current rooms.
- [ ] Connect an XInput-compatible controller; verify stick, D-pad, A/B/X/Y, LB, and Start mappings.
- [ ] Confirm Start/Escape pauses world physics and audio-facing settings remain responsive; Resume continues in place.
- [ ] Confirm checkpoint respawn from the pause menu resumes with full health.
- [ ] Change volume, fullscreen, and reduced-flashing preferences; close and reopen to confirm they persist.
- [ ] Confirm the existing version 1 progression save migrates, and version 2 and 3 progression remains intact.
- [ ] Test the game window at 960×540 and one alternate desktop resolution; confirm HUD and pause controls remain reachable.

## Windows desktop export
1. In Godot, install matching 4.7 export templates from **Editor > Manage Export Templates**.
2. Open **Project > Export**, add **Windows Desktop**, and choose a release build destination such as `builds/Veilfall.exe`.
3. Export a release build, then launch it outside the editor.
4. Verify movement, controller input, pause/settings, save/load, room boundaries, and audio in the exported build.
5. Keep the PCK beside the executable if exporting it separately; otherwise embed it using the preset option.
6. Record the tested Godot version, Windows version, controller model, and any known issues before distributing the build.

The project has not been runtime-tested or exported in this environment because no Godot executable or export templates are available here.
