import 'json_utils.dart';

/// One item as sorted by the player in a finished round.
class SortedItem {
  const SortedItem({required this.itemId, required this.correct});

  final String itemId;
  final bool correct;
}

/// Recycling statistics, saved inside GameState. Ready for weekly goals
/// such as "sort 50 items correctly".
class RecyclingProgress {
  const RecyclingProgress({
    this.roundsCompleted = 0,
    this.itemsSorted = 0,
    this.itemsCorrect = 0,
    this.learnedItemIds = const {},
    this.recentItemIds = const [],
  });

  /// How many recent items we remember to avoid repeats.
  static const recentMemory = 24;

  final int roundsCompleted;
  final int itemsSorted;
  final int itemsCorrect;

  /// Items sorted correctly at least once (a repeat pays fewer coins).
  final Set<String> learnedItemIds;

  /// The last items shown, newest last.
  final List<String> recentItemIds;

  RecyclingProgress record(List<SortedItem> sorted) {
    final learned = {...learnedItemIds};
    final recent = [...recentItemIds];
    var correct = 0;
    for (final item in sorted) {
      if (item.correct) {
        correct++;
        learned.add(item.itemId);
      }
      recent
        ..remove(item.itemId)
        ..add(item.itemId);
    }
    final overflow = recent.length - recentMemory;
    return RecyclingProgress(
      roundsCompleted: roundsCompleted + 1,
      itemsSorted: itemsSorted + sorted.length,
      itemsCorrect: itemsCorrect + correct,
      learnedItemIds: learned,
      recentItemIds: overflow > 0 ? recent.sublist(overflow) : recent,
    );
  }

  Json toJson() => {
        'roundsCompleted': roundsCompleted,
        'itemsSorted': itemsSorted,
        'itemsCorrect': itemsCorrect,
        'learnedItemIds': learnedItemIds.toList(),
        'recentItemIds': recentItemIds,
      };

  factory RecyclingProgress.fromJson(Json json) => RecyclingProgress(
        roundsCompleted: readInt(json, 'roundsCompleted'),
        itemsSorted: readInt(json, 'itemsSorted'),
        itemsCorrect: readInt(json, 'itemsCorrect'),
        learnedItemIds: readStringList(json, 'learnedItemIds').toSet(),
        recentItemIds: readStringList(json, 'recentItemIds'),
      );
}
