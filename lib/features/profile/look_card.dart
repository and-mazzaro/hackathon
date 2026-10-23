import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../core/widgets/eco_card.dart';
import '../../domain/game_controller.dart';
import '../../domain/models/look_mode.dart';
import '../../l10n/app_localizations.dart';

/// "Aspetto": the pet room look, automatic (phone clock) or fixed.
class LookCard extends ConsumerWidget {
  const LookCard({super.key, required this.mode});

  final LookMode mode;

  static String labelOf(LookMode mode, AppLocalizations l10n) =>
      switch (mode) {
        LookMode.auto => l10n.lookAuto,
        LookMode.day => l10n.lookDay,
        LookMode.afternoon => l10n.lookAfternoon,
        LookMode.night => l10n.lookNight,
      };

  static IconData _iconOf(LookMode mode) => switch (mode) {
        LookMode.auto => Icons.schedule_rounded,
        LookMode.day => Icons.wb_sunny_rounded,
        LookMode.afternoon => Icons.wb_twilight_rounded,
        LookMode.night => Icons.nightlight_round,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return EcoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(l10n.lookTitle, style: textTheme.titleMedium),
          ),
          const SizedBox(height: EcoSpacing.xs),
          Text(
            l10n.lookBody,
            style: textTheme.bodyMedium?.copyWith(color: EcoColors.inkMuted),
          ),
          const SizedBox(height: EcoSpacing.s),
          Wrap(
            spacing: EcoSpacing.s,
            runSpacing: EcoSpacing.s,
            children: [
              for (final option in LookMode.values)
                Semantics(
                  selected: option == mode,
                  button: true,
                  child: ChoiceChip(
                    avatar: Icon(_iconOf(option), size: 18),
                    label: Text(labelOf(option, l10n)),
                    selected: option == mode,
                    showCheckmark: false,
                    onSelected: (_) => ref
                        .read(gameControllerProvider.notifier)
                        .updateLookMode(option),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
