import '../../domain/models/audio_settings.dart';

/// Every sound the game can ask for, by meaning, never by file name.
///
/// Screens and controllers say WHAT happened (`SoundId.quizCorrect`);
/// [AudioCatalog] decides which file plays, if any. An id without a file
/// simply stays silent, so a sound can be wired up before it exists.
enum SoundId {
  // Interface
  uiTap('ui.tap', AudioChannel.effects),
  // "Not possible right now": a soft, neutral bop, never a buzzer.
  uiUnavailable('ui.unavailable', AudioChannel.effects),

  // Quiz
  quizQuestion('quiz.question', AudioChannel.effects),
  quizCorrect('quiz.correct', AudioChannel.effects),
  quizIncorrect('quiz.incorrect', AudioChannel.effects),
  // Correct answers in a row: pentatonic C D E G A.
  quizStreak1('quiz.streak.1', AudioChannel.effects),
  quizStreak2('quiz.streak.2', AudioChannel.effects),
  quizStreak3('quiz.streak.3', AudioChannel.effects),
  quizStreak4('quiz.streak.4', AudioChannel.effects),
  quizStreak5('quiz.streak.5', AudioChannel.effects),
  quizComplete('quiz.complete', AudioChannel.effects, ducksMusic: true),

  // Rewards and progression
  rewardXp('reward.xp', AudioChannel.effects),
  rewardCoins('reward.coins', AudioChannel.effects),
  levelUp('level.up', AudioChannel.effects, ducksMusic: true),

  // Room Cleanup
  recyclingSelect('recycling.select', AudioChannel.effects),
  recyclingCorrect('recycling.correct', AudioChannel.effects),
  recyclingIncorrect('recycling.incorrect', AudioChannel.effects),
  recyclingCombo('recycling.combo', AudioChannel.effects),
  recyclingComplete('recycling.complete', AudioChannel.effects,
      ducksMusic: true),

  // Pet
  petFeed('pet.feed', AudioChannel.pet),
  petPlay('pet.play', AudioChannel.pet),
  petBath('pet.bath', AudioChannel.pet),
  petEggPat('pet.egg_pat', AudioChannel.pet),
  petHatch('pet.hatch', AudioChannel.pet, ducksMusic: true),
  petGrow('pet.grow', AudioChannel.pet, ducksMusic: true),

  // Loops (one per channel at a time)
  musicMain('music.main', AudioChannel.music, loops: true),
  ambienceSea('ambience.sea', AudioChannel.pet, loops: true);

  const SoundId(
    this.key,
    this.channel, {
    this.ducksMusic = false,
    this.loops = false,
  });

  /// Stable name used in docs and logs, e.g. "quiz.correct".
  final String key;

  /// Whose volume slider controls this sound.
  final AudioChannel channel;

  /// Important moments: the music dips briefly so they stand out.
  final bool ducksMusic;

  /// Music and ambience loop until stopped; everything else plays once.
  final bool loops;
}
