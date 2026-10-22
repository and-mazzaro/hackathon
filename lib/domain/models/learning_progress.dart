import 'eco_topic.dart';
import 'json_utils.dart';

/// How a player did on one topic. Used later to adapt difficulty and to
/// suggest topics.
class TopicStats {
  const TopicStats({this.answered = 0, this.correct = 0});

  final int answered;
  final int correct;

  Json toJson() => {'answered': answered, 'correct': correct};

  factory TopicStats.fromJson(Json json) => TopicStats(
        answered: readInt(json, 'answered'),
        correct: readInt(json, 'correct'),
      );
}

/// One answered question, as reported by a finished quiz.
class AnsweredQuestion {
  const AnsweredQuestion({
    required this.questionId,
    required this.topic,
    required this.correct,
  });

  final String questionId;
  final EcoTopic topic;
  final bool correct;
}

/// What the player has learned so far. Saved inside GameState.
class LearningProgress {
  const LearningProgress({
    this.quizzesCompleted = 0,
    this.statsByTopic = const {},
    this.learnedQuestionIds = const {},
    this.recentQuestionIds = const [],
  });

  /// How many recent question ids we remember to avoid repeats.
  static const recentMemory = 20;

  final int quizzesCompleted;
  final Map<EcoTopic, TopicStats> statsByTopic;

  /// Questions answered correctly at least once. A repeat earns less XP.
  final Set<String> learnedQuestionIds;

  /// The last questions shown, newest last.
  final List<String> recentQuestionIds;

  /// Adds the answers of one finished quiz.
  LearningProgress record(List<AnsweredQuestion> answers) {
    final stats = {...statsByTopic};
    final learned = {...learnedQuestionIds};
    final recent = [...recentQuestionIds];

    for (final answer in answers) {
      final old = stats[answer.topic] ?? const TopicStats();
      stats[answer.topic] = TopicStats(
        answered: old.answered + 1,
        correct: old.correct + (answer.correct ? 1 : 0),
      );
      if (answer.correct) learned.add(answer.questionId);
      recent
        ..remove(answer.questionId)
        ..add(answer.questionId);
    }
    final overflow = recent.length - recentMemory;

    return LearningProgress(
      quizzesCompleted: quizzesCompleted + 1,
      statsByTopic: stats,
      learnedQuestionIds: learned,
      recentQuestionIds: overflow > 0 ? recent.sublist(overflow) : recent,
    );
  }

  Json toJson() => {
        'quizzesCompleted': quizzesCompleted,
        'statsByTopic': {
          for (final entry in statsByTopic.entries)
            entry.key.id: entry.value.toJson(),
        },
        'learnedQuestionIds': learnedQuestionIds.toList(),
        'recentQuestionIds': recentQuestionIds,
      };

  factory LearningProgress.fromJson(Json json) {
    final stats = <EcoTopic, TopicStats>{};
    readObject(json, 'statsByTopic').forEach((id, value) {
      final topic = EcoTopic.fromId(id);
      if (topic != null && value is Map) {
        stats[topic] = TopicStats.fromJson(value.cast<String, Object?>());
      }
    });
    return LearningProgress(
      quizzesCompleted: readInt(json, 'quizzesCompleted'),
      statsByTopic: stats,
      learnedQuestionIds: readStringList(json, 'learnedQuestionIds').toSet(),
      recentQuestionIds: readStringList(json, 'recentQuestionIds'),
    );
  }
}
