#!/usr/bin/env python3
"""Static integrity checks for the Veilfall Godot project. Uses Python stdlib only."""
from __future__ import annotations

import re
import sys
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []
checks = 0


def require(condition: bool, message: str) -> None:
    global checks
    checks += 1
    if not condition:
        errors.append(message)


def project_files() -> list[Path]:
    return [*ROOT.rglob("*.gd"), *ROOT.rglob("*.tscn"), ROOT / "project.godot", ROOT / "export_presets.cfg"]


project_path = ROOT / "project.godot"
require(project_path.is_file(), "project.godot is missing")
if project_path.is_file():
    project = project_path.read_text(encoding="utf-8")
    main_match = re.search(r'^run/main_scene="([^"]+)"', project, re.MULTILINE)
    require(main_match is not None, "project.godot has no run/main_scene")
    if main_match:
        require((ROOT / main_match.group(1).removeprefix("res://")).is_file(), f"missing main scene: {main_match.group(1)}")
    autoload_section = project.split("[autoload]", 1)[1].split("\n[", 1)[0] if "[autoload]" in project else ""
    for name, path in re.findall(r'^([A-Za-z][A-Za-z0-9_]*)="\*?(res://[^"]+)"$', autoload_section, re.MULTILINE):
        require((ROOT / path.removeprefix("res://")).is_file(), f"missing autoload {name}: {path}")

    input_section = project.split("[input]", 1)[1] if "[input]" in project else ""
    input_section = input_section.split("\n[", 1)[0]
    declared_actions = set(re.findall(r'^([a-z][a-z0-9_]*)=\{', input_section, re.MULTILINE))
    builtin_actions = {"ui_accept", "ui_cancel", "ui_left", "ui_right", "ui_up", "ui_down", "ui_focus_next", "ui_focus_prev", "ui_page_up", "ui_page_down", "ui_home", "ui_end", "ui_select", "ui_menu"}
    used_actions: set[str] = set()
    for path in ROOT.rglob("*.gd"):
        text = path.read_text(encoding="utf-8")
        used_actions.update(re.findall(r'\.is_action_(?:just_pressed|just_released|pressed)\("([^"]+)"\)', text))
    missing_actions = sorted(used_actions - declared_actions - builtin_actions)
    require(not missing_actions, "undeclared input actions: " + ", ".join(missing_actions))

# Check literal resource paths in scripts, scenes, and project configuration.
for path in project_files():
    if not path.is_file():
        continue
    text = path.read_text(encoding="utf-8")
    for resource in set(re.findall(r'res://([^"\s)]+)', text)):
        # Ignore wildcard patterns and text fragments, neither is a loadable path.
        if "*" in resource:
            continue
        candidate = ROOT / resource
        require(candidate.is_file(), f"{path.relative_to(ROOT)} references missing res://{resource}")

# Validate local one-shot audio files as PCM WAVs.
for audio in sorted((ROOT / "assets/audio").rglob("*.wav")):
    try:
        with wave.open(str(audio), "rb") as stream:
            require(stream.getnchannels() in (1, 2), f"unsupported WAV channel count: {audio.relative_to(ROOT)}")
            require(stream.getsampwidth() in (1, 2, 3, 4), f"unsupported WAV sample width: {audio.relative_to(ROOT)}")
            require(stream.getframerate() > 0 and stream.getnframes() > 0, f"empty or invalid WAV: {audio.relative_to(ROOT)}")
    except (wave.Error, OSError) as exc:
        errors.append(f"invalid WAV {audio.relative_to(ROOT)}: {exc}")

# Phase 21 art, audio, and saved-upgrade assets.
for asset in [
    ROOT / "assets/characters/kael_idle.png",
    *[ROOT / "assets/backgrounds/regions" / f"{name}.jpg" for name in ["whispering_woods", "lantern_refuge", "ashen_foundry", "drowned_crypt", "veil_citadel", "echo_depths"]],
    *[ROOT / "assets/audio/music" / f"{name}.wav" for name in ["whispering_woods", "lantern_refuge", "ashen_foundry", "drowned_crypt", "veil_citadel", "echo_depths"]],
    *[ROOT / "assets/audio/ambience" / f"{name}.wav" for name in ["whispering_woods", "lantern_refuge", "ashen_foundry", "drowned_crypt", "veil_citadel", "echo_depths"]],
]:
    require(asset.is_file(), f"Phase 21 asset missing: {asset.relative_to(ROOT)}")
for script_name in ["game_state.gd", "save_manager.gd"]:
    require("resonant_wick_01" in (ROOT / "scripts" / script_name).read_text(encoding="utf-8"), f"Resonant Wick is not allowlisted in {script_name}")
region_audio = (ROOT / "scripts/region_audio.gd").read_text(encoding="utf-8")
require('func start_game_audio()' in region_audio and 'func stop_game_audio()' in region_audio, "regional audio must be scoped to active gameplay")

# Confirm the portable Windows export preset and output path.
preset_path = ROOT / "export_presets.cfg"
require(preset_path.is_file(), "export_presets.cfg is missing")
if preset_path.is_file():
    preset = preset_path.read_text(encoding="utf-8")
    for expected in ['name="Windows Desktop"', 'platform="Windows Desktop"', 'export_path="build/Veilfall.exe"', 'binary_format/architecture="x86_64"', 'binary_format/embed_pck=true']:
        require(expected in preset, f"Windows export preset missing {expected}")

if errors:
    print(f"FAIL: {len(errors)} issue(s) across {checks} checks")
    for issue in errors:
        print(f" - {issue}")
    sys.exit(1)

print(f"PASS: {checks} static project-integrity checks")
print(f"  scenes: {len(list((ROOT / 'scenes').rglob('*.tscn')))}")
print(f"  scripts: {len(list((ROOT / 'scripts').glob('*.gd')))}")
print(f"  audio: {len(list((ROOT / 'assets/audio').rglob('*.wav')))} WAV files")
print("  export: Windows Desktop x86_64, embedded PCK")
