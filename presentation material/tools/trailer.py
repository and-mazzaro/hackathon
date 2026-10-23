"""Build the Laiqua gameplay trailer. Usage: trailer.py SCRATCH REPO OUT.mp4 DOWNLOAD_URL"""
import sys, os, math, subprocess, shutil
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import imageio_ffmpeg, qrcode

S, REPO, OUT, URL = sys.argv[1:5]
FF = imageio_ffmpeg.get_ffmpeg_exe()
RAW = f'{S}/video/raw'
B = f'{S}/video/build'
os.makedirs(B, exist_ok=True)
W, H, FPS = 1920, 1080, 30
F_XB = f'{REPO}/assets/fonts/Nunito-ExtraBold.ttf'
F_SB = f'{REPO}/assets/fonts/Nunito-SemiBold.ttf'
ICON = Image.open(f'{REPO}/docs/art/laiqua_icon_1024.png').convert('RGBA')
OTTER = Image.open(f'{S}/icon/otter_transparent.png').convert('RGBA')
YELLOW, BLUE = (255, 201, 60), (29, 63, 143)


def font(p, s):
    return ImageFont.truetype(p, s)


def gradient(top, bot, w=W, h=H):
    im = Image.new('RGB', (w, h))
    d = ImageDraw.Draw(im)
    for y in range(h):
        t = y / (h - 1)
        d.line([(0, y), (w, y)], fill=tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3)))
    return im.convert('RGBA')


def sparkle(d, cx, cy, r, fill=(255, 255, 255, 220)):
    pts = [(cx + (r if i % 2 == 0 else r * .3) * math.cos(i * math.pi / 4 - math.pi / 2),
            cy + (r if i % 2 == 0 else r * .3) * math.sin(i * math.pi / 4 - math.pi / 2)) for i in range(8)]
    d.polygon(pts, fill=fill)


def outlined(d, xy, text, f, fill=YELLOW, stroke=BLUE, sw=10, anchor='mm'):
    d.text((xy[0] + 6, xy[1] + 8), text, font=f, fill=(10, 25, 60, 160), anchor=anchor,
           stroke_width=sw, stroke_fill=(10, 25, 60, 160))
    d.text(xy, text, font=f, fill=fill, anchor=anchor, stroke_width=sw, stroke_fill=stroke)


def rays(angle, c1, c2, center=(W // 2, H // 2)):
    im = Image.new('RGBA', (W, H), c1)
    d = ImageDraw.Draw(im)
    R = 2400
    for k in range(16):
        a0 = angle + k * 2 * math.pi / 16
        a1 = a0 + math.pi / 16
        d.polygon([center, (center[0] + R * math.cos(a0), center[1] + R * math.sin(a0)),
                   (center[0] + R * math.cos(a1), center[1] + R * math.sin(a1))], fill=c2)
    if center not in _GLOW:
        glow = Image.new('RGBA', (W, H), (0, 0, 0, 0))
        ImageDraw.Draw(glow).ellipse((center[0] - 520, center[1] - 520, center[0] + 520, center[1] + 520),
                                     fill=(255, 255, 230, 120))
        _GLOW[center] = glow.filter(ImageFilter.GaussianBlur(120))
    return Image.alpha_composite(im, _GLOW[center])


_GLOW = {}


def ease_back(t):
    c1, c3 = 1.70158, 2.70158
    return 1 + c3 * (t - 1) ** 3 + c1 * (t - 1) ** 2


def encode_frames(frames_dir, out):
    subprocess.run([FF, '-v', 'error', '-y', '-framerate', str(FPS), '-i', f'{frames_dir}/f_%04d.png',
                    '-c:v', 'libx264', '-preset', 'medium', '-crf', '20', '-pix_fmt', 'yuv420p',
                    '-r', str(FPS), out], check=True)


def white(im, amount):
    return Image.blend(im, Image.new('RGBA', (W, H), (255, 255, 255, 255)), max(0.0, min(1.0, amount)))


def card(name, text, dur, c1, c2):
    d_ = f'{B}/{name}'
    shutil.rmtree(d_, ignore_errors=True)
    os.makedirs(d_)
    n = int(dur * FPS)
    f = font(F_XB, 150)
    txt = Image.new('RGBA', (W, 400), (0, 0, 0, 0))
    outlined(ImageDraw.Draw(txt), (W // 2, 200), text, f, sw=12)
    for i in range(n):
        t = i / FPS
        im = rays(t * 0.6, c1, c2)
        dr = ImageDraw.Draw(im)
        for k, (x, y, r) in enumerate([(220, 200, 30), (1700, 260, 24), (300, 860, 22), (1640, 840, 34)]):
            sparkle(dr, x, y, r * (0.7 + 0.3 * math.sin(t * 8 + k)))
        p = min(1.0, t / 0.28)
        s = max(0.05, ease_back(p)) if p < 1 else 1
        tw = txt.resize((max(1, int(W * s)), max(1, int(400 * s))), Image.LANCZOS)
        im.alpha_composite(tw, ((W - tw.width) // 2, (H - tw.height) // 2))
        if i < 4:
            im = white(im, 1 - i / 4)
        im.convert('RGB').save(f'{d_}/f_{i:04d}.png')
    out = f'{B}/{name}.mp4'
    encode_frames(d_, out)
    return out


def title(dur):
    d_ = f'{B}/title'
    shutil.rmtree(d_, ignore_errors=True)
    os.makedirs(d_)
    n = int(dur * FPS)
    fl = font(F_XB, 190)
    fs = font(F_SB, 56)
    icon = ICON.resize((380, 380), Image.LANCZOS)
    mask = Image.new('L', (380, 380), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, 379, 379), 90, fill=255)
    icon.putalpha(mask)
    logo = Image.new('RGBA', (W, 300), (0, 0, 0, 0))
    outlined(ImageDraw.Draw(logo), (W // 2, 150), 'LAIQUA', fl, sw=14)
    for i in range(n):
        t = i / FPS
        im = rays(t * 0.4, (16, 60, 110, 255), (30, 90, 150, 255), center=(W // 2, 380))
        dr = ImageDraw.Draw(im)
        for k in range(40):
            x = (k * 397 + int(t * 200 * (1 + k % 3))) % W
            y = (k * 211) % 700
            sparkle(dr, x, y, 4 + k % 5, (255, 255, 255, 160))
        p = min(1.0, t / 0.5)
        s = ease_back(p) if p < 1 else 1
        ic = icon.resize((max(1, int(380 * s)), max(1, int(380 * s))), Image.LANCZOS)
        im.alpha_composite(ic, ((W - ic.width) // 2, 330 - ic.height // 2))
        if t > 0.6:
            q = min(1.0, (t - 0.6) / 0.3)
            sc = ease_back(q) if q < 1 else 1
            tw = logo.resize((max(1, int(W * sc)), max(1, int(300 * sc))), Image.LANCZOS)
            im.alpha_composite(tw, ((W - tw.width) // 2, 700 - tw.height // 2))
        if t > 1.4:
            a = int(255 * min(1.0, (t - 1.4) / 0.4))
            ImageDraw.Draw(im).text((W // 2, 900), 'Salva il pianeta, un gioco alla volta', font=fs,
                                    fill=(255, 255, 255, a), anchor='mm')
        if t > dur - 0.25:
            im = white(im, (t - (dur - 0.25)) / 0.25)
        im.convert('RGB').save(f'{d_}/f_{i:04d}.png')
    out = f'{B}/title.mp4'
    encode_frames(d_, out)
    return out


def outro(dur):
    d_ = f'{B}/outro'
    shutil.rmtree(d_, ignore_errors=True)
    os.makedirs(d_)
    n = int(dur * FPS)
    qr = qrcode.QRCode(border=2, box_size=12)
    qr.add_data(URL)
    qr.make(fit=True)
    qimg = qr.make_image(fill_color='#173A2B', back_color='white').convert('RGBA').resize((360, 360), Image.NEAREST)
    otter = OTTER.resize((int(OTTER.width * 0.42), int(OTTER.height * 0.42)), Image.LANCZOS)
    fl = font(F_XB, 150)
    fm = font(F_XB, 58)
    fs = font(F_SB, 40)
    base = gradient((126, 214, 223), (46, 158, 106))
    for i in range(n):
        t = i / FPS
        im = base.copy()
        dr = ImageDraw.Draw(im)
        for k in range(24):
            sparkle(dr, (k * 523) % W, (k * 331) % H, (6 + (k * 7) % 14) * (0.7 + 0.3 * math.sin(t * 5 + k)))
        bob = int(10 * math.sin(t * 2.5))
        im.alpha_composite(otter, (150, H - otter.height + 60 + bob))
        dr = ImageDraw.Draw(im)
        outlined(dr, (1180, 200), 'LAIQUA', fl, sw=12)
        dr.text((1180, 345), 'Gioca, impara e prenditi cura del pianeta', font=fs, fill='white', anchor='mm')
        im.alpha_composite(qimg, (880, 450))
        dr.text((1280, 560), 'Scaricala', font=fm, fill=YELLOW, anchor='lm', stroke_width=6, stroke_fill=BLUE)
        dr.text((1280, 640), 'gratis per Android', font=fm, fill=YELLOW, anchor='lm', stroke_width=6, stroke_fill=BLUE)
        dr.text((880, 860), 'github.com/and-mazzaro/hackathon', font=fs, fill='white', anchor='lm')
        if i < 6:
            im = white(im, 1 - i / 6)
        im.convert('RGB').save(f'{d_}/f_{i:04d}.png')
    out = f'{B}/outro.mp4'
    encode_frames(d_, out)
    return out


# Shared gameplay background with phone bezel, and the screen mask
PX, PY, PW, PH = 300, 50, 441, 980
bg = gradient((126, 214, 223), (46, 158, 106))
dr = ImageDraw.Draw(bg)
for k in range(30):
    sparkle(dr, 800 + (k * 523) % 1100, (k * 331) % H, 5 + (k * 7) % 12, (255, 255, 255, 150))
shadow = Image.new('RGBA', (W, H), (0, 0, 0, 0))
ImageDraw.Draw(shadow).rounded_rectangle((PX - 8, PY - 2, PX + PW + 36, PY + PH + 42), 70, fill=(10, 40, 30, 120))
bg = Image.alpha_composite(bg, shadow.filter(ImageFilter.GaussianBlur(20)))
ImageDraw.Draw(bg).rounded_rectangle((PX - 22, PY - 22, PX + PW + 22, PY + PH + 22), 70, fill=(27, 42, 36, 255))
ic = ICON.resize((96, 96), Image.LANCZOS)
m = Image.new('L', (96, 96), 0)
ImageDraw.Draw(m).rounded_rectangle((0, 0, 95, 95), 24, fill=255)
ic.putalpha(m)
bg.alpha_composite(ic, (1690, 40))
ImageDraw.Draw(bg).text((1675, 88), 'Laiqua', font=font(F_XB, 46), fill='white', anchor='rm',
                        stroke_width=4, stroke_fill=BLUE)
bg.convert('RGB').save(f'{B}/bg.png')
mask = Image.new('L', (PW, PH), 0)
ImageDraw.Draw(mask).rounded_rectangle((0, 0, PW - 1, PH - 1), 46, fill=255)
mask.save(f'{B}/mask.png')


def caption_png(name, big, small):
    im = Image.new('RGBA', (1040, 420), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    fb = font(F_XB, 88 if len(big) < 20 else 72)
    fs = font(F_SB, 46)
    outlined(d, (10, 130), big, fb, sw=10, anchor='lm')
    d.text((14, 260), small, font=fs, fill=(255, 255, 255, 255), anchor='lm', stroke_width=3,
           stroke_fill=(20, 70, 50, 200))
    p = f'{B}/cap_{name}.png'
    im.save(p)
    return p


def segment(name, src, start, end, dur, big, small):
    cap = caption_png(name, big, small)
    speed = (end - start) / dur
    fc = (f"[1:v]trim=start={start}:end={end},setpts=(PTS-STARTPTS)/{speed:.4f},fps={FPS},"
          f"scale={PW}:{PH},format=rgba[v];"
          f"[2:v]format=gray,scale={PW}:{PH}[m];[v][m]alphamerge[vr];[0:v][vr]overlay={PX}:{PY}[b];"
          f"[b][3:v]overlay=x='if(lt(t,0.4),1920-1070*(1-pow(1-t/0.4,3)),850)':y=330,"
          f"fade=t=in:st=0:d=0.22:color=white,format=yuv420p[o]")
    out = f'{B}/seg_{name}.mp4'
    subprocess.run([FF, '-v', 'error', '-y', '-loop', '1', '-i', f'{B}/bg.png', '-i', f'{RAW}/{src}.mp4',
                    '-loop', '1', '-i', f'{B}/mask.png', '-loop', '1', '-i', cap, '-filter_complex', fc,
                    '-map', '[o]', '-t', str(dur), '-r', str(FPS), '-c:v', 'libx264', '-preset', 'medium',
                    '-crf', '20', out], check=True)
    return out


TERR = (float(os.environ.get('TERR_START', '0')), float(os.environ.get('TERR_END', '30')))
parts = [title(4.0)]
parts.append(segment('intro', 's1_intro', 0.5, 10.5, 10, "Un'avventura", 'per salvare il pianeta'))
parts.append(card('c1', 'IMPARA GIOCANDO!', 1.5, (20, 110, 70, 255), (40, 150, 95, 255)))
parts.append(segment('onb', 's2_onboarding', 2.0, 36.0, 8, 'Scegli i tuoi temi', 'riciclo, oceani, clima e altri 7'))
parts.append(segment('quiz', 's3_quiz', 3.0, 69.0, 12, 'Quiz che fanno crescere', '100 domande con fonti verificate'))
parts.append(card('c5', 'IL MIO TERRITORIO!', 1.5, (20, 90, 140, 255), (40, 130, 190, 255)))
parts.append(segment('terr', 's10_territory', TERR[0], TERR[1], 13, 'Dati live di Schio', "aria e meteo: domande dal dato reale"))
parts.append(card('c2', 'RICICLA!', 1.5, (190, 120, 20, 255), (230, 160, 40, 255)))
parts.append(segment('clean', 's4_cleanup', 0.0, 54.0, 11, 'Rifiuti nella stanza', 'mettili nel bidone giusto'))
parts.append(segment('level', 's5_levelup', 47.0, 61.0, 6, 'Sali di livello!', 'e vinci biglietti premio'))
parts.append(card('c3', 'SI SCHIUDE!', 1.5, (160, 60, 110, 255), (210, 90, 150, 255)))
parts.append(segment('hatch', 's6_hatch', 0.0, 19.0, 10, 'Ecco Laiqua!', 'la tua lontra da accudire'))
parts.append(segment('feed', 's7_feed', 0.0, 34.5, 10, 'Prepara la pappa', 'un mini-quiz sui tuoi interessi'))
parts.append(card('c4', 'ARMADIO!', 1.5, (70, 50, 150, 255), (110, 80, 200, 255)))
parts.append(segment('ward', 's8_wardrobe', 0.0, 36.0, 11, 'Ruota dei premi', '25 accessori in 6 rarità'))
parts.append(segment('night', 's9_daynight', 0.0, 31.5, 7, 'Giorno, tramonto, notte', "la stanza segue l'ora del telefono"))
parts.append(outro(11.0))
with open(f'{B}/list.txt', 'w') as fh:
    for p in parts:
        fh.write(f"file '{p}'\n")
subprocess.run([FF, '-v', 'error', '-y', '-f', 'concat', '-safe', '0', '-i', f'{B}/list.txt', '-c', 'copy',
                f'{B}/video_only.mp4'], check=True)
subprocess.run([FF, '-v', 'error', '-y', '-i', f'{B}/video_only.mp4', '-i', f'{B}/music.wav', '-map', '0:v',
                '-map', '1:a', '-c:v', 'copy', '-c:a', 'aac', '-b:a', '160k', '-shortest',
                '-movflags', '+faststart', OUT], check=True)
print('done', OUT)
