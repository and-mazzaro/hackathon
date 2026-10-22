import 'models/recycling_progress.dart';
import 'models/waste_item.dart';

/// What happened after putting an item in a bin.
class SortFeedback {
  const SortFeedback({
    required this.item,
    required this.chosen,
    required this.correct,
    required this.combo,
    required this.comboBonus,
  });

  final WasteItem item;
  final WasteCategory chosen;
  final bool correct;

  /// Correct sorts in a row, including this one (0 after a mistake).
  final int combo;

  /// True when this sort completed a combo (e.g. 3, 6, 9 in a row).
  final bool comboBonus;
}

/// Runs one cleanup round. Plain Dart: the screen only displays it.
///
/// Flow: [select] an item (tap or start of a drag), then [sortInto] a bin.
/// A wrong item still leaves the room (it goes to the right bin) so the
/// round never gets stuck: mistakes teach, they do not block.
class CleanupRound {
  CleanupRound({
    required List<WasteItem> items,
    required this.roundId,
    this.comboLength = 3,
  }) : _remaining = [...items];

  /// Unique per round; the reward is claimed as `sort:roundId`.
  final String roundId;
  final int comboLength;

  final List<WasteItem> _remaining;
  final List<SortedItem> _sorted = [];
  WasteItem? _selected;
  int _combo = 0;

  List<WasteItem> get remaining => List.unmodifiable(_remaining);
  WasteItem? get selected => _selected;
  int get sortedCount => _sorted.length;
  int get total => _sorted.length + _remaining.length;
  int get combo => _combo;
  bool get isFinished => _remaining.isEmpty;
  bool get hasStarted => _sorted.isNotEmpty;

  /// Selects an item still in the room (tapping it again deselects it).
  void select(WasteItem item) {
    if (!_remaining.contains(item)) return;
    _selected = identical(_selected, item) ? null : item;
  }

  /// Puts [item] (default: the selected one) into [bin].
  /// Returns null when there is nothing to sort.
  SortFeedback? sortInto(WasteCategory bin, {WasteItem? item}) {
    final target = item ?? _selected;
    if (target == null || !_remaining.remove(target)) return null;
    _selected = null;

    final correct = target.category == bin;
    _combo = correct ? _combo + 1 : 0;
    _sorted.add(SortedItem(itemId: target.id, correct: correct));
    return SortFeedback(
      item: target,
      chosen: bin,
      correct: correct,
      combo: _combo,
      comboBonus: correct && _combo % comboLength == 0,
    );
  }

  /// All sorted items, for scoring and saving. Only complete rounds count.
  List<SortedItem> get results {
    assert(isFinished, 'Finish the round before reading the results');
    return List.unmodifiable(_sorted);
  }
}
