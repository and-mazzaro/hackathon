import 'dart:math';

import 'package:ecoquest/domain/models/eco_topic.dart';
import 'package:ecoquest/domain/quiz_session.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/quiz_fixtures.dart';

void main() {
  QuizSession newSession({int seed = 3}) => QuizSession(
        questions: testQuizBank().forTopic(EcoTopic.oceans),
        random: Random(seed),
        sessionId: 'test',
      );

  int correctOption(QuizSession s) => s.current.correctIndex;
  int wrongOption(QuizSession s) => (s.current.correctIndex + 1) % 4;

  test('options are shuffled but the right answer is tracked', () {
    final positions = <int>{};
    for (var seed = 0; seed < 20; seed++) {
      final session = newSession(seed: seed);
      final shown = session.current;
      expect(shown.options[shown.correctIndex], startsWith('Giusta'));
      expect(shown.options.toSet(), shown.question.options.toSet());
      positions.add(shown.correctIndex);
    }
    // Over many seeds the right answer is not always in the same place.
    expect(positions.length, greaterThan(1));
  });

  test('answering reports right or wrong; a second tap is ignored', () {
    final session = newSession();
    expect(session.answer(correctOption(session)), isTrue);
    expect(session.answer(wrongOption(session)), isNull);
    expect(session.chosenForCurrent, session.current.correctIndex);
  });

  test('cannot move on before answering', () {
    final session = newSession();
    session.next();
    expect(session.index, 0);
  });

  test('a full quiz collects all answers and the streak', () {
    final session = newSession();
    expect(session.hasStarted, isFalse);

    // ✓ ✓ ✗ ✓ ✓
    for (var i = 0; i < 5; i++) {
      session.answer(i == 2 ? wrongOption(session) : correctOption(session));
      if (i == 1) expect(session.currentStreak, 2);
      if (i == 2) expect(session.currentStreak, 0);
      session.next();
    }

    expect(session.isFinished, isTrue);
    expect(session.isLastQuestion, isTrue);
    expect(session.answers.map((a) => a.correct),
        [true, true, false, true, true]);
    expect(session.answers.every((a) => a.topic == EcoTopic.oceans), isTrue);
  });
}
