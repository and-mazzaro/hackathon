import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sound_id.dart';

/// Which file plays for each [SoundId].
///
/// Only files with a known licence are listed (see
/// `assets/audio/ATTRIBUTION.md`). Ids without a file stay silent until a
/// licensed sound is added here; `missing` lists them.
class AudioCatalog {
  const AudioCatalog(this._assets);

  final Map<SoundId, String> _assets;

  /// The sounds shipped with EcoQuest today. Effects are Kenney CC0 sounds
  /// converted to WAV (plays on Android and iOS); see ATTRIBUTION.md.
  static const ecoQuest = AudioCatalog({
    SoundId.uiTap: 'assets/audio/ui/tap.wav',
    SoundId.uiUnavailable: 'assets/audio/ui/unavailable.wav',
    SoundId.quizQuestion: 'assets/audio/quiz/question.wav',
    SoundId.quizCorrect: 'assets/audio/quiz/correct.wav',
    SoundId.quizIncorrect: 'assets/audio/quiz/not_quite.wav',
    SoundId.quizStreak1: 'assets/audio/quiz/streak_1.wav',
    SoundId.quizStreak2: 'assets/audio/quiz/streak_2.wav',
    SoundId.quizStreak3: 'assets/audio/quiz/streak_3.wav',
    SoundId.quizStreak4: 'assets/audio/quiz/streak_4.wav',
    SoundId.quizStreak5: 'assets/audio/quiz/streak_5.wav',
    SoundId.quizComplete: 'assets/audio/quiz/complete.wav',
    SoundId.rewardXp: 'assets/audio/rewards/xp.wav',
    SoundId.rewardCoins: 'assets/audio/rewards/coins.wav',
    SoundId.levelUp: 'assets/audio/rewards/level_up.wav',
    SoundId.recyclingSelect: 'assets/audio/recycling/pick_up.wav',
    SoundId.recyclingCorrect: 'assets/audio/recycling/correct.wav',
    SoundId.recyclingIncorrect: 'assets/audio/recycling/not_quite.wav',
    SoundId.recyclingCombo: 'assets/audio/recycling/combo.wav',
    SoundId.recyclingComplete: 'assets/audio/recycling/complete.wav',
    SoundId.petFeed: 'assets/audio/pet/feed.wav',
    SoundId.petPlay: 'assets/audio/pet/play.wav',
    SoundId.petBath: 'assets/audio/pet/bath.wav',
    SoundId.petEggPat: 'assets/audio/pet/egg_pat.wav',
    SoundId.petHatch: 'assets/audio/pet/hatch.wav',
    SoundId.petGrow: 'assets/audio/pet/grow.wav',
    SoundId.ambienceSea: 'assets/audio/ambience/sea_waves.mp3',
    // music.main: no CC0 music loop yet, so no background music.
  });

  /// The asset path (e.g. `assets/audio/ui/tap.wav`), or null if missing.
  String? assetFor(SoundId id) => _assets[id];

  Map<SoundId, String> get assets => Map.unmodifiable(_assets);

  List<SoundId> get missing =>
      [for (final id in SoundId.values) if (!_assets.containsKey(id)) id];
}

final audioCatalogProvider = Provider<AudioCatalog>((ref) => AudioCatalog.ecoQuest);
