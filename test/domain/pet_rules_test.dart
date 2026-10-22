import 'package:ecoquest/domain/models/pet_state.dart';
import 'package:ecoquest/domain/rules/economy_config.dart';
import 'package:ecoquest/domain/rules/pet_rules.dart';
import 'package:ecoquest/domain/rules/progression.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const economy = EconomyConfig.defaults; // decay 4/3/2 per hour, floor 20
  final start = DateTime(2026, 10, 22, 8);

  PetState baby({int satiety = 80, int happiness = 80, int cleanliness = 80}) =>
      PetState(
        stage: PetStage.baby,
        name: 'Ecò',
        satiety: satiety,
        happiness: happiness,
        cleanliness: cleanliness,
        needsUpdatedAt: start,
      );

  group('petNow (needs over time)', () {
    test('needs drop by their hourly rate', () {
      final pet = petNow(baby(), start.add(const Duration(hours: 5)), economy);
      expect(pet.satiety, 60); // 80 - 5×4
      expect(pet.happiness, 65); // 80 - 5×3
      expect(pet.cleanliness, 70); // 80 - 5×2
    });

    test('a month away never goes below the floor (no punishment)', () {
      final pet = petNow(baby(), start.add(const Duration(days: 30)), economy);
      expect(pet.satiety, 20);
      expect(pet.happiness, 20);
      expect(pet.cleanliness, 20);
    });

    test('an egg does not get hungry or dirty', () {
      final egg = PetState(needsUpdatedAt: start); // stage egg
      final later = petNow(egg, start.add(const Duration(days: 3)), economy);
      expect(later.satiety, egg.satiety);
    });

    test('a clock that went backwards changes nothing', () {
      final pet =
          petNow(baby(), start.subtract(const Duration(hours: 6)), economy);
      expect(pet.satiety, 80);
    });

    test('looking at the pet does not move its "last updated" time', () {
      final pet = petNow(baby(), start.add(const Duration(hours: 2)), economy);
      expect(pet.needsUpdatedAt, start);
    });
  });

  group('moodOf', () {
    test('high needs: happy; middle: ok; one low need: sad', () {
      expect(moodOf(baby()), PetMood.happy);
      expect(moodOf(baby(satiety: 60, happiness: 60, cleanliness: 60)),
          PetMood.ok);
      expect(moodOf(baby(cleanliness: 30)), PetMood.sad);
    });

    test('an egg is always content', () {
      expect(moodOf(PetState(needsUpdatedAt: start)), PetMood.happy);
    });
  });

  group('applyCare', () {
    test('adds 30 to the matching need and records the time', () {
      final now = start.add(const Duration(hours: 5)); // satiety now 60
      final fed = applyCare(baby(), CareAction.feed, now, economy);
      expect(fed.satiety, 90);
      expect(fed.happiness, 65); // decay applied, not changed by feeding
      expect(fed.needsUpdatedAt, now);
    });

    test('never goes above 100', () {
      final washed = applyCare(baby(cleanliness: 95), CareAction.clean,
          start, economy);
      expect(washed.cleanliness, 100);
    });

    test('a sad pet recovers with a few taps', () {
      var pet = petNow(baby(), start.add(const Duration(days: 10)), economy);
      expect(moodOf(pet), PetMood.sad);
      for (final action in CareAction.values) {
        pet = applyCare(pet, action, start.add(const Duration(days: 10)),
            economy);
        pet = applyCare(pet, action, start.add(const Duration(days: 10)),
            economy);
      }
      expect(moodOf(pet), PetMood.happy);
    });

    test('an egg cannot be cared for yet', () {
      final egg = PetState(needsUpdatedAt: start);
      expect(applyCare(egg, CareAction.feed, start, economy).satiety,
          egg.satiety);
    });
  });

  test('a quiz makes a hatched pet happier, not an egg', () {
    final happier = petAfterQuiz(baby(happiness: 50), start, economy);
    expect(happier.happiness, 65);
    final egg = PetState(needsUpdatedAt: start);
    expect(petAfterQuiz(egg, start, economy).happiness, egg.happiness);
  });

  group('growth', () {
    test('stages follow the player level: 2, 5, 10', () {
      expect(nextStage(PetStage.egg, 1, economy), isNull);
      expect(nextStage(PetStage.egg, 2, economy), PetStage.baby);
      expect(nextStage(PetStage.baby, 4, economy), isNull);
      expect(nextStage(PetStage.baby, 5, economy), PetStage.young);
      expect(nextStage(PetStage.young, 10, economy), PetStage.adult);
      expect(nextStage(PetStage.adult, 50, economy), isNull);
    });

    test('hatching at level 2 needs 100 XP in total', () {
      expect(totalXpForLevel(economy.hatchLevel, economy), 100);
      expect(totalXpForLevel(3, economy), 250);
      expect(totalXpForLevel(1, economy), 0);
    });

    test('the room gets greener with levels, up to 3 extra plants', () {
      expect(roomPlants(1, economy), 0);
      expect(roomPlants(2, economy), 1);
      expect(roomPlants(4, economy), 2);
      expect(roomPlants(30, economy), 3);
    });
  });
}
