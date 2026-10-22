import 'dart:math' as math;

import '../models/pet_state.dart';
import 'economy_config.dart';

/// Name used when the player does not choose one at hatching.
const defaultPetName = 'Ecò';

enum PetMood { happy, ok, sad }

enum CareAction { feed, play, clean }

/// The pet as it is NOW: needs dropped for the time since the last change.
///
/// - Calculated, not saved: just looking at the pet never writes the save.
/// - Needs never go below `petNeedFloor` (no harsh punishment).
/// - An egg has no needs that drop.
/// - If the device clock went backwards, nothing changes.
PetState petNow(PetState pet, DateTime now, EconomyConfig economy) {
  if (pet.stage == PetStage.egg) return pet;
  final minutes = now.difference(pet.needsUpdatedAt).inMinutes;
  if (minutes <= 0) return pet;
  final hours = minutes / 60;

  int drop(int value, int perHour) {
    if (value <= economy.petNeedFloor) return value;
    final lowered = value - (perHour * hours).floor();
    return math.max(lowered, economy.petNeedFloor);
  }

  return pet.copyWith(
    satiety: drop(pet.satiety, economy.satietyDecayPerHour),
    happiness: drop(pet.happiness, economy.happinessDecayPerHour),
    cleanliness: drop(pet.cleanliness, economy.cleanlinessDecayPerHour),
  );
}

/// How the pet feels, from its needs. Only changes its face and a hint.
PetMood moodOf(PetState pet) {
  if (pet.stage == PetStage.egg) return PetMood.happy;
  final needs = [pet.satiety, pet.happiness, pet.cleanliness];
  if (needs.reduce(math.min) < 35) return PetMood.sad;
  final average = needs.reduce((a, b) => a + b) / needs.length;
  return average >= 70 ? PetMood.happy : PetMood.ok;
}

/// The need a care action restores.
int needFor(PetState pet, CareAction action) => switch (action) {
      CareAction.feed => pet.satiety,
      CareAction.play => pet.happiness,
      CareAction.clean => pet.cleanliness,
    };

/// Applies one care action at [now]. An egg cannot be cared for yet.
PetState applyCare(
  PetState pet,
  CareAction action,
  DateTime now,
  EconomyConfig economy,
) {
  if (pet.stage == PetStage.egg) return pet;
  final current = petNow(pet, now, economy);
  final amount = economy.petCareAmount;
  return switch (action) {
    CareAction.feed => current.copyWith(
        satiety: current.satiety + amount, needsUpdatedAt: now),
    CareAction.play => current.copyWith(
        happiness: current.happiness + amount, needsUpdatedAt: now),
    CareAction.clean => current.copyWith(
        cleanliness: current.cleanliness + amount, needsUpdatedAt: now),
  };
}

/// A finished quiz makes a hatched pet happier.
PetState petAfterQuiz(PetState pet, DateTime now, EconomyConfig economy) {
  if (pet.stage == PetStage.egg) return pet;
  final current = petNow(pet, now, economy);
  return current.copyWith(
    happiness: current.happiness + economy.quizPetHappinessBoost,
    needsUpdatedAt: now,
  );
}

/// The player level needed to reach the stage after [stage] (null: adult).
int? levelForNextStage(PetStage stage, EconomyConfig economy) =>
    switch (stage) {
      PetStage.egg => economy.hatchLevel,
      PetStage.baby => economy.youngLevel,
      PetStage.young => economy.adultLevel,
      PetStage.adult => null,
    };

/// The next stage if the player's [level] allows it, otherwise null.
PetStage? nextStage(PetStage stage, int level, EconomyConfig economy) {
  final needed = levelForNextStage(stage, economy);
  if (needed == null || level < needed) return null;
  return PetStage.values[stage.index + 1];
}

/// How many plants decorate the room (0–3): the room gets greener as the
/// player progresses.
int roomPlants(int level, EconomyConfig economy) =>
    math.min(3, level ~/ economy.levelsPerRoomPlant);
