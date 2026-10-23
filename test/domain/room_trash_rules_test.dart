import 'package:ecoquest/domain/models/game_state.dart';
import 'package:ecoquest/domain/models/waste_item.dart';
import 'package:ecoquest/domain/rules/economy_config.dart';
import 'package:ecoquest/domain/rules/room_trash_rules.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/waste_fixtures.dart';

void main() {
  final cleaned = DateTime(2026, 10, 22, 10);
  DateTime after(int hours, [int minutes = 0]) =>
      cleaned.add(Duration(hours: hours, minutes: minutes));

  group('roomTrashCount', () {
    test('no cleanup saved yet (old save / new player): 2 items', () {
      expect(roomTrashCount(null, cleaned, 50), 2);
      expect(roomTrashCount(null, cleaned, 0), 2);
      expect(roomTrashCount(null, cleaned, 100), 2);
    });

    test('right after a cleanup the room is clean', () {
      expect(roomTrashCount(cleaned, cleaned, 50), 0);
      expect(roomTrashCount(cleaned, after(3, 59), 50), 0);
    });

    test('mid score: one item every 4 hours', () {
      expect(roomTrashCount(cleaned, after(4), 50), 1);
      expect(roomTrashCount(cleaned, after(8), 50), 2);
      expect(roomTrashCount(cleaned, after(12), 50), 3);
    });

    test('low score (likely away): one item every 2 hours', () {
      expect(roomTrashHoursPerItem(20, EconomyConfig.defaults), 2);
      expect(roomTrashCount(cleaned, after(1, 59), 20), 0);
      expect(roomTrashCount(cleaned, after(2), 20), 1);
      expect(roomTrashCount(cleaned, after(4), 20), 2);
    });

    test('high score: one item every 6 hours', () {
      expect(roomTrashCount(cleaned, after(5, 59), 90), 0);
      expect(roomTrashCount(cleaned, after(6), 90), 1);
      expect(roomTrashCount(cleaned, after(12), 90), 2);
    });

    test('never more than 3 items', () {
      expect(roomTrashCount(cleaned, after(24 * 30), 0), 3);
      expect(roomTrashCount(cleaned, after(24 * 30), 100), 3);
    });

    test('a clock that went backwards gives 0', () {
      expect(roomTrashCount(cleaned, after(-5), 50), 0);
      expect(roomTrashCount(cleaned, after(-24 * 365), 0), 0);
    });
  });

  group('pickRoomTrash', () {
    final bank = testWasteBank().items;

    test('same cleanup time → same items; more items keep the first ones',
        () {
      final one = pickRoomTrash(bank, 1, cleaned);
      final two = pickRoomTrash(bank, 2, cleaned);
      final twoAgain = pickRoomTrash(bank, 2, cleaned);
      expect(two.map((item) => item.id), twoAgain.map((item) => item.id));
      expect(two.first.id, one.first.id);
      expect(two.map((item) => item.id).toSet(), hasLength(2));
    });

    test('works for old saves and edge cases', () {
      expect(pickRoomTrash(bank, 2, null), hasLength(2));
      expect(pickRoomTrash(bank, 0, cleaned), isEmpty);
      expect(pickRoomTrash(const <WasteItem>[], 3, cleaned), isEmpty);
      expect(pickRoomTrash(bank.take(2).toList(), 3, cleaned), hasLength(2));
    });
  });

  group('GameState.lastCleanupAt', () {
    test('is saved and loaded; old saves have none', () {
      final state =
          GameState.initial(now: cleaned).copyWith(lastCleanupAt: after(1));
      final loaded = GameState.fromJson(state.toJson(), now: cleaned);
      expect(loaded.lastCleanupAt, after(1));

      final old = GameState.initial(now: cleaned).toJson()
        ..remove('lastCleanupAt');
      expect(GameState.fromJson(old, now: cleaned).lastCleanupAt, isNull);
    });
  });
}
