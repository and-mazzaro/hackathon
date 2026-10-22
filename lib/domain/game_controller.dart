import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/save/save_repository.dart';
import 'models/eco_topic.dart';
import 'models/game_state.dart';
import 'models/player_profile.dart';
import 'models/reward.dart';
import 'rules/economy_config.dart';
import 'rules/profile_rules.dart';
import 'rules/progression.dart';

/// The balancing numbers. Tests can override this with other values.
final economyProvider = Provider<EconomyConfig>((ref) => EconomyConfig.defaults);

/// The current time. Tests override this to control dates.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// The saved game. Widgets read it with `ref.watch(gameControllerProvider)`
/// and change it ONLY through the methods of [GameController].
final gameControllerProvider =
    AsyncNotifierProvider<GameController, GameState>(GameController.new);

/// The result of [GameController.claimReward], for reward animations.
class ClaimResult {
  const ClaimResult({
    required this.applied,
    required this.reward,
    required this.levelBefore,
    required this.levelAfter,
  });

  /// False when this claim id was already paid before (nothing changed).
  final bool applied;
  final Reward reward;
  final int levelBefore;
  final int levelAfter;

  bool get leveledUp => levelAfter > levelBefore;
}

/// The single place where the game state changes.
///
/// Every change: compute the new state → show it → save it.
///
/// CONTRACT for the feature teams — build on [claimReward], never add coins
/// or XP yourself. Use claim ids of the form `feature:uniqueId`:
///
/// | Planned method (milestone)         | Builds on / claim id                |
/// |------------------------------------|-------------------------------------|
/// | `completeQuiz` (quiz)              | claimReward, `quiz:sessionId`       |
/// | `sortWasteItem` (recycling)        | claimReward, `sort:roundId:itemNo`  |
/// | `claimMission` (missions)          | claimReward, `mission:missionId:day`|
/// | `spendCoins` / `buyItem` (shop)    | new spend method, same pattern      |
/// | `rollCosmetic`, `equip` (cosmetics)| inventory update                    |
/// | `feedPet`, `cleanPet` (pet)        | pet update                          |
class GameController extends AsyncNotifier<GameState> {
  SaveRepository get _repository => ref.read(saveRepositoryProvider);
  EconomyConfig get _economy => ref.read(economyProvider);
  DateTime _now() => ref.read(clockProvider)();

  @override
  Future<GameState> build() async {
    final saved = await ref.watch(saveRepositoryProvider).load();
    return saved ?? GameState.initial(now: _now(), economy: _economy);
  }

  /// The current level, derived from the total XP.
  LevelInfo get levelInfo =>
      levelForTotalXp(state.requireValue.progress.totalXp, _economy);

  /// Pays [reward] once for [claimId]. Calling it again with the same id
  /// (double tap, back button, app restart) changes nothing.
  Future<ClaimResult> claimReward(String claimId, Reward reward) async {
    final current = state.requireValue;
    final progress = current.progress;
    final levelBefore = levelForTotalXp(progress.totalXp, _economy).level;

    if (progress.claimedRewardIds.contains(claimId)) {
      return ClaimResult(
        applied: false,
        reward: Reward.none,
        levelBefore: levelBefore,
        levelAfter: levelBefore,
      );
    }

    final updated = progress.copyWith(
      totalXp: progress.totalXp + reward.xp,
      coins: progress.coins + reward.coins,
      tickets: progress.tickets + reward.tickets,
      claimedRewardIds: {...progress.claimedRewardIds, claimId},
    );
    await _commit(current.copyWith(progress: updated));

    return ClaimResult(
      applied: true,
      reward: reward,
      levelBefore: levelBefore,
      levelAfter: levelForTotalXp(updated.totalXp, _economy).level,
    );
  }

  /// Saves the onboarding answers. Progress is left untouched.
  /// [nickname] is cleaned with `normalizeNickname`.
  Future<void> completeOnboarding({
    required Set<EcoTopic> interests,
    String? nickname,
    AgeRange? ageRange,
  }) async {
    final current = state.requireValue;
    await _commit(current.copyWith(
      profile: PlayerProfile(
        createdAt: current.profile.createdAt,
        nickname: normalizeNickname(nickname),
        ageRange: ageRange,
        interests: interests,
        onboardingCompleted: true,
      ),
    ));
  }

  /// Changes nickname and age range from the profile. Passing null clears
  /// them. Interests and progress stay as they are.
  Future<void> updateProfileDetails({
    required String? nickname,
    required AgeRange? ageRange,
  }) async {
    final current = state.requireValue;
    final profile = current.profile;
    await _commit(current.copyWith(
      profile: PlayerProfile(
        createdAt: profile.createdAt,
        nickname: normalizeNickname(nickname),
        ageRange: ageRange,
        interests: profile.interests,
        onboardingCompleted: profile.onboardingCompleted,
      ),
    ));
  }

  /// Changes the interests at any time. XP, coins, pet and items stay
  /// exactly as they are, and onboarding does not restart.
  /// An empty set means "no preference" (recommendations use all topics);
  /// the UI asks the player to keep at least one.
  Future<void> updateInterests(Set<EcoTopic> interests) async {
    final current = state.requireValue;
    await _commit(current.copyWith(
      profile: current.profile.copyWith(interests: interests),
    ));
  }

  /// Starts a new game, replacing the saved one. Used by the "start over"
  /// button when the save cannot be read. Works even in the error state.
  Future<void> startFresh() async {
    await _commit(GameState.initial(now: _now(), economy: _economy));
  }

  /// Shows the new state immediately, then saves it.
  ///
  /// The state is set before the await, so two quick calls in a row both
  /// see the latest state and no change gets lost.
  Future<void> _commit(GameState next) async {
    state = AsyncData(next);
    await _repository.save(next);
  }
}
