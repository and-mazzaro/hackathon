import '../rules/economy_config.dart';
import 'activity_log.dart';
import 'audio_settings.dart';
import 'inventory.dart';
import 'json_utils.dart';
import 'learning_progress.dart';
import 'pet_state.dart';
import 'player_profile.dart';
import 'player_progress.dart';
import 'recycling_progress.dart';

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
    this.recycling = const RecyclingProgress(),
    this.audio = AudioSettings.defaults,
    this.activity = ActivityLog.empty,
    this.reminder = ReminderSettings.defaults,
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

  /// Recycling statistics. Added in M7: older saves simply start empty.
  final RecyclingProgress recycling;

  /// Sound preferences. Added with audio: older saves get the defaults.
  final AudioSettings audio;

  /// Local activity log for the comeback score. Added in M10: older saves
  /// start with an empty log (neutral score).
  final ActivityLog activity;

  /// Optional daily reminder. Added in M10: older saves have it off.
  final ReminderSettings reminder;

  GameState copyWith({
    PlayerProfile? profile,
    PlayerProgress? progress,
    PetState? pet,
    Inventory? inventory,
    LearningProgress? learning,
    RecyclingProgress? recycling,
    AudioSettings? audio,
    ActivityLog? activity,
    ReminderSettings? reminder,
  }) {
    return GameState(
      profile: profile ?? this.profile,
      progress: progress ?? this.progress,
      pet: pet ?? this.pet,
      inventory: inventory ?? this.inventory,
      learning: learning ?? this.learning,
      recycling: recycling ?? this.recycling,
      audio: audio ?? this.audio,
      activity: activity ?? this.activity,
      reminder: reminder ?? this.reminder,
    );
  }

  Json toJson() => {
        'profile': profile.toJson(),
        'progress': progress.toJson(),
        'pet': pet.toJson(),
        'inventory': inventory.toJson(),
        'learning': learning.toJson(),
        'recycling': recycling.toJson(),
        'audio': audio.toJson(),
        'activity': activity.toJson(),
        'reminder': reminder.toJson(),
      };

  /// [now] is only used for dates missing from an old or partial save.
  factory GameState.fromJson(Json json, {required DateTime now}) {
    return GameState(
      profile: PlayerProfile.fromJson(readObject(json, 'profile'), now: now),
      progress: PlayerProgress.fromJson(readObject(json, 'progress')),
      pet: PetState.fromJson(readObject(json, 'pet'), now: now),
      inventory: Inventory.fromJson(readObject(json, 'inventory')),
      learning: LearningProgress.fromJson(readObject(json, 'learning')),
      recycling: RecyclingProgress.fromJson(readObject(json, 'recycling')),
      audio: AudioSettings.fromJson(readObject(json, 'audio')),
      activity: ActivityLog.fromJson(readObject(json, 'activity')),
      reminder: ReminderSettings.fromJson(readObject(json, 'reminder')),
    );
  }
}
