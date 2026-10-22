import 'economy_config.dart';

/// Where the player stands inside their current level.
class LevelInfo {
  const LevelInfo({
    required this.level,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
  });

  final int level;

  /// XP earned since reaching [level].
  final int xpIntoLevel;

  /// XP needed in total to go from [level] to the next one.
  final int xpForNextLevel;

  /// 0.0 – 1.0, for progress bars.
  double get progress => xpIntoLevel / xpForNextLevel;
}

/// Turns the saved total XP into a level.
///
/// Example with the default economy: 0 XP → level 1 (0/100),
/// 100 XP → level 2 (0/150), 260 XP → level 3 (10/200).
LevelInfo levelForTotalXp(int totalXp, EconomyConfig economy) {
  var level = 1;
  var remaining = totalXp < 0 ? 0 : totalXp;
  var needed = economy.xpForFirstLevelUp;

  while (remaining >= needed) {
    remaining -= needed;
    level++;
    needed += economy.xpIncreasePerLevel;
  }
  return LevelInfo(
    level: level,
    xpIntoLevel: remaining,
    xpForNextLevel: needed,
  );
}
