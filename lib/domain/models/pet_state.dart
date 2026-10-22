import 'json_utils.dart';

enum PetStage {
  egg('egg'),
  baby('baby'),
  young('young'),
  adult('adult');

  const PetStage(this.id);

  final String id;

  static PetStage fromId(String? id) =>
      values.firstWhere((stage) => stage.id == id, orElse: () => egg);
}

/// The pet's needs go from 0 (empty) to 100 (full).
///
/// Rule for every team member: the pet never dies and is never punished
/// permanently. Needs may drop while the player is away (Phase 6), but they
/// always stop at a minimum and can always be restored.
class PetState {
  const PetState({
    required this.needsUpdatedAt,
    this.name,
    this.stage = PetStage.egg,
    this.satiety = 80,
    this.happiness = 80,
    this.cleanliness = 80,
  });

  static const maxNeed = 100;

  final String? name;
  final PetStage stage;
  final int satiety;
  final int happiness;
  final int cleanliness;

  /// When the needs were last changed. Used later to compute how much they
  /// dropped while the app was closed.
  final DateTime needsUpdatedAt;

  PetState copyWith({
    String? name,
    PetStage? stage,
    int? satiety,
    int? happiness,
    int? cleanliness,
    DateTime? needsUpdatedAt,
  }) {
    return PetState(
      name: name ?? this.name,
      stage: stage ?? this.stage,
      satiety: _clampNeed(satiety ?? this.satiety),
      happiness: _clampNeed(happiness ?? this.happiness),
      cleanliness: _clampNeed(cleanliness ?? this.cleanliness),
      needsUpdatedAt: needsUpdatedAt ?? this.needsUpdatedAt,
    );
  }

  Json toJson() => {
        'name': name,
        'stage': stage.id,
        'satiety': satiety,
        'happiness': happiness,
        'cleanliness': cleanliness,
        'needsUpdatedAt': needsUpdatedAt.toIso8601String(),
      };

  factory PetState.fromJson(Json json, {required DateTime now}) {
    return PetState(
      name: readString(json, 'name'),
      stage: PetStage.fromId(readString(json, 'stage')),
      satiety: _clampNeed(readInt(json, 'satiety', fallback: 80)),
      happiness: _clampNeed(readInt(json, 'happiness', fallback: 80)),
      cleanliness: _clampNeed(readInt(json, 'cleanliness', fallback: 80)),
      needsUpdatedAt: readDate(json, 'needsUpdatedAt', fallback: now),
    );
  }

  static int _clampNeed(int value) => value.clamp(0, maxNeed);
}
