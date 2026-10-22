import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../data/save/save_repository.dart';
import '../../domain/game_controller.dart';
import '../../l10n/app_localizations.dart';
import 'eco_button.dart';

/// Shown when the saved game cannot be loaded.
class SaveErrorView extends ConsumerWidget {
  const SaveErrorView({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    final body = switch (error) {
      SaveCorruptedException() => l10n.saveCorruptedBody,
      SaveFromNewerAppException() => l10n.saveNewerAppBody,
      _ => l10n.saveUnknownErrorBody,
    };
    // Never offer to overwrite a save from a newer app version.
    final canStartFresh = error is SaveCorruptedException;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(EcoSpacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 64, color: EcoColors.alert),
              const SizedBox(height: EcoSpacing.m),
              Semantics(
                header: true,
                child: Text(
                  l10n.saveErrorTitle,
                  style: textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: EcoSpacing.s),
              Text(body,
                  style: textTheme.bodyLarge, textAlign: TextAlign.center),
              const SizedBox(height: EcoSpacing.l),
              EcoButton(
                label: l10n.retryAction,
                icon: Icons.refresh_rounded,
                expand: true,
                onPressed: () => ref.invalidate(gameControllerProvider),
              ),
              if (canStartFresh) ...[
                const SizedBox(height: EcoSpacing.s),
                EcoButton(
                  label: l10n.startFreshAction,
                  variant: EcoButtonVariant.secondary,
                  expand: true,
                  onPressed: () =>
                      ref.read(gameControllerProvider.notifier).startFresh(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
