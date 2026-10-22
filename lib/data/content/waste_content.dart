import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/waste_item.dart';

/// Italian waste items for Room Cleanup (general national guidance).
const wasteContentAsset = 'assets/content/waste_items_it.json';

/// All waste items, loaded once. Tests override it with a small bank.
final wasteBankProvider = FutureProvider<WasteBank>((ref) async {
  final text = await rootBundle.loadString(wasteContentAsset);
  return WasteBank.fromJson((jsonDecode(text) as Map).cast<String, Object?>());
});
