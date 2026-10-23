import 'dart:math';

import '../models/waste_item.dart';
import 'economy_config.dart';

/// Hours between two pieces of trash appearing in the pet's room.
///
/// A low comeback score (player likely away) makes trash appear sooner,
/// so there is something to do when they come back; a high score makes
/// it slower, so a daily player is not asked to clean all the time.
int roomTrashHoursPerItem(int comebackScore, EconomyConfig economy) {
  if (comebackScore < economy.comebackLowScore) {
    return economy.roomTrashHoursLowScore;
  }
  if (comebackScore >= economy.roomTrashHighScore) {
    return economy.roomTrashHoursHighScore;
  }
  return economy.roomTrashHoursMidScore;
}

/// How many pieces of trash are in the room now (0 to
/// [EconomyConfig.roomTrashMax]): one more every
/// [roomTrashHoursPerItem] hours since the last cleanup.
///
/// No cleanup saved yet (new player or an old save) →
/// [EconomyConfig.roomTrashWithoutCleanup], so the room can be cleaned
/// right away. A clock that went backwards → 0 (never a crash).
int roomTrashCount(
  DateTime? lastCleanupAt,
  DateTime now,
  int comebackScore, {
  EconomyConfig economy = EconomyConfig.defaults,
}) {
  if (lastCleanupAt == null) {
    return economy.roomTrashWithoutCleanup.clamp(0, economy.roomTrashMax);
  }
  if (now.isBefore(lastCleanupAt)) return 0;
  final minutesPerItem = roomTrashHoursPerItem(comebackScore, economy) * 60;
  if (minutesPerItem <= 0) return economy.roomTrashMax;
  final items = now.difference(lastCleanupAt).inMinutes ~/ minutesPerItem;
  return items.clamp(0, economy.roomTrashMax);
}

/// Which waste items lie in the room: [count] items from [bank], chosen
/// with a seed from [lastCleanupAt], so the same items stay there (and a
/// new one is just added) until the room is cleaned.
List<WasteItem> pickRoomTrash(
  List<WasteItem> bank,
  int count,
  DateTime? lastCleanupAt,
) {
  if (count <= 0 || bank.isEmpty) return const [];
  final seed = (lastCleanupAt?.millisecondsSinceEpoch ?? 0) % 0x7fffffff;
  final shuffled = [...bank]..shuffle(Random(seed));
  return shuffled.take(count).toList();
}
