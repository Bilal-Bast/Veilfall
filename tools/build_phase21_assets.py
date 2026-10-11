from pathlib import Path
import math, wave
import numpy as np
from PIL import Image
from scipy import ndimage

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets"
BG = OUT / "backgrounds" / "regions"
MUSIC = OUT / "audio" / "music"
AMBIENCE = OUT / "audio" / "ambience"
for folder in (BG, MUSIC, AMBIENCE, OUT / "characters"):
    folder.mkdir(parents=True, exist_ok=True)

source_backgrounds = {
    "whispering_woods": "exec-13cd98e0-d536-4b6e-afe1-b7e1ca529d6e.png",
    "ashen_foundry": "exec-b643dec1-a911-43ef-b44c-dc0c6345be14.png",
    "drowned_crypt": "exec-d2935e00-3e5d-427f-ab7b-6734b69518e5.png",
    "veil_citadel": "exec-72069a9c-500e-483c-ad4a-a64edb28dd24.png",
    "echo_depths": "exec-458103f7-1330-48ae-b3fa-eb0c87087343.png",
    "lantern_refuge": "exec-168ee862-2ea2-46a0-855e-43f81f21d176.png",
}
generated = ROOT.parent / "generated_images"
for name, filename in source_backgrounds.items():
    src = generated / filename
    im = Image.open(src).convert("RGB")
    # Fit the game viewport's 16:9 canvas, then size for one camera frame.
    w, h = im.size
    target_ratio = 16 / 9
    if w / h > target_ratio:
        nw = round(h * target_ratio)
        left = (w - nw) // 2
        im = im.crop((left, 0, left + nw, h))
    else:
        nh = round(w / target_ratio)
        top = (h - nh) // 2
        im = im.crop((0, top, w, top + nh))
    im = im.resize((960, 540), Image.Resampling.LANCZOS)
    im.save(BG / f"{name}.jpg", quality=88, optimize=True, progressive=True)

# The image generator uses a checker pattern to preview transparency. Remove
# only the connected neutral checker region, preserving the character pixels.
hero_src = generated / "exec-4f600c8d-035b-4149-8ea5-d1ddbda58760.png"
im = Image.open(hero_src).convert("RGB")
rgb = np.asarray(im, dtype=np.int16)
neutral = (rgb.max(axis=2) - rgb.min(axis=2) < 24) & (rgb.mean(axis=2) > 142)
seeds = np.zeros(neutral.shape, dtype=bool)
seeds[0, :] = neutral[0, :]; seeds[-1, :] = neutral[-1, :]
seeds[:, 0] = neutral[:, 0]; seeds[:, -1] = neutral[:, -1]
background = ndimage.binary_propagation(seeds, structure=np.ones((3, 3), dtype=bool), mask=neutral)
alpha = np.where(background, 0, 255).astype(np.uint8)
# Soft alpha only on boundary pixels to avoid a hard matte at antialiased edges.
edge = ndimage.binary_dilation(background) & ~background
alpha[edge] = 176
rgba = np.dstack((np.asarray(im), alpha))
hero = Image.fromarray(rgba, "RGBA")
bbox = hero.getbbox()
hero = hero.crop(bbox)
hero.thumbnail((320, 384), Image.Resampling.NEAREST)
hero.save(OUT / "characters" / "kael_idle.png", optimize=True)

# Original synthesized, seamlessly looping regional music and ambience.
SR = 22050
def write_wav(path, values):
    values = np.clip(values, -0.96, 0.96)
    pcm = (values * 32767).astype("<i2")
    with wave.open(str(path), "wb") as wav:
        wav.setnchannels(1); wav.setsampwidth(2); wav.setframerate(SR)
        wav.writeframes(pcm.tobytes())

def tone(freq, t, phase=0.0):
    return np.sin(2 * np.pi * freq * t + phase)

tracks = {
    "whispering_woods": (78, [146.83, 174.61, 220.00, 196.00], [293.66, 349.23, 440.00, 392.00], "bells"),
    "lantern_refuge": (68, [130.81, 164.81, 196.00, 174.61], [261.63, 329.63, 392.00, 349.23], "warm"),
    "ashen_foundry": (96, [110.00, 130.81, 146.83, 123.47], [220.00, 261.63, 293.66, 246.94], "metal"),
    "drowned_crypt": (66, [98.00, 130.81, 123.47, 110.00], [196.00, 261.63, 246.94, 220.00], "water"),
    "veil_citadel": (74, [116.54, 146.83, 174.61, 155.56], [233.08, 293.66, 349.23, 311.13], "choir"),
    "echo_depths": (82, [103.83, 123.47, 155.56, 138.59], [207.65, 246.94, 311.13, 277.18], "glass"),
}
for name, (bpm, roots, highs, flavor) in tracks.items():
    beat = 60.0 / bpm
    duration = beat * 16
    n = round(duration * SR)
    t = np.arange(n, dtype=np.float64) / SR
    beat_pos = t / beat
    bar = np.floor(beat_pos / 4).astype(int) % 4
    local_beat = beat_pos % 4
    root = np.take(np.asarray(roots), bar)
    high = np.take(np.asarray(highs), bar)
    pad = (0.14 * tone(root, t) + 0.065 * tone(root * 1.5, t, 0.3) + 0.045 * tone(root * 2, t, 0.8))
    # A soft plucked note every other beat, enveloped so each note decays cleanly.
    step = np.floor(beat_pos * 2).astype(int)
    note_phase = (beat_pos * 2) % 1
    # A four-note regional motif moves through the bar's chord tones.
    motif = np.take(np.asarray([1.0, 1.25, 1.5, 1.25]), step % 4)
    f = high * motif
    pluck = np.sin(2 * np.pi * f * t) * np.exp(-note_phase * 5.5) * (note_phase < 0.72)
    if flavor == "metal":
        percussion = (np.sin(2*np.pi*58*t) + 0.35*np.sin(2*np.pi*117*t)) * ((local_beat < 0.11) * 0.15)
        line = pad * 0.7 + pluck * 0.12 + percussion
    elif flavor == "choir":
        line = pad * 0.7 + 0.08 * tone(root * 2**(7/12), t) + pluck * 0.10
    elif flavor == "water":
        line = pad * 0.85 + 0.07 * tone(root * 0.5, t) + pluck * 0.08
    elif flavor == "glass":
        line = pad * 0.68 + pluck * 0.14 + 0.035 * tone(high * 2, t, 0.5)
    else:
        line = pad * 0.72 + pluck * 0.13
    fade = np.minimum(1.0, np.minimum(t / 0.12, (duration - t) / 0.12))
    write_wav(MUSIC / f"{name}.wav", line * fade)

ambience_profiles = {
    "whispering_woods": (90, 0.2, [0.12, 0.18, 0.24]),
    "lantern_refuge": (140, 0.1, [0.10, 0.16, 0.23]),
    "ashen_foundry": (58, 0.32, [0.08, 0.16, 0.21]),
    "drowned_crypt": (48, 0.24, [0.07, 0.13, 0.19]),
    "veil_citadel": (72, 0.2, [0.09, 0.17, 0.25]),
    "echo_depths": (64, 0.18, [0.06, 0.12, 0.18]),
}
for name, (base, noise_gain, partials) in ambience_profiles.items():
    duration = 12.0
    n = round(duration * SR)
    t = np.arange(n, dtype=np.float64) / SR
    rng = np.random.default_rng(sum(name.encode("utf-8")))
    noise = rng.normal(0, 1, n)
    # Circular low-pass noise gives each ambience a soft, wind-like texture.
    frequencies = np.fft.rfftfreq(n, 1 / SR)
    spectrum = np.fft.rfft(noise)
    spectrum *= 1.0 / np.sqrt(1.0 + (frequencies / 800.0) ** 2)
    filtered = np.fft.irfft(spectrum, n)
    filtered /= max(1e-6, np.std(filtered))
    bed = noise_gain * filtered
    for i, gain in enumerate(partials):
        freq = base * (1 + i * 0.71)
        bed += gain * tone(freq, t, phase=i * 1.7)
    if name == "ashen_foundry":
        pulse = np.maximum(0.0, np.sin(2*np.pi*0.22*t)) ** 8
        bed += pulse * (0.09 * tone(110, t) + 0.035 * tone(224, t))
    elif name == "drowned_crypt":
        bed += 0.04 * tone(0.11, t) * tone(310, t)
    elif name == "whispering_woods":
        bed += 0.025 * tone(0.17, t) * tone(1550, t)
    elif name == "lantern_refuge":
        bed += 0.035 * tone(0.09, t) * tone(523.25, t)
    fade = np.minimum(1.0, np.minimum(t / 0.15, (duration - t) / 0.15))
    write_wav(AMBIENCE / f"{name}.wav", bed * fade * 0.55)

print("Built six region backdrops, Kael idle sprite, and 12 original audio loops.")
