import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/models/game_state.dart';
import 'in_memory_save_repository.dart';
import 'json_file_save_repository.dart';

/// Loads and stores the one [GameState] of this device.
///
/// The rest of the app only knows this interface, so the storage can change
/// (file today, Drift or a server later) without touching any feature.
abstract interface class SaveRepository {
  /// The saved game, or null when nothing was saved yet (first launch).
  ///
  /// Throws [SaveCorruptedException] or [SaveFromNewerAppException].
  Future<GameState?> load();

  /// Replaces the saved game. Calls are written in the order they are made.
  Future<void> save(GameState state);
}

/// Base type for the save errors the UI knows how to show.
sealed class SaveException implements Exception {
  const SaveException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The save (and its backup) could not be read.
class SaveCorruptedException extends SaveException {
  const SaveCorruptedException(super.message);
}

/// The save was written by a newer EcoQuest. We must not overwrite it.
class SaveFromNewerAppException extends SaveException {
  const SaveFromNewerAppException(this.version)
      : super('Save version $version is newer than this app supports');

  final int version;
}

/// The repository used by the app. Tests replace it with
/// `saveRepositoryProvider.overrideWithValue(InMemorySaveRepository())`.
final saveRepositoryProvider = Provider<SaveRepository>((ref) {
  // The web build is only a developer preview: it keeps progress in memory.
  if (kIsWeb) return InMemorySaveRepository();
  return JsonFileSaveRepository(directory: getApplicationSupportDirectory);
});
