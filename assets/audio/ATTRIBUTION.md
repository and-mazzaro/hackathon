# Audio attribution

Every audio file in `assets/audio/` must be listed here with its source and licence BEFORE it is committed.
Files with an unknown licence stay out of the app (see `AUDIO_AUDIT.md`).

## Kenney sound packs — CC0 (public domain)

Source packs, downloaded from kenney.nl on 2026-10-22 (each zip contains a `License.txt`):

| Pack | Page | Licence text in the pack |
|------|------|--------------------------|
| Interface Sounds 1.0 | https://kenney.nl/assets/interface-sounds | "License: (Creative Commons Zero, CC0) … free to use in personal, educational and commercial projects" |
| Music Jingles | https://kenney.nl/assets/music-jingles | "License (Creative Commons Zero, CC0) … Credit (Kenney or www.kenney.nl) would be nice but is not mandatory" |
| RPG Audio | https://kenney.nl/assets/rpg-audio | same CC0 text |
| Impact Sounds 1.0 | https://kenney.nl/assets/impact-sounds | same CC0 text |
| Digital Audio | https://kenney.nl/assets/digital-audio | same CC0 text |

Credit is not required by CC0; we credit "Sounds by Kenney (www.kenney.nl), CC0" anyway.

How the files were made: the original `.ogg` files were decoded in a browser (Web Audio), mixed where noted,
pitch-shifted where noted, peak-normalised to the level in the table, trimmed (silence below −50 dB, 10 ms
fade-out) and saved as WAV, mono, 44.1 kHz, 16 bit. WAV instead of OGG because iOS cannot play OGG.
Changes to CC0 material need no permission.

| App file | Sound id | Made from (pack: file) | Processing | Peak |
|----------|----------|------------------------|------------|------|
| `ui/tap.wav` | `ui.tap` | Interface Sounds: `click_002` | — | −9 dB |
| `ui/unavailable.wav` | `ui.unavailable` | Interface Sounds: `bong_001` | — | −8 dB |
| `quiz/question.wav` | `quiz.question` | Interface Sounds: `maximize_008` | — | −6 dB |
| `quiz/correct.wav` | `quiz.correct` | Interface Sounds: `confirmation_001` | — | −3 dB |
| `quiz/not_quite.wav` | `quiz.incorrect` | Interface Sounds: `question_004` | — | −6 dB |
| `quiz/streak_1.wav` `quiz/streak_2.wav` `quiz/streak_3.wav` `quiz/streak_4.wav` `quiz/streak_5.wav` | `quiz.streak.1` … `5` | Interface Sounds: `glass_001` | pitch-shifted to C5 D5 E5 G5 A5 (rate 0.545 / 0.612 / 0.687 / 0.817 / 0.917) | −3 dB |
| `quiz/complete.wav` | `quiz.complete` | Music Jingles: `jingles_PIZZI10` | — | −3 dB |
| `rewards/xp.wav` | `reward.xp` | Interface Sounds: `glass_002` | — | −5 dB |
| `rewards/coins.wav` | `reward.coins` | RPG Audio: `handleCoins` | — | −4 dB |
| `rewards/level_up.wav` | `level.up` | Music Jingles: `jingles_STEEL02` | — | −1 dB |
| `recycling/pick_up.wav` | `recycling.select` | RPG Audio: `handleSmallLeather` | — | −8 dB |
| `recycling/correct.wav` | `recycling.correct` | Impact Sounds: `impactSoft_medium_000` + Interface Sounds: `glass_003` | thud, ding 70 ms later | −3 dB |
| `recycling/not_quite.wav` | `recycling.incorrect` | Impact Sounds: `impactSoft_medium_001` | — | −6 dB |
| `recycling/combo.wav` | `recycling.combo` | Interface Sounds: `confirmation_004` | — | −2 dB |
| `recycling/complete.wav` | `recycling.complete` | Music Jingles: `jingles_STEEL10` | — | −3 dB |
| `pet/feed.wav` | `pet.feed` | RPG Audio: `chop` + Digital Audio: `pepSound3` | crunch, happy chirp 160 ms later | −4 dB |
| `pet/play.wav` | `pet.play` | Digital Audio: `pepSound5` | — | −4 dB |
| `pet/bath.wav` | `pet.bath` | Interface Sounds: `glass_004` | — | −6 dB |
| `pet/egg_pat.wav` | `pet.egg_pat` | RPG Audio: `cloth1` | — | −6 dB |
| `pet/hatch.wav` | `pet.hatch` | Impact Sounds: `impactGlass_light_000`, `impactGlass_light_002` + Digital Audio: `pepSound3` | crack, crack at 140 ms, chirp at 420 ms | −2 dB |
| `pet/grow.wav` | `pet.grow` | Digital Audio: `highUp` + `pepSound5` | rising sweep, chirp at 340 ms | −2 dB |

## Other sources

| App file | Sound id(s) | Original name | Source | Author / channel | Licence | Checked on | Used |
|----------|-------------|---------------|--------|------------------|---------|------------|------|
| `ambience/sea_waves.mp3` | `ambience.sea` | `Sea Waves - Sound Effect.mp3` (from the team archive `Effetti.zip`, MP3 192 kbps, 13 s) | https://www.youtube.com/watch?v=B3ZbsOhNTas | "Sound Effects" (YouTube channel `UCaDuguIZW7Fwo1b43UWQejQ`) | Creative Commons Attribution (YouTube CC BY: "riutilizzo consentito") | 2026-10-22 | Yes, unchanged copy |

Credit text for the app's credits screen / store listing:

> Sounds by Kenney (www.kenney.nl), CC0.
> "Sea Waves - Sound Effect" by Sound Effects (YouTube), licensed under Creative Commons Attribution.

Open points for the team:
- Sounds were chosen by measuring them (length, pitch direction, brightness), not by ear: listen to all of them
  on a phone and swap any that feel wrong (the source packs have many alternatives).
- The YouTube channel may have re-uploaded someone else's recording. Before a public store release, prefer a
  sea ambience whose original author is clear.
- Check by ear that `sea_waves.mp3` loops without a click.
- No background music yet (`music.main`): Kenney has no CC0 music loop pack.

Not included, and why: `Pokemon Level Up - Sound Effect (HD).mp3` (copyrighted game audio),
`Game Over Sound Effect.mp3` (empty file), `Wooden Treasure Chest Opening  Free Sound Effect.mp3`,
`Missione riuscita.mp3`, `Completata missione.mp3` (licence unknown).
