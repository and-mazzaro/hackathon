# Laiqua — materiale per la presentazione

## Scarica l'app (Android)

| File | Per chi |
|---|---|
| [**Laiqua.apk**](https://github.com/and-mazzaro/hackathon/raw/main/presentation%20material/Laiqua.apk) (21 MB) | Quasi tutti i telefoni Android degli ultimi anni (64 bit) |
| [Laiqua-telefoni-meno-recenti.apk](https://github.com/and-mazzaro/hackathon/raw/main/presentation%20material/Laiqua-telefoni-meno-recenti.apk) (19 MB) | Telefoni Android vecchi (32 bit), se il primo file non si installa |

Oppure inquadra il QR code in `art/qr_download_laiqua.png` (porta a `Laiqua.apk`).

Come installarla:
1. Apri il link dal telefono e scarica il file.
2. Android chiede di consentire l'installazione da "origini sconosciute" per il browser: consentila solo per questa installazione.
3. Apri `Laiqua.apk` e tocca **Installa**.

Note: è una build di prova per la presentazione, firmata con la chiave di sviluppo (non è sul Play Store). iOS non è disponibile
(nessun Mac per compilare e firmare). Tutti i dati restano sul telefono, senza account.

## Video di gameplay (2 minuti)

`Laiqua_gameplay_trailer.mp4` — 1920×1080, 30 fps, 1:59, con musica. Stile trailer da console portatile (ispirato ai trailer
Pokémon del periodo DS): logo che "esplode" sui raggi, cartelli a schermo intero tra le scene, testi grandi gialli con bordo
blu, tagli con flash bianco, musica chiptune.

Scaletta:

| Tempo | Scena |
|---|---|
| 0:00 | Titolo: icona e logo LAIQUA |
| 0:04 | Introduzione in stile Pokémon con Laiqua che parla |
| 0:16 | Cartello "IMPARA GIOCANDO!" · scelta dei temi |
| 0:26 | "Gioca subito": quiz con fonti verificate, 5 su 5 |
| 0:42 | Cartello "RICICLA!" · rifiuti nella stanza e pulizia, 8 su 8 |
| 0:58 | Livello 2 e biglietto premio |
| 1:04 | Cartello "SI SCHIUDE!" · nasce Laiqua |
| 1:15 | "Prepara la pappa", il mini-quiz per dare da mangiare |
| 1:25 | Cartello "ARMADIO!" · ruota dei premi, maschera e bandana |
| 1:40 | Giorno, tramonto e notte nella stanza |
| 1:48 | Finale con QR code per scaricare l'app |

Il gameplay è registrato davvero sull'emulatore Android (Pixel 7) con la build di rilascio, partendo da un'installazione
pulita, e accelerato in montaggio. La musica è stata generata da codice (`tools/music.py`), quindi non ha problemi di licenza.

## Altro materiale

- `art/laiqua_icon_1024.png` — icona dell'app (1024 px), per slide e locandine
- `art/laiqua_otter_trasparente.png` — Laiqua a figura intera su sfondo trasparente (disegnata dal codice dell'app)
- `art/laiqua_design_originale.jpg` — il disegno di partenza della lontra
- `art/qr_download_laiqua.png` — QR code per scaricare l'app
- `screenshots/` — schermate reali dall'emulatore (introduzione, Impara, stanza di notte con i rifiuti, armadio, risultati)
- `tools/` — gli script usati per il video: `trailer.py` (montaggio con Pillow e ffmpeg), `music.py` (musica chiptune),
  `answer.py` (risposte automatiche durante la registrazione)

## Rifare il video

Servono Python con `pillow`, `numpy`, `qrcode` e `imageio-ffmpeg`, le registrazioni grezze (`adb shell screenrecord`) in
`<cartella>/video/raw/` e il rendering della lontra (`flutter test test/tools/render_app_icon_test.dart` con
`ECOQUEST_RENDER_DIR=<cartella>/icon`). Poi:

```
python tools/music.py <cartella>/video/build/music.wav 121
python tools/trailer.py <cartella> <repo> Laiqua_gameplay_trailer.mp4 <link di download>
```
