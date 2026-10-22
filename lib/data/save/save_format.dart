import 'dart:convert';

import '../../domain/models/game_state.dart';
import '../../domain/models/json_utils.dart';
import 'save_repository.dart';

/// How a [GameState] is written to text, including the version number.
///
/// File layout:
/// ```json
/// { "version": 1, "savedAt": "2026-10-22T10:15:00.000", "state": { ... } }
/// ```
abstract final class SaveFormat {
  /// Increase this when the meaning of saved data changes, and add a step
  /// to [_migrations] that turns version N into N + 1.
  static const currentVersion = 1;

  /// Example for the future:
  /// ```dart
  /// 1: (state) => {...state, 'streak': {'days': 0}},   // v1 → v2
  /// ```
  static final Map<int, Json Function(Json state)> _migrations = {};

  static String encode(GameState state, {required DateTime savedAt}) {
    return const JsonEncoder.withIndent('  ').convert({
      'version': currentVersion,
      'savedAt': savedAt.toIso8601String(),
      'state': state.toJson(),
    });
  }

  /// Throws [FormatException] for unreadable text and
  /// [SaveFromNewerAppException] for saves from a newer app version.
  static GameState decode(String text, {required DateTime now}) {
    final root = jsonDecode(text); // throws FormatException if not JSON
    if (root is! Map) throw const FormatException('Save is not a JSON object');
    final json = root.cast<String, Object?>();

    final version = readInt(json, 'version', fallback: -1);
    if (version < 1) throw FormatException('Invalid save version $version');
    if (version > currentVersion) throw SaveFromNewerAppException(version);

    var state = readObject(json, 'state');
    for (var v = version; v < currentVersion; v++) {
      final step = _migrations[v];
      if (step == null) throw StateError('Missing migration from v$v');
      state = step(state);
    }

    try {
      return GameState.fromJson(state, now: now);
    } on TypeError catch (error) {
      // A wrong type deep inside (e.g. a number where text belongs).
      throw FormatException('Unexpected data in save: $error');
    }
  }
}
