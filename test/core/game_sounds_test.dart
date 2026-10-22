import 'package:ecoquest/core/audio/game_sounds.dart';
import 'package:ecoquest/core/audio/sound_id.dart';
import 'package:ecoquest/domain/cleanup_round.dart';
import 'package:ecoquest/domain/game_controller.dart';
import 'package:ecoquest/domain/models/reward.dart';
import 'package:ecoquest/domain/models/waste_item.dart';
import 'package:ecoquest/domain/rules/pet_rules.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/waste_fixtures.dart';

ClaimResult _claim({bool applied = true, int xp = 10, int coins = 0,
        bool levelUp = false}) =>
    ClaimResult(
      applied: applied,
      reward: applied ? Reward(xp: xp, coins: coins) : Reward.none,
      levelBefore: 1,
      levelAfter: levelUp ? 2 : 1,
    );

SortFeedback _sorted({required bool correct, bool combo = false}) =>
    SortFeedback(
      item: testWaste(WasteCategory.paper, 1),
      chosen: WasteCategory.paper,
      correct: correct,
      combo: combo ? 3 : 1,
      comboBonus: combo,
    );

void main() {
  test('correct answers climb the pentatonic scale, then stay on top', () {
    expect(answerSounds(correct: true, streak: 1).first, SoundId.quizStreak1);
    expect(answerSounds(correct: true, streak: 3).first, SoundId.quizStreak3);
    expect(answerSounds(correct: true, streak: 5).first, SoundId.quizStreak5);
    expect(answerSounds(correct: true, streak: 9).first, SoundId.quizStreak5);
    // Without note files, the plain "correct" sound is the fallback.
    expect(answerSounds(correct: true, streak: 2).last, SoundId.quizCorrect);
  });

  test('a wrong answer gets only the soft neutral sound', () {
    expect(answerSounds(correct: false, streak: 0), [SoundId.quizIncorrect]);
  });

  test('results: jingle then reward chime; level-up replaces the jingle', () {
    expect(
        resultSounds(
            claim: _claim(),
            complete: SoundId.quizComplete,
            reward: SoundId.rewardXp),
        [SoundId.quizComplete, SoundId.rewardXp]);
    expect(
        resultSounds(
            claim: _claim(coins: 20, levelUp: true),
            complete: SoundId.recyclingComplete,
            reward: SoundId.rewardCoins),
        [SoundId.levelUp, SoundId.rewardCoins]);
  });

  test('no reward chime for a zero reward, no sound for a reward already '
      'paid', () {
    expect(
        resultSounds(
            claim: _claim(xp: 0),
            complete: SoundId.quizComplete,
            reward: SoundId.rewardXp),
        [SoundId.quizComplete]);
    expect(
        resultSounds(
            claim: _claim(applied: false),
            complete: SoundId.quizComplete,
            reward: SoundId.rewardXp),
        isEmpty);
  });

  test('sorting: correct, combo milestone, neutral wrong', () {
    expect(sortSound(_sorted(correct: true)), SoundId.recyclingCorrect);
    expect(sortSound(_sorted(correct: true, combo: true)),
        SoundId.recyclingCombo);
    expect(sortSound(_sorted(correct: false)), SoundId.recyclingIncorrect);
  });

  test('each care action has its own pet sound', () {
    expect(CareAction.values.map(careSound).toSet().length,
        CareAction.values.length);
    for (final action in CareAction.values) {
      expect(careSound(action).channel.id, 'pet');
    }
  });
}
