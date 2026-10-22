import 'package:ecoquest/data/save/in_memory_save_repository.dart';
import 'package:ecoquest/data/save/save_repository.dart';
import 'package:ecoquest/domain/game_controller.dart';
import 'package:ecoquest/domain/models/eco_topic.dart';
import 'package:ecoquest/domain/models/game_state.dart';
import 'package:ecoquest/domain/models/learning_progress.dart';
import 'package:ecoquest/domain/models/pet_state.dart';
import 'package:ecoquest/domain/rules/pet_rules.dart';
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

  test('onboarding cleans the nickname', () async {
    final app = await startApp();

    await controller(app).completeOnboarding(
        interests: {EcoTopic.climate}, nickname: '   ');

    expect(game(app).profile.nickname, isNull);
    expect(game(app).profile.onboardingCompleted, isTrue);
  });

  test('profile details can be changed and cleared; progress stays',
      () async {
    final app = await startApp();
    await controller(app).completeOnboarding(
      interests: {EcoTopic.energy},
      nickname: 'Sole',
      ageRange: AgeRange.age19to22,
    );
    await controller(app).claimReward('quiz:1', const Reward(coins: 9));

    await controller(app)
        .updateProfileDetails(nickname: '  Luna ', ageRange: null);

    final state = game(app);
    expect(state.profile.nickname, 'Luna');
    expect(state.profile.ageRange, isNull);
    expect(state.profile.interests, {EcoTopic.energy});
    expect(state.profile.onboardingCompleted, isTrue);
    expect(state.progress.coins, 9);
    expect(repository.saved!.profile.nickname, 'Luna');
  });

  group('completeQuiz', () {
    List<AnsweredQuestion> answers(List<bool> results) => [
          for (var i = 0; i < results.length; i++)
            AnsweredQuestion(
              questionId: 'oceans_00${i + 1}',
              topic: EcoTopic.oceans,
              correct: results[i],
            ),
        ];

    test('adds XP and learning stats in one save', () async {
      final app = await startApp();

      final outcome = await controller(app).completeQuiz(
        sessionId: 's1',
        answers: answers([true, true, false, true, true]),
      );

      expect(outcome.score.xp, 50);
      expect(outcome.claim.applied, isTrue);
      expect(game(app).progress.totalXp, 50);
      expect(game(app).learning.quizzesCompleted, 1);
      expect(game(app).learning.statsByTopic[EcoTopic.oceans]!.correct, 4);
      expect(repository.saveCount, 1);
      expect(repository.saved!.learning.learnedQuestionIds, hasLength(4));
    });

    test('the same session is never paid or counted twice', () async {
      final app = await startApp();
      final quiz = answers([true, true, true, true, true]);

      await controller(app).completeQuiz(sessionId: 's1', answers: quiz);
      final again =
          await controller(app).completeQuiz(sessionId: 's1', answers: quiz);

      expect(again.claim.applied, isFalse);
      expect(game(app).progress.totalXp, 70);
      expect(game(app).learning.quizzesCompleted, 1);
    });

    test('replaying known questions pays much less', () async {
      final app = await startApp();
      final quiz = answers([true, true, true, true, true]);

      final first =
          await controller(app).completeQuiz(sessionId: 's1', answers: quiz);
      final second =
          await controller(app).completeQuiz(sessionId: 's2', answers: quiz);

      expect(first.score.xp, 70);
      expect(second.score.xp, 30); // 5 × 2 + 4 × 5
      expect(second.score.newlyLearned, 0);
    });

    test('a quiz can cause a level-up', () async {
      final app = await startApp();
      await controller(app).claimReward('earlier', const Reward(xp: 60));

      final outcome = await controller(app).completeQuiz(
        sessionId: 's1',
        answers: answers([true, true, true, true, true]),
      );

      expect(outcome.claim.leveledUp, isTrue);
      expect(outcome.claim.levelAfter, 2);
    });
  });

  group('pet', () {
    test('the egg cannot hatch before level 2, nor be fed', () async {
      final app = await startApp();

      expect(await controller(app).evolvePet(name: 'Ecò'), isNull);
      expect(await controller(app).careForPet(CareAction.feed), isFalse);
      expect(game(app).pet.stage, PetStage.egg);
      expect(repository.saveCount, 0);
    });

    test('at level 2 the egg hatches with the chosen name', () async {
      final app = await startApp();
      await controller(app).claimReward('xp', const Reward(xp: 100));

      final stage = await controller(app).evolvePet(name: '  Foglia ');

      expect(stage, PetStage.baby);
      expect(game(app).pet.name, 'Foglia');
      expect(game(app).pet.satiety, 80);
      expect(game(app).pet.needsUpdatedAt, now);
      expect(repository.saved!.pet.stage, PetStage.baby);
    });

    test('an empty name becomes the default name', () async {
      final app = await startApp();
      await controller(app).claimReward('xp', const Reward(xp: 100));
      await controller(app).evolvePet(name: '');
      expect(game(app).pet.name, defaultPetName);
    });

    test('care changes only the pet and gives no rewards', () async {
      final app = await startApp();
      await controller(app).claimReward('xp', const Reward(xp: 100));
      await controller(app).evolvePet();

      expect(await controller(app).careForPet(CareAction.play), isTrue);

      expect(game(app).pet.happiness, 100); // 80 + 30, capped
      expect(game(app).progress.totalXp, 100);
      expect(game(app).progress.coins, 0);
    });

    test('a completed quiz makes the hatched pet happier', () async {
      final app = await startApp();
      await controller(app).claimReward('xp', const Reward(xp: 100));
      await controller(app).evolvePet(); // happiness starts at 80

      final outcome = await controller(app).completeQuiz(
        sessionId: 's1',
        answers: [
          const AnsweredQuestion(
              questionId: 'q1', topic: EcoTopic.water, correct: true),
        ],
      );

      expect(outcome.petHappier, isTrue);
      expect(game(app).pet.happiness, 95); // 80 + 15, same save as the XP
      expect(repository.saved!.pet.happiness, 95);
    });

    test('a quiz does not change an egg', () async {
      final app = await startApp();
      final outcome = await controller(app).completeQuiz(
        sessionId: 's1',
        answers: [
          const AnsweredQuestion(
              questionId: 'q1', topic: EcoTopic.water, correct: true),
        ],
      );
      expect(outcome.petHappier, isFalse);
      expect(game(app).pet.stage, PetStage.egg);
    });
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
