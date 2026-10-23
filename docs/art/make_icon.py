import sys, math
from PIL import Image, ImageDraw, ImageFilter
S = sys.argv[1]
otter = Image.open(f"{S}/icon/otter_transparent.png").convert("RGBA")
# Face crop in reference coords (viewBox origin 128,196, scale x2)
x0, y0, x1, y1 = 128, 190, 850, 885
crop = otter.crop(((x0-128)*2, max(0,(y0-196)*2), (x1-128)*2, (y1-196)*2))
N = 1024
bg = Image.new("RGBA", (N, N))
d = ImageDraw.Draw(bg)
top, bot = (126, 214, 223), (46, 158, 106)  # sky teal -> leaf green
for y in range(N):
    t = y / (N - 1)
    d.line([(0, y), (N, y)], fill=tuple(int(top[i] + (bot[i]-top[i]) * t) for i in range(3)) + (255,))
# soft glow behind the head
glow = Image.new("RGBA", (N, N), (0, 0, 0, 0))
ImageDraw.Draw(glow).ellipse((150, 140, 874, 864), fill=(255, 250, 220, 150))
bg = Image.alpha_composite(bg, glow.filter(ImageFilter.GaussianBlur(70)))
# sparkles
sp = ImageDraw.Draw(bg)
for cx, cy, r in [(150, 170, 26), (880, 230, 20), (120, 820, 16), (900, 760, 24), (800, 120, 12)]:
    pts = []
    for i in range(8):
        a = i * math.pi / 4 - math.pi / 2
        rr = r if i % 2 == 0 else r * 0.35
        pts.append((cx + rr * math.cos(a), cy + rr * math.sin(a)))
    sp.polygon(pts, fill=(255, 255, 255, 230))
# head, scaled to ~84% of the icon, shadow underneath
scale = (N * 0.74) / max(crop.size)
head = crop.resize((int(crop.width * scale), int(crop.height * scale)), Image.LANCZOS)
px = (N - head.width) // 2
py = N - head.height + 40
shadow = Image.new("RGBA", (N, N), (0, 0, 0, 0))
shadow.paste((20, 60, 40, 90), (px + 12, py + 18), head)
bg = Image.alpha_composite(bg, shadow.filter(ImageFilter.GaussianBlur(18)))
bg.alpha_composite(head, (px, py))
master = bg.convert("RGB")
master.save(f"{S}/icon/laiqua_icon_1024.png")
print("ok", head.size, (px, py))

