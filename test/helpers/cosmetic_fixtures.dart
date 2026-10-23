import 'package:ecoquest/domain/models/cosmetic_item.dart';

/// A fake cosmetic. Its name says slot and rarity ("Oggetto head common").
CosmeticItem testCosmetic(CosmeticSlot slot, CosmeticRarity rarity) =>
    CosmeticItem(
      id: '${slot.id}_${rarity.id}',
      name: 'Oggetto ${slot.id} ${rarity.id}',
      slot: slot,
      rarity: rarity,
      icon: 'star',
      color: 0xFFE5578A,
    );

/// One item per slot and rarity (9 in total).
CosmeticCatalog testCosmeticCatalog() => CosmeticCatalog([
      for (final slot in CosmeticSlot.values)
        for (final rarity in CosmeticRarity.values) testCosmetic(slot, rarity),
    ]);
