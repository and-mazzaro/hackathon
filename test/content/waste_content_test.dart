import 'dart:convert';
import 'dart:io';

import 'package:ecoquest/data/content/waste_content.dart';
import 'package:ecoquest/domain/models/waste_item.dart';
import 'package:ecoquest/features/cleanup/waste_labels.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Checks the REAL waste item file. Run `flutter test test/content`
/// after editing it.
void main() {
  late WasteBank bank;
  late List<Map<String, Object?>> raw;

  setUpAll(() {
    final json = (jsonDecode(File(wasteContentAsset).readAsStringSync())
            as Map)
        .cast<String, Object?>();
    raw = [
      for (final item in json['items']! as List)
        (item as Map).cast<String, Object?>(),
    ];
    bank = WasteBank.fromJson(json); // also checks ids are unique
  });

  test('enough items for rounds of 8, with tricky ones', () {
    expect(bank.items.length, greaterThanOrEqualTo(16));
    expect(bank.items.where((i) => i.tricky).length, greaterThanOrEqualTo(3));
  });

  test('every bin has at least 3 items', () {
    for (final category in WasteCategory.values) {
      expect(bank.items.where((i) => i.category == category).length,
          greaterThanOrEqualTo(3),
          reason: category.id);
    }
  });

  test('ids look like waste_000', () {
    for (final item in bank.items) {
      expect(item.id, matches(RegExp(r'^waste_\d{3}$')));
    }
  });

  test('every icon key is known (no generic fallback by mistake)', () {
    for (final item in raw) {
      final key = item['icon']! as String;
      expect(wasteIcon(key) != Icons.delete_outline_rounded || key == 'generic',
          isTrue,
          reason: '${item['id']}: unknown icon "$key"');
    }
  });

  test('texts fit on a phone screen', () {
    for (final item in bank.items) {
      expect(item.name.length, lessThanOrEqualTo(45), reason: item.id);
      expect(item.explanation.trim(), isNotEmpty, reason: item.id);
      expect(item.explanation.length, lessThanOrEqualTo(260), reason: item.id);
      expect(item.localNote?.length ?? 0, lessThanOrEqualTo(160),
          reason: item.id);
    }
  });

  test('every item has a verified https source and an excerpt', () {
    final today = DateTime.now();
    for (final item in bank.items) {
      final uri = Uri.tryParse(item.source.url);
      expect(uri?.scheme, 'https', reason: item.id);
      expect(uri!.host, isNot(contains('example')), reason: item.id);
      expect(item.source.verifiedOn.isAfter(today), isFalse, reason: item.id);
    }
    for (final item in raw) {
      expect((item['sourceExcerpt'] as String?)?.trim(), isNotEmpty,
          reason: '${item['id']}');
    }
  });
}
