import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';
import '../../core/widgets/stat_bar.dart';
import '../../domain/game_controller.dart';
import '../../domain/rules/progression.dart';
import '../../l10n/app_localizations.dart';

/// "It hatches at level 2: 60 XP to go" as a progress bar (Home, Pet tab).
class EggProgressBar extends ConsumerWidget {
  const EggProgressBar({super.key, required this.totalXp});

  final int totalXp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final economy = ref.watch(economyProvider);
    final target = totalXpForLevel(economy.hatchLevel, economy);
    final missing = math.max(0, target - totalXp);

    return StatBar(
      label: missing == 0
          ? l10n.eggReady
          : l10n.eggHatchProgress(economy.hatchLevel, missing),
      value: target == 0 ? 1 : totalXp / target,
      color: EcoColors.xp,
      icon: Icons.egg_rounded,
      valueText: '${math.min(totalXp, target)}/$target',
      semanticsValue: l10n.xpProgress(math.min(totalXp, target), target),
    );
  }
}
