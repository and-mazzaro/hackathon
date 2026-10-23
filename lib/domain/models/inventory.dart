import 'json_utils.dart';

/// Cosmetics the player owns and which ones the pet is wearing.
///
/// Items are referenced by stable ids (e.g. "hat_leaf"); their name, price
/// and rarity live in the content files, not in the save.
class Inventory {
  const Inventory({
    this.ownedItemIds = const {},
    this.equippedBySlot = const {},
  });

  final Set<String> ownedItemIds;

  /// Slot id (e.g. "head") → item id.
  final Map<String, String> equippedBySlot;

  bool owns(String itemId) => ownedItemIds.contains(itemId);

  Inventory add(String itemId) =>
      copyWith(ownedItemIds: {...ownedItemIds, itemId});

  /// Puts [itemId] in [slotId], replacing what was there.
  Inventory equip(String slotId, String itemId) =>
      copyWith(equippedBySlot: {...equippedBySlot, slotId: itemId});

  Inventory unequip(String slotId) =>
      copyWith(equippedBySlot: {...equippedBySlot}..remove(slotId));

  Inventory copyWith({
    Set<String>? ownedItemIds,
    Map<String, String>? equippedBySlot,
  }) {
    return Inventory(
      ownedItemIds: ownedItemIds ?? this.ownedItemIds,
      equippedBySlot: equippedBySlot ?? this.equippedBySlot,
    );
  }

  Json toJson() => {
        'ownedItemIds': ownedItemIds.toList(),
        'equippedBySlot': equippedBySlot,
      };

  factory Inventory.fromJson(Json json) {
    return Inventory(
      ownedItemIds: readStringList(json, 'ownedItemIds').toSet(),
      equippedBySlot: readObject(json, 'equippedBySlot')
          .map((slot, item) => MapEntry(slot, item as String)),
    );
  }
}
