import 'dart:convert';
import 'dart:io';

import 'package:ecoquest/data/content/cosmetic_content.dart';
import 'package:ecoquest/domain/models/cosmetic_item.dart';
import 'package:ecoquest/features/wardrobe/cosmetic_art.dart';
import 'package:flutter_test/flutter_test.dart';

/// Checks the REAL cosmetics file. Run `flutter test test/content`
/// after editing it.
void main() {
  late CosmeticCatalog catalog;

  setUpAll(() {
    final json = (jsonDecode(File(cosmeticContentAsset).readAsStringSync())
            as Map)
        .cast<String, Object?>();
    catalog = CosmeticCatalog.fromJson(json); // also checks ids are unique
  });

  test('every slot has items, and every rarity exists', () {
    for (final slot in CosmeticSlot.values) {
      expect(catalog.items.where((i) => i.slot == slot), isNotEmpty,
          reason: slot.id);
    }
    for (final rarity in CosmeticRarity.values) {
      expect(catalog.withRarity(rarity), isNotEmpty, reason: rarity.id);
    }
  });

  test('ids start with their slot', () {
    for (final item in catalog.items) {
      expect(item.id, startsWith('${item.slot.id}_'));
    }
  });

  test('every icon key has a drawing (no star fallback by mistake)', () {
    for (final item in catalog.items) {
      expect(cosmeticArtKeys, contains(item.icon), reason: item.id);
    }
  });

  test('colours are opaque', () {
    for (final item in catalog.items) {
      expect(item.color >> 24, 0xFF, reason: item.id);
    }
  });

  test('names are filled in and all different', () {
    final names = <String>{};
    for (final item in catalog.items) {
      expect(item.name.trim(), isNotEmpty, reason: item.id);
      expect(names.add(item.name.trim().toLowerCase()), isTrue,
          reason: 'name "${item.name}" used twice');
    }
  });
}
