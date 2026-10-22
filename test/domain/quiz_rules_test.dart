import 'dart:math';

import 'package:ecoquest/domain/models/eco_topic.dart';
import 'package:ecoquest/domain/models/learning_progress.dart';
import 'package:ecoquest/domain/models/quiz_question.dart';
import 'package:ecoquest/domain/rules/economy_config.dart';
import 'package:ecoquest/domain/rules/quiz_rules.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/quiz_fixtures.dart';

void main() {
  final bank = testQuizBank(); // recycling, oceans, climate × 5

  List<QuizQuestion> pick({
    Set<EcoTopic> interests = const {},
    EcoTopic? topic,
    LearningProgress learning = const LearningProgress(),
    int seed = 1,
    QuizBank? from,
  }) =>
      pickQuizQuestions(
        bank: from ?? bank,
        learning: learning,
        random: Random(seed),
        interests: interests,
        topic: topic,
      );

  group('pickQuizQuestions', () {
    test('a topic quiz uses only that topic, 5 questions', () {
      final questions = pick(topic: EcoTopic.oceans);
      expect(questions, hasLength(5));
      expect(questions.every((q) => q.topic == EcoTopic.oceans), isTrue);
    });

    test('questions go from easy to hard', () {
      for (var seed = 0; seed < 20; seed++) {
        final levels = pick(seed: seed, interests: {EcoTopic.climate})
            .map((q) => q.difficulty)
            .toList();
        expect(levels, orderedEquals([...levels]..sort()),
            reason: 'seed $seed');
      }
    });

    test('a mixed quiz prefers the player\'s interests', () {
      final questions = pick(interests: {EcoTopic.oceans});
      expect(questions.every((q) => q.topic == EcoTopic.oceans), isTrue);
    });

    test('with few interest questions, other topics fill the gap', () {
      final small = QuizBank([
        testQuestion(EcoTopic.water, 1),
        testQuestion(EcoTopic.water, 2),
        ...testQuizBank().questions,
      ]);
      final questions = pick(from: small, interests: {EcoTopic.water});
      expect(questions, hasLength(5));
      expect(questions.where((q) => q.topic == EcoTopic.water), hasLength(2));
    });

    test('recently seen questions are avoided while others are left', () {
      final recent = [for (var n = 1; n <= 3; n++) 'oceans_00$n'];
      final questions = pick(
        interests: {EcoTopic.oceans},
        learning: LearningProgress(recentQuestionIds: recent),
      );
      final ids = questions.map((q) => q.id).toSet();
      // oceans 4 and 5 are new; the other 3 come from other topics
      // rather than repeating recent ones.
      expect(ids.containsAll({'oceans_004', 'oceans_005'}), isTrue);
      expect(ids.intersection(recent.toSet()), isEmpty);
    });

    test('a topic quiz repeats questions when it has no new ones', () {
      final all = [for (var n = 1; n <= 5; n++) 'oceans_00$n'];
      final questions = pick(
        topic: EcoTopic.oceans,
        learning: LearningProgress(recentQuestionIds: all),
      );
      expect(questions, hasLength(5));
    });

    test('no interests: any topic can appear', () {
      final topics = {
        for (var seed = 0; seed < 10; seed++)
          ...pick(seed: seed).map((q) => q.topic),
      };
      expect(topics.length, greaterThan(1));
    });

    test('an empty topic gives an empty quiz', () {
      expect(pick(topic: EcoTopic.energy), isEmpty);
    });
  });

  group('scoreQuiz', () {
    const economy = EconomyConfig.defaults; // 10 XP, repeat 2, streak +5

    AnsweredQuestion a(String id, bool correct) => AnsweredQuestion(
        questionId: id, topic: EcoTopic.oceans, correct: correct);

    test('all wrong gives 0 XP, never negative', () {
      final score = scoreQuiz(
          [for (var i = 0; i < 5; i++) a('q$i', false)],
          const LearningProgress(),
          economy);
      expect(score.xp, 0);
      expect(score.correctCount, 0);
      expect(score.bestStreak, 0);
    });

    test('perfect quiz: 5 × 10 XP + 4 streak bonuses × 5 = 70', () {
      final score = scoreQuiz(
          [for (var i = 0; i < 5; i++) a('q$i', true)],
          const LearningProgress(),
          economy);
      expect(score.xp, 70);
      expect(score.perfect, isTrue);
      expect(score.bestStreak, 5);
      expect(score.newlyLearned, 5);
    });

    test('a wrong answer breaks the streak', () {
      // ✓ ✓ ✗ ✓ ✓ → 4×10 + 2 bonuses (2nd and 5th) = 50
      final score = scoreQuiz([
        a('q1', true),
        a('q2', true),
        a('q3', false),
        a('q4', true),
        a('q5', true),
      ], const LearningProgress(), economy);
      expect(score.xp, 50);
      expect(score.bestStreak, 2);
    });

    test('questions learned before give reduced XP', () {
      final before = LearningProgress(learnedQuestionIds: {'q1', 'q2'});
      // q1, q2 repeats: 2 + (2+5); q3 new: 10+5 → 24
      final score = scoreQuiz(
          [a('q1', true), a('q2', true), a('q3', true)], before, economy);
      expect(score.xp, 24);
      expect(score.newlyLearned, 1);
    });
  });
}
