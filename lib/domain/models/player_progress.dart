import 'json_utils.dart';

/// Resources and the list of rewards that were already paid out.
class PlayerProgress {
  const PlayerProgress({
    this.totalXp = 0,
    this.coins = 0,
    this.tickets = 0,
    this.claimedRewardIds = const {},
  });

  /// Only the total is stored; the level is always calculated from it
  /// (see `levelForTotalXp`), so level and XP can never disagree.
  final int totalXp;
  final int coins;
  final int tickets;

  /// Ids of rewards already paid, e.g. "quiz:2026-10-22T10:15:00.123".
  /// The same id is never paid twice (double taps, back button, restarts).
  final Set<String> claimedRewardIds;

  PlayerProgress copyWith({
    int? totalXp,
    int? coins,
    int? tickets,
    Set<String>? claimedRewardIds,
  }) {
    return PlayerProgress(
      totalXp: totalXp ?? this.totalXp,
      coins: coins ?? this.coins,
      tickets: tickets ?? this.tickets,
      claimedRewardIds: claimedRewardIds ?? this.claimedRewardIds,
    );
  }

  Json toJson() => {
        'totalXp': totalXp,
        'coins': coins,
        'tickets': tickets,
        'claimedRewardIds': claimedRewardIds.toList(),
      };

  factory PlayerProgress.fromJson(Json json) {
    return PlayerProgress(
      totalXp: readInt(json, 'totalXp'),
      coins: readInt(json, 'coins'),
      tickets: readInt(json, 'tickets'),
      claimedRewardIds: readStringList(json, 'claimedRewardIds').toSet(),
    );
  }
}
