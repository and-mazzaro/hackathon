import 'json_utils.dart';
import 'quiz_question.dart';

/// The five bins of the game. [id] is used in content files: never change
/// an id; renaming the enum value is fine.
enum WasteCategory {
  plasticMetal('plastic_metal'),
  paper('paper'),
  organic('organic'),
  glass('glass'),
  residual('residual');

  const WasteCategory(this.id);

  final String id;

  static WasteCategory? fromId(String? id) {
    for (final category in values) {
      if (category.id == id) return category;
    }
    return null;
  }
}

/// One item to sort, from `assets/content/waste_items_it.json`.
class WasteItem {
  const WasteItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.difficulty,
    required this.explanation,
    required this.source,
    this.localNote,
  });

  final String id;
  final String name;

  /// A key such as "bottle"; the UI maps it to an icon.
  final String icon;

  /// The bin suggested by national guidance.
  final WasteCategory category;

  /// 1 = obvious, 2 = needs some knowledge, 3 = tricky edge case.
  final int difficulty;

  /// Why it goes in that bin (shown after a mistake, and on request).
  final String explanation;

  /// Set when municipalities really differ, e.g. drink cartons.
  final String? localNote;
  final ContentSource source;

  bool get tricky => difficulty >= 3;

  factory WasteItem.fromJson(Json json) {
    final id = readString(json, 'id');
    final name = readString(json, 'name');
    final category = WasteCategory.fromId(readString(json, 'category'));
    final explanation = readString(json, 'explanation');
    if (id == null || name == null || category == null ||
        explanation == null) {
      throw FormatException('Waste item "$id" is missing fields or has an '
          'unknown category');
    }
    final difficulty = readInt(json, 'difficulty');
    if (difficulty < 1 || difficulty > 3) {
      throw FormatException('Waste item "$id" has difficulty $difficulty');
    }
    return WasteItem(
      id: id,
      name: name,
      icon: readString(json, 'icon') ?? 'generic',
      category: category,
      difficulty: difficulty,
      explanation: explanation,
      localNote: readString(json, 'localNote'),
      source: ContentSource.fromJson(readObject(json, 'source')),
    );
  }
}

/// All waste items from the content file.
class WasteBank {
  WasteBank(List<WasteItem> items) : items = List.unmodifiable(items);

  final List<WasteItem> items;

  /// File layout: `{ "version": 1, "items": [ ... ] }`.
  factory WasteBank.fromJson(Json json) {
    final list = json['items'];
    if (list is! List) throw const FormatException('"items" should be a list');
    final items = [
      for (final entry in list)
        WasteItem.fromJson((entry as Map).cast<String, Object?>()),
    ];
    final ids = <String>{};
    for (final item in items) {
      if (!ids.add(item.id)) {
        throw FormatException('Duplicate waste item id ${item.id}');
      }
    }
    return WasteBank(items);
  }
}
