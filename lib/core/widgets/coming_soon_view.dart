import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../l10n/app_localizations.dart';

/// Friendly placeholder for screens that are not built yet.
class ComingSoonView extends StatelessWidget {
  const ComingSoonView({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(EcoSpacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: const BoxDecoration(
                    color: EcoColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 56, color: EcoColors.primary),
                ),
              ),
              const SizedBox(height: EcoSpacing.l),
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: EcoSpacing.s),
              Text(
                body,
                style: textTheme.bodyLarge?.copyWith(color: EcoColors.inkMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: EcoSpacing.m),
              Chip(
                label: Text(AppLocalizations.of(context).comingSoon),
                avatar: const Icon(Icons.construction_rounded, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
