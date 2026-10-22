import '../../domain/models/game_state.dart';
import 'save_repository.dart';

/// Keeps the game in memory only. Used by tests and the web preview.
class InMemorySaveRepository implements SaveRepository {
  InMemorySaveRepository([this.saved]);

  /// The last saved state (public so tests can inspect it).
  GameState? saved;

  /// How many times [save] was called.
  int saveCount = 0;

  @override
  Future<GameState?> load() async => saved;

  @override
  Future<void> save(GameState state) async {
    saved = state;
    saveCount++;
  }
}
