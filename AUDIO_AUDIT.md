# EcoQuest — Audio audit (audio Milestone 1)

Date: 2026-10-22. Nothing in the app was changed for this audit: no assets copied, no packages added.

> **Status:** Milestone 2 (infrastructure) is done as planned in §7 — see PROJECT_STATUS.md (D40–D44).
> Only `Sea Waves` was copied into the app; every other id is silent until a licensed file is added to
> `AudioCatalog.ecoQuest` and `assets/audio/ATTRIBUTION.md`.

## 1. What already exists in the project

| Area | Finding |
|------|---------|
| Audio packages | None in `pubspec.yaml` |
| Audio files in the project | None (`*.mp3, wav, ogg, m4a, aac, flac, opus`: 0 files) |
| State management | Riverpod 3 (`AsyncNotifier`); providers are overridden in tests (`randomProvider`, `clockProvider`, ...) |
| Game changes | Only through `GameController` (`lib/domain/game_controller.dart`). Results already tell us what really happened: `ClaimResult.applied` (false when a reward was already paid) and `leveledUp`, `QuizOutcome`, `CleanupOutcome.petCleaner`, `careForPet` → bool, `evolvePet` → new stage or null |
| Persistence | One versioned JSON save (`GameState`) behind `SaveRepository`. New fields need a default in `fromJson`. There are no user settings yet |
| Accessibility | Every result already has visible text + screen-reader text (D8, D15). Sound will only be an extra layer |

Features that exist today and can get sounds: Home, onboarding, Learn hub + Quiz, Pet tab (care, egg, hatch,
grow), Room Cleanup (recycling), Profile. **Not built yet** (so no sounds now): missions, shop/cosmetics, reward
chest, collections/badges, Eco Journey, Smart Driving, Waste Detective, Green Shopping, Upcycling Lab, Nature
Missions, Fun Fact Album, seasonal events, room upgrades.

## 2. Verified inventory of `C:\Users\franc\Downloads\Effetti.zip`

The archive (948 KB) holds a folder `Effetti/` with 6 MP3 files and 6 macOS `__MACOSX/._*` resource files
(275 bytes each; they only hold file-system attributes, no source or licence information). No licence,
readme or attribution file is included.

All files: MP3, 192 kbps, encoded with ffmpeg (`Lavf` tag), which is typical of YouTube-to-MP3 converters.
Durations from Windows file properties (rounded to the second).

| # | File (real name) | Size | Length | Tags / origin | Licence | Usable? |
|---|------------------|------|--------|---------------|---------|---------|
| 1 | `Game Over Sound Effect.mp3` | **4 bytes** | — | Only the bytes `ID3` + version: **the file is empty/broken** | unknown | ❌ No audio in it |
| 2 | `Pokemon Level Up - Sound Effect (HD).mp3` | 103 KB | 4 s | Lavf, no other tags | **Pokémon game sound** — copyright Nintendo / Game Freak / The Pokémon Company | ❌ **Must not be used or committed** (our GitHub repo is public) |
| 3 | `Wooden Treasure Chest Opening  Free Sound Effect.mp3` | 245 KB | 10 s | Lavf, no source URL | unknown ("Free" in a YouTube title is not a licence) | ⚠️ Only if the team finds the original page and its licence |
| 4 | `Missione riuscita.mp3` | 140 KB | 5 s | Lavf, no source URL | unknown | ⚠️ Team: where does it come from? |
| 5 | `Completata missione.mp3` | 330 KB | 14 s | Lavf, no source URL | unknown | ⚠️ Team: where does it come from? Also too long for an effect |
| 6 | `Sea Waves - Sound Effect.mp3` | 429 KB | 13 s | Title "Sea Waves - Sound Effect", artist "Sound Effects", date 2021-10-21, comment `https://www.youtube.com/watch?v=B3ZbsOhNTas` | YouTube page (checked 2026-10-22): **Creative Commons Attribution** ("riutilizzo consentito"), channel "Sound Effects" (`UCaDuguIZW7Fwo1b43UWQejQ`) | ✅ With attribution (see note) |

Notes:
- I cannot listen to audio, so loudness, clean start/end and whether #6 loops without a click must be checked by
  ear by the team (e.g. in Audacity).
- #6: YouTube's CC BY means "credit the channel". A "Sound Effects" channel may itself have re-uploaded someone
  else's recording; for a public release, a sound from a source with a clear original author is safer.
- #3–#5: long files (5–14 s). For in-game effects they should be trimmed (in Audacity, saved as a new file; the
  originals stay untouched) — or the audio service can stop them after N seconds with a fade-out.

## 3. Mapping to real gameplay events (existing features only)

| Semantic id | Real trigger in the code today | Channel | File from the archive |
|-------------|--------------------------------|---------|-----------------------|
| `ui.tap` | `EcoButton` pressed | effects | — missing |
| `quiz.question` | new question shown in `QuizSession` | effects | — missing |
| `quiz.correct` / `quiz.incorrect` | answer evaluated in the quiz screen (not on rebuild) | effects | — missing |
| `quiz.streak.1…5` | streak 1–5 (pentatonic C D E G A) | effects | — missing (needs 5 note files) |
| `quiz.complete` | `completeQuiz` returned with `claim.applied` | effects | #4 `Missione riuscita` *(if licence OK)* |
| `reward.xp` / `reward.coins` | result screens, only when `claim.applied` | effects | — missing |
| `level.up` | `claim.leveledUp` (quiz or cleanup) | effects, ducks music | — missing (#2 is not allowed) |
| `recycling.select` | item selected / drag started | effects | — missing |
| `recycling.correct` / `recycling.incorrect` | `CleanupRound.sortInto` feedback | effects | — missing |
| `recycling.combo` | `SortFeedback.comboBonus` | effects | — missing |
| `recycling.complete` | `completeCleanup` with `claim.applied` | effects | #5 `Completata missione` *(if licence OK, trimmed)* |
| `pet.care.feed / play / bath` | `careForPet` returned true | pet | — missing |
| `pet.egg.pat` | "Accarezza l'uovo" | pet | — missing |
| `pet.hatch` / `pet.grow` | `evolvePet` returned a stage | pet + effects, ducks music | — missing |
| `ambience.sea` | optional room ambience (loop) | pet/ambience | #6 `Sea Waves` ✅ |
| `music.main` | background loop | music | — missing |
| `reward.chest_open` | *(reward chest not built yet)* | effects | #3 `Wooden Treasure Chest` *(if licence OK)* |
| `mission.complete` | *(missions not built yet)* | effects | #4 or #5 *(if licence OK)* |

## 4. Missing sounds (essential for the current MVP)

Background music loop · button tap · quiz correct · quiz "not quite" (soft, never a buzzer) · question swoosh ·
XP pling · coins · level-up fanfare · 5 pentatonic notes for streaks · item pick-up · correct sort · neutral
wrong sort · combo chime · pet reactions (happy, eating, playing, bath) · egg crack / hatch sparkle.

I did not download anything. Sources the team can check themselves (licence written on each pack/page):
- **Kenney.nl** audio packs (e.g. "Interface Sounds", "UI Audio", "Music Jingles", "Impact Sounds") — CC0,
  no attribution required. Covers most effects and jingles above.
- **Pixabay** sound effects / music — Pixabay Content License (free use, no attribution; read the terms).
- **Freesound.org** with the "Creative Commons 0" filter.
- **OpenGameArt.org** with the CC0 licence filter (good for calm music loops).

Until files are added, the game stays fully playable: every sound is optional, the catalog marks missing ids,
and the service simply does nothing for them (all feedback is already visual + spoken by screen readers).

## 5. Licensing summary (needs team review)

- ❌ `Pokemon Level Up` — copyrighted game audio. Do not ship, do not commit to the public repo.
- ❌ `Game Over Sound Effect` — empty file.
- ⚠️ `Wooden Treasure Chest`, `Missione riuscita`, `Completata missione` — **licence unknown**. Not copied into
  the app until someone finds the original source and licence (or the team made them itself).
- ✅ `Sea Waves` — CC BY via YouTube, credit "Sound Effects" (YouTube) + link; record it in
  `assets/audio/ATTRIBUTION.md`.

## 6. Package choice

**`audioplayers`** (one package; version chosen by `flutter pub add`, D9):
- short effects and a looping music track, many players at once, per-player volume;
- `AudioPool` for rapid repeated effects with a fixed number of players (no player per tap);
- `AudioContext` per platform: on iOS "ambient" (mixes with the user's music, respects the silent switch); on
  Android no audio focus grab for effects;
- works on Android and iOS (iOS untested: no Mac).

Not chosen: `just_audio` (great for music/podcasts, but one heavy player per sound for effects),
`flutter_soloud` (excellent low latency, but native C++ engine — more than a student MVP needs),
`flame_audio` (wraps audioplayers but pulls in the Flame engine).

## 7. Plan for audio Milestone 2 (infrastructure, no screen changes yet)

1. `flutter pub add audioplayers`; copy **only** cleared files into `assets/audio/<category>/` with clean names
   (today: only `ambience/sea_waves.mp3`), register `assets/audio/` in `pubspec.yaml`, write
   `assets/audio/ATTRIBUTION.md`.
2. `AudioSettings` (master mute, music / effects / pet-ambience volume 0–1, defaults 0.35 / 0.8 / 0.6) saved as a
   new `GameState.audio` field with defaults for old saves; `GameController.updateAudioSettings` saves it
   (sliders save when released, not on every move).
3. `SoundId` enum + `AudioCatalog` (id → asset path, channel, priority, optional max length) — missing ids map to
   nothing and are listed by a test.
4. `AudioService` interface; `AudioplayersAudioService` (effects pool with a small player limit, one music player
   with loop, ambience player, ~0.5 s ducking for high-priority sounds, per-id cooldown against double plays, all
   errors caught and logged); `FakeAudioService` that records calls for tests; `audioServiceProvider`.
5. Lifecycle: pause music/ambience when the app goes to the background; resume music on return only if it was
   playing and not muted; effects are never resumed.
6. Tests: defaults, clamping, mute, save/load of settings, old saves without `audio`, catalog ids → existing
   asset files, missing-asset handling, ducking timing, cooldown, lifecycle with the fake service.

Milestone 3 then connects the events in section 3; Milestone 4 adds the settings screen (Profile → "Audio").
