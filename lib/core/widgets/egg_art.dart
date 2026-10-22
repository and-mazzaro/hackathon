import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';

/// Temporary pet artwork: a spotted egg drawn with plain widgets.
/// Decorative only — wrap it in Semantics where it needs a description.
/// The virtual-pet milestone replaces it with the animated pet.
class EggArt extends StatelessWidget {
  const EggArt({super.key});

  @override
  Widget build(BuildContext context) {
    const spot = EcoColors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120,
          height: 150,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF0),
            // Narrower top, rounder bottom: an egg shape.
            borderRadius: const BorderRadius.only(
              topLeft: Radius.elliptical(60, 90),
              topRight: Radius.elliptical(60, 90),
              bottomLeft: Radius.elliptical(60, 60),
              bottomRight: Radius.elliptical(60, 60),
            ),
            border: Border.all(color: EcoColors.ink.withValues(alpha: 0.12)),
          ),
          child: Stack(
            children: [
              _spot(left: 30, top: 40, size: 22, color: spot),
              _spot(left: 70, top: 70, size: 16, color: spot),
              _spot(left: 40, top: 100, size: 12, color: spot),
            ],
          ),
        ),
        // Shadow under the egg
        Container(
          width: 100,
          height: 14,
          decoration: BoxDecoration(
            color: EcoColors.ink.withValues(alpha: 0.12),
            borderRadius: const BorderRadius.all(Radius.elliptical(50, 7)),
          ),
        ),
      ],
    );
  }

  Widget _spot({
    required double left,
    required double top,
    required double size,
    required Color color,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
