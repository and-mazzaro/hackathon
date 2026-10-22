import 'dart:math';

import '../models/pet_state.dart';
import '../models/recycling_progress.dart';
import '../models/waste_item.dart';
import 'economy_config.dart';
import 'pet_rules.dart';

/// Chooses the items for one cleanup round.
///
/// - At least one tricky item (difficulty 3) when the bank has one.
/// - Items shown recently are used only if nothing else is left.
/// - The order is random, so the room looks different every time.
List<WasteItem> pickCleanupItems({
  required WasteBank bank,
  required RecyclingProgress progress,
  required Random random,
  int count = 8,
}) {
  final recent = progress.recentItemIds.toSet();
  List<WasteItem> group(bool Function(WasteItem) test) =>
      bank.items.where(test).toList()..shuffle(random);

  final fresh = group((i) => !recent.contains(i.id));
  final old = group((i) => recent.contains(i.id));
  final chosen = [...fresh, ...old].take(count).toList();

  // Guarantee one tricky item: swap it in for an easy one if missing.
  if (!chosen.any((i) => i.tricky)) {
    final tricky = [...fresh, ...old].where((i) => i.tricky);
    if (tricky.isNotEmpty && chosen.isNotEmpty) {
      final easiest = chosen.indexWhere((i) => i.difficulty == 1);
      chosen[easiest == -1 ? chosen.length - 1 : easiest] = tricky.first;
    }
  }
  return chosen..shuffle(random);
}

/// What a finished round is worth.
class CleanupScore {
  const CleanupScore({
    required this.correctCount,
    required this.itemCount,
    required this.coins,
    required this.xp,
    required this.bestCombo,
    required this.newlyLearned,
  });

  final int correctCount;
  final int itemCount;
  final int coins;
  final int xp;
  final int bestCombo;

  /// Items sorted correctly for the first time ever.
  final int newlyLearned;

  bool get perfect => correctCount == itemCount;
}

/// Coins: [EconomyConfig.coinsPerCorrectSort] for a first-time correct
/// item, [EconomyConfig.coinsPerRepeatSort] for a known one, plus
/// [EconomyConfig.sortComboBonusCoins] for every [EconomyConfig.sortComboLength]
/// correct in a row. XP only for a good round. Mistakes never cost anything.
CleanupScore scoreCleanup(
  List<SortedItem> sorted,
  RecyclingProgress before,
  EconomyConfig economy,
) {
  var coins = 0;
  var combo = 0;
  var bestCombo = 0;
  var correct = 0;
  var newlyLearned = 0;

  for (final item in sorted) {
    if (!item.correct) {
      combo = 0;
      continue;
    }
    correct++;
    combo++;
    bestCombo = max(bestCombo, combo);
    final firstTime = !before.learnedItemIds.contains(item.itemId);
    if (firstTime) newlyLearned++;
    coins += firstTime ? economy.coinsPerCorrectSort : economy.coinsPerRepeatSort;
    if (combo % economy.sortComboLength == 0) {
      coins += economy.sortComboBonusCoins;
    }
  }

  final good = sorted.isNotEmpty &&
      correct * 100 >= economy.cleanupGoodRoundPercent * sorted.length;
  return CleanupScore(
    correctCount: correct,
    itemCount: sorted.length,
    coins: coins,
    xp: good ? economy.cleanupGoodRoundXp : 0,
    bestCombo: bestCombo,
    newlyLearned: newlyLearned,
  );
}

/// A clean room makes a hatched pet cleaner as well.
PetState petAfterCleanup(PetState pet, DateTime now, EconomyConfig economy) {
  if (pet.stage == PetStage.egg) return pet;
  final current = petNow(pet, now, economy);
  return current.copyWith(
    cleanliness: current.cleanliness + economy.cleanupPetCleanliness,
    needsUpdatedAt: now,
  );
}
