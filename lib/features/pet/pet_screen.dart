import 'package:material_ui/material_ui.dart';

import '../../core/widgets/coming_soon_view.dart';
import '../../l10n/app_localizations.dart';

/// PET room. Placeholder until the virtual-pet milestone.
class PetScreen extends StatelessWidget {
  const PetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ComingSoonView(
      icon: Icons.pets_rounded,
      title: l10n.petTitle,
      body: l10n.petBody,
    );
  }
}
