import 'package:ecoquest/domain/models/eco_topic.dart';
import 'package:ecoquest/domain/models/quiz_question.dart';

/// Difficulty of question 1..5 in every fixture topic.
const fixtureDifficulties = [1, 1, 2, 2, 3];

/// A fake question. The right answer always starts with "Giusta", so tests
/// can find it whatever order the options are shuffled into.
QuizQuestion testQuestion(EcoTopic topic, int n, {int? difficulty}) {
  final tag = '${topic.id} $n';
  return QuizQuestion(
    id: '${topic.id}_${n.toString().padLeft(3, '0')}',
    topic: topic,
    difficulty: difficulty ?? fixtureDifficulties[(n - 1) % 5],
    question: 'Domanda $tag?',
    options: ['Giusta $tag', 'Sbagliata A $tag', 'Sbagliata B $tag',
        'Sbagliata C $tag'],
    correctIndex: 0,
    explanation: 'Spiegazione $tag.',
    source: ContentSource(
      name: 'Fonte di prova',
      url: 'https://example.org/$n',
      verifiedOn: DateTime(2026, 10, 22),
    ),
  );
}

/// 5 questions each for recycling, oceans and climate; nothing else.
QuizBank testQuizBank({
  List<EcoTopic> topics = const [
    EcoTopic.recycling,
    EcoTopic.oceans,
    EcoTopic.climate,
  ],
}) {
  return QuizBank([
    for (final topic in topics)
      for (var n = 1; n <= 5; n++) testQuestion(topic, n),
  ]);
}
