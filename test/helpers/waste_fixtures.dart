import 'package:ecoquest/domain/models/quiz_question.dart';
import 'package:ecoquest/domain/models/waste_item.dart';

/// A fake waste item. Its name says which bin is right ("… carta 2"),
/// so tests can find both the item and the correct bin.
WasteItem testWaste(WasteCategory category, int n, {int difficulty = 1}) {
  final tag = '${category.id} $n';
  return WasteItem(
    id: 'waste_${category.index}$n',
    name: 'Rifiuto $tag',
    icon: 'generic',
    category: category,
    difficulty: difficulty,
    explanation: 'Perché $tag.',
    localNote: n == 2 ? 'Nota locale $tag.' : null,
    source: ContentSource(
      name: 'Fonte rifiuti',
      url: 'https://example.org/waste/$n',
      verifiedOn: DateTime(2026, 10, 22),
    ),
  );
}

/// 2 items per bin (10 in total); the second paper item is tricky.
WasteBank testWasteBank() => WasteBank([
      for (final category in WasteCategory.values)
        for (var n = 1; n <= 2; n++)
          testWaste(
            category,
            n,
            difficulty: category == WasteCategory.paper && n == 2 ? 3 : 1,
          ),
    ]);
