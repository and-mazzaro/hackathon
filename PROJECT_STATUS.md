# EcoQuest — Project Status

**Current milestone:** M8 — Cosmetics (shop, reward roll, wardrobe) → **done on Android**, on branch `m8-cosmetics`,
not merged/pushed yet (iOS untested, no Mac)
**Done before:** M1 shell (`39e8b3d`) · M2 saving (`d7c3454`) · M3 onboarding (`6695199`) · M5 quiz (`11f752a`) ·
M6 pet (`e7b7281`) · M7 cleanup (`8be652d`) · M8 cosmetics (`1d36120`, `686dfac`, `0ca3b01`)
**Repository:** https://github.com/and-mazzaro/hackathon (`origin`, branch `main`; pushed up to M7 on 2026-10-22).
Teammates need to be added as collaborators by and-mazzaro before they can push.
**Audio:** Milestones 1 (audit, `AUDIO_AUDIT.md`), 2 (infrastructure, `be6eace`) and 3 (game events wired) done.
25 Kenney CC0 effects + the sea ambience are in; only background music is missing. Next: Milestone 4 (settings screen).
**Next milestone:** M10 — Comeback Score (spec in `MILESTONE_10_RETENTION.md`; its decisions start at D54 now, since
M8 and the otter used D45–D53) or M9 recommendations. Read-aloud (flutter_tts) is a small follow-up.
**Agent skills:** Matt Pocock's engineering + productivity skills (github.com/mattpocock/skills, MIT, commit `5beb35b`)
are in `.claude/skills/` (commit `2b337f0`, on `main`, not pushed yet), e.g. `/grill-me`, `/to-spec`, `/to-tickets`,
`/tdd`, `/diagnosing-bugs`, `/handoff`. Installed by copying, since this PC has no Node.js; update by re-copying.
Their `code-review` skill has the same name as Claude Code's built-in one.

## Environment (lead PC)
| Item | Status |
|------|--------|
| PC | Windows 11, 15 GB RAM. Smart App Control turned **off** by the owner (it blocked Flutter's `impellerc.exe`). No Mac → **iOS untested** |
| Git | MinGit 2.56.0 portable in `C:\src\mingit` (on user PATH) |
| Flutter | 3.47.7 stable, Dart 3.13.5, in `C:\src\flutter` (on user PATH), analytics disabled |
| Java | Oracle JDK 21 (used by Gradle and the Android tools) |
| Android SDK | `C:\src\android-sdk` (`ANDROID_HOME`): cmdline-tools 23, platform-tools, emulator, platform 36, build-tools 36.0.0, NDK 28.2.13676358, system image android-36 google_apis x86_64 |
| Emulator | AVD `EcoQuest_Pixel_7` (Pixel 7, Android 36), WHPX hardware acceleration |
| Project path | `C:\Users\franc\Desktop\hackathon\ecoquest` — ASCII only on purpose: the Android Gradle plugin rejects non-ASCII paths such as `hackathì` on Windows |

### Setup tips for teammates (Windows)
- Keep the Flutter SDK, Android SDK and project in paths **without spaces or accented letters**.
- If Smart App Control is on, Flutter builds fail with "Application Control policy has blocked" → owner must switch it off.
- `sdkmanager.bat` splits package names at `;` when called from PowerShell. Install packages with a package file:
  write one package per line into `packages.txt`, then `sdkmanager --package_file=packages.txt`.
  Gradle's automatic NDK download hits the same bug → install `ndk;28.2.13676358` this way before the first build.
- The warning "SDK XML version 4 was encountered" during builds is harmless.

## Decisions
| # | Decision | Status |
|---|----------|--------|
| D1 | Flutter + Dart, one codebase for Android and iOS | Accepted |
| D2 | Riverpod 3 (plain `Notifier`, no code generation) | Accepted |
| D3 | go_router 18, `StatefulShellRoute` bottom tabs: Home / Impara / Cucciolo / Profilo | Accepted |
| D4 | Versioned JSON save file behind a `SaveRepository` interface (safe writes, version handling, load/save tests) | Accepted |
| D5 | All game rules in pure Dart (`lib/domain/rules`), unit-tested without UI | Accepted |
| D6 | Every reward claim has a unique id; already-seen ids are ignored | Accepted |
| D7 | Educational content in JSON assets with `source`, `sourceUrl`, `verifiedOn` | Accepted |
| D8 | Accessibility: TalkBack/VoiceOver via `Semantics`, tap alternative for drag, optional read-aloud (flutter_tts) | Accepted |
| D9 | Versions chosen by `flutter pub add`, never by hand | Accepted |
| D10 | UI in **Italian** via `gen-l10n` (`lib/l10n/app_it.arb`); English = add `app_en.arb` later. Code/docs in English | Accepted |
| D11 | Import **`package:material_ui/material_ui.dart`**, never `package:flutter/material.dart`. Material moved out of the framework in 2026 and go_router already uses `material_ui`; mixing both gives two separate Theme systems | Accepted |
| D12 | Use `GlobalMaterialLocalizations.delegates` from `material_ui` + `AppLocalizations.delegate` (the generated `AppLocalizations.localizationsDelegates` still points at the old framework library) | Accepted |
| D13 | `web/` folder is a **developer preview only**, not a supported platform; it may stop working when we add file-based saving | Accepted |
| D14 | Font: Nunito (SIL OFL 1.1, bundled in `assets/fonts`, works offline) | Accepted |
| D15 | Each balance/stat/image that the screen reader should focus on its own uses `Semantics(container: true, ...)`; otherwise its label merges into a neighbour | Accepted |
| D16 | Only **total XP** is saved; the level is always computed (`levelForTotalXp`), so level and XP can never disagree | New (M2) |
| D17 | All game changes go through `GameController`; rewards only via `claimReward(claimId, reward)`, claim ids `feature:uniqueId`, each paid once (also across restarts) | New (M2) |
| D18 | Save file = `{version, savedAt, state}` JSON in the app support folder; write temp → copy backup → atomic rename; unreadable file → backup; both broken → error screen with "Riprova"/"Ricomincia da capo"; newer version → refused, never overwritten | New (M2) |
| D19 | Saved ids are stable strings (`EcoTopic.id`, `PetStage.id`, item ids), never enum indexes; new fields need a default in `fromJson` | New (M2) |
| D20 | Riverpod automatic retry is switched off (`ProviderScope(retry: ...)`): re-reading a broken save does not help | New (M2) |
| D21 | `EconomyConfig` holds every balancing number (first guesses, to tune in play-tests) | Accepted |
| D22 | Navigation to/from onboarding is decided only by the router `redirect` (re-checked on every game change). Screens never navigate there themselves | New (M3) |
| D23 | Half-finished onboarding answers are temporary screen state; nothing is saved until "Fine"/"Salta" | New (M3) |
| D24 | Profile interest changes save immediately (no "save" button); at least one interest is kept by the UI | New (M3) |
| D25 | Nickname cleaned in one place (`normalizeNickname`, max 20 visible characters), applied inside `GameController` | New (M3) |
| D26 | Topic/age labels and icons live in the UI layer (`profile_labels.dart`); the domain only knows stable ids | Accepted |
| D27 | Quiz content = data: `assets/content/quiz_questions_it.json`, every question with source name, URL, `verifiedOn` and a short `sourceExcerpt` for reviewers; checked by `test/content/quiz_content_test.dart` | New (M5) |
| D28 | Quiz = 5 questions, easy → hard; topic quiz = only that topic; personal quiz prefers interests, avoids the last 30 questions shown; when it must repeat, it takes the ones seen longest ago (rotation), and shuffles within each difficulty | New (M5), rotation added |
| D29 | Quiz XP: 10 per first-time correct answer, 2 for a question already learned, +5 for each correct answer in a row after the first; quizzes give XP only (coins come from recycling/games) | New (M5) |
| D30 | `QuizSession` (plain Dart) runs a quiz; `completeQuiz` saves XP + learning stats in one write, once per session id | New (M5) |
| D31 | Randomness through `randomProvider`, so tests use a fixed seed | Accepted |
| D32 | Pet needs drop per hour (4/3/2) but never below 20; the egg has no needs; decay is CALCULATED (`petNow`) when shown, never saved just by time passing; clock going backwards changes nothing | New (M6) |
| D33 | Pet stages follow the player level (hatch 2, young 5, adult 10): learning makes the pet grow. Growing is a player action ("Fai schiudere" / "Fai crescere") | New (M6) |
| D34 | Care (feed/play/bath, +30) is free and gives no XP/coins (cannot be farmed); each completed quiz gives the pet +15 happiness in the same save write | New (M6) |
| D35 | Looping animations go through `animationsEnabledProvider` (off in tests) and respect the phone's "remove animations" setting | Accepted |
| D36 | Room Cleanup: 5 bins (plastica e metalli, carta e cartone, organico, vetro, indifferenziato) with GENERAL national guidance, a visible "rules differ by Comune" note and a per-item `localNote` where municipalities differ | New (M7) |
| D37 | Sorting by tap (item → bin, screen-reader friendly) AND drag that starts at once (no long press: players did not discover it and a plain drag only scrolled); a wrong bin teaches (right bin + why) and never blocks or costs anything | New (M7) |
| D38 | Coins per round: 2 per first-time correct item, 1 for known items, +3 every 3 in a row; +10 XP for ≥ 75% right; paid once per round (`sort:roundId`) with stats and pet cleanliness (+25) in one write | New (M7) |
| D39 | Waste content = data: `assets/content/waste_items_it.json` (name, icon key, bin, difficulty, explanation, localNote, source, excerpt), checked by `test/content/waste_content_test.dart` | New (M7) |
| D40 | Audio with **`audioplayers`** only, hidden behind `AudioBackend` (`lib/core/audio/`); screens ask for sounds by meaning (`SoundId`), never by file, and only in event handlers (never in `build`) | New (Audio 2) |
| D41 | Only sounds with a known licence are bundled, each listed in `assets/audio/ATTRIBUTION.md`; ids without a file stay silent. Tests check catalog ↔ files ↔ pubspec ↔ attribution | New (Audio 2) |
| D42 | 3 channels (music / effects / pet + ambience) with volumes 0–100 + master mute, saved in `GameState.audio` (defaults 35 / 80 / 60 for old saves) via `GameController.updateAudioSettings` | New (Audio 2) |
| D43 | "Ambient" audio session: mixes with the player's own music (no audio focus on Android), follows the iOS silent switch. Loops pause in the background and resume on return (unless muted); short sounds are never replayed later | New (Audio 2) |
| D44 | Important sounds (level-up, hatch/grow, quiz/cleanup complete) duck the music to 30% for 0.5 s, back in 0.3 s; the same sound within 80 ms plays once; a failing file is logged and skipped, never crashes (`AudioTiming` holds the numbers) | New (Audio 2) |
| D45 | Cosmetics = data: `assets/content/cosmetics_it.json` (id, name, slot `head`/`face`/`neck`/`paws`, rarity `common`/`uncommon`/`rare`/`epic`/`legendary`/`mythic`, drawing key, ARGB colour), checked by `test/content/cosmetic_content_test.dart`. Items are drawn in code (`CosmeticDrawing` in `cosmetic_art.dart`), no image files | Updated (otter) |
| D46 | Shop sells common (60 coins), uncommon (100) and rare (160) items and reward tickets (100 coins); epic, legendary and mythic only from the roll. Prices, odds and refunds are per-rarity maps in `EconomyConfig` | Updated (otter) |
| D47 | Reward roll: rarity first with the odds shown on screen (40/25/17/10/6/2 %), then one item of that rarity, equally likely (`pickRolledCosmetic`, `randomProvider`). A rarity with no items falls back to a more common one. A test checks the odds add up to 100 | Updated (otter) |
| D48 | Duplicates can come out of the roll and are paid back in coins (15/25/40/60/90/150 by rarity); the rule is written on the roll card before rolling | Updated (otter) |
| D49 | Every level gained pays `ticketsPerLevelUp` (1) ticket inside `claimReward`, in the same write, and is part of `ClaimResult.reward` (result screens say so); a re-claimed id pays nothing | New (M8) |
| D50 | Spending (`buyTicket`, `buyItem`, `rollCosmetic`) and `equip`/`unequip` go through `GameController`; the screen passes the catalog/item in, the controller never loads content. Not enough coins / not for sale / already owned → nothing saved | New (M8) |
| D51 | One item per slot (`Inventory.equippedBySlot`). Head items replace the green leaf, neck items the green bandana, face items sit on the eyes, paws items are held between the front paws. Ids not in the content any more are ignored when drawing (`petOutfitProvider`). The egg can own items but shows them only after hatching | Updated (otter) |
| D52 | Wardrobe = full-screen route `/wardrobe`, opened from a hanger button in the Pet room (no extra row above the care buttons) and from a Home card; bottom tabs unchanged (D3) | New (M8) |
| D53 | The pet is an otter (design: `docs/art/otter_reference.jpg`), drawn in code by `OtterPainter` in the reference picture's pixel coordinates (`OtterGeometry`: anchors per slot, pivots; `OtterPalette`). Separate layers (tail, body, paws, neck, head group) and an `OtterPose` (headTilt, tailSwing, eyesOpen, earTwitch, bodyLift) so it can be animated later; cosmetics are drawn in the same coordinates | New (otter) |

## Implemented (M1)
- App entry point, `ProviderScope`, router in a provider (fresh router per test)
- Theme tokens: `eco_colors.dart` (all text pairs ≥ 4.5:1 WCAG AA), `eco_spacing.dart`, `app_theme.dart`
- Bottom-tab shell; Android back on a non-Home tab returns to Home
- Reusable widgets in `lib/core/widgets/`: `EcoCard`, `EcoButton`, `StatBar`, `CurrencyChip`, `ComingSoonView`
- Home screen: level/XP, coins/tickets, drawn room + egg, 3 need bars, 2 activity shortcuts
- Learn / Pet / Profile: "In arrivo" placeholders

## Implemented (M2)
- Models in `lib/domain/models/`: `GameState` = `PlayerProfile` (nickname, age range, interests, onboarding flag),
  `PlayerProgress` (total XP, coins, tickets, claimed reward ids), `PetState` (stage, 3 needs 0–100), `Inventory`; `Reward`
- Rules in `lib/domain/rules/`: `EconomyConfig`, `levelForTotalXp` (100 XP for level 2, +50 per level)
- Saving in `lib/data/save/`: `SaveRepository` interface, `SaveFormat` (version 1 + migration hook),
  `JsonFileSaveRepository` (Android/iOS), `InMemorySaveRepository` (tests, web preview)
- `GameController` (`lib/domain/game_controller.dart`): `claimReward`, `completeOnboarding`, `updateInterests`,
  `startFresh`, `levelInfo`; planned feature methods listed in its doc comment
- Home shows the saved game, with loading and error states (`SaveErrorView`)
- New player: level 1, 0 coins, 1 welcome ticket, pet needs 80
- **DEBUG ONLY** button on Home "Ricompensa di prova" (+30 XP, +15 coins), hidden in release builds by `kDebugMode`.
  Remove it once real activities exist.

## Implemented (M3)
- Onboarding route `/onboarding` (no tabs), 3 steps with progress bar, on-screen back arrow (iOS) and Android back:
  welcome + privacy note → interests (≥ 1 required, counter) → optional nickname + age range ("Fine" / "Salta")
- Router redirect: unfinished players → onboarding; finished players never see it again; "Ricomincia da capo" → onboarding
- Profile tab: nickname/"Ospite", level, age range; edit sheet for nickname + age (Salva/Annulla);
  interest tiles saved immediately; "I tuoi dati" privacy card
- Shared widgets: `GameStateView` (loading/error/data for any screen), `EggArt`, `InterestPicker`, `AboutYouFields`
- `GameController.updateProfileDetails`; nickname cleaning in `profile_rules.dart`
- Screen readers: tiles read as checked/not checked, step changes announced ("Passo 2 di 3"), field hints and counters

## Implemented (M5)
- Learn hub: "Quiz per te" (mixed, from interests) + one quiz per topic, interests first with a "Per te" badge,
  question counts, per-topic stats, quizzes completed; reorders immediately when interests change
- Quiz screen (full screen, route `/quiz?topic=...`): 5 questions easy → hard, shuffled options, difficulty and
  streak chips, right/wrong with icons + text (not colour only), explanation, source sheet (name, URL, date),
  exit confirmation (X, Android back) that saves nothing; Home "Quiz del giorno" opens the personal quiz
- Result screen: score, XP, level-up banner, best streak, newly learned, note about reduced XP for repeats,
  "Gioca ancora" / "Chiudi"
- `QuizSession`, `pickQuizQuestions`, `scoreQuiz`, `LearningProgress` (stats per topic, learned ids, last 20 seen)
- **Content: 50 questions in Italian, 5 per topic (difficulty 1,1,2,2,3)**, researched by two AI research agents
  that opened every source page (ISPRA, CoReVe, CIAL, Commissione europea, ONU, NASA, NOAA, EPA, FAO, IUCN, CBD,
  EEA, OMS, IEA, IRENA, USGS, Water Footprint Network, Fraunhofer ISE, Normattiva, ...). Reviewed by the lead
  agent: one duplicate replaced; three extra explanation claims re-checked on the pages (all supported).

## Implemented (M6)
- Pet tab: name + stage/mood chips, animated room (idle bob, egg wobble, bounce + floating icon on care,
  pop-in when hatching/growing), live message for screen readers, need bars, care buttons, kind hint when sad,
  "next growth at level N"
- Egg: hatch progress ("ti mancano N XP" / "è pronto a schiudersi"), "Accarezza l'uovo", hatch sheet with
  optional name (default "Ecò")
- Drawn pet (`PetArt`): face follows mood, dirt spots when cleanliness < 40, size/colour/leaves by stage
- Room plants: 1 + one more every 2 levels (max 4 in total)
- Home: same `PetView`, need bars after hatching, egg progress before; quiz result says when the pet got happier
- `pet_rules.dart`: `petNow`, `moodOf`, `applyCare`, `petAfterQuiz`, `nextStage`, `roomPlants`;
  `GameController.careForPet` / `evolvePet`; `totalXpForLevel` in progression

## Implemented (M7)
- Room Cleanup (full screen, route `/cleanup`), opened from the Home card "Pulisci la stanza" and from the Pet tab
- 8 items per round: avoids the last 24 shown, always at least one tricky item (difficulty 3)
- Tap an item (selected state read by screen readers) then a bin, or drag it straight onto a bin (swiping
  next to the items still scrolls the page);
  a bin tapped with nothing selected explains what to do
- Feedback card after every item: right/wrong with icon + text, the right bin, why, the local note when rules
  differ, and the source sheet; combo chip ("Combo xN"); a wrong item still leaves the room (no blocking)
- Result: score, coins, XP, level-up, best combo, newly learned, "the pet is cleaner too", repeat note;
  exit dialog (X, Android back) that saves nothing
- With 200% text, bins and "Vedi il risultato" scroll with the page instead of being pinned at the bottom
- `CleanupRound` (plain Dart), `pickCleanupItems`, `scoreCleanup`, `petAfterCleanup`, `RecyclingProgress`
  (rounds, sorted, correct, learned ids, last 24 seen); `GameController.completeCleanup`
- `showSourceSheet` moved to `lib/core/widgets/source_sheet.dart`, shared by quiz and cleanup
- **Content: 24 items** (plastic/metal 5, paper 5, organic 4, glass 4, residual 6; difficulty 8/9/7), researched by
  an AI agent that opened every page: COREPLA, CIAL, Comieco, CoReVe, CIC (national consortia) and, for three items
  with no national page, the Comune di Gaeta waste dictionary. The lead agent re-fetched six of the pages to
  spot-check the excerpts (all found) and removed explanation details the pages did not support (caps left on,
  "no rinsing", "recyclable forever", "a few pieces ruin a lot of glass").

## Implemented (Audio Milestone 1–2)
- Audit of the team archive `Effetti.zip` in `AUDIO_AUDIT.md`: 6 files, only "Sea Waves" (YouTube CC BY) cleared;
  Pokémon level-up (copyrighted) and an empty file rejected; 3 files with unknown licence left out
- `assets/audio/ambience/sea_waves.mp3` (unchanged copy) + `assets/audio/ATTRIBUTION.md`
- `lib/core/audio/`: `SoundId` (27 semantic ids with channel, ducking, loop flag), `AudioCatalog` (id → file;
  today only `ambience.sea`), `AudioService` (settings, mute, ducking, cooldown, loops per channel, background
  pause, error-proof), `AudioBackend` + `AudioplayersBackend` (4 shared effect players, 1 player per loop
  channel, lazy creation), `AudioBinding` (applies saved settings at start and on change; app lifecycle)
- `AudioSettings` in the save; `GameController.updateAudioSettings`
- Committed as `be6eace`

## Implemented (Audio Milestone 3 — sounds connected to the game)
- `lib/core/audio/game_sounds.dart`: pure functions choosing the sound for each event (answer + streak note,
  results, sorting, care); `AudioService.playAny` (first sound with a file: streak note → plain "correct") and
  `playSequence` (fanfare, then the reward chime 0.7 s later, never together)
- Quiz: answer checked → note climbing with the streak (C D E G A) or soft "not quite"; next question → swoosh;
  result → level-up OR "quiz complete", then XP chime. A reward already paid → no celebration
- Room Cleanup: item picked (tap or drag start) → pick-up; correct → chime, every 3rd in a row → combo chime;
  wrong bin → neutral sound; bin with nothing selected → soft "unavailable"; result → level-up OR "room clean",
  then coins
- Pet: feed / play / bath sounds after the care is saved; "already full" → soft "unavailable"; stroke the egg;
  hatch / grow (duck the music)
- Bottom tabs → soft tap
- `AmbienceLoop`: the sea waves loop only while the Pet room is really on screen (stops on other tabs, under
  full-screen pages and in the background)
- All sounds are played in event handlers, never in `build`; all feedback stays visual + screen-reader text
- **Sound files (2026-10-22):** 25 effects made from Kenney CC0 packs (Interface Sounds, Music Jingles, RPG Audio,
  Impact Sounds, Digital Audio), downloaded with the team's OK. Chosen by measuring length, pitch direction and
  brightness (not by ear), converted OGG → WAV mono 44.1 kHz in the browser (iOS cannot play OGG), peak-normalised
  per sound, streak notes pitch-shifted to C D E G A, a few mixed (sort = thud + ding, hatch = crack + crack +
  chirp). 1.1 MB in total; every file, source and processing step in `assets/audio/ATTRIBUTION.md`
- Every sound id now has a file except `music.main` (no CC0 music loop yet → no background music)

## Implemented (M8 — Cosmetics)
- **Otter redesign (2026-10-23):** the pet is now the otter from `docs/art/otter_reference.jpg`, redrawn in code
  (`lib/features/pet/otter_painter.dart`, `otter_geometry.dart`); outline, eyes, nose, ears, belly, paws and tail line up
  with the reference within a few pixels. Moods: happy (open mouth), ok (closed smile), sad (small frown, raised
  brows); dirty = mud spots; stages differ by size (adult fur slightly darker, baby head slightly bigger)
- **25 cosmetics redesigned for the otter**, six rarities, four slots: head (Foglia rossa, Foglia d'acero, Fiore di
  campo, Cappellino di ghianda, Corona di alghe, Corona di rami d'oro, **Foglia leggendaria** = mythic), face (Occhiali
  tondi, Occhiali da sole, Occhialini da nuoto, Maschera da supereroe, Monocolo d'oro), neck (Bandana rossa, Bandana
  blu, Bandana a pois, Sciarpa di lana, Papillon, Collana di conchiglie, Medaglia dell'eco-eroe), paws (Sassolino
  preferito, Conchiglia, Stella marina, Pesciolino di pezza, Perla luminosa, **Sasso arcobaleno** = mythic)
- Wardrobe shows all six odds and refunds; legendary/mythic reveals get their own heading
- Dev tools (skipped in normal runs): `ECOQUEST_RENDER_DIR=<folder> flutter test test/tools/` renders the otter in every
  mood/stage/outfit and each item over the reference picture
- First M8 version (below) had 12 items on the old leafy pet; kept for history
- Content: 12 items (head 4, face 3, neck 5; 6 common, 4 rare, 2 epic), Italian names, each drawn in code
  (flower, straw hat, party hat, crown of twigs, round glasses, sunglasses, hero mask, scarf, bow tie, bell,
  eco-hero medal, seed necklace)
- `CosmeticItem`/`CosmeticCatalog` (`lib/domain/models/cosmetic_item.dart`), `cosmetic_rules.dart` (`shopPrice`,
  `rollOdds`, `duplicateRefund`, `pickRolledCosmetic`), `Inventory.owns/add/equip/unequip`,
  `cosmeticCatalogProvider` (`lib/data/content/cosmetic_content.dart`)
- `GameController.buyTicket`, `buyItem`, `rollCosmetic`, `equip`, `unequip` (+ `PurchaseResult`, `RollOutcome`);
  level-up tickets in `_applyReward`
- Wardrobe screen (`lib/features/wardrobe/`): balances, pet preview, roll card with odds chips (one screen-reader
  item: "Probabilità: comune 60 percento, …"), duplicate rule, "Usa 1 biglietto" (disabled + reason with 0 tickets),
  "Compra un biglietto (100 monete)"; reveal sheet ("Nuovo oggetto!" / "Ce l'hai già" + refund, "Indossa ora");
  shop tiles with price and "Ti servono altre N monete"; "I miei oggetti" by slot with Indossa/Togli (toggle
  semantics); snackbars for bought / worn / taken off
- `PetArt` draws the outfit (`PetView` reads `petOutfitProvider`), so Home, Pet tab and wardrobe all show it
- Quiz and cleanup result screens add "Premio: 1 biglietto per la ruota dell'Armadio!" after a level-up
- Sounds reuse existing ids: coins on buy/refund, `reward.xp` on a new item, soft "unavailable", tap on equip

### Waste content still needing a human check
- waste_016 toothbrush, waste_017 pen, waste_023 toy cite a single municipal dictionary (Gaeta). Common practice,
  but a national or big-city source would be better. The same dictionary disagrees with Comieco on receipts and
  very greasy pizza boxes, so it is used only where no national page exists.
- waste_020 drink carton: Comieco allows paper OR plastic/metals depending on the Comune; the game says paper
  (always recycled at the paper mill) with a local note. waste_019 pizza box follows Comieco ("anche se unto").
- waste_006 banana peel: the CIC page says "scarti di cucina", it does not name fruit peels.
- Left out on purpose (sources disagree or only municipal): used tissues, baking paper, coffee grounds, tea bags,
  CDs, corks, single-use plastic plates. The `wasteIcon` map already has keys for some of them.

### Content still needing a human check (before the demo)
- Excerpts were read through a summarising web tool: open a few source pages and compare the wording.
- Dated figures that will age: biodiversity_005 (ISPRA bear estimate, summer 2025), transport_005 (EEA, 2023),
  consumption_004 (UNEP 2022 food waste), innovation_004 (IRENA, end 2021), energy_005 (IEA, −1 °C ≈ 7%).
- Industry/secondary sources: recycling_003 (CIAL's own 95% figure), transport_003 (Chalmers news article),
  energy_004 (IEA heat-pump programme site), consumption_004 (UN News, UNEP page blocked).
- climate_004: EPA gives "more than 28 times" without a time horizon (it is the usual 100-year value).

## Tests
| Check | Result |
|-------|--------|
| `flutter analyze` | ✅ No issues (2026-10-22, after M2) |
| `flutter test` — 51 tests: M1 UI/accessibility tests + level curve, JSON round-trip and defaults, file save (backup, corruption, newer version, overlapping saves, leftover temp file), controller (pay once, double tap, simultaneous claims, level-up, restart, interests keep progress, error → start fresh), Home with saved data and error screens | ✅ All pass (2026-10-22) |
| M2 on the emulator: earned 2 debug rewards → force-stop → relaunch → still 60/100 XP, 30 coins; save + backup files present in the app folder | ✅ Checked (2026-10-22) |
| `flutter test` after M3 — 75 tests (+ onboarding flow, profile editing, nickname rules, guidelines and 200% text on every onboarding step) | ✅ All pass (2026-10-22) |
| M3 on the emulator: wiped data → onboarding (2 topics, nickname, age) → Home; restart skips onboarding; profile interest change saved at once and kept after restart; save file checked | ✅ Checked (2026-10-22) |
| `flutter test` after M5 — 116 tests (+ quiz selection/scoring/session, learning stats, old saves without quiz data, completeQuiz pay-once and reduced repeat XP, full quiz UI flow, exit dialog, guidelines and 200% text on quiz + result, **content validation of the real 50-question file**) | ✅ All pass (2026-10-22) |
| `flutter test` after M6 — 147 tests (+ decay/floor/30-day absence/clock backwards, mood, care cap, growth thresholds, plants, controller care/evolve/quiz happiness, Pet tab flows: egg progress, hatch with name, dismissed sheet, feed, already-full, sad hint, guidelines and 200% text in all three states) | ✅ All pass (2026-10-22) |
| M6 visual check: pet art rendered for every stage/mood (test render), then on the emulator: Home with a hatched pet "Boss" (leaf, mood face, plants, needs 100%), save file shows stage baby + name + needs | ✅ Checked (2026-10-22); the emulator was again used by someone in parallel, so the hatch/care taps were done by hand, not by script |
| M5 on the emulator: Learn hub with real content and "Per te" order; a personal quiz played (questions easy → hard, wrong-answer feedback with correct answer + explanation); save shows 1 quiz, claim id, XP 0 → 40 | ⚠️ Partly — the emulator was being used at the same time, so the scripted run was interrupted; a clean manual play-through is still worth doing |
| `flutter test` after M7 — 182 tests (+ item picking/recent/tricky, scoring first-time/repeat/combo/XP threshold, `CleanupRound` select/deselect/wrong bin, old saves without recycling data, `completeCleanup` pay-once + pet cleanliness, cleanup UI: tap sorting, plain drag without holding (fails on the old long-press version), drop outside a bin, wrong-bin feedback with source, empty bin tap, full round saved, exit dialog, Pet tab entry, screen-reader states, guidelines, 200% text on a small phone, **content validation of the real 24-item file**) · `flutter analyze` clean | ✅ All pass (2026-10-22) |
| M7 on the emulator: Home → Pulisci la stanza → 8 real items; crystal glass into "Vetro" → "Quasi!" card with CoReVe explanation; the other 7 right → "Combo x7", result 7/8, +20 coins, +10 XP, pet cleaner; save shows 1 round, 8 sorted, 7 correct, 7 learned, `sort:` claim | ✅ Checked by script + screenshots (2026-10-22) |
| `flutter test` after Audio 2 — 209 tests (+ audio settings defaults/mute/clamping/JSON, old saves without audio, settings saved once and kept after restart, service with a fake backend and fake time: channel volumes, master mute, missing file silent, cooldown, loop not restarted, loops side by side, live volume change, background pause/resume, no replay of dropped sounds, ducking down/hold/smooth return/extension, broken file skipped; real files ↔ catalog ↔ pubspec ↔ ATTRIBUTION; app wiring: saved settings applied at start and on change, lifecycle pause/resume, nothing plays at start) · `flutter analyze` clean | ✅ All pass (2026-10-22) |
| Audio 2 on the emulator (temporary check entry point, then removed): saved settings loaded; sea loop on the pet channel + same file as music loop really play (audio_flinger: 2 active tracks, −4.4 dB = 60% and −9.1 dB = 35%, restarting every 13 s = looping); level-up effect via SoundPool started and ducked the music, back to −9.1 dB after ~1 s; missing file only logged; Home → both tracks stop, back to the app → both resume; usage `USAGE_GAME`, no audio focus taken | ✅ Checked (2026-10-22) — not listened to by ear (no speakers in this setup) |
| `flutter test` after Audio 3 — 224 tests (+ sound choice rules: pentatonic streak + fallback, results with level-up / no celebration for a reward already paid, sorting, care; `playAny`, `playSequence` order and gap, sequence dropped on dispose; UI with a fake file for every id: full quiz sound order, second tap and rebuilds silent, full cleanup round incl. combo / wrong / empty bin / result, sea ambience on Pet tab only and stopped under the cleanup page, care / full / egg stroke / hatch, tab tap, master mute = total silence) · `flutter analyze` clean | ✅ All pass (2026-10-22) |
| `flutter test` after adding the Kenney sounds — 225 tests (+ every effect is WAV, mono, 44.1 kHz, ≤ 1.5 s; only `music.main` still silent; files ↔ catalog ↔ pubspec ↔ ATTRIBUTION) · `flutter analyze` clean | ✅ All pass (2026-10-22) |
| Kenney sounds on the emulator: tab tap → SoundPool effect player `event:started`; Pet tab → sea loop player created; no audio errors in the log | ✅ Checked (2026-10-22) — not listened to by ear; the team should listen to every sound |
| Audio 3 on the emulator: Home → 0 active audio tracks; Pet tab → 1 (sea loop); Home → 0; Pet → 1; app in background → 0; back → 1; no audio errors in the log for the silent ids | ✅ Checked (2026-10-22) |
| M7 drag fix on the emulator: the old version ignored a plain drag (only a ~1 s hold worked); now a quick swipe from an item to a bin sorts it, tap-then-bin still works, swiping on the feedback card scrolls | ✅ Checked by script (2026-10-22) |
| `flutter test` after M8 — 255 tests (+ shop prices, odds sum, 10 000 seeded rolls within ±2 % of the shown odds, rarity fallback, inventory JSON + old save without inventory, level-up tickets (one/two levels, none on repeat), buy ticket/item incl. not enough coins / epic / already owned, roll new vs duplicate refund, no ticket, equip only owned + one per slot + kept after restart, real cosmetics file, wardrobe flow from Pet room and Home, roll → wear → pet shows it, shop buy/wear/take off, disabled buttons, guidelines, 200% text on a small phone) · `flutter analyze` clean | ✅ All pass (2026-10-23, on the M8 branch) |
| M8 on the emulator (Pixel_7, existing save from M7 testing: level 2, 26 coins, 1 ticket): new build loaded the old save; hanger button → wardrobe; roll → "Fiore di campo" (common) → "Indossa ora" → flower replaces the leaf, snackbar "Ecò indossa: Fiore di campo"; force-stop + relaunch → Home pet still wears it, save shows `head_flower` owned + equipped, 0 tickets. The tester's save was backed up first and restored afterwards | ✅ Checked by script + screenshots (2026-10-23). Shop purchase on the device not tried (26 coins); covered by widget tests |
| `flutter test` after the otter redesign — 275 tests, 2 dev-tool tests skipped (+ otter painter sizes/moods/poses/shouldRepaint, six-rarity prices/odds/refunds, 20 000 seeded rolls within ±1.5 points, real 25-item content file, wardrobe odds/refunds/reveal) · `flutter analyze` clean | ✅ All pass (2026-10-23) |
| Otter visual check: render of the default otter overlaid on the reference picture, every mood × stage, every item worn, full outfits per rarity, thumbnails; on the emulator the Pet tab shows the otter (sad mood from the saved needs) and the wardrobe shows six odds, six refunds and the computed shop note. Tester save backed up and restored | ✅ Looked at (2026-10-23) |
| `flutter build apk --debug` | ✅ Builds (again after the otter redesign, 2026-10-23) |
| Otter idle animation (`otter_idle.dart`: 12 s loop of tail wag, head tilt, two blinks, one ear flick; off in tests and with "remove animations"): unit tests for the pose loop; on the emulator, consecutive screenshots of the Pet room differ (it moves) | ✅ Checked (2026-10-23) |
| `flutter build apk --release` (signed with the debug key, for demo installs) | ✅ Builds, 53 MB (2026-10-23) |
| **Full play-through on the emulator with the release APK, fresh data**: onboarding (2 interests, nickname, age) → Home without the debug button → Quiz del giorno 5/5, +70 XP, streak 5 → Room Cleanup 8/8, +22 coins, +10 XP, combo 8 → Clima quiz 5/5 → "Hai raggiunto il livello 2!" + "Premio: 1 biglietto…" → Pet tab: egg ready, hatched and named "Ondina" (otter appears, idle animation runs) → wardrobe with 2 tickets: Maschera da supereroe (Epico) worn, Sciarpa di lana (Raro) worn → force-stop + relaunch: Level 2, 50/150 XP, 22 coins, 0 tickets, both items saved and equipped. The tester's save was backed up first and restored afterwards (the debug build is installed again) | ✅ Checked by script + screenshots (2026-10-23) |
| Android emulator (Pixel 7, Android 36): app starts, Home renders, tab switch, system Back from a tab returns to Home | ✅ Checked manually with screenshots (2026-10-22) |
| Android accessibility tree (uiautomator dump): every stat, balance, image, card and tab has an Italian label | ✅ Checked (2026-10-22) |
| Listening to TalkBack live | ⏳ Not done yet (optional, by a team member) |
| Physical Android phone | ⏳ Not tested |
| iOS | ⛔ Not possible (no Mac) |

## Known issues / notes
- No open bugs. (Smart App Control and the sdkmanager `;` problem are solved on the lead PC; see setup tips.)
- `claimedRewardIds` grows with every claim. Fine for the hackathon; prune old ids if it ever gets large.
- Android Auto Backup (on by default) can copy the save to the user's own Google account backup. Decide before
  release whether to keep it (restores progress on a new phone) or turn it off in `AndroidManifest.xml`.
- Web preview keeps progress in memory only.
- Home egg card: "Si schiuderà al livello 2: ti mancano 100 XP" is cut with "…" on a Pixel 7 (seen in the play-through); fine for the demo, could wrap to two lines
- Polish idea: on onboarding step 3 the open keyboard pushes "Fine/Salta" up so they cover the last age chips
  (still scrollable; the keyboard ✓ closes it). Consider moving the buttons into the scroll area on that step.
- Interests now drive the quiz ("Per te" order and the personal quiz). Facts, missions and other activities
  will use them later (recommendation milestone).
- Not done yet for the quiz: read-aloud button (flutter_tts), difficulty adapting to past answers (stats are
  already saved), English content file.
- The research content files and merge script used for M5 lived in a temporary folder; the merged result is
  `assets/content/quiz_questions_it.json`, which is now the file to edit.

### Hackathon deadline is set at Friday, October 23, 2026, at 9:00 PM CEST (Central European Summer Time) / UTC+2.
## Open questions
1. Choice of Modes 2–4 (options in the Phase 0 plan)

## Remaining work
- Room Cleanup polish ideas: a short "how to play" for first-timers, a simple room drawing that gets tidier as
  items leave, more items (Pyrex, greaseproof paper and colour-catcher sheets were verified but left out for space)
- Pet needs are recalculated when a screen rebuilds (tab switch, any action), not every minute while the
  app stays open on the same screen. Fine for the demo; a periodic refresh can be added later.
- The pet's idle animation keeps Android's `uiautomator dump` from working (it waits for a still screen).
  TalkBack is not affected; scripted device tests should use screenshots or turn animations off.
- Audio: Milestone 4 (settings screen: master mute, 3 sliders, reset) · listen to every sound on a real phone and
  swap any that feel wrong (alternatives in the same Kenney packs) · background music (`music.main`) is wired in
  the service but not started anywhere until a CC0 music loop is found · iOS audio untested (no Mac)
- Cosmetics polish ideas: a small animation for the roll reveal, more items per slot, room decorations
  (left out of M8 on purpose), a "new" badge in "I miei oggetti", a dedicated reveal sound
- Balancing: shop prices, odds and refunds are first guesses (D21); tune in play-tests
- Next: M10 comeback score (renumber its decisions from D54) · M9 recommendations · quiz read-aloud
