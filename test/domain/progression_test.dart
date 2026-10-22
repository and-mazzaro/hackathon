import 'package:ecoquest/domain/rules/economy_config.dart';
import 'package:ecoquest/domain/rules/progression.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const economy = EconomyConfig.defaults; // 100, then +50 per level

  test('a new player is level 1 with 0 of 100 XP', () {
    final info = levelForTotalXp(0, economy);
    expect(info.level, 1);
    expect(info.xpIntoLevel, 0);
    expect(info.xpForNextLevel, 100);
    expect(info.progress, 0);
  });

  test('just before and exactly at a level-up', () {
    expect(levelForTotalXp(99, economy).level, 1);

    final atLevelUp = levelForTotalXp(100, economy);
    expect(atLevelUp.level, 2);
    expect(atLevelUp.xpIntoLevel, 0);
    expect(atLevelUp.xpForNextLevel, 150);
  });

  test('each level needs 50 XP more than the previous one', () {
    // 100 + 150 = 250 XP to reach level 3, then 200 more for level 4.
    final info = levelForTotalXp(260, economy);
    expect(info.level, 3);
    expect(info.xpIntoLevel, 10);
    expect(info.xpForNextLevel, 200);
  });

  test('a big XP gain can jump several levels', () {
    // 100 + 150 + 200 + 250 = 700 XP → level 5
    expect(levelForTotalXp(700, economy).level, 5);
  });

  test('negative XP (should never happen) counts as 0', () {
    expect(levelForTotalXp(-50, economy).level, 1);
  });

  test('a different economy changes the curve without other code changes',
      () {
    const flat = EconomyConfig(xpForFirstLevelUp: 10, xpIncreasePerLevel: 0);
    expect(levelForTotalXp(35, flat).level, 4);
  });
}
