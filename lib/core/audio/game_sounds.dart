import '../../domain/cleanup_round.dart';
import '../../domain/game_controller.dart';
import '../../domain/rules/pet_rules.dart';
import 'sound_id.dart';

/// Which sound goes with which game event. Pure functions, so the choices
/// are tested without any screen; screens only pass the result on to
/// `AudioService` in their event handlers.

/// The answer to a quiz question. A correct answer climbs the pentatonic
/// scale with the streak (C D E G A); without note files the plain
/// "correct" sound is used. A wrong answer is a soft, neutral sound.
List<SoundId> answerSounds({required bool correct, required int streak}) {
  if (!correct) return const [SoundId.quizIncorrect];
  const notes = [
    SoundId.quizStreak1,
    SoundId.quizStreak2,
    SoundId.quizStreak3,
    SoundId.quizStreak4,
    SoundId.quizStreak5,
  ];
  final note = notes[(streak.clamp(1, notes.length)) - 1];
  return [note, SoundId.quizCorrect];
}

/// The end of a quiz or cleanup round: a level-up beats the normal
/// "complete" jingle, then the reward chime follows. A reward that was
/// already paid (double tap, replay) gives no celebration at all.
List<SoundId> resultSounds({
  required ClaimResult claim,
  required SoundId complete,
  required SoundId reward,
}) {
  if (!claim.applied) return const [];
  return [
    claim.leveledUp ? SoundId.levelUp : complete,
    if (claim.reward.xp > 0 || claim.reward.coins > 0) reward,
  ];
}

/// One item sorted in Room Cleanup. A combo milestone gets the richer
/// chime instead of the normal one; a wrong bin a neutral sound.
SoundId sortSound(SortFeedback feedback) {
  if (!feedback.correct) return SoundId.recyclingIncorrect;
  return feedback.comboBonus ? SoundId.recyclingCombo : SoundId.recyclingCorrect;
}

SoundId careSound(CareAction action) => switch (action) {
      CareAction.feed => SoundId.petFeed,
      CareAction.play => SoundId.petPlay,
      CareAction.clean => SoundId.petBath,
    };
