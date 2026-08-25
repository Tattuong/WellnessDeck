#!/usr/bin/env python3
"""WellnessDeck mark — fanned daily cards: sun (Today), drop (hydrate), heart pip."""
from __future__ import annotations

import math

from PIL import Image, ImageDraw, ImageFilter

CREAM = (244, 241, 236, 255)
NAVY = (26, 28, 61, 255)
SAGE = (94, 154, 110, 255)
TEAL = (61, 184, 176, 255)
WHITE = (255, 255, 255, 255)
PINK = (229, 138, 166, 255)
SHADOW = (26, 28, 61, 42)

SIZE = 1024


def _card(w: int, h: int, fill: tuple[int, ...], outline: tuple[int, ...], stroke: int, radius: int) -> Image.Image:
    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    inset = stroke // 2 + 2
    d.rounded_rectangle((inset, inset, w - inset - 1, h - inset - 1), radius=radius, fill=fill, outline=outline, width=stroke)
    return img


def _water_drop(draw: ImageDraw.ImageDraw, cx: int, cy: int, s: int, fill: tuple[int, ...]) -> None:
    r = s // 2
    draw.ellipse((cx - r, cy - int(r * 0.12), cx + r, cy + r + r // 6), fill=fill)
    draw.polygon(
        [(cx, cy - r - r // 2), (cx - r + 4, cy + 10), (cx + r - 4, cy + 10)],
        fill=fill,
    )


def _heart(draw: ImageDraw.ImageDraw, cx: int, cy: int, s: int, fill: tuple[int, ...]) -> None:
    hs = s
    draw.ellipse((cx - hs, cy - hs // 2, cx, cy + hs // 2), fill=fill)
    draw.ellipse((cx, cy - hs // 2, cx + hs, cy + hs // 2), fill=fill)
    draw.polygon([(cx - hs - 1, cy + 6), (cx + hs + 1, cy + 6), (cx, cy + hs + 20)], fill=fill)


def _sun(draw: ImageDraw.ImageDraw, cx: int, cy: int, r: int, color: tuple[int, ...], stroke: int) -> None:
    inner = int(r * 0.38)
    draw.ellipse((cx - inner, cy - inner, cx + inner, cy + inner), outline=color, width=stroke)
    for i in range(8):
        a = -math.pi / 2 + i * math.pi / 4
        p0 = (cx + math.cos(a) * r * 0.54, cy + math.sin(a) * r * 0.54)
        p1 = (cx + math.cos(a) * r * 0.90, cy + math.sin(a) * r * 0.90)
        draw.line([p0, p1], fill=color, width=stroke)


def _paste_rotated(base: Image.Image, overlay: Image.Image, cx: int, cy: int, angle: float) -> None:
    rot = overlay.rotate(angle, resample=Image.Resampling.BICUBIC, expand=True)
    base.alpha_composite(rot, (cx - rot.width // 2, cy - rot.height // 2))


def _face() -> Image.Image:
    w, h = 560, 700
    card = _card(w, h, WHITE, NAVY, 22, 72)
    d = ImageDraw.Draw(card)
    cx, cy = w // 2 - 8, h // 2 - 36
    _sun(d, cx + 18, cy - 8, 168, NAVY, 18)
    bbox = (cx - 118, cy - 150, cx + 168, cy + 136)
    d.arc(bbox, start=300, end=78, fill=SAGE, width=18)
    _water_drop(d, cx - 78, cy + 58, 108, TEAL)
    _heart(d, w - 118, h - 128, 28, PINK)
    return card


def make_logo() -> Image.Image:
    canvas = Image.new('RGBA', (SIZE, SIZE), CREAM)
    w, h = 560, 700
    cx, cy = SIZE // 2 + 18, SIZE // 2 + 8

    sage = _card(w, h, SAGE, WHITE, 10, 72)
    navy = _card(w, h, NAVY, WHITE, 10, 72)
    face = _face()

    shadow = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle((210, 250, 860, 900), radius=80, fill=SHADOW)
    canvas.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(18)))

    _paste_rotated(canvas, sage, cx - 78, cy + 12, -19)
    _paste_rotated(canvas, navy, cx - 36, cy + 4, -9)
    _paste_rotated(canvas, face, cx, cy, 3.5)
    return canvas.convert('RGB')


def padded(src: Image.Image, pad_ratio: float = 0.08) -> Image.Image:
    pad = int(SIZE * pad_ratio)
    inner = src.resize((SIZE - pad * 2, SIZE - pad * 2), Image.Resampling.LANCZOS)
    out = Image.new('RGB', (SIZE, SIZE), CREAM[:3])
    out.paste(inner, (pad, pad))
    return out


def main() -> None:
    logo = make_logo()
    logo.save('assets/logo.png')
    padded(logo, 0.10).save('assets/logo_padded.png')
    # Android circle / adaptive safe zone is the inner ~66%. Keep the deck inside it.
    padded(logo, 0.22).save('assets/icon_foreground.png')
    print('wrote assets/logo.png, logo_padded.png, icon_foreground.png', logo.size, logo.mode)


if __name__ == '__main__':
    main()
