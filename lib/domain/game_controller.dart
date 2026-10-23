import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/save/save_repository.dart';
import 'models/audio_settings.dart';
import 'models/cosmetic_item.dart';
import 'models/eco_topic.dart';
import 'models/game_state.dart';
import 'models/learning_progress.dart';
import 'models/pet_state.dart';
import 'models/player_profile.dart';
import 'models/recycling_progress.dart';
import 'models/reward.dart';
import 'rules/cosmetic_rules.dart';
import 'rules/economy_config.dart';
import 'rules/pet_rules.dart';
import 'rules/profile_rules.dart';
import 'rules/progression.dart';
import 'rules/quiz_rules.dart';
import 'rules/recycling_rules.dart';

/// The balancing numbers. Tests can override this with other values.
final economyProvider = Provider<EconomyConfig>((ref) => EconomyConfig.defaults);

/// The current time. Tests override this to control dates.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Randomness (question choice, option order). Tests use a fixed seed.
final randomProvider = Provider<Random>((ref) => Random());

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

/// The result of [GameController.completeQuiz], for the results screen.
class QuizOutcome {
  const QuizOutcome({
    required this.score,
    required this.claim,
    this.petHappier = false,
  });

  final QuizScore score;
  final ClaimResult claim;

  /// True when the quiz also made a hatched pet happier.
  final bool petHappier;
}

/// The result of [GameController.completeCleanup], for the results screen.
class CleanupOutcome {
  const CleanupOutcome({
    required this.score,
    required this.claim,
    this.petCleaner = false,
  });

  final CleanupScore score;
  final ClaimResult claim;

  /// True when the clean room also made a hatched pet cleaner.
  final bool petCleaner;
}

/// The answer of [GameController.buyItem] and [GameController.buyTicket].
enum PurchaseResult { bought, notEnoughCoins, alreadyOwned, notForSale }

/// The result of [GameController.rollCosmetic], for the reveal sheet.
class RollOutcome {
  const RollOutcome({
    required this.item,
    required this.isNew,
    this.refundCoins = 0,
  });

  final CosmeticItem item;

  /// False when the player already owned it: [refundCoins] were paid back.
  final bool isNew;
  final int refundCoins;
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
/// | `completeQuiz` (quiz) — DONE       | claimReward, `quiz:sessionId`       |
/// | `completeCleanup` — DONE           | claimReward, `sort:roundId`         |
/// | `claimMission` (missions)          | claimReward, `mission:missionId:day`|
/// | `buyTicket`, `buyItem` — DONE      | spend coins, inventory update       |
/// | `rollCosmetic`, `equip` — DONE     | spend a ticket, inventory update    |
/// | `careForPet`, `evolvePet` — DONE   | pet update (no rewards)             |
/// | `updateAudioSettings` — DONE       | settings update (no rewards)        |
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
    final (next, result) = _applyReward(state.requireValue, claimId, reward);
    if (result.applied) await _commit(next);
    return result;
  }

  /// Saves a finished quiz: XP (paid once per session) and learning stats,
  /// in ONE write so they can never disagree.
  Future<QuizOutcome> completeQuiz({
    required String sessionId,
    required List<AnsweredQuestion> answers,
  }) async {
    final current = state.requireValue;
    // Score against what was learned BEFORE this quiz (first-time XP).
    final score = scoreQuiz(answers, current.learning, _economy);
    final (withXp, claim) = _applyReward(
        current, 'quiz:$sessionId', Reward(xp: score.xp));

    if (!claim.applied) return QuizOutcome(score: score, claim: claim);

    // Learning makes the pet happier: same write as the XP.
    final hatched = current.pet.stage != PetStage.egg;
    await _commit(withXp.copyWith(
      learning: current.learning.record(answers),
      pet: petAfterQuiz(current.pet, _now(), _economy),
    ));
    return QuizOutcome(score: score, claim: claim, petHappier: hatched);
  }

  /// Saves a finished cleanup round: coins (+ XP for a good round), the
  /// recycling stats and a cleaner pet, in ONE write, paid once per round.
  Future<CleanupOutcome> completeCleanup({
    required String roundId,
    required List<SortedItem> sorted,
  }) async {
    final current = state.requireValue;
    // Score against what was learned BEFORE this round (first-time coins).
    final score = scoreCleanup(sorted, current.recycling, _economy);
    final (withReward, claim) = _applyReward(current, 'sort:$roundId',
        Reward(coins: score.coins, xp: score.xp));

    if (!claim.applied) return CleanupOutcome(score: score, claim: claim);

    final hatched = current.pet.stage != PetStage.egg;
    await _commit(withReward.copyWith(
      recycling: current.recycling.record(sorted),
      pet: petAfterCleanup(current.pet, _now(), _economy),
    ));
    return CleanupOutcome(score: score, claim: claim, petCleaner: hatched);
  }

  /// Feeds, plays with or bathes the pet. Free, and gives no XP or coins
  /// (care cannot be farmed). Returns false for an egg.
  Future<bool> careForPet(CareAction action) async {
    final current = state.requireValue;
    if (current.pet.stage == PetStage.egg) return false;
    await _commit(current.copyWith(
      pet: applyCare(current.pet, action, _now(), _economy),
    ));
    return true;
  }

  /// Hatches the egg or lets the pet grow, if the player's level allows
  /// it. [name] is only used when hatching (empty → [defaultPetName]).
  /// Returns the new stage, or null when the pet cannot grow yet.
  Future<PetStage?> evolvePet({String? name}) async {
    final current = state.requireValue;
    final level = levelForTotalXp(current.progress.totalXp, _economy).level;
    final next = nextStage(current.pet.stage, level, _economy);
    if (next == null) return null;

    final now = _now();
    final start = _economy.startingPetNeed;
    final pet = current.pet.stage == PetStage.egg
        ? PetState(
            name: normalizeNickname(name) ?? defaultPetName,
            stage: next,
            satiety: start,
            happiness: start,
            cleanliness: start,
            needsUpdatedAt: now,
          )
        : petNow(current.pet, now, _economy)
            .copyWith(stage: next, needsUpdatedAt: now);
    await _commit(current.copyWith(pet: pet));
    return next;
  }

  /// Buys one reward ticket with coins.
  Future<PurchaseResult> buyTicket() async {
    final current = state.requireValue;
    final progress = current.progress;
    final price = _economy.ticketPriceInCoins;
    if (progress.coins < price) return PurchaseResult.notEnoughCoins;
    await _commit(current.copyWith(
      progress: progress.copyWith(
          coins: progress.coins - price, tickets: progress.tickets + 1),
    ));
    return PurchaseResult.bought;
  }

  /// Buys [item] in the shop. Epic items are not sold, and an item is
  /// never bought twice.
  Future<PurchaseResult> buyItem(CosmeticItem item) async {
    final current = state.requireValue;
    final progress = current.progress;
    final price = shopPrice(item.rarity, _economy);
    if (price == null) return PurchaseResult.notForSale;
    if (current.inventory.owns(item.id)) return PurchaseResult.alreadyOwned;
    if (progress.coins < price) return PurchaseResult.notEnoughCoins;
    await _commit(current.copyWith(
      progress: progress.copyWith(coins: progress.coins - price),
      inventory: current.inventory.add(item.id),
    ));
    return PurchaseResult.bought;
  }

  /// Spends one ticket on a reward roll (odds in `pickRolledCosmetic`).
  /// A new item goes into the inventory; a duplicate pays coins back.
  /// Returns null when the player has no ticket.
  Future<RollOutcome?> rollCosmetic(CosmeticCatalog catalog) async {
    final current = state.requireValue;
    final progress = current.progress;
    if (progress.tickets < 1 || catalog.items.isEmpty) return null;

    final item =
        pickRolledCosmetic(catalog, ref.read(randomProvider), _economy);
    final isNew = !current.inventory.owns(item.id);
    final refund = isNew ? 0 : duplicateRefund(item.rarity, _economy);
    await _commit(current.copyWith(
      progress: progress.copyWith(
          tickets: progress.tickets - 1, coins: progress.coins + refund),
      inventory: isNew ? current.inventory.add(item.id) : null,
    ));
    return RollOutcome(item: item, isNew: isNew, refundCoins: refund);
  }

  /// Puts an owned [item] on the pet, in its own slot. Returns false when
  /// the player does not own it.
  Future<bool> equip(CosmeticItem item) async {
    final current = state.requireValue;
    if (!current.inventory.owns(item.id)) return false;
    await _commit(current.copyWith(
      inventory: current.inventory.equip(item.slot.id, item.id),
    ));
    return true;
  }

  /// Takes off whatever the pet wears in [slot].
  Future<void> unequip(CosmeticSlot slot) async {
    final current = state.requireValue;
    if (!current.inventory.equippedBySlot.containsKey(slot.id)) return;
    await _commit(current.copyWith(
      inventory: current.inventory.unequip(slot.id),
    ));
  }

  /// Pure calculation shared by every reward: no saving here.
  /// Every level gained also pays [EconomyConfig.ticketsPerLevelUp]
  /// tickets, included in the returned reward.
  (GameState, ClaimResult) _applyReward(
      GameState current, String claimId, Reward reward) {
    final progress = current.progress;
    final levelBefore = levelForTotalXp(progress.totalXp, _economy).level;

    if (progress.claimedRewardIds.contains(claimId)) {
      return (
        current,
        ClaimResult(
          applied: false,
          reward: Reward.none,
          levelBefore: levelBefore,
          levelAfter: levelBefore,
        ),
      );
    }

    final levelAfter =
        levelForTotalXp(progress.totalXp + reward.xp, _economy).level;
    final paid = reward +
        Reward(
            tickets: (levelAfter - levelBefore) * _economy.ticketsPerLevelUp);
    final updated = progress.copyWith(
      totalXp: progress.totalXp + paid.xp,
      coins: progress.coins + paid.coins,
      tickets: progress.tickets + paid.tickets,
      claimedRewardIds: {...progress.claimedRewardIds, claimId},
    );
    return (
      current.copyWith(progress: updated),
      ClaimResult(
        applied: true,
        reward: paid,
        levelBefore: levelBefore,
        levelAfter: levelAfter,
      ),
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

  /// Saves the sound preferences. Nothing is written when they did not
  /// change (sliders call this when released, not while moving).
  Future<void> updateAudioSettings(AudioSettings audio) async {
    final current = state.requireValue;
    if (current.audio == audio) return;
    await _commit(current.copyWith(audio: audio));
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
