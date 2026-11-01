import math
from PIL import Image, ImageDraw, ImageFilter

def create_app_logo(path="mobile/assets/icons/app_logo.png", size=512):
    # 512x512 high-res app icon with supersampling (render at 1024x1024 then downsample)
    s = size * 2
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 1. Background Rounded Rectangle with Gradient
    bg = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    bg_draw = ImageDraw.Draw(bg)

    # Gradient from rich dark forest teal to vibrant emerald green
    for y in range(s):
        ratio = y / s
        r = int(0 * (1 - ratio) + 0 * ratio)
        g = int(77 * (1 - ratio) + 121 * ratio)
        b = int(64 * (1 - ratio) + 107 * ratio)
        bg_draw.line([(0, y), (s, y)], fill=(r, g, b, 255))

    # Mask for rounded corners
    mask = Image.new("L", (s, s), 0)
    mask_draw = ImageDraw.Draw(mask)
    corner_radius = int(s * 0.22)  # modern squircle-like radius
    mask_draw.rounded_rectangle([(0, 0), (s - 1, s - 1)], radius=corner_radius, fill=255)

    img.paste(bg, (0, 0), mask)
    draw = ImageDraw.Draw(img)

    # 2. Golden Sun & Weather Aura (top-right / center)
    sun_x, sun_y = int(s * 0.65), int(s * 0.35)
    sun_radius = int(s * 0.18)

    # Outer glow
    for dr in range(60, 0, -4):
        alpha = int(35 * (1 - dr / 60))
        draw.ellipse(
            [sun_x - sun_radius - dr, sun_y - sun_radius - dr, sun_x + sun_radius + dr, sun_y + sun_radius + dr],
            fill=(255, 215, 64, alpha)
        )

    # Main Sun
    draw.ellipse(
        [sun_x - sun_radius, sun_y - sun_radius, sun_x + sun_radius, sun_y + sun_radius],
        fill=(255, 193, 7, 240)
    )

    # 3. Stylized Golden-Green Rice Stalks (Palay)
    # Stalk stem arc
    stalk_points = []
    for t in range(100):
        frac = t / 99.0
        # Curve starting from bottom-left to center-upwards
        x = int(s * 0.28 + math.sin(frac * math.pi * 0.7) * (s * 0.32) + frac * (s * 0.08))
        y = int(s * 0.88 - frac * (s * 0.58))
        stalk_points.append((x, y))

    # Draw smooth thick stem
    for i in range(len(stalk_points) - 1):
        draw.line([stalk_points[i], stalk_points[i+1]], fill=(129, 199, 132, 255), width=int(s * 0.024))

    # Leaf sweeping out to the left
    leaf_curve = []
    for t in range(50):
        frac = t / 49.0
        lx = int(s * 0.35 - math.sin(frac * math.pi) * (s * 0.18))
        ly = int(s * 0.78 - frac * (s * 0.28))
        leaf_curve.append((lx, ly))

    for i in range(len(leaf_curve) - 1):
        w = int(math.sin(i / len(leaf_curve) * math.pi) * s * 0.045) + 3
        draw.line([leaf_curve[i], leaf_curve[i+1]], fill=(76, 175, 80, 240), width=w)

    # Rice Grains (Golden oval grains along the curving stalk)
    grains = [
        # (stalk_fraction, angle_deg, size_mult, is_left)
        (0.35, -45, 1.0, False),
        (0.45, 40, 1.05, True),
        (0.52, -40, 1.1, False),
        (0.60, 45, 1.15, True),
        (0.68, -35, 1.1, False),
        (0.75, 35, 1.05, True),
        (0.82, -25, 0.95, False),
        (0.88, 25, 0.85, True),
        (0.95, -10, 0.75, False),
        (1.0, 10, 0.65, True),
    ]

    for frac, angle_deg, sz, is_left in grains:
        idx = int(frac * (len(stalk_points) - 1))
        cx, cy = stalk_points[idx]
        offset = int(s * 0.065 * sz) * (-1 if is_left else 1)
        gx = cx + offset
        gy = cy - int(s * 0.015)

        # Draw rotated grain as polygon
        gw = int(s * 0.038 * sz)
        gh = int(s * 0.075 * sz)
        rad = math.radians(angle_deg)
        cos_a = math.cos(rad)
        sin_a = math.sin(rad)

        pts = []
        for a in range(0, 360, 20):
            r_rad = math.radians(a)
            px = math.cos(r_rad) * gw
            py = math.sin(r_rad) * gh
            rx = gx + (px * cos_a - py * sin_a)
            ry = gy + (px * sin_a + py * cos_a)
            pts.append((rx, ry))

        # Grain body (warm golden amber)
        draw.polygon(pts, fill=(255, 213, 79, 255))
        # Grain border / highlight
        draw.polygon(pts, outline=(255, 179, 0, 255), width=int(s * 0.005))

    # Inner bright ring highlight for premium app icon feel
    border_mask = Image.new("L", (s, s), 0)
    border_draw = ImageDraw.Draw(border_mask)
    border_draw.rounded_rectangle([(0, 0), (s - 1, s - 1)], radius=corner_radius, outline=255, width=int(s * 0.015))
    img.paste((255, 255, 255, 45), (0, 0), border_mask)

    # Downsample with high-quality Lanczos filter for crisp edges
    final_img = img.resize((size, size), Image.Resampling.LANCZOS)
    final_img.save(path, "PNG")
    print(f"App logo successfully generated at: {path}")


def create_splash_background(path="mobile/assets/images/splash_background.png", width=1080, height=1920):
    # Generates a scenic portrait dawn rice terrace backdrop
    w, h = width, height
    img = Image.new("RGBA", (w, h), (0, 0, 0, 255))
    draw = ImageDraw.Draw(img)

    # 1. Sky Gradient: Deep twilight teal-blue to warm morning amber/gold
    sky_colors = [
        (0.00, (10, 35, 45)),
        (0.25, (16, 54, 60)),
        (0.45, (40, 85, 75)),
        (0.60, (140, 120, 65)),
        (0.75, (230, 160, 60)),
        (0.85, (255, 200, 100)),
        (1.00, (255, 230, 160)),
    ]

    for y in range(int(h * 0.65)):
        ratio = y / (h * 0.65)
        # Find segment
        for i in range(len(sky_colors) - 1):
            r1, c1 = sky_colors[i]
            r2, c2 = sky_colors[i + 1]
            if r1 <= ratio <= r2:
                local_t = (ratio - r1) / (r2 - r1)
                r = int(c1[0] * (1 - local_t) + c2[0] * local_t)
                g = int(c1[1] * (1 - local_t) + c2[1] * local_t)
                b = int(c1[2] * (1 - local_t) + c2[2] * local_t)
                draw.line([(0, y), (w, y)], fill=(r, g, b, 255))
                break

    # 2. Rising Sun Glow
    sun_x, sun_y = int(w * 0.5), int(h * 0.48)
    for r in range(350, 0, -5):
        alpha = int(90 * (1 - r / 350))
        draw.ellipse([sun_x - r, sun_y - r, sun_x + r, sun_y + r], fill=(255, 220, 120, alpha))
    draw.ellipse([sun_x - 70, sun_y - 70, sun_x + 70, sun_y + 70], fill=(255, 245, 200, 230))

    # 3. Distant Mountain Silhouette
    mount_pts = [(0, int(h * 0.52))]
    for x in range(0, w + 20, 20):
        my = int(h * 0.50 + math.sin(x * 0.004) * 50 + math.cos(x * 0.012) * 25)
        mount_pts.append((x, my))
    mount_pts.extend([(w, h), (0, h)])
    draw.polygon(mount_pts, fill=(28, 62, 58, 255))

    # 4. Layered Curving Rice Terraces
    terrace_layers = [
        # (base_y_frac, amplitude, freq, color)
        (0.56, 35, 0.005, (36, 85, 68)),
        (0.62, 45, 0.006, (44, 110, 78)),
        (0.69, 55, 0.005, (52, 135, 85)),
        (0.77, 60, 0.004, (38, 115, 72)),
        (0.86, 70, 0.003, (24, 85, 55)),
        (0.94, 65, 0.003, (14, 60, 40)),
    ]

    for base_y, amp, freq, col in terrace_layers:
        t_pts = [(0, int(h * base_y))]
        for x in range(0, w + 15, 15):
            ty = int(h * base_y + math.sin(x * freq) * amp + math.sin(x * 0.015) * 12)
            t_pts.append((x, ty))
        t_pts.extend([(w, h), (0, h)])
        draw.polygon(t_pts, fill=(*col, 255))

        # Add terrace rim highlight (water reflection)
        for i in range(len(t_pts) - 3):
            draw.line([t_pts[i], t_pts[i+1]], fill=(140, 210, 160, 110), width=3)

    # 5. Soft vignette overlay at the bottom for text contrast
    for y in range(int(h * 0.65), h):
        ratio = (y - h * 0.65) / (h * 0.35)
        alpha = int(140 * ratio)
        draw.line([(0, y), (w, y)], fill=(0, 20, 15, alpha))

    img.save(path, "PNG")
    print(f"Splash background successfully generated at: {path}")

if __name__ == "__main__":
    create_app_logo()
    create_splash_background()

