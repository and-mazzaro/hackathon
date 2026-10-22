import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../core/widgets/stat_bar.dart';
import '../../domain/models/pet_state.dart';
import '../../l10n/app_localizations.dart';

/// The three need bars (Home and Pet tab). Pass the pet "now".
class PetNeedBars extends StatelessWidget {
  const PetNeedBars({super.key, required this.pet});

  final PetState pet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    double value(int need) => need / PetState.maxNeed;

    return Column(
      children: [
        StatBar(
          label: l10n.statSatiety,
          value: value(pet.satiety),
          color: EcoColors.satiety,
          icon: Icons.restaurant_rounded,
        ),
        const SizedBox(height: EcoSpacing.s + EcoSpacing.xs),
        StatBar(
          label: l10n.statHappiness,
          value: value(pet.happiness),
          color: EcoColors.happiness,
          icon: Icons.favorite_rounded,
        ),
        const SizedBox(height: EcoSpacing.s + EcoSpacing.xs),
        StatBar(
          label: l10n.statCleanliness,
          value: value(pet.cleanliness),
          color: EcoColors.cleanliness,
          icon: Icons.water_drop_rounded,
        ),
      ],
    );
  }
}
