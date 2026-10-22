import 'dart:io';

import '../../domain/models/game_state.dart';
import 'save_format.dart';
import 'save_repository.dart';

/// Saves the game as a JSON file in the app's private folder.
///
/// Safe writing, so a crash or a full disk never destroys the progress:
/// 1. write the new save to `ecoquest_save.json.tmp`,
/// 2. copy the current save to `ecoquest_save.bak.json`,
/// 3. rename the temporary file over the real one (an atomic step).
/// If the real file is unreadable, the backup is loaded instead.
class JsonFileSaveRepository implements SaveRepository {
  /// Callers write `directory:` and `clock:`; the fields stay private.
  JsonFileSaveRepository({
    required this._directory,
    this._clock = DateTime.now,
  });

  static const fileName = 'ecoquest_save.json';
  static const backupName = 'ecoquest_save.bak.json';
  static const tempName = 'ecoquest_save.json.tmp';

  final Future<Directory> Function() _directory;
  final DateTime Function() _clock;

  /// Saves run one after another, never at the same time.
  Future<void> _queue = Future.value();

  @override
  Future<GameState?> load() async {
    await _queue;
    final dir = await _directory();
    final main = _file(dir, fileName);
    final backup = _file(dir, backupName);

    if (!await main.exists() && !await backup.exists()) return null;

    final mainState = await _tryRead(main);
    if (mainState != null) return mainState;

    // The real save is missing or broken: try the backup.
    if (await main.exists()) await _setAside(main);
    final backupState = await _tryRead(backup);
    if (backupState != null) return backupState;

    if (await backup.exists()) await _setAside(backup);
    throw const SaveCorruptedException(
        'Neither the save nor its backup could be read');
  }

  @override
  Future<void> save(GameState state) {
    // Chain onto the previous save; a failed save does not block later ones.
    final next = _queue.catchError((_) {}).then((_) => _write(state));
    _queue = next.catchError((_) {});
    return next;
  }

  Future<void> _write(GameState state) async {
    final dir = await _directory();
    await dir.create(recursive: true);
    final main = _file(dir, fileName);
    final temp = _file(dir, tempName);

    await temp.writeAsString(
      SaveFormat.encode(state, savedAt: _clock()),
      flush: true,
    );
    if (await main.exists()) {
      await main.copy(_file(dir, backupName).path);
    }
    await temp.rename(main.path);
  }

  /// Returns null when the file is missing or unreadable.
  /// A save from a newer app version is NOT treated as unreadable.
  Future<GameState?> _tryRead(File file) async {
    if (!await file.exists()) return null;
    try {
      return SaveFormat.decode(await file.readAsString(), now: _clock());
    } on FormatException {
      return null;
    } on FileSystemException {
      return null;
    }
  }

  /// Keeps a broken file for debugging, under a name we never load.
  Future<void> _setAside(File file) async {
    final stamp = _clock().millisecondsSinceEpoch;
    await file.rename('${file.path}.corrupt-$stamp');
  }

  File _file(Directory dir, String name) =>
      File('${dir.path}${Platform.pathSeparator}$name');
}
