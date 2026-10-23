import 'json_utils.dart';

/// Where an item sits on the pet. [id] is used in content files and in the
/// save (`Inventory.equippedBySlot`): never change an id.
enum CosmeticSlot {
  /// Replaces the green leaf on the otter's head.
  head('head'),
  face('face'),

  /// Replaces the green bandana.
  neck('neck'),

  /// Something held between the front paws (otters keep a favourite pebble).
  paws('paws');

  const CosmeticSlot(this.id);

  final String id;

  static CosmeticSlot? fromId(String? id) {
    for (final slot in values) {
      if (slot.id == id) return slot;
    }
    return null;
  }
}

/// How rare an item is, from the most to the least common: decides its
/// shop price, its roll odds and the coins paid back for a duplicate (all
/// in `EconomyConfig`). The order of the values matters for the roll.
enum CosmeticRarity {
  common('common'),
  uncommon('uncommon'),
  rare('rare'),
  epic('epic'),
  legendary('legendary'),
  mythic('mythic');

  const CosmeticRarity(this.id);

  final String id;

  static CosmeticRarity? fromId(String? id) {
    for (final rarity in values) {
      if (rarity.id == id) return rarity;
    }
    return null;
  }
}

/// One thing the pet can wear, from `assets/content/cosmetics_it.json`.
class CosmeticItem {
  const CosmeticItem({
    required this.id,
    required this.name,
    required this.slot,
    required this.rarity,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final CosmeticSlot slot;
  final CosmeticRarity rarity;

  /// A key such as "crown"; the UI maps it to an icon.
  final String icon;

  /// ARGB colour of the drawn item, e.g. 0xFFE5578A.
  final int color;

  factory CosmeticItem.fromJson(Json json) {
    final id = readString(json, 'id');
    final name = readString(json, 'name');
    final slot = CosmeticSlot.fromId(readString(json, 'slot'));
    final rarity = CosmeticRarity.fromId(readString(json, 'rarity'));
    final color = readString(json, 'color');
    final argb = color == null ? null : int.tryParse(color, radix: 16);
    if (id == null ||
        name == null ||
        slot == null ||
        rarity == null ||
        argb == null) {
      throw FormatException(
        'Cosmetic "$id" is missing fields or has an '
        'unknown slot, rarity or colour',
      );
    }
    return CosmeticItem(
      id: id,
      name: name,
      slot: slot,
      rarity: rarity,
      icon: readString(json, 'icon') ?? 'generic',
      color: argb,
    );
  }
}

/// All cosmetics from the content file.
class CosmeticCatalog {
  CosmeticCatalog(List<CosmeticItem> items)
    : items = List.unmodifiable(items),
      _byId = {for (final item in items) item.id: item};

  static final empty = CosmeticCatalog(const []);

  final List<CosmeticItem> items;
  final Map<String, CosmeticItem> _byId;

  /// Null for ids that are no longer in the content (old saves).
  CosmeticItem? byId(String id) => _byId[id];

  List<CosmeticItem> withRarity(CosmeticRarity rarity) =>
      items.where((item) => item.rarity == rarity).toList();

  /// File layout: `{ "version": 1, "items": [ ... ] }`.
  factory CosmeticCatalog.fromJson(Json json) {
    final list = json['items'];
    if (list is! List) throw const FormatException('"items" should be a list');
    final items = [
      for (final entry in list)
        CosmeticItem.fromJson((entry as Map).cast<String, Object?>()),
    ];
    final ids = <String>{};
    for (final item in items) {
      if (!ids.add(item.id)) {
        throw FormatException('Duplicate cosmetic id ${item.id}');
      }
    }
    return CosmeticCatalog(items);
  }
}
