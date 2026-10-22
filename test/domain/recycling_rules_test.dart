import 'dart:math';

import 'package:ecoquest/domain/cleanup_round.dart';
import 'package:ecoquest/domain/models/pet_state.dart';
import 'package:ecoquest/domain/models/recycling_progress.dart';
import 'package:ecoquest/domain/models/waste_item.dart';
import 'package:ecoquest/domain/rules/economy_config.dart';
import 'package:ecoquest/domain/rules/recycling_rules.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/waste_fixtures.dart';

void main() {
  const economy = EconomyConfig.defaults; // 2 / 1 coins, combo 3 → +3
  final bank = testWasteBank(); // 10 items, one tricky

  group('pickCleanupItems', () {
    test('picks 8 different items and always one tricky item', () {
      for (var seed = 0; seed < 20; seed++) {
        final items = pickCleanupItems(
            bank: bank,
            progress: const RecyclingProgress(),
            random: Random(seed));
        expect(items, hasLength(8));
        expect(items.map((i) => i.id).toSet(), hasLength(8));
        expect(items.any((i) => i.tricky), isTrue, reason: 'seed $seed');
      }
    });

    test('recently seen items are avoided while others are left', () {
      final recent = [for (final i in bank.items.take(2)) i.id];
      final items = pickCleanupItems(
        bank: bank,
        progress: RecyclingProgress(recentItemIds: recent),
        random: Random(1),
      );
      expect(items.map((i) => i.id).toSet().intersection(recent.toSet()),
          isEmpty);
    });

    test('a small bank gives a shorter round instead of failing', () {
      final small = WasteBank(bank.items.take(3).toList());
      final items = pickCleanupItems(
          bank: small, progress: const RecyclingProgress(), random: Random(1));
      expect(items, hasLength(3));
    });
  });

  group('scoreCleanup', () {
    SortedItem s(String id, bool correct) =>
        SortedItem(itemId: id, correct: correct);

    test('8 right first time: 8×2 coins + 2 combos×3 = 22, plus 10 XP', () {
      final score = scoreCleanup(
          [for (var i = 0; i < 8; i++) s('w$i', true)],
          const RecyclingProgress(),
          economy);
      expect(score.coins, 22);
      expect(score.xp, 10);
      expect(score.bestCombo, 8);
      expect(score.perfect, isTrue);
    });

    test('mistakes cost nothing but break the combo', () {
      // ✓ ✓ ✗ ✓ ✓ ✓ → 5×2 + one combo (the last three) = 13
      final score = scoreCleanup([
        s('a', true),
        s('b', true),
        s('c', false),
        s('d', true),
        s('e', true),
        s('f', true),
      ], const RecyclingProgress(), economy);
      expect(score.coins, 13);
      expect(score.bestCombo, 3);
    });

    test('XP only for rounds with at least 75% right', () {
      final five = scoreCleanup(
          [for (var i = 0; i < 8; i++) s('w$i', i < 5)],
          const RecyclingProgress(),
          economy);
      final six = scoreCleanup(
          [for (var i = 0; i < 8; i++) s('w$i', i < 6)],
          const RecyclingProgress(),
          economy);
      expect(five.xp, 0); // 62%
      expect(six.xp, 10); // 75%
    });

    test('items sorted right before pay 1 coin instead of 2', () {
      final before = RecyclingProgress(learnedItemIds: {'a', 'b'});
      final score = scoreCleanup(
          [s('a', true), s('b', true), s('c', true)], before, economy);
      expect(score.coins, 1 + 1 + 2 + 3); // + combo of 3
      expect(score.newlyLearned, 1);
    });
  });

  test('a clean room makes a hatched pet cleaner, not an egg', () {
    final now = DateTime(2026, 10, 22, 10);
    final baby = PetState(
        stage: PetStage.baby, cleanliness: 50, needsUpdatedAt: now);
    expect(petAfterCleanup(baby, now, economy).cleanliness, 75);
    final egg = PetState(needsUpdatedAt: now);
    expect(petAfterCleanup(egg, now, economy).cleanliness, egg.cleanliness);
  });

  group('CleanupRound', () {
    final paper = testWaste(WasteCategory.paper, 1);
    final glass = testWaste(WasteCategory.glass, 1);
    final organic = testWaste(WasteCategory.organic, 1);

    CleanupRound round() =>
        CleanupRound(items: [paper, glass, organic], roundId: 'r');

    test('select then sort into the right bin', () {
      final r = round()..select(paper);
      final feedback = r.sortInto(WasteCategory.paper)!;

      expect(feedback.correct, isTrue);
      expect(feedback.combo, 1);
      expect(r.remaining, [glass, organic]);
      expect(r.selected, isNull);
    });

    test('a wrong bin still removes the item and resets the combo', () {
      final r = round()..select(paper);
      r.sortInto(WasteCategory.paper);
      r.select(glass);
      final feedback = r.sortInto(WasteCategory.residual)!;

      expect(feedback.correct, isFalse);
      expect(feedback.combo, 0);
      expect(r.remaining, [organic]);
    });

    test('dragging sorts an item without selecting it first', () {
      final r = round();
      final feedback = r.sortInto(WasteCategory.glass, item: glass)!;
      expect(feedback.correct, isTrue);
    });

    test('a bin without a selected item does nothing', () {
      final r = round();
      expect(r.sortInto(WasteCategory.paper), isNull);
      expect(r.remaining, hasLength(3));
    });

    test('tapping the selected item again deselects it', () {
      final r = round()..select(paper);
      r.select(paper);
      expect(r.selected, isNull);
    });

    test('the third correct item in a row is a combo bonus', () {
      final r = round();
      r.sortInto(WasteCategory.paper, item: paper);
      r.sortInto(WasteCategory.glass, item: glass);
      final third = r.sortInto(WasteCategory.organic, item: organic)!;

      expect(third.comboBonus, isTrue);
      expect(r.isFinished, isTrue);
      expect(r.results.every((s) => s.correct), isTrue);
    });
  });
}
