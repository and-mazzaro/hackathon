import 'package:ecoquest/data/save/in_memory_save_repository.dart';
import 'package:ecoquest/data/save/save_repository.dart';
import 'package:ecoquest/domain/game_controller.dart';
import 'package:ecoquest/domain/models/eco_topic.dart';
import 'package:ecoquest/domain/models/game_state.dart';
import 'package:ecoquest/domain/models/player_profile.dart';
import 'package:ecoquest/domain/models/reward.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 22, 10);
  late InMemorySaveRepository repository;

  /// A ProviderContainer is the app's state without any UI.
  /// Creating a new one with the same repository = restarting the app.
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

  setUp(() => repository = InMemorySaveRepository());

  test('first launch creates a new game without saving yet', () async {
    final app = await startApp();

    expect(game(app).progress.tickets, 1);
    expect(game(app).profile.onboardingCompleted, isFalse);
    expect(repository.saveCount, 0);
  });

  test('claimReward adds XP, coins and tickets and saves', () async {
    final app = await startApp();

    final result = await controller(app)
        .claimReward('quiz:1', const Reward(xp: 40, coins: 5, tickets: 1));

    expect(result.applied, isTrue);
    expect(game(app).progress.totalXp, 40);
    expect(game(app).progress.coins, 5);
    expect(game(app).progress.tickets, 2);
    expect(repository.saved!.progress.coins, 5);
  });

  test('the same claim id is never paid twice', () async {
    final app = await startApp();
    const reward = Reward(xp: 10, coins: 10);

    await controller(app).claimReward('quiz:1', reward);
    final second = await controller(app).claimReward('quiz:1', reward);

    expect(second.applied, isFalse);
    expect(game(app).progress.coins, 10);
  });

  test('two claims started at the same time are both counted', () async {
    final app = await startApp();

    await Future.wait([
      controller(app).claimReward('a', const Reward(coins: 3)),
      controller(app).claimReward('b', const Reward(coins: 4)),
    ]);

    expect(game(app).progress.coins, 7);
    expect(repository.saved!.progress.coins, 7);
  });

  test('a double tap on the same reward pays once', () async {
    final app = await startApp();

    await Future.wait([
      controller(app).claimReward('quiz:9', const Reward(coins: 5)),
      controller(app).claimReward('quiz:9', const Reward(coins: 5)),
    ]);

    expect(game(app).progress.coins, 5);
  });

  test('claimReward reports level-ups', () async {
    final app = await startApp();

    final result =
        await controller(app).claimReward('quiz:1', const Reward(xp: 120));

    expect(result.levelBefore, 1);
    expect(result.levelAfter, 2);
    expect(result.leveledUp, isTrue);
    expect(controller(app).levelInfo.xpIntoLevel, 20);
  });

  test('progress survives an app restart', () async {
    final first = await startApp();
    await controller(first).claimReward('quiz:1', const Reward(xp: 30));
    await controller(first)
        .completeOnboarding(interests: {EcoTopic.water}, nickname: 'Luca');
    first.dispose();

    final second = await startApp();
    expect(game(second).progress.totalXp, 30);
    expect(game(second).profile.nickname, 'Luca');
    expect(game(second).profile.onboardingCompleted, isTrue);

    // A reward claimed before the restart is still blocked afterwards.
    final again =
        await controller(second).claimReward('quiz:1', const Reward(xp: 30));
    expect(again.applied, isFalse);
  });

  test('changing interests keeps all progress and onboarding status',
      () async {
    final app = await startApp();
    await controller(app).completeOnboarding(
      interests: {EcoTopic.recycling},
      ageRange: AgeRange.age16to18,
    );
    await controller(app)
        .claimReward('quiz:1', const Reward(xp: 50, coins: 20));

    await controller(app)
        .updateInterests({EcoTopic.oceans, EcoTopic.biodiversity});

    final state = game(app);
    expect(state.profile.interests, {EcoTopic.oceans, EcoTopic.biodiversity});
    expect(state.profile.onboardingCompleted, isTrue);
    expect(state.profile.ageRange, AgeRange.age16to18);
    expect(state.progress.totalXp, 50);
    expect(state.progress.coins, 20);
    expect(repository.saved!.profile.interests,
        {EcoTopic.oceans, EcoTopic.biodiversity});
  });

  test('a broken save shows an error; startFresh recovers', () async {
    final broken = _BrokenRepository();
    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        saveRepositoryProvider.overrideWithValue(broken),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);
    // Keep the provider alive while we look at it.
    container.listen(gameControllerProvider, (previous, next) {});

    await expectLater(container.read(gameControllerProvider.future),
        throwsA(isA<SaveCorruptedException>()));
    expect(container.read(gameControllerProvider).hasError, isTrue);

    await container.read(gameControllerProvider.notifier).startFresh();

    expect(container.read(gameControllerProvider).requireValue.progress.tickets,
        1);
    expect(broken.saved, isNotNull);
  });
}

class _BrokenRepository implements SaveRepository {
  GameState? saved;

  @override
  Future<GameState?> load() async =>
      throw const SaveCorruptedException('test');

  @override
  Future<void> save(GameState state) async => saved = state;
}
