import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../l10n/app_localizations.dart';

/// A labelled progress bar for pet needs and XP.
///
/// Screen readers hear one item, e.g. "Sazietà, 40 percento", instead of
/// separate icon, text and bar nodes.
class StatBar extends StatelessWidget {
  const StatBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.icon,
    this.valueText,
    this.semanticsValue,
  });

  final String label;

  /// From 0.0 (empty) to 1.0 (full). Values outside are clamped.
  final double value;
  final Color color;
  final IconData? icon;

  /// Short text shown on the right, e.g. "40/100". Defaults to "40%".
  final String? valueText;

  /// What screen readers say for the value, e.g. "40 su 100 punti
  /// esperienza". Defaults to "40 percento".
  final String? semanticsValue;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final percent = (clamped * 100).round();
    final spoken =
        semanticsValue ?? AppLocalizations.of(context).percentValue(percent);
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      label: label,
      value: spoken,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: color),
                  const SizedBox(width: EcoSpacing.xs),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.labelLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  valueText ?? '$percent%',
                  style: textTheme.labelMedium
                      ?.copyWith(color: EcoColors.inkMuted),
                ),
              ],
            ),
            const SizedBox(height: EcoSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(EcoSpacing.radiusPill),
              child: LinearProgressIndicator(
                value: clamped,
                minHeight: 10,
                color: color,
                backgroundColor: color.withValues(alpha: 0.18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
