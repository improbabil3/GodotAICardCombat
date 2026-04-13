#!/usr/bin/env python3
"""make_icon_variants.py

Generate icon background variants (flat, metallic, neon) using Pillow.

Usage: python tools/make_icon_variants.py
Requires: Pillow (pip install pillow)
"""
from PIL import Image, ImageDraw, ImageFilter, ImageOps, ImageEnhance
import os
import math
import random

CANVAS = 1024
SRC = os.path.join("assets", "icon_souce.png")
OUTDIR = os.path.join("build", "icons")


def ensure_outdir():
    os.makedirs(OUTDIR, exist_ok=True)


def linear_gradient(size, top_color, bottom_color):
    w, h = size
    base = Image.new("RGB", (w, h), top_color)
    draw = ImageDraw.Draw(base)
    for y in range(h):
        t = y / float(h - 1)
        r = int(top_color[0] * (1 - t) + bottom_color[0] * t)
        g = int(top_color[1] * (1 - t) + bottom_color[1] * t)
        b = int(top_color[2] * (1 - t) + bottom_color[2] * t)
        draw.line([(0, y), (w, y)], fill=(r, g, b))
    return base


def radial_gradient(size, inner_color, outer_color):
    w, h = size
    cx, cy = w / 2.0, h / 2.0
    maxd = math.hypot(cx, cy)
    im = Image.new("RGB", (w, h))
    px = im.load()
    for y in range(h):
        for x in range(w):
            d = math.hypot(x - cx, y - cy) / maxd
            t = min(1.0, d)
            r = int(inner_color[0] * (1 - t) + outer_color[0] * t)
            g = int(inner_color[1] * (1 - t) + outer_color[1] * t)
            b = int(inner_color[2] * (1 - t) + outer_color[2] * t)
            px[x, y] = (r, g, b)
    return im


def add_starfield(image, density=0.0008, brightness=180):
    w, h = image.size
    overlay = Image.new("RGBA", image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    count = int(w * h * density)
    for _ in range(count):
        x = random.randrange(0, w)
        y = random.randrange(0, h)
        alpha = random.randint(30, brightness)
        r = g = b = 255
        draw.point((x, y), fill=(r, g, b, alpha))
    return Image.alpha_composite(image.convert("RGBA"), overlay)


def make_star_overlay(size, density=0.0006, brightness=120):
    w, h = size
    overlay = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    count = int(w * h * density)
    for _ in range(count):
        x = random.randrange(0, w)
        y = random.randrange(0, h)
        a = random.randint(30, brightness)
        draw.point((x, y), fill=(255, 255, 255, a))
    return overlay


def rounded_rect_mask(size, margin=80, radius=120):
    w, h = size
    mask = Image.new('L', (w, h), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((margin, margin, w - margin, h - margin), radius=radius, fill=255)
    return mask


def center_icon_on(bg, icon, scale=0.7, shadow=True):
    w, h = bg.size
    icon_w = int(w * scale)
    icon_h = int(icon_w * icon.height / icon.width)
    icon_resized = icon.resize((icon_w, icon_h), Image.LANCZOS)

    if shadow:
        # shadow from alpha (use blurred alpha as mask and paste a semi-opaque black)
        alpha = icon_resized.split()[-1]
        sh_mask = alpha.filter(ImageFilter.GaussianBlur(radius=18))
        shadow = Image.new("RGBA", bg.size, (0, 0, 0, 0))
        black = Image.new("RGBA", icon_resized.size, (0, 0, 0, 180))
        pos = (int((w - icon_w) / 2), int((h - icon_h) / 2) + 28)
        # paste expects mask to be same size as source; ensure sh_mask is same size as black
        if sh_mask.size != black.size:
            sh_mask = sh_mask.resize(black.size, resample=Image.LANCZOS)
        shadow.paste(black, pos, mask=sh_mask)
        base = Image.alpha_composite(bg.convert("RGBA"), shadow)
    else:
        base = bg.convert("RGBA")

    base.paste(icon_resized, (int((w - icon_w) / 2), int((h - icon_h) / 2)), icon_resized)
    return base


def make_flat_variant(icon):
    # create transparent canvas + rounded badge with linear gradient and starfield
    size = (CANVAS, CANVAS)
    grad = linear_gradient(size, (7, 10, 20), (26, 8, 51)).convert('RGBA')
    mask = rounded_rect_mask(size, margin=int(CANVAS*0.08), radius=int(CANVAS*0.08))
    badge = Image.composite(grad, Image.new('RGBA', size, (0,0,0,0)), mask)
    stars = make_star_overlay(size, density=0.0006, brightness=80)
    stars_masked = Image.composite(stars, Image.new('RGBA', size, (0,0,0,0)), mask)
    badge = Image.alpha_composite(badge, stars_masked)
    out = center_icon_on(badge, icon, scale=0.72, shadow=True)
    return out


def make_metal_variant(icon):
    size = (CANVAS, CANVAS)
    grad = radial_gradient(size, (15, 2, 54), (42, 0, 112)).convert('RGBA')
    mask = rounded_rect_mask(size, margin=int(CANVAS*0.08), radius=int(CANVAS*0.08))
    badge = Image.composite(grad, Image.new('RGBA', size, (0,0,0,0)), mask)
    # golden backing element inside the badge (circle)
    g = Image.new('RGBA', size, (0,0,0,0))
    draw = ImageDraw.Draw(g)
    cx, cy = CANVAS // 2, CANVAS // 2
    r = int(CANVAS * 0.35)
    draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(255, 200, 87, 255))
    g_masked = Image.composite(g, Image.new('RGBA', size, (0,0,0,0)), mask)
    badge = Image.alpha_composite(badge, g_masked)
    # subtle vignette inside badge
    vignette = Image.new('L', size, 0)
    vd = ImageDraw.Draw(vignette)
    vd.ellipse((-int(CANVAS*0.1), -int(CANVAS*0.1), int(CANVAS*1.1), int(CANVAS*1.1)), fill=255)
    vignette = vignette.filter(ImageFilter.GaussianBlur(radius=int(CANVAS*0.12)))
    dark = Image.new('RGBA', size, (8,2,30,255))
    badge = Image.composite(badge, dark, vignette)
    out = center_icon_on(badge, icon, scale=0.72, shadow=True)
    # slight specular overlay
    spec = out.filter(ImageFilter.GaussianBlur(radius=6)).point(lambda p: p * 0.06)
    out = Image.alpha_composite(out, spec)
    return out


def make_neon_variant(icon):
    size = (CANVAS, CANVAS)
    grad = linear_gradient(size, (5,5,10), (11,15,26)).convert('RGBA')
    mask = rounded_rect_mask(size, margin=int(CANVAS*0.08), radius=int(CANVAS*0.08))
    badge = Image.composite(grad, Image.new('RGBA', size, (0,0,0,0)), mask)
    # create colored glow layers from the icon and composite onto badge
    alpha = icon.split()[-1]
    ic_c = Image.new('RGBA', icon.size, (0,246,255,0))
    ic_p = Image.new('RGBA', icon.size, (106,0,255,0))
    ic_c.putalpha(alpha)
    ic_p.putalpha(alpha)
    ic_c = ic_c.resize((int(CANVAS*0.72), int(CANVAS*0.72)), Image.LANCZOS)
    ic_p = ic_p.resize((int(CANVAS*0.72*0.98), int(CANVAS*0.72*0.98)), Image.LANCZOS)
    glow = Image.new('RGBA', size, (0,0,0,0))
    glow.paste(ic_c, (int(CANVAS*0.14), int(CANVAS*0.14)), ic_c)
    glow = glow.filter(ImageFilter.GaussianBlur(radius=60))
    glow2 = Image.new('RGBA', size, (0,0,0,0))
    glow2.paste(ic_p, (int(CANVAS*0.15), int(CANVAS*0.155)), ic_p)
    glow2 = glow2.filter(ImageFilter.GaussianBlur(radius=36))
    # only keep glow inside badge mask
    glow_masked = Image.composite(glow, Image.new('RGBA', size, (0,0,0,0)), mask)
    glow2_masked = Image.composite(glow2, Image.new('RGBA', size, (0,0,0,0)), mask)
    badge = Image.alpha_composite(badge, glow_masked)
    badge = Image.alpha_composite(badge, glow2_masked)
    out = center_icon_on(badge, icon, scale=0.72, shadow=False)
    return out


def save_variants(icon):
    flat = make_flat_variant(icon)
    metal = make_metal_variant(icon)
    neon = make_neon_variant(icon)

    variants = [("flat", flat), ("metal", metal), ("neon", neon)]
    sizes = [1024, 512, 256]
    for name, img in variants:
        for s in sizes:
            outp = os.path.join(OUTDIR, f"icon_{name}_{s}.png")
            if s == CANVAS:
                img.save(outp)
            else:
                img.resize((s, s), Image.LANCZOS).save(outp)


def main():
    ensure_outdir()
    if not os.path.exists(SRC):
        print(f"Source icon not found: {SRC}\nPlace your PNG (transparent background) at this path.")
        return 2
    icon = Image.open(SRC).convert("RGBA")
    save_variants(icon)
    print("Variants generated in:", OUTDIR)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
