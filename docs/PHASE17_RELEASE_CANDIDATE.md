# Phase 17 — Release Candidate Preparation

## Goal
Make the 38-room project easier to audit and export consistently, while clearly separating checks that can run here from the editor and Windows tests that still need to be performed.

## Added

- `tools/verify_project.py`: standard-library-only static integrity checker for project boot scene, autoloads, literal `res://` references, used custom input actions, WAV structure, and export preset settings.
- `export_presets.cfg`: Windows Desktop x86_64 release preset. It embeds project resources in `build/Veilfall.exe` so the game can be handed off as one executable. No signing identity or credentials are stored in the project.
- The main README now explains that F5 opens the title screen and points to the release checks.

## Local preflight

From the project directory:

```powershell
python tools\verify_project.py
godot --headless --editor --path . --quit
godot --headless --path . --export-release "Windows Desktop" build\Veilfall.exe
```

Install the matching Godot 4.7 export templates through **Editor > Manage Export Templates** before exporting. Godot requires an export preset and matching templates; the Windows preset uses x86_64 and embeds the PCK. See the [Godot 4.7 export guide](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_projects.html) and [Windows exporter options](https://docs.godotengine.org/en/4.7/classes/class_editorexportplatformwindows.html).

## Required runtime and release checks

1. Open the project in Godot 4.7; resolve every parser, import, missing-resource, and autoload error before exporting.
2. Run with a fresh save. Check title focus, Options, New Journey, first checkpoint, combat, pickups, Veil Shift, room boundary/camera changes, pause, and save creation.
3. Relaunch with the save. Continue; verify checkpoint and progression. Start New Journey, cancel once, then confirm once and verify the reset persists after relaunch.
4. Test keyboard/mouse plus an XInput-compatible controller. Check the title, Options, pause, map, dialogue/portal interactions, and action mappings.
5. Check windowed and fullscreen modes, 960×540 and one alternate resolution, audio levels, and Reduce Flashing.
6. Play through the main route and at least one optional room from every region; test all five bosses, unlocked traversal, shortcuts, the ending, and postgame route.
7. Export the Windows release. Copy only `Veilfall.exe` to a clean folder or another Windows machine and launch it outside the editor. Verify input, title, settings, save writes, room transitions, and audio.
8. Record Godot version, Windows version, tested controller, export template version, and known issues before sharing a build.

## Status

The static preflight ran successfully in this environment: **143 checks passed** across project resources, custom actions, WAV files, and export settings. The Godot executable and Windows export templates are not available here, so the editor parse, runtime playthrough, and `.exe` export are not claimed as complete. Treat this as a release candidate package pending those checks, not as a tested final release.
