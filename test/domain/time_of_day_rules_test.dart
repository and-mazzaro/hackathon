import 'package:ecoquest/data/save/in_memory_save_repository.dart';
import 'package:ecoquest/data/save/save_repository.dart';
import 'package:ecoquest/domain/game_controller.dart';
import 'package:ecoquest/domain/models/game_state.dart';
import 'package:ecoquest/domain/models/look_mode.dart';
import 'package:ecoquest/domain/rules/time_of_day_rules.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

DateTime _at(int hour, [int minute = 0]) =>
    DateTime(2026, 10, 22, hour, minute);

void main() {
  group('timeOfDayFor', () {
    test('day from 7:00 to 15:59', () {
      expect(timeOfDayFor(_at(7)), TimeOfDayLook.day);
      expect(timeOfDayFor(_at(10)), TimeOfDayLook.day);
      expect(timeOfDayFor(_at(15, 59)), TimeOfDayLook.day);
    });

    test('afternoon from 16:00 to 19:59', () {
      expect(timeOfDayFor(_at(16)), TimeOfDayLook.afternoon);
      expect(timeOfDayFor(_at(18, 30)), TimeOfDayLook.afternoon);
      expect(timeOfDayFor(_at(19, 59)), TimeOfDayLook.afternoon);
    });

    test('night from 20:00 to 6:59', () {
      expect(timeOfDayFor(_at(20)), TimeOfDayLook.night);
      expect(timeOfDayFor(_at(23, 59)), TimeOfDayLook.night);
      expect(timeOfDayFor(_at(0)), TimeOfDayLook.night);
      expect(timeOfDayFor(_at(6, 59)), TimeOfDayLook.night);
    });
  });

  test('lookFor: auto follows the clock, a fixed choice ignores it', () {
    expect(lookFor(LookMode.auto, _at(21)), TimeOfDayLook.night);
    expect(lookFor(LookMode.auto, _at(10)), TimeOfDayLook.day);
    expect(lookFor(LookMode.day, _at(21)), TimeOfDayLook.day);
    expect(lookFor(LookMode.afternoon, _at(10)), TimeOfDayLook.afternoon);
    expect(lookFor(LookMode.night, _at(10)), TimeOfDayLook.night);
  });

  group('save', () {
    final now = _at(10);

    test('a new game starts on auto', () {
      expect(GameState.initial(now: now).lookMode, LookMode.auto);
    });

    test('old save without lookMode loads as auto', () {
      final oldSave = GameState.initial(now: now).toJson()..remove('lookMode');
      expect(GameState.fromJson(oldSave, now: now).lookMode, LookMode.auto);
    });

    test('unknown value loads as auto', () {
      final save = GameState.initial(now: now).toJson()..['lookMode'] = 'x';
      expect(GameState.fromJson(save, now: now).lookMode, LookMode.auto);
    });

    test('round trip keeps the choice', () {
      final state =
          GameState.initial(now: now).copyWith(lookMode: LookMode.night);
      expect(GameState.fromJson(state.toJson(), now: now).lookMode,
          LookMode.night);
    });

    test('GameController.updateLookMode saves the choice', () async {
      final repository = InMemorySaveRepository();
      final container = ProviderContainer(
        retry: (retryCount, error) => null,
        overrides: [
          saveRepositoryProvider.overrideWithValue(repository),
          clockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);
      await container.read(gameControllerProvider.future);

      await container
          .read(gameControllerProvider.notifier)
          .updateLookMode(LookMode.afternoon);

      expect(container.read(gameControllerProvider).requireValue.lookMode,
          LookMode.afternoon);
      expect(repository.saved!.lookMode, LookMode.afternoon);
    });
  });
}
