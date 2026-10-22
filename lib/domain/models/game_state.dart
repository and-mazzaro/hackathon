import '../rules/economy_config.dart';
import 'inventory.dart';
import 'json_utils.dart';
import 'learning_progress.dart';
import 'pet_state.dart';
import 'player_profile.dart';
import 'player_progress.dart';

/// Everything that is saved. One object, saved as one JSON document, so a
/// reward and the "already claimed" mark are always written together.
///
/// Adding a field: give it a default in `fromJson` so older saves still
/// load. Changing the meaning of a field: add a migration in SaveFormat.
class GameState {
  const GameState({
    required this.profile,
    required this.progress,
    required this.pet,
    required this.inventory,
    this.learning = const LearningProgress(),
  });

  /// A brand-new player.
  factory GameState.initial({
    required DateTime now,
    EconomyConfig economy = EconomyConfig.defaults,
  }) {
    final need = economy.startingPetNeed;
    return GameState(
      profile: PlayerProfile(createdAt: now),
      progress: PlayerProgress(
        coins: economy.startingCoins,
        tickets: economy.startingTickets,
      ),
      pet: PetState(
        needsUpdatedAt: now,
        satiety: need,
        happiness: need,
        cleanliness: need,
      ),
      inventory: const Inventory(),
    );
  }

  final PlayerProfile profile;
  final PlayerProgress progress;
  final PetState pet;
  final Inventory inventory;

  /// Quiz statistics. Added in M5: older saves simply start empty.
  final LearningProgress learning;

  GameState copyWith({
    PlayerProfile? profile,
    PlayerProgress? progress,
    PetState? pet,
    Inventory? inventory,
    LearningProgress? learning,
  }) {
    return GameState(
      profile: profile ?? this.profile,
      progress: progress ?? this.progress,
      pet: pet ?? this.pet,
      inventory: inventory ?? this.inventory,
      learning: learning ?? this.learning,
    );
  }

  Json toJson() => {
        'profile': profile.toJson(),
        'progress': progress.toJson(),
        'pet': pet.toJson(),
        'inventory': inventory.toJson(),
        'learning': learning.toJson(),
      };

  /// [now] is only used for dates missing from an old or partial save.
  factory GameState.fromJson(Json json, {required DateTime now}) {
    return GameState(
      profile: PlayerProfile.fromJson(readObject(json, 'profile'), now: now),
      progress: PlayerProgress.fromJson(readObject(json, 'progress')),
      pet: PetState.fromJson(readObject(json, 'pet'), now: now),
      inventory: Inventory.fromJson(readObject(json, 'inventory')),
      learning: LearningProgress.fromJson(readObject(json, 'learning')),
    );
  }
}
