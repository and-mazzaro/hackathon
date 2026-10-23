import 'dart:math';

import 'package:ecoquest/domain/models/cosmetic_item.dart';
import 'package:ecoquest/domain/models/inventory.dart';
import 'package:ecoquest/domain/rules/cosmetic_rules.dart';
import 'package:ecoquest/domain/rules/economy_config.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/cosmetic_fixtures.dart';

void main() {
  const economy = EconomyConfig.defaults;

  test('the test catalog has one item per slot and rarity', () {
    final catalog = testCosmeticCatalog();
    expect(catalog.items, hasLength(4 * 6));
    expect(catalog.byId('paws_mythic')!.name, 'Oggetto paws mythic');
  });

  group('shop', () {
    test('commons, uncommons and rares are sold (60/100/160)', () {
      expect(shopPrice(CosmeticRarity.common, economy), 60);
      expect(shopPrice(CosmeticRarity.uncommon, economy), 100);
      expect(shopPrice(CosmeticRarity.rare, economy), 160);
    });

    test('epic, legendary and mythic come only from the roll', () {
      expect(shopPrice(CosmeticRarity.epic, economy), isNull);
      expect(shopPrice(CosmeticRarity.legendary, economy), isNull);
      expect(shopPrice(CosmeticRarity.mythic, economy), isNull);
      expect(economy.shopPrices.keys, {
        CosmeticRarity.common,
        CosmeticRarity.uncommon,
        CosmeticRarity.rare,
      });
    });

    test('a rarer item never costs less', () {
      final prices = [
        for (final rarity in CosmeticRarity.values) ?shopPrice(rarity, economy),
      ];
      for (var i = 1; i < prices.length; i++) {
        expect(prices[i], greaterThan(prices[i - 1]));
      }
    });
  });

  group('roll odds', () {
    test('the odds shown to the player are 40/25/17/10/6/2', () {
      expect([for (final r in CosmeticRarity.values) rollOdds(r, economy)],
          [40, 25, 17, 10, 6, 2]);
    });

    // The constructor does not check the odds any more: this test does.
    test('the default odds cover every rarity and add up to 100', () {
      expect(economy.rollOddsPercent.keys.toSet(),
          CosmeticRarity.values.toSet());
      for (final rarity in CosmeticRarity.values) {
        expect(rollOdds(rarity, economy), greaterThan(0), reason: rarity.id);
      }
      final total = CosmeticRarity.values
          .map((r) => rollOdds(r, economy))
          .reduce((a, b) => a + b);
      expect(total, 100);
    });

    test('rarer means less likely', () {
      for (var i = 1; i < CosmeticRarity.values.length; i++) {
        expect(rollOdds(CosmeticRarity.values[i], economy),
            lessThan(rollOdds(CosmeticRarity.values[i - 1], economy)));
      }
    });
  });

  group('duplicates', () {
    test('refunds are 15/25/40/60/90/150', () {
      expect(
          [for (final r in CosmeticRarity.values) duplicateRefund(r, economy)],
          [15, 25, 40, 60, 90, 150]);
    });

    test('refunds strictly increase with rarity', () {
      expect(economy.duplicateRefunds.keys.toSet(),
          CosmeticRarity.values.toSet());
      for (var i = 1; i < CosmeticRarity.values.length; i++) {
        expect(duplicateRefund(CosmeticRarity.values[i], economy),
            greaterThan(duplicateRefund(CosmeticRarity.values[i - 1], economy)),
            reason: CosmeticRarity.values[i].id);
      }
    });
  });

  test('20 000 seeded rolls follow the shown odds (±1.5 points)', () {
    final catalog = testCosmeticCatalog();
    final random = Random(7);
    const rolls = 20000;
    final counts = {for (final r in CosmeticRarity.values) r: 0};
    for (var i = 0; i < rolls; i++) {
      final item = pickRolledCosmetic(catalog, random, economy);
      counts[item.rarity] = counts[item.rarity]! + 1;
    }
    for (final rarity in CosmeticRarity.values) {
      final percent = counts[rarity]! * 100 / rolls;
      expect(percent, closeTo(rollOdds(rarity, economy), 1.5),
          reason: rarity.id);
    }
  });

  test('a rarity without items falls back to a more common one', () {
    final onlyCommons = CosmeticCatalog([
      testCosmetic(CosmeticSlot.head, CosmeticRarity.common),
    ]);
    final random = Random(1);
    for (var i = 0; i < 50; i++) {
      expect(pickRolledCosmetic(onlyCommons, random, economy).id,
          'head_common');
    }
  });

  test('without commons, a common roll still gives an item', () {
    final onlyMythic = CosmeticCatalog([
      testCosmetic(CosmeticSlot.paws, CosmeticRarity.mythic),
    ]);
    final random = Random(1);
    for (var i = 0; i < 50; i++) {
      expect(pickRolledCosmetic(onlyMythic, random, economy).id,
          'paws_mythic');
    }
  });

  test('the same seed gives the same roll', () {
    final catalog = testCosmeticCatalog();
    expect(pickRolledCosmetic(catalog, Random(3), economy).id,
        pickRolledCosmetic(catalog, Random(3), economy).id);
  });

  group('Inventory', () {
    test('equip replaces the item in the same slot; unequip clears it', () {
      final inventory = const Inventory()
          .add('a')
          .add('b')
          .equip('head', 'a')
          .equip('head', 'b');
      expect(inventory.equippedBySlot, {'head': 'b'});
      expect(inventory.unequip('head').equippedBySlot, isEmpty);
    });

    test('JSON round trip, and an old save without inventory loads', () {
      final inventory = const Inventory()
          .add('a')
          .add('p')
          .equip('neck', 'a')
          .equip('paws', 'p');
      final copy = Inventory.fromJson(inventory.toJson());
      expect(copy.ownedItemIds, {'a', 'p'});
      expect(copy.equippedBySlot, {'neck': 'a', 'paws': 'p'});

      final old = Inventory.fromJson(const {});
      expect(old.ownedItemIds, isEmpty);
      expect(old.equippedBySlot, isEmpty);
    });
  });
}
