import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/content/waste_content.dart';
import '../../domain/game_controller.dart';
import '../../domain/models/waste_item.dart';
import '../../domain/rules/comeback_rules.dart';
import '../../domain/rules/room_trash_rules.dart';
import '../../l10n/app_localizations.dart';

/// How much trash is in the pet's room now (0 = clean: no cleanup).
final roomTrashCountProvider = Provider<int>((ref) {
  final game = ref.watch(gameControllerProvider).value;
  if (game == null) return 0;
  final now = ref.watch(clockProvider)();
  return roomTrashCount(
    game.lastCleanupAt,
    now,
    comebackScore(game.activity, now),
    economy: ref.watch(economyProvider),
  );
});

/// The waste items lying in the room (empty while the bank loads).
final roomTrashProvider = Provider<List<WasteItem>>((ref) {
  final count = ref.watch(roomTrashCountProvider);
  if (count == 0) return const [];
  final bank = ref.watch(wasteBankProvider).value;
  if (bank == null) return const [];
  final lastCleanupAt = ref.watch(
      gameControllerProvider.select((game) => game.value?.lastCleanupAt));
  return pickRoomTrash(bank.items, count, lastCleanupAt);
});

/// The room's semantic label plus the trash in it, for screen readers.
String roomLabelWithTrash(
    String petLabel, List<WasteItem> trash, AppLocalizations l10n) {
  if (trash.isEmpty) return petLabel;
  final names = trash.map((item) => item.name).join(', ');
  return '$petLabel. ${l10n.roomTrashSemantics(trash.length, names)}';
}
