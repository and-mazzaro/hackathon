import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_spacing.dart';
import '../../core/widgets/eco_button.dart';
import '../../domain/game_controller.dart';
import '../../domain/models/player_profile.dart';
import '../../l10n/app_localizations.dart';
import 'about_you_fields.dart';

/// Opens the bottom sheet to change nickname and age range.
Future<void> showProfileDetailsSheet(
    BuildContext context, PlayerProfile profile) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true, // lets the sheet grow above the keyboard
    showDragHandle: true,
    builder: (context) => _ProfileDetailsSheet(profile: profile),
  );
}

class _ProfileDetailsSheet extends ConsumerStatefulWidget {
  const _ProfileDetailsSheet({required this.profile});

  final PlayerProfile profile;

  @override
  ConsumerState<_ProfileDetailsSheet> createState() =>
      _ProfileDetailsSheetState();
}

class _ProfileDetailsSheetState extends ConsumerState<_ProfileDetailsSheet> {
  late final _nickname =
      TextEditingController(text: widget.profile.nickname ?? '');
  late AgeRange? _ageRange = widget.profile.ageRange;

  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref.read(gameControllerProvider.notifier).updateProfileDetails(
          nickname: _nickname.text,
          ageRange: _ageRange,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      // Keeps the fields above the on-screen keyboard.
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            EcoSpacing.l, 0, EcoSpacing.l, EcoSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(l10n.profileEditTitle,
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: EcoSpacing.m),
            AboutYouFields(
              nicknameController: _nickname,
              ageRange: _ageRange,
              onAgeRangeChanged: (range) => setState(() => _ageRange = range),
            ),
            const SizedBox(height: EcoSpacing.l),
            EcoButton(label: l10n.saveAction, expand: true, onPressed: _save),
            const SizedBox(height: EcoSpacing.s),
            EcoButton(
              label: l10n.cancelAction,
              variant: EcoButtonVariant.secondary,
              expand: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
