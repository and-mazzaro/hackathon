import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';

/// Rounded white card with a soft shadow.
///
/// When [onTap] is set the whole card is one button for screen readers
/// (its texts are read together), so do not put other buttons inside it.
class EcoCard extends StatelessWidget {
  const EcoCard({
    super.key,
    required this.child,
    this.onTap,
    this.color = EcoColors.surface,
    this.padding = const EdgeInsets.all(EcoSpacing.m),
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(EcoSpacing.radiusCard);

    Widget card = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: EcoColors.ink.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: color,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    if (onTap != null) {
      card = MergeSemantics(child: Semantics(button: true, child: card));
    }
    return card;
  }
}
