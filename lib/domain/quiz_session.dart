import 'dart:math';

import 'models/eco_topic.dart';
import 'models/learning_progress.dart';
import 'models/quiz_question.dart';

/// A question as shown on screen: options in a shuffled order.
class ShownQuestion {
  ShownQuestion._(this.question, this.options, this.correctIndex);

  factory ShownQuestion.shuffle(QuizQuestion question, Random random) {
    final order = List.generate(question.options.length, (i) => i)
      ..shuffle(random);
    return ShownQuestion._(
      question,
      [for (final i in order) question.options[i]],
      order.indexOf(question.correctIndex),
    );
  }

  final QuizQuestion question;
  final List<String> options;
  final int correctIndex;
}

/// Runs one quiz: which question is shown, what was answered, the result.
///
/// Plain Dart with no Flutter: the screen only displays it, and tests can
/// play a whole quiz without any UI.
class QuizSession {
  QuizSession({
    required List<QuizQuestion> questions,
    required Random random,
    required this.sessionId,
    this.topic,
  })  : assert(questions.isNotEmpty),
        questions = [
          for (final q in questions) ShownQuestion.shuffle(q, random),
        ];

  /// Unique per quiz; the reward is claimed as `quiz:sessionId`.
  final String sessionId;

  /// null for a mixed quiz.
  final EcoTopic? topic;
  final List<ShownQuestion> questions;

  int _index = 0;
  final List<int> _chosen = [];

  int get index => _index;
  int get length => questions.length;
  ShownQuestion get current => questions[_index];

  /// The option picked for the current question, or null if not answered.
  int? get chosenForCurrent => _chosen.length > _index ? _chosen[_index] : null;
  bool get currentAnswered => chosenForCurrent != null;

  /// True once at least one question was answered.
  bool get hasStarted => _chosen.isNotEmpty;
  bool get isLastQuestion => _index == questions.length - 1;
  bool get isFinished => _chosen.length == questions.length;

  /// Correct answers in a row up to now.
  int get currentStreak {
    var streak = 0;
    for (var i = _chosen.length - 1; i >= 0; i--) {
      if (_chosen[i] != questions[i].correctIndex) break;
      streak++;
    }
    return streak;
  }

  /// Records the answer to the current question. Returns whether it was
  /// right. A second tap on the same question is ignored (returns null).
  bool? answer(int optionIndex) {
    if (currentAnswered) return null;
    _chosen.add(optionIndex);
    return optionIndex == current.correctIndex;
  }

  /// Moves to the next question (only after answering the current one).
  void next() {
    if (!currentAnswered || isLastQuestion) return;
    _index++;
  }

  /// The answers, for scoring and saving. Only complete quizzes count.
  List<AnsweredQuestion> get answers {
    assert(isFinished, 'Finish the quiz before reading the answers');
    return [
      for (var i = 0; i < questions.length; i++)
        AnsweredQuestion(
          questionId: questions[i].question.id,
          topic: questions[i].question.topic,
          correct: _chosen[i] == questions[i].correctIndex,
        ),
    ];
  }
}
