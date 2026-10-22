# Milestone 10: "Comeback Score" (on-device retention)

Repo: https://github.com/and-mazzaro/hackathon (EcoQuest, Flutter). Continuity file: `PROJECT_STATUS.md`.
Status: spec for implementation. Build on a branch `m10-comeback`, independent of M8 (cosmetics) and M9 (recommendations).

## Idea (from the Duolingo reel, adapted)
A small daily number estimates how likely the player is to come back, from simple local signals. If it is low, the app responds gently. An optional reminder helps at a time the player chooses.

## What we keep / reject
- KEEP: daily score; signals = how the app was opened (icon vs notification), activities done today, wrong answers, crash since last open; a well-timed reminder; reminder text based on the player's interests.
- REJECT: Wi-Fi fingerprinting, silent-mode tracking, location, device ids (privacy, young audience); guilt streaks, punishment, anything that makes the pet suffer (D32-D34: pet never dies).

## Fit with existing architecture (read PROJECT_STATUS.md decisions)
- D5: score formula = pure Dart in `lib/domain/rules/comeback_rules.dart`, unit-tested, no UI.
- D4/D18/D19: new state goes in the versioned save with defaults in `fromJson`; old saves must still load. Add a save-format test.
- D17: any bonus goes through `GameController.claimReward(claimId, reward)` with claim id like `comeback:YYYY-MM-DD` (paid once per day).
- D21: bonus amount and thresholds live in `EconomyConfig`.
- D10/D12: all text in `lib/l10n/app_it.arb`.
- D11: import `package:material_ui/material_ui.dart`, never `package:flutter/material.dart`.
- D9: add the notification plugin with `flutter pub add` (expected: `flutter_local_notifications`, plus timezone support if needed), never by hand-editing versions.
- D31: any randomness via `randomProvider`.
- D8: screen-reader labels (`Semantics`), 200% text, buttons not hidden by the keyboard.

## Behavior
1. Local activity log (last ~14 days max): per day, entry source, activities completed, correct/wrong answer counts; plus a `lastSessionEndedCleanly` flag.
2. `comebackScore(log, now)` returns 0-100 with a transparent formula (documented in code). Neutral default on day 1. Clock going backwards must not break it (like D32).
3. Gentle response when the score is low: pet message ("Mi sei mancato!"), suggest the easier activity, small fixed comeback bonus. No guilt text.
4. Reminder: opt-in screen in Profile/Settings (plain Italian explanation), time picker, max 1 local notification per day, toggle off anytime. Text may mention an interest or the pet.
5. "Cancella la mia attività" button clears the log and cancels notifications.

## Acceptance criteria
- Given a new player, when onboarding ends, then no notification permission is requested.
- Given fixed sample logs, when the score is computed, then values are in 0-100 and match the unit-test table.
- Given an old save without activity data, when the app starts, then it loads with defaults.
- Given a low score, when the player opens Home, then they see a friendly pet message and a suggested easier activity; nothing is lost or blocked.
- Given a reminder at 18:00, then exactly one local notification is scheduled per day; disabling it cancels it.
- Given permission denied (Android 13+), then the app works fully and does not nag.
- `flutter analyze` clean, `flutter test` all pass, `flutter build apk --debug` builds, checked on the emulator.

## Out of scope
Server push, analytics, ML, location/Wi-Fi, leaderboards, guilt streaks, iOS validation (no Mac, say it is untested).

## Open questions
- Notification permission wording for the target age range.
- Bonus size vs XP/coin balance (first guess in EconomyConfig, tune in play-tests).

---
# Prompt for Claude Code (paste in the repo folder)

```
Read PROJECT_STATUS.md (decisions D1-D44, current state) and MILESTONE_10_RETENTION.md.
Implement Milestone 10 "Comeback Score" exactly as specified, following every decision in PROJECT_STATUS.md.
Implementation is authorized for this milestone only.

Rules:
- Work on a new branch m10-comeback, small commits. Do not touch M8/M9 areas unless strictly needed.
- First do a quick read-only look at: GameState/save format, GameController, EconomyConfig, Profile screen, Home screen, Android manifest. Then write a short plan (files, new dependency, risks) and go ahead.
- No Wi-Fi, location, silent-mode or device-id collection. No guilt mechanics. Pet never dies.
- Domain logic pure Dart with unit tests; old-save test; l10n in Italian; Semantics.
- Verify: flutter analyze, flutter test, flutter build apk --debug, and an emulator check of the reminder opt-in and the low-score Home message. Report only what you actually verified; say iOS is untested.
- At the end update PROJECT_STATUS.md: add M10 under "Implemented", new decisions D45+, test results, and known issues. Then list the commits and stop; do not merge or push without my OK.
```
