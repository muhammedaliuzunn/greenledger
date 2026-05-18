"""
GreenLedger uygulama ikonu oluşturma scripti.
Çıktı: assets/icon/app_icon.png (1024x1024)
"""

import os
import math
from PIL import Image, ImageDraw, ImageFont

SIZE = 1024
RADIUS = 200

# Renkler (app_theme.dart'tan)
BG_TOP    = (20, 43, 31)    # #142B1F  sidebarBg
BG_BOT    = (45, 122, 79)   # #2D7A4F  primary
GOLD      = (212, 160, 23)  # #D4A017  accent
WHITE     = (255, 255, 255)
LIGHT_GRN = (164, 224, 191) # yaprak damarı

def make_rounded_mask(size, radius):
    mask = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=255)
    return mask

def draw_gradient_bg(draw, size):
    for y in range(size):
        t = y / size
        r = int(BG_TOP[0] + (BG_BOT[0] - BG_TOP[0]) * t)
        g = int(BG_TOP[1] + (BG_BOT[1] - BG_TOP[1]) * t)
        b = int(BG_TOP[2] + (BG_BOT[2] - BG_TOP[2]) * t)
        draw.line([(0, y), (size, y)], fill=(r, g, b))

def draw_leaf(draw, cx, cy, size):
    """Basit stilize yaprak: iki bezier'ı simüle eden polygon."""
    lw = int(size * 0.28)
    lh = int(size * 0.40)
    pts = []
    n = 60
    for i in range(n + 1):
        t = i / n
        # Sol kenar
        x = cx - lw * math.sin(math.pi * t)
        y = cy + lh * (2 * t - 1)
        pts.append((x, y))
    for i in range(n, -1, -1):
        t = i / n
        # Sağ kenar (sivri)
        x = cx + lw * 0.6 * math.sin(math.pi * t)
        y = cy + lh * (2 * t - 1)
        pts.append((x, y))
    draw.polygon(pts, fill=GOLD)

    # Yaprak damarı (orta)
    stem_top = (cx, cy - lh * 0.95)
    stem_bot = (cx, cy + lh * 0.95)
    lw2 = max(4, int(size * 0.012))
    draw.line([stem_top, stem_bot], fill=LIGHT_GRN, width=lw2)

    # Yan damarlar
    for frac, angle_deg in [(-0.5, 30), (-0.2, 28), (0.15, 25)]:
        mx = cx
        my = cy + int(lh * frac)
        angle = math.radians(angle_deg)
        length = lw * 0.55
        ex = int(mx + length * math.cos(angle))
        ey = int(my - length * math.sin(angle))
        draw.line([(mx, my), (ex, ey)], fill=LIGHT_GRN, width=max(2, lw2 - 2))
        ex2 = int(mx - length * 0.8 * math.cos(angle))
        ey2 = int(my - length * 0.8 * math.sin(angle))
        draw.line([(mx, my), (ex2, ey2)], fill=LIGHT_GRN, width=max(2, lw2 - 2))

def draw_chart_bars(draw, cx, cy, size):
    """Yaprak altında küçük bar grafik."""
    bar_w = int(size * 0.055)
    gap   = int(size * 0.015)
    heights = [0.10, 0.16, 0.13, 0.20]
    total_w = len(heights) * bar_w + (len(heights) - 1) * gap
    start_x = cx - total_w // 2
    base_y  = cy + int(size * 0.04)
    for i, h in enumerate(heights):
        bh = int(size * h)
        x0 = start_x + i * (bar_w + gap)
        x1 = x0 + bar_w
        y0 = base_y - bh
        y1 = base_y
        r  = max(2, bar_w // 4)
        draw.rounded_rectangle([x0, y0, x1, y1], radius=r, fill=WHITE + (200,))

def main():
    os.makedirs("assets/icon", exist_ok=True)

    img  = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Gradient arka plan
    draw_gradient_bg(draw, SIZE)

    # Yuvarlak köşe maskesi uygula
    mask = make_rounded_mask(SIZE, RADIUS)
    img.putalpha(mask)

    # Yaprak ikonu (üst yarı)
    leaf_cx = SIZE // 2
    leaf_cy = int(SIZE * 0.38)
    draw_leaf(draw, leaf_cx, leaf_cy, SIZE)

    # Bar grafik (alt yarı)
    draw_chart_bars(draw, SIZE // 2, int(SIZE * 0.72), SIZE)

    # "GL" metni küçük, alt köşe
    try:
        font = ImageFont.truetype("arial.ttf", int(SIZE * 0.07))
    except Exception:
        font = ImageFont.load_default()
    text = "GreenLedger"
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    tx = (SIZE - tw) // 2
    ty = int(SIZE * 0.84)
    draw.text((tx, ty), text, font=font, fill=WHITE + (210,))

    out_path = "assets/icon/app_icon.png"
    img.save(out_path, "PNG")
    print(f"İkon oluşturuldu: {out_path}  ({SIZE}x{SIZE})")

if __name__ == "__main__":
    main()
