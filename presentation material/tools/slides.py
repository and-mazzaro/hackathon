"""Laiqua pitch slides: each slide is drawn as a 1920x1080 image (exact look, reusable in any deck)
and packed into a .pptx with Italian speaker notes.
Usage: slides.py SCRATCH REPO OUT_DIR [TERRITORY_SCREENSHOT.png]"""
import sys, os, math
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import qrcode
from pptx import Presentation
from pptx.util import Emu

S, REPO, OUT = sys.argv[1:4]
SHOT = sys.argv[4] if len(sys.argv) > 4 and os.path.exists(sys.argv[4]) else None
os.makedirs(OUT, exist_ok=True)
W, H = 1920, 1080
XB = f'{REPO}/assets/fonts/Nunito-ExtraBold.ttf'
SB = f'{REPO}/assets/fonts/Nunito-SemiBold.ttf'
RG = f'{REPO}/assets/fonts/Nunito-Regular.ttf'
INK, GREEN, TEAL, YELLOW, BLUE, CREAM = (78, 52, 36), (63, 127, 58), (126, 214, 223), (255, 201, 60), (29, 63, 143), (248, 240, 222)
WHITE = (255, 255, 255)
ICON = Image.open(f'{REPO}/docs/art/laiqua_icon_1024.png').convert('RGBA')
OTTER = Image.open(f'{S}/icon/otter_transparent.png').convert('RGBA')
DL = 'https://github.com/and-mazzaro/hackathon/raw/main/presentation%20material/Laiqua.apk'


def f(p, s): return ImageFont.truetype(p, s)


def gradient(top, bot):
    im = Image.new('RGB', (W, H)); d = ImageDraw.Draw(im)
    for y in range(H):
        t = y / (H - 1); d.line([(0, y), (W, y)], fill=tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3)))
    return im.convert('RGBA')


def sparkle(d, cx, cy, r, fill=(255, 255, 255, 200)):
    d.polygon([(cx + (r if i % 2 == 0 else r * .3) * math.cos(i * math.pi / 4 - math.pi / 2),
                cy + (r if i % 2 == 0 else r * .3) * math.sin(i * math.pi / 4 - math.pi / 2)) for i in range(8)], fill=fill)


def wrap(d, text, font, width):
    words, lines, cur = text.split(), [], ''
    for w in words:
        t = (cur + ' ' + w).strip()
        if d.textlength(t, font=font) <= width: cur = t
        else: lines.append(cur); cur = w
    if cur: lines.append(cur)
    return lines


def para(d, xy, text, font, fill, width, gap=1.25):
    x, y = xy
    for line in wrap(d, text, font, width):
        d.text((x, y), line, font=font, fill=fill); y += int(font.size * gap)
    return y


def card(im, box, fill=WHITE, r=36, shadow=True):
    if shadow:
        sh = Image.new('RGBA', im.size, (0, 0, 0, 0))
        ImageDraw.Draw(sh).rounded_rectangle((box[0] + 6, box[1] + 12, box[2] + 6, box[3] + 12), r, fill=(90, 60, 30, 60))
        im.alpha_composite(sh.filter(ImageFilter.GaussianBlur(14)))
    ImageDraw.Draw(im).rounded_rectangle(box, r, fill=fill)


def badge(im, cx, cy, r, color, text, font):
    d = ImageDraw.Draw(im); d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=color)
    d.text((cx, cy + 2), text, font=font, fill=WHITE, anchor='mm')


def title(d, text, sub=None, color=INK):
    d.text((110, 90), text, font=f(XB, 68), fill=color)
    if sub: d.text((112, 185), sub, font=f(SB, 34), fill=(color if color != INK else (125, 98, 72)))


def light_bg():
    im = Image.new('RGBA', (W, H), WHITE)
    ImageDraw.Draw(im).rectangle((0, 0, W, H), fill=CREAM)
    return im


def phone(im, shot, box):
    x0, y0, x1, y1 = box
    ImageDraw.Draw(im).rounded_rectangle((x0 - 16, y0 - 16, x1 + 16, y1 + 16), 54, fill=(27, 42, 36))
    s = Image.open(shot).convert('RGBA').resize((x1 - x0, y1 - y0), Image.LANCZOS)
    m = Image.new('L', s.size, 0); ImageDraw.Draw(m).rounded_rectangle((0, 0, s.width - 1, s.height - 1), 40, fill=255)
    im.paste(s, (x0, y0), m)


def mock_card(im, box):
    """Drawn stand-in for the Home 'Il mio territorio' card when no screenshot is given."""
    card(im, box, WHITE, 40)
    d = ImageDraw.Draw(im); x0, y0, x1, y1 = box
    d.text((x0 + 40, y0 + 34), 'Il mio territorio · Schio', font=f(XB, 40), fill=INK)
    d.rounded_rectangle((x0 + 40, y0 + 110, x0 + 330, y0 + 190), 40, fill=(56, 160, 90))
    d.text((x0 + 185, y0 + 150), 'Aria buona', font=f(XB, 36), fill=WHITE, anchor='mm')
    for i, (k, v) in enumerate([('PM10', '5,5 µg/m³'), ('PM2,5', '4,9 µg/m³'), ('Temperatura', '10 °C')]):
        d.text((x0 + 40 + i * 230, y0 + 225), k, font=f(SB, 28), fill=(80, 100, 90))
        d.text((x0 + 40 + i * 230, y0 + 262), v, font=f(XB, 34), fill=INK)
    d.rounded_rectangle((x0 + 40, y0 + 330, x1 - 40, y0 + 450), 24, fill=(232, 245, 236))
    para(d, (x0 + 66, y0 + 352), 'Aria buona: oggi vai a scuola in bici o a piedi', f(SB, 32), INK, x1 - x0 - 140)
    d.rounded_rectangle((x0 + 40, y0 + 480, x0 + 330, y0 + 560), 40, fill=GREEN)
    d.text((x0 + 185, y0 + 520), 'Quiz del territorio', font=f(XB, 28), fill=WHITE, anchor='mm')
    d.text((x0 + 40, y1 - 50), 'Dati: Open-Meteo.com (CC BY 4.0), CAMS Europe', font=f(RG, 24), fill=(90, 110, 100))


slides = []

# 1 — Title / promise
im = gradient((126, 214, 223), (46, 158, 106)); d = ImageDraw.Draw(im)
for k in range(28): sparkle(d, (k * 523) % W, (k * 331) % H, 6 + (k * 7) % 12)
ot = OTTER.resize((int(OTTER.width * 0.40), int(OTTER.height * 0.40)), Image.LANCZOS)
im.alpha_composite(ot, (60, H - ot.height + 30))
d = ImageDraw.Draw(im)
d.text((1280, 300), 'LAIQUA', font=f(XB, 170), fill=YELLOW, stroke_width=12, stroke_fill=BLUE, anchor='mm')
d.text((1280, 450), 'La mia sostenibilità, un gioco alla volta', font=f(XB, 46), fill=WHITE, anchor='mm')
para(d, (840, 560), "Dai dati ambientali dell'Alto Vicentino a piccole azioni quotidiane, con una lontra da far crescere.",
     f(SB, 40), WHITE, 900)
slides.append((im, "Laiqua risponde alla domanda guida: come trasformiamo i dati ambientali del nostro territorio in azioni alla portata di chi le deve prendere? Il nostro pubblico sono i ragazzi: per loro l'azione è quotidiana (come vado a scuola, come differenzio, cosa imparo), e il motore è un gioco con un cucciolo che cresce."))

# 2 — The loop
im = light_bg(); d = ImageDraw.Draw(im)
title(d, 'Dai dati del territorio alle azioni', 'Il ciclo di Laiqua, ogni giorno')
steps = [('1', 'Dati aperti live', 'Qualità dell\'aria e meteo di Schio, Thiene e Valdagno (Open-Meteo, CAMS Europe)', (29, 113, 184)),
         ('2', 'Domande del giorno', 'Il quiz si genera dai numeri reali di oggi, con la fonte e l\'ora', (27, 127, 76)),
         ('3', 'Il consiglio', '"Aria buona: vai a scuola in bici". Lo fai, tocchi "L\'ho fatto!"', (214, 120, 20)),
         ('4', 'Il pet cresce', 'XP, monete e biglietti: Laiqua si schiude, cresce, si veste', (160, 60, 110))]
for i, (n, h, b, c) in enumerate(steps):
    x = 110 + i * 440
    card(im, (x, 330, x + 400, 900))
    d = ImageDraw.Draw(im); badge(im, x + 80, 420, 50, c, n, f(XB, 54))
    d = ImageDraw.Draw(im); d.text((x + 40, 500), h, font=f(XB, 38), fill=INK)
    para(d, (x + 40, 570), b, f(SB, 31), (60, 85, 72), 330)
    if i < 3: d.polygon([(x + 412, 600), (x + 432, 615), (x + 412, 630)], fill=(150, 175, 160))
slides.append((im, "Il cuore del progetto è un ciclo quotidiano. 1) L'app legge dati aperti del territorio: qualità dell'aria e meteo per Schio, Thiene e Valdagno. 2) Da quei numeri genera le domande del giorno: non sono inventate, la risposta giusta è calcolata dal dato. 3) Dallo stesso dato nasce un consiglio pratico. 4) Ogni azione e ogni risposta fanno crescere il pet: è la motivazione per tornare domani."))

# 3 — Live territory card
im = light_bg(); d = ImageDraw.Draw(im)
title(d, 'Il mio territorio, in tempo reale', 'Dati aperti spiegati in linguaggio semplice')
if SHOT:
    phone(im, SHOT, (170, 280, 170 + 342, 280 + 760))
else:
    mock_card(im, (110, 300, 830, 960))
d = ImageDraw.Draw(im)
rows = [('Fonte', 'Open-Meteo Air Quality + Forecast: dati CAMS Europe (Copernicus), aggiornati ogni ora, senza chiavi'),
        ('Dove', 'Schio, Thiene, Valdagno: il giocatore sceglie il suo comune'),
        ('Cosa', 'Indice europeo EAQI, PM10, PM2,5, NO2, ozono, temperatura, pioggia, vento'),
        ('Offline', 'Ultima lettura salvata sul telefono; se manca, l\'app lo dice e non inventa nulla')]
y = 310
for k, v in rows:
    card(im, (640, y, 1810, y + 150), WHITE, 28)
    d = ImageDraw.Draw(im); d.text((680, y + 26), k, font=f(XB, 34), fill=GREEN)
    para(d, (680, y + 72), v, f(SB, 30), INK, 1090, 1.2); y += 175
slides.append((im, "Nella Home c'è la scheda Il mio territorio: indice europeo della qualità dell'aria con colore e parola semplice, PM10, PM2,5 e temperatura, l'ora dell'ultimo aggiornamento e la fonte. I dati arrivano da Open-Meteo, che distribuisce i modelli CAMS di Copernicus, senza account né chiavi. Se manca la rete, si vede l'ultima lettura salvata: l'app non inventa mai un numero."))

# 4 — Questions from data, not invented
im = light_bg(); d = ImageDraw.Draw(im)
title(d, 'Domande generate dai dati, non inventate', 'L\'intelligenza è nel collegare il numero al significato')
card(im, (110, 300, 1000, 960))
d = ImageDraw.Draw(im)
d.text((160, 340), 'Esempio di domanda di oggi', font=f(SB, 30), fill=(80, 105, 92))
para(d, (160, 400), 'A Schio il PM10 adesso è 5,5 µg/m³. Rispetto al limite UE giornaliero di 50 µg/m³ è…', f(XB, 40), INK, 790)
opts = [('Sotto il limite', True), ('Sopra il limite', False), ('Esattamente al limite', False)]
y = 610
for o, ok in opts:
    d.rounded_rectangle((160, y, 950, y + 80), 22, fill=(214, 240, 222) if ok else (243, 245, 244), outline=(27, 127, 76) if ok else (215, 222, 218), width=3)
    d.text((195, y + 40), o, font=f(SB, 32), fill=INK, anchor='lm')
    if ok: d.text((905, y + 40), 'giusta', font=f(XB, 28), fill=GREEN, anchor='rm')
    y += 100
d.text((160, 905), 'Fonte: Open-Meteo / CAMS Europe · dato delle 01:00', font=f(RG, 26), fill=(90, 110, 100))
cards = [('Risposta calcolata', 'La risposta giusta viene dal dato, non da un modello che "ricorda"'),
         ('Fonte e ora sempre visibili', 'Ogni domanda cita la fonte e l\'ora della misura'),
         ('100 domande verificate', 'Oltre ai dati live, 100 domande con fonti aperte una per una')]
y = 300
for h, b in cards:
    card(im, (1060, y, 1810, y + 200), WHITE, 28)
    d = ImageDraw.Draw(im); d.text((1100, y + 30), h, font=f(XB, 36), fill=GREEN)
    para(d, (1100, y + 88), b, f(SB, 29), INK, 670, 1.2); y += 230
slides.append((im, "Abbiamo scelto di non far inventare le domande a un modello che cerca sul web: per un pubblico giovane il rischio di fatti sbagliati è troppo alto. Le domande del territorio sono generate dai numeri reali, e la risposta giusta è calcolata. Ogni domanda mostra fonte e ora. In più l'app ha 100 domande con fonti verificate, una per una."))

# 5 — Action and community
im = light_bg(); d = ImageDraw.Draw(im)
title(d, 'Dall\'informazione all\'azione', 'Piccoli gesti, misurati e premiati')
tips = [('Aria buona', 'Vai a scuola in bici o a piedi', (56, 160, 90)),
        ('Aria pesante', 'Niente sport intenso all\'aperto, mezzi pubblici, non bruciare foglie', (214, 120, 20)),
        ('Piove', 'Raccogli l\'acqua piovana per le piante', (29, 113, 184)),
        ('Fa freddo', 'Chiudi bene le finestre: risparmi energia', (110, 80, 200))]
for i, (h, b, c) in enumerate(tips):
    x = 110 + (i % 2) * 560; y = 300 + (i // 2) * 330
    card(im, (x, y, x + 520, y + 290))
    d = ImageDraw.Draw(im); d.rounded_rectangle((x + 40, y + 40, x + 300, y + 100), 30, fill=c)
    d.text((x + 170, y + 70), h, font=f(XB, 30), fill=WHITE, anchor='mm')
    para(d, (x + 40, y + 130), b, f(SB, 32), INK, 440)
d.rounded_rectangle((1300, 300, 1810, 920), 40, fill=GREEN)
d.text((1555, 380), '"L\'ho fatto!"', font=f(XB, 52), fill=YELLOW, anchor='mm')
para(d, (1350, 450), 'Un tocco al giorno: piccola ricompensa, mai punizioni.', f(SB, 34), WHITE, 420)
para(d, (1350, 620), 'Più rifiuti nella stanza se il giocatore rischia di non tornare: il gioco richiama gentilmente all\'azione.', f(SB, 30), WHITE, 420)
slides.append((im, "Dallo stesso dato nasce un consiglio pratico, diverso ogni giorno. Il ragazzo lo mette in pratica e tocca L'ho fatto: una piccola ricompensa, una volta al giorno, senza punizioni. Anche il ritmo del gioco è legato al comportamento: i rifiuti compaiono nella stanza più spesso quando il punteggio di ritorno dice che il giocatore sta perdendo l'abitudine."))

# 6 — What's built
im = gradient((20, 70, 50), (27, 127, 76)); d = ImageDraw.Draw(im)
title(d, 'Cosa funziona già', 'App Android completa, testata', color=WHITE)
stats = [('100', 'domande con fonti verificate'), ('3', 'comuni con dati live'), ('25', 'accessori, 6 rarità'),
         ('380+', 'test automatici'), ('0', 'account o dati inviati'), ('200%', 'testo leggibile, screen reader')]
for i, (n, l) in enumerate(stats):
    x = 110 + (i % 3) * 580; y = 300 + (i // 3) * 330
    tile = Image.new('RGBA', (W, H), (0, 0, 0, 0)); ImageDraw.Draw(tile).rounded_rectangle((x, y, x + 540, y + 290), 36, fill=(255, 255, 255, 38)); im.alpha_composite(tile)
    d = ImageDraw.Draw(im); d.text((x + 50, y + 40), n, font=f(XB, 110), fill=YELLOW)
    para(d, (x + 50, y + 190), l, f(SB, 34), WHITE, 450)
slides.append((im, "Non è un prototipo di schermate: è un'app Android completa, con onboarding, quiz, pulizia della stanza, pet che cresce, armadio, introduzione in stile videogioco, modalità demo, giorno e notte, e ora i dati live del territorio. Più di 380 test automatici. Nessun account, nessun dato inviato: tutto resta sul telefono. Pensata per l'accessibilità: testo al 200 per cento e screen reader."))

# 8 — Try it
im = gradient((126, 214, 223), (46, 158, 106)); d = ImageDraw.Draw(im)
for k in range(24): sparkle(d, (k * 523) % W, (k * 331) % H, 6 + (k * 7) % 12)
qr = qrcode.QRCode(border=2, box_size=14); qr.add_data(DL); qr.make(fit=True)
q = qr.make_image(fill_color='#173A2B', back_color='white').convert('RGBA').resize((420, 420), Image.NEAREST)
im.alpha_composite(q, (1300, 330))
ic = ICON.resize((300, 300), Image.LANCZOS); m = Image.new('L', (300, 300), 0); ImageDraw.Draw(m).rounded_rectangle((0, 0, 299, 299), 70, fill=255); ic.putalpha(m)
im.alpha_composite(ic, (160, 200))
d = ImageDraw.Draw(im)
d.text((160, 560), 'Provala ora', font=f(XB, 96), fill=YELLOW, stroke_width=8, stroke_fill=BLUE)
para(d, (165, 700), 'Inquadra il QR code: Laiqua per Android, gratis. Video di gameplay e materiale su github.com/and-mazzaro/hackathon', f(SB, 40), WHITE, 1000)
d.text((1510, 790), 'Laiqua.apk', font=f(XB, 40), fill=WHITE, anchor='mm')
slides.append((im, "Potete provarla subito: il QR code scarica l'app per Android. Nel repository ci sono anche il video di gameplay e tutto il materiale."))

# 9 — What's next
im = light_bg(); d = ImageDraw.Draw(im)
title(d, "Cosa c'è dopo", 'Da Schio al resto del mondo')
nexts = [('Il tuo territorio, ovunque', "Con il tuo permesso l'app usa la posizione del telefono: aria e meteo di dove sei, anche dall'altra parte del mondo. La posizione non viene salvata né condivisa", (29, 113, 184)),
         ('Moda sostenibile', "Collaborazioni con brand di abbigliamento eco-friendly: capi in edizione limitata per l'armadio di Laiqua, legati a un impegno reale del brand", (63, 127, 58)),
         ('Eventi a tempo', "Accessori speciali per la Giornata della Terra, la Settimana europea per la riduzione dei rifiuti e le stagioni", (214, 120, 20)),
         ('Nuove modalità di gioco', "Specie del Pasubio con GBIF, sfide di classe e di quartiere, nuovi mini-giochi per le cure, un'AI che spiega i dati con la fonte", (160, 60, 110))]
for i, (h, b, c) in enumerate(nexts):
    x = 110 + (i % 2) * 860; y = 290 + (i // 2) * 370
    card(im, (x, y, x + 820, y + 330))
    badge(im, x + 80, y + 85, 42, c, str(i + 1), f(XB, 44))
    d = ImageDraw.Draw(im); d.text((x + 150, y + 60), h, font=f(XB, 40), fill=INK)
    para(d, (x + 50, y + 150), b, f(SB, 30), (90, 66, 48), 720)
slides.append((im, "Cosa c'è dopo. Primo: il territorio ovunque. Con il permesso dell'utente l'app userà la posizione del telefono per mostrare l'aria e il meteo di dove si trova, anche all'estero: la fonte dei dati copre tutto il mondo, e la posizione non viene salvata né condivisa. Secondo: collaborazioni con brand di moda sostenibile, che portano capi in edizione limitata nell'armadio di Laiqua, legati a un impegno reale del brand. Terzo: eventi a tempo con accessori speciali, per esempio per la Giornata della Terra. Quarto: nuove modalità di gioco, come le specie del Pasubio con i dati GBIF, le sfide di classe e di quartiere e un'AI che spiega i dati citando sempre la fonte."))

prs = Presentation(); prs.slide_width = Emu(12192000); prs.slide_height = Emu(6858000)
blank = prs.slide_layouts[6]
for i, (im, notes) in enumerate(slides, 1):
    p = f'{OUT}/slide_{i:02d}.png'; im.convert('RGB').save(p, optimize=True)
    s = prs.slides.add_slide(blank)
    s.shapes.add_picture(p, 0, 0, width=prs.slide_width, height=prs.slide_height)
    s.notes_slide.notes_text_frame.text = notes
prs.save(f'{OUT}/Laiqua_slide_aggiornate.pptx')
print('ok', len(slides), 'slides')
