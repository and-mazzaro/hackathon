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

/// One item per slot and rarity (4 slots x 6 rarities = 24), in slot
/// order, commons first.
CosmeticCatalog testCosmeticCatalog() => CosmeticCatalog([
      for (final slot in CosmeticSlot.values)
        for (final rarity in CosmeticRarity.values) testCosmetic(slot, rarity),
    ]);
