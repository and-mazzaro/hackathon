import 'dart:convert';

import 'package:ecoquest/data/save/save_format.dart';
import 'package:ecoquest/domain/models/eco_topic.dart';
import 'package:ecoquest/domain/models/learning_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AnsweredQuestion a(String id, EcoTopic topic, bool correct) =>
      AnsweredQuestion(questionId: id, topic: topic, correct: correct);

  test('record counts answers per topic and remembers what was learned', () {
    final after = const LearningProgress().record([
      a('oceans_001', EcoTopic.oceans, true),
      a('oceans_002', EcoTopic.oceans, false),
      a('water_001', EcoTopic.water, true),
    ]);

    expect(after.quizzesCompleted, 1);
    expect(after.statsByTopic[EcoTopic.oceans]!.answered, 2);
    expect(after.statsByTopic[EcoTopic.oceans]!.correct, 1);
    expect(after.statsByTopic[EcoTopic.water]!.correct, 1);
    expect(after.learnedQuestionIds, {'oceans_001', 'water_001'});
    expect(after.recentQuestionIds,
        ['oceans_001', 'oceans_002', 'water_001']);
  });

  test('only the last 30 question ids are remembered', () {
    var learning = const LearningProgress();
    for (var quiz = 0; quiz < 8; quiz++) {
      learning = learning.record([
        for (var q = 0; q < 5; q++)
          a('id_${quiz}_$q', EcoTopic.climate, false),
      ]);
    }
    expect(learning.recentQuestionIds, hasLength(30));
    expect(learning.recentQuestionIds.first, 'id_2_0'); // oldest kept
    expect(learning.recentQuestionIds.last, 'id_7_4');
    expect(learning.quizzesCompleted, 8);
  });

  test('an old save with 20 recent ids still loads and grows to 30', () {
    final old = LearningProgress.fromJson({
      'recentQuestionIds': [for (var i = 0; i < 20; i++) 'old_$i'],
    });
    expect(old.recentQuestionIds, hasLength(20));
    final next = old.record([
      for (var q = 0; q < 5; q++) a('new_$q', EcoTopic.climate, true),
    ]);
    expect(next.recentQuestionIds, hasLength(25));
    expect(next.recentQuestionIds.first, 'old_0');
  });

  test('toJson → fromJson keeps everything', () {
    final original = const LearningProgress().record([
      a('oceans_001', EcoTopic.oceans, true),
    ]);
    final copy = LearningProgress.fromJson(
        jsonDecode(jsonEncode(original.toJson())) as Map<String, Object?>);

    expect(copy.toJson(), original.toJson());
  });

  test('a save from before the quiz milestone loads with empty stats', () {
    // Version 1 save written by M2/M3: no "learning" field at all.
    final oldSave = jsonEncode({
      'version': 1,
      'state': {
        'progress': {'totalXp': 40, 'coins': 5},
      },
    });

    final state = SaveFormat.decode(oldSave, now: DateTime(2026, 10, 22));
    expect(state.progress.totalXp, 40);
    expect(state.learning.quizzesCompleted, 0);
    expect(state.learning.learnedQuestionIds, isEmpty);
  });
}
