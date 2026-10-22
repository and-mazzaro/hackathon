import 'dart:math';

import '../models/eco_topic.dart';
import '../models/learning_progress.dart';
import '../models/quiz_question.dart';
import 'economy_config.dart';

/// Chooses the questions for one quiz.
///
/// - [topic] set: only that topic ("Quiz: Oceani").
///   [topic] null: a mixed quiz that prefers the player's [interests].
/// - Questions shown recently are used only if nothing else is left.
/// - The result is sorted from easy to hard (rising difficulty).
///
/// [random] makes the choice testable: tests pass `Random(seed)`.
List<QuizQuestion> pickQuizQuestions({
  required QuizBank bank,
  required LearningProgress learning,
  required Random random,
  Set<EcoTopic> interests = const {},
  EcoTopic? topic,
  int count = 5,
}) {
  final pool = topic == null ? bank.questions : bank.forTopic(topic);
  final recent = learning.recentQuestionIds.toSet();

  bool preferred(QuizQuestion q) =>
      topic != null || interests.isEmpty || interests.contains(q.topic);

  // Groups in order of preference; each group is shuffled.
  List<QuizQuestion> group(bool Function(QuizQuestion) test) =>
      pool.where(test).toList()..shuffle(random);
  final ordered = [
    ...group((q) => preferred(q) && !recent.contains(q.id)),
    ...group((q) => !preferred(q) && !recent.contains(q.id)),
    ...group((q) => preferred(q) && recent.contains(q.id)),
    ...group((q) => !preferred(q) && recent.contains(q.id)),
  ];

  final chosen = ordered.take(count).toList();
  return sortedByDifficulty(chosen);
}

/// Easy → hard. Questions of the same difficulty keep their order.
List<QuizQuestion> sortedByDifficulty(List<QuizQuestion> questions) => [
      for (var level = QuizQuestion.minDifficulty;
          level <= QuizQuestion.maxDifficulty;
          level++)
        ...questions.where((q) => q.difficulty == level),
    ];

/// The XP of one finished quiz.
class QuizScore {
  const QuizScore({
    required this.correctCount,
    required this.questionCount,
    required this.xp,
    required this.bestStreak,
    required this.newlyLearned,
  });

  final int correctCount;
  final int questionCount;
  final int xp;
  final int bestStreak;

  /// Correct answers to questions never answered correctly before.
  final int newlyLearned;

  bool get perfect => correctCount == questionCount;
}

/// Calculates XP for a quiz.
///
/// - correct, first time: `quizXpPerCorrectAnswer`
/// - correct, already learned before: `quizRepeatXp`
/// - each correct answer after the first in a row: + `quizStreakBonusXp`
/// - wrong answers: 0 (never negative)
QuizScore scoreQuiz(
  List<AnsweredQuestion> answers,
  LearningProgress before,
  EconomyConfig economy,
) {
  var xp = 0;
  var streak = 0;
  var bestStreak = 0;
  var correct = 0;
  var newlyLearned = 0;

  for (final answer in answers) {
    if (!answer.correct) {
      streak = 0;
      continue;
    }
    correct++;
    streak++;
    if (streak > bestStreak) bestStreak = streak;

    final firstTime = !before.learnedQuestionIds.contains(answer.questionId);
    if (firstTime) newlyLearned++;
    xp += firstTime ? economy.quizXpPerCorrectAnswer : economy.quizRepeatXp;
    if (streak > 1) xp += economy.quizStreakBonusXp;
  }

  return QuizScore(
    correctCount: correct,
    questionCount: answers.length,
    xp: xp,
    bestStreak: bestStreak,
    newlyLearned: newlyLearned,
  );
}
