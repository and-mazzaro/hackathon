import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../l10n/app_localizations.dart';

enum CurrencyKind { coins, tickets }

/// Pill showing a coin or reward-ticket balance.
/// Screen readers hear e.g. "1.250 monete" instead of "icon, 1250".
class CurrencyChip extends StatelessWidget {
  const CurrencyChip({super.key, required this.kind, required this.amount});

  final CurrencyKind kind;
  final int amount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();

    final (icon, iconColor, spokenLabel) = switch (kind) {
      CurrencyKind.coins => (
          Icons.monetization_on_rounded,
          EcoColors.coin,
          l10n.coinsAmount(amount),
        ),
      CurrencyKind.tickets => (
          Icons.confirmation_number_rounded,
          EcoColors.xp,
          l10n.ticketsAmount(amount),
        ),
    };

    // container: its own screen-reader item, not merged into neighbours.
    return Semantics(
      container: true,
      label: spokenLabel,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: EcoSpacing.s + EcoSpacing.xs,
            vertical: EcoSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: EcoColors.surface,
            borderRadius: BorderRadius.circular(EcoSpacing.radiusPill),
            border: Border.all(color: iconColor.withValues(alpha: 0.5), width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: iconColor),
              const SizedBox(width: EcoSpacing.xs),
              Text(
                NumberFormat.decimalPattern(locale).format(amount),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
