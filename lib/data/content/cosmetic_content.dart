import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/cosmetic_item.dart';

/// Items the pet can wear (names in Italian).
const cosmeticContentAsset = 'assets/content/cosmetics_it.json';

/// All cosmetics, loaded once. Tests override it with a small catalog.
final cosmeticCatalogProvider = FutureProvider<CosmeticCatalog>((ref) async {
  final text = await rootBundle.loadString(cosmeticContentAsset);
  return CosmeticCatalog.fromJson(
    (jsonDecode(text) as Map).cast<String, Object?>(),
  );
});
