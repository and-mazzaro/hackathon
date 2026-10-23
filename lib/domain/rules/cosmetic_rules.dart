import 'dart:math';

import '../models/cosmetic_item.dart';
import 'economy_config.dart';

/// Coins needed to buy [rarity] in the shop, or null when it is not sold
/// (epic items come only from the reward roll).
int? shopPrice(CosmeticRarity rarity, EconomyConfig economy) =>
    switch (rarity) {
      CosmeticRarity.common => economy.shopPriceCommon,
      CosmeticRarity.rare => economy.shopPriceRare,
      CosmeticRarity.epic => null,
    };

/// Chance in percent that a roll gives an item of [rarity].
int rollOdds(CosmeticRarity rarity, EconomyConfig economy) => switch (rarity) {
  CosmeticRarity.common => economy.rollOddsCommon,
  CosmeticRarity.rare => economy.rollOddsRare,
  CosmeticRarity.epic => economy.rollOddsEpic,
};

/// Coins paid back when a roll gives an item the player already owns.
int duplicateRefund(CosmeticRarity rarity, EconomyConfig economy) =>
    switch (rarity) {
      CosmeticRarity.common => economy.duplicateRefundCommon,
      CosmeticRarity.rare => economy.duplicateRefundRare,
      CosmeticRarity.epic => economy.duplicateRefundEpic,
    };

/// One reward roll: first the rarity, with exactly the odds shown to the
/// player, then one item of that rarity, each equally likely. Owned items
/// can come out again (they are paid back in coins).
///
/// A rarity with no items in the catalog falls back to the next more
/// common one, so a small catalog never breaks the roll.
CosmeticItem pickRolledCosmetic(
  CosmeticCatalog catalog,
  Random random,
  EconomyConfig economy,
) {
  if (catalog.items.isEmpty) {
    throw StateError('Cannot roll: the cosmetic catalog is empty');
  }
  final ticket = random.nextInt(100);
  var rarity = CosmeticRarity.common;
  var threshold = 0;
  for (final candidate in CosmeticRarity.values) {
    threshold += rollOdds(candidate, economy);
    if (ticket < threshold) {
      rarity = candidate;
      break;
    }
  }

  for (var index = rarity.index; index >= 0; index--) {
    final pool = catalog.withRarity(CosmeticRarity.values[index]);
    if (pool.isNotEmpty) return pool[random.nextInt(pool.length)];
  }
  return catalog.items[random.nextInt(catalog.items.length)];
}
