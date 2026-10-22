import 'package:ecoquest/domain/models/audio_settings.dart';
import 'package:ecoquest/domain/models/eco_topic.dart';
import 'package:ecoquest/domain/models/game_state.dart';
import 'package:ecoquest/domain/models/inventory.dart';
import 'package:ecoquest/domain/models/pet_state.dart';
import 'package:ecoquest/domain/models/player_profile.dart';
import 'package:ecoquest/domain/models/player_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 22, 10);

  GameState fullState() => GameState(
        profile: PlayerProfile(
          createdAt: DateTime(2026, 10, 1),
          nickname: 'Giulia',
          ageRange: AgeRange.age16to18,
          interests: {EcoTopic.oceans, EcoTopic.recycling},
          onboardingCompleted: true,
        ),
        progress: const PlayerProgress(
          totalXp: 260,
          coins: 42,
          tickets: 2,
          claimedRewardIds: {'quiz:1', 'sort:7:3'},
        ),
        pet: PetState(
          name: 'Ecò',
          stage: PetStage.baby,
          satiety: 55,
          happiness: 70,
          cleanliness: 30,
          needsUpdatedAt: DateTime(2026, 10, 21, 18),
        ),
        inventory: const Inventory(
          ownedItemIds: {'hat_leaf', 'plant_fern'},
          equippedBySlot: {'head': 'hat_leaf'},
        ),
        audio: const AudioSettings(muted: true, musicVolume: 20),
      );

  test('toJson → fromJson keeps every field', () {
    final original = fullState();
    final copy = GameState.fromJson(original.toJson(), now: now);

    expect(copy.toJson(), original.toJson());
    expect(copy.profile.interests, {EcoTopic.oceans, EcoTopic.recycling});
    expect(copy.pet.stage, PetStage.baby);
    expect(copy.inventory.equippedBySlot['head'], 'hat_leaf');
    expect(copy.audio, const AudioSettings(muted: true, musicVolume: 20));
  });

  test('missing fields fall back to safe defaults', () {
    final state = GameState.fromJson(const {}, now: now);

    expect(state.progress.totalXp, 0);
    expect(state.progress.coins, 0);
    expect(state.profile.onboardingCompleted, isFalse);
    expect(state.profile.createdAt, now);
    expect(state.pet.stage, PetStage.egg);
    expect(state.inventory.ownedItemIds, isEmpty);
    expect(state.audio, AudioSettings.defaults); // saves from before audio
  });

  test('unknown topic ids from another app version are ignored', () {
    final json = fullState().toJson();
    (json['profile']! as Map)['interests'] = ['oceans', 'space_mining'];

    final state = GameState.fromJson(json, now: now);
    expect(state.profile.interests, {EcoTopic.oceans});
  });

  test('pet needs are kept between 0 and 100', () {
    final json = fullState().toJson();
    (json['pet']! as Map)
      ..['satiety'] = 250
      ..['cleanliness'] = -10;

    final pet = GameState.fromJson(json, now: now).pet;
    expect(pet.satiety, 100);
    expect(pet.cleanliness, 0);
  });

  test('a wrong type is reported as a FormatException', () {
    final json = fullState().toJson();
    (json['progress']! as Map)['coins'] = 'lots';

    expect(() => GameState.fromJson(json, now: now),
        throwsA(isA<FormatException>()));
  });

  test('a new game starts from the economy values', () {
    final state = GameState.initial(now: now);

    expect(state.progress.coins, 0);
    expect(state.progress.tickets, 1);
    expect(state.pet.satiety, 80);
    expect(state.pet.needsUpdatedAt, now);
  });
}
