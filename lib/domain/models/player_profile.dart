import 'eco_topic.dart';
import 'json_utils.dart';

/// Age ranges instead of a birth date: we only collect what we need.
enum AgeRange {
  age13to15('13-15'),
  age16to18('16-18'),
  age19to22('19-22'),
  age23to26('23-26'),
  over26('27+');

  const AgeRange(this.id);

  final String id;

  static AgeRange? fromId(String? id) {
    for (final range in values) {
      if (range.id == id) return range;
    }
    return null;
  }
}

/// Who is playing. Local only: nothing here leaves the device.
class PlayerProfile {
  const PlayerProfile({
    required this.createdAt,
    this.nickname,
    this.ageRange,
    this.interests = const {},
    this.onboardingCompleted = false,
  });

  final DateTime createdAt;
  final String? nickname;
  final AgeRange? ageRange;
  final Set<EcoTopic> interests;
  final bool onboardingCompleted;

  PlayerProfile copyWith({
    String? nickname,
    AgeRange? ageRange,
    Set<EcoTopic>? interests,
    bool? onboardingCompleted,
  }) {
    return PlayerProfile(
      createdAt: createdAt,
      nickname: nickname ?? this.nickname,
      ageRange: ageRange ?? this.ageRange,
      interests: interests ?? this.interests,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  Json toJson() => {
        'createdAt': createdAt.toIso8601String(),
        'nickname': nickname,
        'ageRange': ageRange?.id,
        'interests': [for (final topic in interests) topic.id],
        'onboardingCompleted': onboardingCompleted,
      };

  factory PlayerProfile.fromJson(Json json, {required DateTime now}) {
    return PlayerProfile(
      createdAt: readDate(json, 'createdAt', fallback: now),
      nickname: readString(json, 'nickname'),
      ageRange: AgeRange.fromId(readString(json, 'ageRange')),
      interests: {
        // The leading "?" skips nulls: unknown topic ids are dropped.
        for (final id in readStringList(json, 'interests'))
          ?EcoTopic.fromId(id),
      },
      onboardingCompleted: readBool(json, 'onboardingCompleted'),
    );
  }
}
