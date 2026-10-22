import 'package:material_ui/material_ui.dart';

import '../../core/widgets/coming_soon_view.dart';
import '../../l10n/app_localizations.dart';

/// LEARN hub. Placeholder until the quiz milestone.
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ComingSoonView(
      icon: Icons.school_rounded,
      title: l10n.learnTitle,
      body: l10n.learnBody,
    );
  }
}
