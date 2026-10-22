# EcoQuest — Project Status

**Current milestone:** M5 — Topic Quiz → **done on Android** (iOS untested, no Mac)
**Done before:** M1 app shell (`39e8b3d`) · M2 game state + saving (`d7c3454`) · M3 onboarding + profile (`6695199`)
**Next milestone:** M6 — Virtual pet room (pet state, care interactions, visual feedback).
Recycling (M7) can run in parallel. Read-aloud (flutter_tts) is a small follow-up for the quiz.

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
| D28 | Quiz = 5 questions, easy → hard; topic quiz = only that topic; personal quiz prefers interests, avoids the last 20 questions shown | New (M5) |
| D29 | Quiz XP: 10 per first-time correct answer, 2 for a question already learned, +5 for each correct answer in a row after the first; quizzes give XP only (coins come from recycling/games) | New (M5) |
| D30 | `QuizSession` (plain Dart) runs a quiz; `completeQuiz` saves XP + learning stats in one write, once per session id | New (M5) |
| D31 | Randomness through `randomProvider`, so tests use a fixed seed | New (M5) |

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
| M5 on the emulator: Learn hub with real content and "Per te" order; a personal quiz played (questions easy → hard, wrong-answer feedback with correct answer + explanation); save shows 1 quiz, claim id, XP 0 → 40 | ⚠️ Partly — the emulator was being used at the same time, so the scripted run was interrupted; a clean manual play-through is still worth doing |
| `flutter build apk --debug` | ✅ Builds |
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
- Polish idea: on onboarding step 3 the open keyboard pushes "Fine/Salta" up so they cover the last age chips
  (still scrollable; the keyboard ✓ closes it). Consider moving the buttons into the scroll area on that step.
- Interests now drive the quiz ("Per te" order and the personal quiz). Facts, missions and other activities
  will use them later (recommendation milestone).
- Not done yet for the quiz: read-aloud button (flutter_tts), difficulty adapting to past answers (stats are
  already saved), English content file.
- The research content files and merge script used for M5 lived in a temporary folder; the merged result is
  `assets/content/quiz_questions_it.json`, which is now the file to edit.

## Open questions
1. Hackathon deadline / available hours (unknown → keep MVP small)
2. Choice of Modes 2–4 (options in the Phase 0 plan)

## Remaining work
- Commit M5 (after a quick human look at the content checklist above)
- Parallel work, each building on `GameController` + `EconomyConfig`:
  M6 pet room · M7 recycling (then M8 cosmetics, M9 recommendations) · quiz read-aloud
