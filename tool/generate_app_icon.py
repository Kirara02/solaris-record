#!/usr/bin/env python3
"""Generates the Solaris Record app icon artwork (needs Pillow).

    python3 tool/generate_app_icon.py

Writes the master images under assets/icon/ (consumed by flutter_launcher_icons,
see pubspec.yaml) and assets/images/app_icon.png (shown inside the app).

The mark is an "SR" monogram set in Inter Bold (the app's typeface) on an
indigo gradient, with a small gold four-pointed "convene" star as the accent.
"""
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

SIZE = 1024
SS = 2  # supersampling factor for smooth edges
ROOT = Path(__file__).resolve().parent.parent
FONT = ROOT / "assets" / "fonts" / "Inter-Bold.ttf"

INDIGO_DARK = (16, 20, 58)
INDIGO_MID = (38, 48, 128)
INDIGO_LIGHT = (84, 104, 235)
GOLD_LIGHT = (255, 232, 150)
GOLD_DEEP = (255, 176, 46)
WHITE = (255, 255, 255)

# Width of the "SR" lettering on the 1024 grid. Kept well inside the Android
# adaptive-icon safe zone (a circle of 66% of the canvas, radius ~341).
TEXT_WIDTH = 515
LETTER_GAP = -10  # tight tracking for a compact monogram


def lerp(a, b, t):
    return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


def gradient_background(size):
    """Diagonal indigo gradient with a soft light bloom in the upper left."""
    img = Image.new("RGB", (size, size))
    px = img.load()
    for y in range(size):
        for x in range(size):
            t = (x * 0.35 + y * 0.65) / size  # mostly top -> bottom
            base = lerp(INDIGO_MID, INDIGO_DARK, min(max(t, 0), 1))
            # Bloom centred at (22%, 18%).
            d = math.hypot(x - size * 0.22, y - size * 0.18) / (size * 0.75)
            glow = max(0.0, 1.0 - d) ** 2
            px[x, y] = lerp(base, INDIGO_LIGHT, glow * 0.85)
    return img


def sparkle_polygon(cx, cy, r, waist=0.2):
    pts = []
    for i in range(8):
        ang = -math.pi / 2 + i * math.pi / 4
        rad = r if i % 2 == 0 else r * waist
        pts.append((cx + math.cos(ang) * rad, cy + math.sin(ang) * rad))
    return pts


def monogram_layer(size, color_mode="color"):
    """Transparent RGBA layer with the centred "SR" and the star accent.

    color_mode "mono" is a single-colour white silhouette (Android themed icon).
    """
    s = size * SS
    u = s / 1024
    # Find the font size whose "SR" is TEXT_WIDTH wide (including the gap).
    target = TEXT_WIDTH * u
    px = 400
    for _ in range(6):
        font = ImageFont.truetype(str(FONT), round(px))
        w = font.getlength("S") + LETTER_GAP * u + font.getlength("R")
        px *= target / w
    font = ImageFont.truetype(str(FONT), round(px))

    left_s = font.getbbox("S")  # (l, t, r, b) relative to the draw origin
    left_r = font.getbbox("R")
    adv_s = font.getlength("S")
    gap = LETTER_GAP * u
    total_w = adv_s + gap + font.getlength("R")
    top = min(left_s[1], left_r[1])
    bottom = max(left_s[3], left_r[3])
    # Optical centring on the cap-height box of the pair.
    ox = (s - total_w) / 2
    oy = (s - (bottom - top)) / 2 - top

    layer = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    fill = WHITE + (255,)
    d.text((ox, oy), "S", font=font, fill=fill)
    d.text((ox + adv_s + gap, oy), "R", font=font, fill=fill)

    # Star accent riding on the upper right of the "R".
    r_right = ox + total_w - (font.getlength("R") - left_r[2])
    star_r = 40 * u
    cx = r_right - 6 * u
    cy = oy + top - 10 * u
    star = sparkle_polygon(cx, cy, star_r)
    if color_mode == "mono":
        d.polygon(star, fill=fill)
    else:
        grad = Image.new("RGBA", (s, s), (0, 0, 0, 0))
        gd = ImageDraw.Draw(grad)
        y0, y1 = int(cy - star_r), int(cy + star_r)
        for y in range(y0, y1 + 1):
            t = (y - y0) / max(y1 - y0, 1)
            gd.line([(0, y), (s, y)], fill=lerp(GOLD_LIGHT, GOLD_DEEP, t) + (255,))
        mask = Image.new("L", (s, s), 0)
        ImageDraw.Draw(mask).polygon(star, fill=255)
        layer.paste(grad, (0, 0), mask)
    return layer.resize((size, size), Image.LANCZOS)


def rounded_mask(size, radius_ratio=0.2237):
    s = size * SS
    mask = Image.new("L", (s, s), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, s - 1, s - 1], radius=s * radius_ratio, fill=255
    )
    return mask.resize((size, size), Image.LANCZOS)


def drop_shadow(layer, offset=(0, 10), blur=14, opacity=90):
    """Soft shadow under a transparent layer, for depth on the gradient."""
    alpha = layer.getchannel("A")
    shadow = Image.new("RGBA", layer.size, (0, 0, 0, 0))
    black = Image.new("RGBA", layer.size, (0, 0, 20, opacity))
    shadow.paste(black, offset, alpha)
    return shadow.filter(ImageFilter.GaussianBlur(blur))


def full_bleed():
    bg = gradient_background(SIZE).convert("RGBA")
    mark = monogram_layer(SIZE)
    bg.alpha_composite(drop_shadow(mark))
    bg.alpha_composite(mark)
    return bg


def main():
    out = ROOT / "assets" / "icon"
    out.mkdir(parents=True, exist_ok=True)

    full = full_bleed()
    full.convert("RGB").save(out / "icon_full.png")  # opaque: iOS, Android legacy, web

    rounded = full.copy()
    rounded.putalpha(rounded_mask(SIZE))
    rounded.save(out / "icon_rounded.png")  # macOS / Windows / in-app

    # Android adaptive icon layers.
    gradient_background(SIZE).save(out / "adaptive_background.png")
    monogram_layer(SIZE).save(out / "adaptive_foreground.png")
    monogram_layer(SIZE, "mono").save(out / "adaptive_monochrome.png")

    images = ROOT / "assets" / "images"
    images.mkdir(parents=True, exist_ok=True)
    rounded.resize((512, 512), Image.LANCZOS).save(images / "app_icon.png")
    print("wrote", sorted(p.name for p in out.iterdir()), "and assets/images/app_icon.png")


if __name__ == "__main__":
    main()
