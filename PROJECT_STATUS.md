# EcoQuest — Project Status

**Current milestone:** M1 — Toolchain + runnable app shell → **done on Android** (iOS untested, no Mac)
**Next milestone:** M2 — Shared foundations (GameState model, economy config, SaveRepository, GameController contract)

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
| D15 | Each balance/stat/image that the screen reader should focus on its own uses `Semantics(container: true, ...)`; otherwise its label merges into a neighbour | New |

## Implemented (M1)
- App entry point, `ProviderScope`, router in a provider (fresh router per test)
- Theme tokens: `eco_colors.dart` (all text pairs ≥ 4.5:1 WCAG AA), `eco_spacing.dart`, `app_theme.dart`
- Bottom-tab shell; Android back on a non-Home tab returns to Home
- Reusable widgets in `lib/core/widgets/`: `EcoCard`, `EcoButton`, `StatBar`, `CurrencyChip`, `ComingSoonView`
- Home screen layout preview: level/XP, coins/tickets, drawn room + egg, 3 need bars, 2 activity shortcuts
  - **PLACEHOLDER DATA**: all numbers on Home are fixed preview constants until M2
- Learn / Pet / Profile: "In arrivo" placeholders

## Tests
| Check | Result |
|-------|--------|
| `flutter analyze` | ✅ No issues (2026-10-22) |
| `flutter test` — 15 tests: navigation, back button, semantics, tap-target/label/contrast guidelines, 200% text on 320×568 | ✅ All pass (2026-10-22) |
| `flutter build apk --debug` | ✅ Builds |
| Android emulator (Pixel 7, Android 36): app starts, Home renders, tab switch, system Back from a tab returns to Home | ✅ Checked manually with screenshots (2026-10-22) |
| Android accessibility tree (uiautomator dump): every stat, balance, image, card and tab has an Italian label | ✅ Checked (2026-10-22) |
| Listening to TalkBack live | ⏳ Not done yet (optional, by a team member) |
| Physical Android phone | ⏳ Not tested |
| iOS | ⛔ Not possible (no Mac) |

## Known issues
_None open._ (Smart App Control and the sdkmanager `;` problem are solved on the lead PC; see setup tips.)

## Open questions
1. Hackathon deadline / available hours (unknown → keep MVP small)
2. Choice of Modes 2–4 (options in the Phase 0 plan)

## Remaining work
- First Git commit of M1 (repository initialised, nothing committed yet)
- M2 shared contracts (GameState, economy config, SaveRepository + JSON implementation with tests,
  GameController signatures) → unlocks parallel work for the six team members
