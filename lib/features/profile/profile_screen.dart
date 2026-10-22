import 'package:material_ui/material_ui.dart';

import '../../core/widgets/coming_soon_view.dart';
import '../../l10n/app_localizations.dart';

/// Profile, interests and settings. Placeholder until the profile milestone.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ComingSoonView(
      icon: Icons.person_rounded,
      title: l10n.profileTitle,
      body: l10n.profileBody,
    );
  }
}
