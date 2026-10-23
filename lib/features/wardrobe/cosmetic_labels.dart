import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/content/cosmetic_content.dart';
import '../../domain/game_controller.dart';
import '../../domain/models/cosmetic_item.dart';
import '../../l10n/app_localizations.dart';

/// Italian names for slots and rarities (UI layer only).
extension CosmeticSlotLabels on CosmeticSlot {
  String label(AppLocalizations l10n) => switch (this) {
        CosmeticSlot.head => l10n.slotHead,
        CosmeticSlot.face => l10n.slotFace,
        CosmeticSlot.neck => l10n.slotNeck,
        CosmeticSlot.paws => l10n.slotPaws,
      };
}

extension CosmeticRarityLabels on CosmeticRarity {
  String label(AppLocalizations l10n) => switch (this) {
        CosmeticRarity.common => l10n.rarityCommon,
        CosmeticRarity.uncommon => l10n.rarityUncommon,
        CosmeticRarity.rare => l10n.rarityRare,
        CosmeticRarity.epic => l10n.rarityEpic,
        CosmeticRarity.legendary => l10n.rarityLegendary,
        CosmeticRarity.mythic => l10n.rarityMythic,
      };

  /// Light tint behind dark text (contrast ≥ 4.5:1 with the ink colour).
  Color get tint => switch (this) {
        CosmeticRarity.common => const Color(0xFFE2E4E3),
        CosmeticRarity.uncommon => const Color(0xFFD5EDC8),
        CosmeticRarity.rare => const Color(0xFFCFE3FA),
        CosmeticRarity.epic => const Color(0xFFE6D6F7),
        CosmeticRarity.legendary => const Color(0xFFFFE9A8),
        CosmeticRarity.mythic => const Color(0xFFFAD2EC),
      };
}

/// What the pet is wearing now, slot → item. Empty while the catalog
/// loads; items no longer in the content are skipped.
final petOutfitProvider = Provider<Map<CosmeticSlot, CosmeticItem>>((ref) {
  final catalog = ref.watch(cosmeticCatalogProvider).value;
  final game = ref.watch(gameControllerProvider).value;
  if (catalog == null || game == null) return const {};
  return {
    for (final MapEntry(key: slotId, value: itemId)
        in game.inventory.equippedBySlot.entries)
      if ((CosmeticSlot.fromId(slotId), catalog.byId(itemId))
          case (final slot?, final item?) when item.slot == slot)
        slot: item,
  };
});
