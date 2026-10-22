import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../domain/models/player_profile.dart';
import '../../domain/rules/profile_rules.dart';
import '../../l10n/app_localizations.dart';
import 'profile_labels.dart';

/// Nickname field + age range choice. The parent owns the values, so the
/// same fields work in onboarding and in the profile edit sheet.
class AboutYouFields extends StatelessWidget {
  const AboutYouFields({
    super.key,
    required this.nicknameController,
    required this.ageRange,
    required this.onAgeRangeChanged,
  });

  final TextEditingController nicknameController;

  /// null = "Preferisco non dirlo".
  final AgeRange? ageRange;
  final ValueChanged<AgeRange?> onAgeRangeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    Widget ageChip(AgeRange? value, String label) => ChoiceChip(
          label: Text(label),
          selected: ageRange == value,
          onSelected: (_) => onAgeRangeChanged(value),
          selectedColor: EcoColors.primaryContainer,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: nicknameController,
          maxLength: maxNicknameLength,
          textCapitalization: TextCapitalization.words,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            labelText: l10n.nicknameLabel,
            hintText: l10n.nicknameHint,
            helperText: l10n.nicknameHelper,
            helperMaxLines: 3,
            filled: true,
            fillColor: EcoColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: EcoSpacing.l),
        Text(l10n.ageRangeLabel, style: textTheme.titleMedium),
        const SizedBox(height: EcoSpacing.s),
        Wrap(
          spacing: EcoSpacing.s,
          runSpacing: EcoSpacing.s,
          children: [
            for (final range in AgeRange.values)
              ageChip(range, range.label(l10n)),
            ageChip(null, l10n.ageRangeNotSaid),
          ],
        ),
      ],
    );
  }
}
