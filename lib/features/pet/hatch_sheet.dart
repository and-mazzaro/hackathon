import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../core/widgets/eco_button.dart';
import '../../domain/rules/profile_rules.dart';
import '../../l10n/app_localizations.dart';

/// Asks for the new pet's name. Returns the typed text ('' = default
/// name), or null if the sheet was dismissed without confirming.
Future<String?> showHatchSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const _HatchSheet(),
  );
}

class _HatchSheet extends StatefulWidget {
  const _HatchSheet();

  @override
  State<_HatchSheet> createState() => _HatchSheetState();
}

class _HatchSheetState extends State<_HatchSheet> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            EcoSpacing.l, 0, EcoSpacing.l, EcoSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.egg_alt_rounded, size: 56, color: EcoColors.coin),
            const SizedBox(height: EcoSpacing.s),
            Semantics(
              header: true,
              child: Text(l10n.hatchTitle,
                  style: textTheme.titleLarge, textAlign: TextAlign.center),
            ),
            const SizedBox(height: EcoSpacing.s),
            Text(l10n.hatchBody,
                style: textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: EcoSpacing.m),
            TextField(
              controller: _name,
              maxLength: maxNicknameLength,
              textCapitalization: TextCapitalization.words,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.petNameLabel,
                hintText: l10n.petNameHint,
                filled: true,
                fillColor: EcoColors.surface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: EcoSpacing.m),
            EcoButton(
              label: l10n.hatchConfirm,
              icon: Icons.check_rounded,
              expand: true,
              onPressed: () => Navigator.of(context).pop(_name.text),
            ),
          ],
        ),
      ),
    );
  }
}
