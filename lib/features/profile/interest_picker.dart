import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../domain/models/eco_topic.dart';
import '../../l10n/app_localizations.dart';
import 'profile_labels.dart';

/// A grid of topic tiles that can be switched on and off.
/// Used by onboarding and by the profile screen.
class InterestPicker extends StatelessWidget {
  const InterestPicker({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final Set<EcoTopic> selected;
  final ValueChanged<EcoTopic> onToggle;

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(10) > 15;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 1 column with very large text, 3 on wide screens, else 2.
        final columns = largeText
            ? 1
            : constraints.maxWidth >= 560
                ? 3
                : 2;
        const gap = EcoSpacing.s;
        final tileWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final topic in EcoTopic.values)
              SizedBox(
                width: tileWidth,
                child: _InterestTile(
                  topic: topic,
                  selected: selected.contains(topic),
                  onTap: () => onToggle(topic),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _InterestTile extends StatelessWidget {
  const _InterestTile({
    required this.topic,
    required this.selected,
    required this.onTap,
  });

  final EcoTopic topic;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final radius = BorderRadius.circular(16);

    // One screen-reader item: "Clima, casella selezionata" (or not).
    return MergeSemantics(
      child: Semantics(
        checked: selected,
        child: Material(
          color: selected ? EcoColors.primaryContainer : EcoColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(
              color: selected
                  ? EcoColors.primary
                  : EcoColors.ink.withValues(alpha: 0.15),
              width: 2,
            ),
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: EcoSpacing.s + EcoSpacing.xs,
                  vertical: EcoSpacing.s,
                ),
                child: Row(
                  children: [
                    Icon(topic.icon, color: EcoColors.primary, size: 24),
                    const SizedBox(width: EcoSpacing.s),
                    Expanded(
                      child: Text(
                        topic.label(l10n),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(width: EcoSpacing.xs),
                    Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: selected ? EcoColors.primary : EcoColors.inkMuted,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
