import 'package:ecoquest/data/save/in_memory_save_repository.dart';
import 'package:ecoquest/data/save/save_repository.dart';
import 'package:ecoquest/domain/game_controller.dart';
import 'package:ecoquest/domain/models/activity_log.dart';
import 'package:ecoquest/domain/models/eco_topic.dart';
import 'package:ecoquest/domain/models/game_state.dart';
import 'package:ecoquest/domain/models/learning_progress.dart';
import 'package:ecoquest/domain/models/pet_state.dart';
import 'package:ecoquest/domain/models/recycling_progress.dart';
import 'package:ecoquest/domain/rules/pet_rules.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var now = DateTime(2026, 10, 22, 10);
  late InMemorySaveRepository repository;

  Future<ProviderContainer> startApp() async {
    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        saveRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);
    await container.read(gameControllerProvider.future);
    return container;
  }

  GameController controller(ProviderContainer c) =>
      c.read(gameControllerProvider.notifier);
  GameState game(ProviderContainer c) =>
      c.read(gameControllerProvider).requireValue;

  setUp(() {
    now = DateTime(2026, 10, 22, 10);
    repository = InMemorySaveRepository();
  });

  test('old save without activity data loads with defaults', () {
    final oldSave = GameState.initial(now: now).toJson()
      ..remove('activity')
      ..remove('reminder');
    final state = GameState.fromJson(oldSave, now: now);
    expect(state.activity.days, isEmpty);
    expect(state.activity.lastSessionEndedCleanly, isTrue);
    expect(state.reminder.enabled, isFalse);
  });

  test('quiz, cleanup and care are recorded with right/wrong counts',
      () async {
    repository = InMemorySaveRepository(GameState.initial(now: now).copyWith(
      pet: PetState(
        name: 'Ecò',
        stage: PetStage.baby,
        satiety: 50,
        happiness: 50,
        cleanliness: 50,
        needsUpdatedAt: now,
      ),
    ));
    final app = await startApp();

    await controller(app).completeQuiz(sessionId: 's1', answers: const [
      AnsweredQuestion(questionId: 'q1', topic: EcoTopic.oceans, correct: true),
      AnsweredQuestion(
          questionId: 'q2', topic: EcoTopic.oceans, correct: false),
    ]);
    await controller(app).completeCleanup(roundId: 'r1', sorted: const [
      SortedItem(itemId: 'a', correct: true),
    ]);
    await controller(app).careForPet(CareAction.feed);

    final today = game(app).activity.dayOf(now)!;
    expect(today.activities, 3);
    expect(today.correctAnswers, 2);
    expect(today.wrongAnswers, 1);
    expect(repository.saved!.activity.dayOf(now)!.activities, 3);
  });

  test('app open, notification open and crash detection', () async {
    final app = await startApp();
    await controller(app).recordAppOpen(coldStart: true);
    // Killed without going to the background → next start sees a crash.
    await controller(app)
        .recordAppOpen(coldStart: true, fromNotification: true);

    final today = game(app).activity.dayOf(now)!;
    expect(today.opens, 2);
    expect(today.notificationOpens, 1);
    expect(today.uncleanExits, 1);

    await controller(app).recordSessionEnded();
    expect(game(app).activity.lastSessionEndedCleanly, isTrue);
    await controller(app).recordAppOpen(coldStart: true);
    expect(game(app).activity.dayOf(now)!.uncleanExits, 1);
  });

  test('comeback bonus only on a low-score day, once per day', () async {
    repository = InMemorySaveRepository(GameState.initial(now: now).copyWith(
      activity: ActivityLog(days: [
        DayActivity(day: dayKey(DateTime(2026, 10, 12)), opens: 1),
      ]),
    ));
    final app = await startApp();
    expect(controller(app).comebackScoreToday, lessThan(45));

    final first = await controller(app).claimComebackBonus();
    expect(first!.applied, isTrue);
    expect(game(app).progress.coins, 10);
    expect(game(app).progress.claimedRewardIds, contains('comeback:2026-10-22'));

    final again = await controller(app).claimComebackBonus();
    expect(again!.applied, isFalse);
    expect(game(app).progress.coins, 10);
  });

  test('no bonus on a neutral day (new player)', () async {
    final app = await startApp();
    expect(controller(app).comebackScoreToday, 50);
    expect(await controller(app).claimComebackBonus(), isNull);
    expect(game(app).progress.coins, 0);
  });

  test('clearActivity empties the log and turns the reminder off', () async {
    repository = InMemorySaveRepository(GameState.initial(now: now).copyWith(
      activity: ActivityLog(days: [
        DayActivity(day: dayKey(now), opens: 3, activities: 2),
      ]),
      reminder: const ReminderSettings(enabled: true, hour: 17),
    ));
    final app = await startApp();
    await controller(app).clearActivity();

    expect(game(app).activity.days, isEmpty);
    expect(game(app).reminder.enabled, isFalse);
    expect(game(app).reminder.hour, 17);
    expect(repository.saved!.activity.days, isEmpty);
  });

  test('clock going backwards does not break recording', () async {
    final app = await startApp();
    await controller(app).recordAppOpen(coldStart: true);
    now = DateTime(2026, 10, 20, 10);
    await controller(app).recordAppOpen();
    expect(game(app).activity.days.length, 2);
    expect(controller(app).comebackScoreToday, 50);
  });
}
