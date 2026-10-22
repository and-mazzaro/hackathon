import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/game_controller.dart';
import '../../domain/models/game_state.dart';
import '../../l10n/app_localizations.dart';
import 'save_error_view.dart';

/// Shows [builder] once the saved game is loaded, a spinner while it
/// loads, and the save error screen if it cannot be read.
/// Use it on every screen that needs the GameState.
class GameStateView extends ConsumerWidget {
  const GameStateView({super.key, required this.builder});

  final Widget Function(BuildContext context, GameState game) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(gameControllerProvider).when(
          data: (game) => builder(context, game),
          error: (error, stackTrace) => SaveErrorView(error: error),
          loading: () => Center(
            child: CircularProgressIndicator(
              semanticsLabel: AppLocalizations.of(context).loadingProgress,
            ),
          ),
        );
  }
}
