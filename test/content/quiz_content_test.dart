import 'dart:convert';
import 'dart:io';

import 'package:ecoquest/data/content/quiz_content.dart';
import 'package:ecoquest/domain/models/eco_topic.dart';
import 'package:ecoquest/domain/models/quiz_question.dart';
import 'package:flutter_test/flutter_test.dart';

/// Checks the REAL question file, so a typo in the content cannot reach
/// the app. Run `flutter test test/content` after editing the questions.
void main() {
  late QuizBank bank;
  late List<Map<String, Object?>> raw;

  setUpAll(() {
    final text = File(quizContentAsset).readAsStringSync();
    final json = (jsonDecode(text) as Map).cast<String, Object?>();
    raw = [
      for (final item in json['questions']! as List)
        (item as Map).cast<String, Object?>(),
    ];
    bank = QuizBank.fromJson(json); // also checks ids are unique
  });

  test('every topic has at least 5 questions from easy to hard', () {
    for (final topic in EcoTopic.values) {
      final questions = bank.forTopic(topic);
      expect(questions.length, greaterThanOrEqualTo(5),
          reason: '${topic.id} needs at least 5 questions');
      final levels = questions.map((q) => q.difficulty).toSet();
      expect(levels, containsAll([1, 3]),
          reason: '${topic.id} needs easy and hard questions');
    }
  });

  test('ids follow the "<topic>_<3 digits>" pattern of their topic', () {
    for (final q in bank.questions) {
      expect(q.id, matches(RegExp('^${q.topic.id}_\\d{3}\$')));
    }
  });

  test('exactly 4 different, non-empty options', () {
    for (final q in bank.questions) {
      expect(q.options, hasLength(4), reason: q.id);
      expect(q.options.toSet(), hasLength(4), reason: '${q.id} repeats');
      expect(q.options.every((o) => o.trim().isNotEmpty), isTrue,
          reason: q.id);
    }
  });

  test('texts fit on a phone screen', () {
    for (final q in bank.questions) {
      expect(q.question.length, lessThanOrEqualTo(200), reason: q.id);
      expect(q.options.every((o) => o.length <= 80), isTrue, reason: q.id);
      expect(q.explanation.trim(), isNotEmpty, reason: q.id);
      expect(q.explanation.length, lessThanOrEqualTo(300), reason: q.id);
    }
  });

  test('every question has a real-looking, verified source', () {
    final today = DateTime.now();
    for (final q in bank.questions) {
      final uri = Uri.tryParse(q.source.url);
      expect(uri?.scheme, 'https', reason: '${q.id}: ${q.source.url}');
      expect(uri!.host, isNot(contains('example')), reason: q.id);
      expect(q.source.name.trim(), isNotEmpty, reason: q.id);
      expect(q.source.verifiedOn.isAfter(today), isFalse, reason: q.id);
    }
  });

  test('reviewers get a short supporting excerpt for every question', () {
    for (final item in raw) {
      final excerpt = item['sourceExcerpt'];
      expect(excerpt, isA<String>(), reason: '${item['id']}');
      expect((excerpt! as String).trim(), isNotEmpty, reason: '${item['id']}');
    }
  });

  test('the right answer is not always in the same position', () {
    final positions = bank.questions.map((q) => q.correctIndex).toSet();
    expect(positions.length, greaterThan(1));
  });
}
