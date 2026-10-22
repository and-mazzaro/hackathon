import 'eco_topic.dart';
import 'json_utils.dart';

/// Where a fact comes from. Shown to the player after each answer.
class ContentSource {
  const ContentSource({
    required this.name,
    required this.url,
    required this.verifiedOn,
  });

  /// Short publisher name, e.g. "ISPRA".
  final String name;
  final String url;

  /// When a team member last checked that the page supports the fact.
  final DateTime verifiedOn;

  factory ContentSource.fromJson(Json json) {
    final name = readString(json, 'name');
    final url = readString(json, 'url');
    final verifiedOn = readString(json, 'verifiedOn');
    if (name == null || url == null || verifiedOn == null) {
      throw const FormatException('A source needs name, url and verifiedOn');
    }
    return ContentSource(
      name: name,
      url: url,
      verifiedOn: DateTime.parse(verifiedOn),
    );
  }
}

/// One multiple-choice question from the content file.
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.topic,
    required this.difficulty,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.source,
  });

  static const minDifficulty = 1;
  static const maxDifficulty = 3;

  /// Stable id, e.g. "oceans_003". Saved in the player's progress:
  /// never reuse an id for a different question.
  final String id;
  final EcoTopic topic;

  /// 1 = easy, 2 = medium, 3 = hard.
  final int difficulty;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final ContentSource source;

  String get correctOption => options[correctIndex];

  factory QuizQuestion.fromJson(Json json) {
    final id = readString(json, 'id');
    final topicId = readString(json, 'topic');
    final topic = topicId == null ? null : EcoTopic.fromId(topicId);
    final question = readString(json, 'question');
    final explanation = readString(json, 'explanation');
    if (id == null || topic == null || question == null ||
        explanation == null) {
      throw FormatException('Question "$id" is missing fields or has an '
          'unknown topic "$topicId"');
    }
    final options = readStringList(json, 'options');
    final correctIndex = readInt(json, 'correctIndex', fallback: -1);
    final difficulty = readInt(json, 'difficulty');
    if (options.length < 2 ||
        correctIndex < 0 ||
        correctIndex >= options.length) {
      throw FormatException('Question "$id" has invalid options');
    }
    if (difficulty < minDifficulty || difficulty > maxDifficulty) {
      throw FormatException('Question "$id" has difficulty $difficulty');
    }
    return QuizQuestion(
      id: id,
      topic: topic,
      difficulty: difficulty,
      question: question,
      options: options,
      correctIndex: correctIndex,
      explanation: explanation,
      source: ContentSource.fromJson(readObject(json, 'source')),
    );
  }
}

/// All questions from the content file.
class QuizBank {
  QuizBank(List<QuizQuestion> questions)
      : questions = List.unmodifiable(questions);

  final List<QuizQuestion> questions;

  List<QuizQuestion> forTopic(EcoTopic topic) =>
      questions.where((q) => q.topic == topic).toList();

  int countFor(EcoTopic topic) =>
      questions.where((q) => q.topic == topic).length;

  /// File layout: `{ "version": 1, "questions": [ ... ] }`.
  /// Extra fields (e.g. "sourceExcerpt" for reviewers) are ignored.
  factory QuizBank.fromJson(Json json) {
    final list = json['questions'];
    if (list is! List) {
      throw const FormatException('"questions" should be a list');
    }
    final questions = [
      for (final item in list)
        QuizQuestion.fromJson((item as Map).cast<String, Object?>()),
    ];
    final ids = <String>{};
    for (final q in questions) {
      if (!ids.add(q.id)) throw FormatException('Duplicate question id ${q.id}');
    }
    return QuizBank(questions);
  }
}
