import 'dart:math';

import 'package:ecoquest/domain/models/cosmetic_item.dart';
import 'package:ecoquest/domain/models/inventory.dart';
import 'package:ecoquest/domain/rules/cosmetic_rules.dart';
import 'package:ecoquest/domain/rules/economy_config.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/cosmetic_fixtures.dart';

void main() {
  const economy = EconomyConfig.defaults;

  test('commons and rares are sold, epics only come from the roll', () {
    expect(shopPrice(CosmeticRarity.common, economy), 60);
    expect(shopPrice(CosmeticRarity.rare, economy), 150);
    expect(shopPrice(CosmeticRarity.epic, economy), isNull);
  });

  test('the odds shown to the player add up to 100', () {
    final total = CosmeticRarity.values
        .map((r) => rollOdds(r, economy))
        .reduce((a, b) => a + b);
    expect(total, 100);
  });

  test('rarer duplicates pay back more coins', () {
    expect(duplicateRefund(CosmeticRarity.common, economy), 20);
    expect(duplicateRefund(CosmeticRarity.rare, economy), 40);
    expect(duplicateRefund(CosmeticRarity.epic, economy), 80);
  });

  test('10 000 rolls follow the shown odds (±2%)', () {
    final catalog = testCosmeticCatalog();
    final random = Random(7);
    final counts = {for (final r in CosmeticRarity.values) r: 0};
    for (var i = 0; i < 10000; i++) {
      final item = pickRolledCosmetic(catalog, random, economy);
      counts[item.rarity] = counts[item.rarity]! + 1;
    }
    for (final rarity in CosmeticRarity.values) {
      expect(counts[rarity]! / 100, closeTo(rollOdds(rarity, economy), 2),
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
      final inventory = const Inventory().add('a').equip('neck', 'a');
      final copy = Inventory.fromJson(inventory.toJson());
      expect(copy.ownedItemIds, {'a'});
      expect(copy.equippedBySlot, {'neck': 'a'});

      final old = Inventory.fromJson(const {});
      expect(old.ownedItemIds, isEmpty);
      expect(old.equippedBySlot, isEmpty);
    });
  });
}
