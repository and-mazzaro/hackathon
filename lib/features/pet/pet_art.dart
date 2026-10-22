import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';
import '../../domain/models/pet_state.dart';
import '../../domain/rules/pet_rules.dart';

/// Temporary pet artwork drawn with plain widgets: a round leafy creature.
/// Its face follows the mood, dirt spots show when it needs a bath, and it
/// grows (size, colour, leaves) with each stage. Decorative only.
class PetArt extends StatelessWidget {
  const PetArt({
    super.key,
    required this.stage,
    required this.mood,
    this.dirty = false,
  });

  final PetStage stage;
  final PetMood mood;
  final bool dirty;

  @override
  Widget build(BuildContext context) {
    final size = switch (stage) {
      PetStage.young => 165.0,
      PetStage.adult => 190.0,
      _ => 140.0,
    };
    final body = switch (stage) {
      PetStage.young => const Color(0xFF5DBB7E),
      PetStage.adult => const Color(0xFF3FA866),
      _ => const Color(0xFF8BD3A0),
    };
    final leaves = math.max(1, stage.index); // baby 1, young 2, adult 3
    final eyeHeight = mood == PetMood.sad ? size * 0.08 : size * 0.15;

    return SizedBox(
      width: size,
      height: size * 1.2,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Leaves on the head
          Positioned(
            top: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < leaves; i++)
                  Transform.rotate(
                    angle: (i - (leaves - 1) / 2) * 0.6,
                    child: Icon(Icons.eco_rounded,
                        size: size * 0.24, color: EcoColors.primary),
                  ),
              ],
            ),
          ),
          // Body
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: body,
              borderRadius: BorderRadius.only(
                topLeft: Radius.elliptical(size / 2, size * 0.55),
                topRight: Radius.elliptical(size / 2, size * 0.55),
                bottomLeft: Radius.elliptical(size / 2, size * 0.45),
                bottomRight: Radius.elliptical(size / 2, size * 0.45),
              ),
              boxShadow: [
                BoxShadow(
                  color: EcoColors.ink.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Belly
                Positioned(
                  left: size * 0.25,
                  right: size * 0.25,
                  bottom: size * 0.06,
                  height: size * 0.32,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(size, size)),
                    ),
                  ),
                ),
                // Eyes
                for (final left in [size * 0.28, size * 0.60])
                  Positioned(
                    left: left,
                    top: size * 0.30,
                    child: _Eye(
                        width: size * 0.12, height: eyeHeight),
                  ),
                // Cheeks
                for (final left in [size * 0.16, size * 0.70])
                  Positioned(
                    left: left,
                    top: size * 0.50,
                    child: _Dot(
                      size: size * 0.13,
                      color: const Color(0xFFFF7FA3).withValues(alpha: 0.75),
                    ),
                  ),
                // Mouth
                Positioned(
                  left: size * 0.38,
                  top: size * 0.50,
                  width: size * 0.24,
                  height: size * 0.12,
                  child: CustomPaint(painter: _MouthPainter(mood)),
                ),
                // Dirt spots when it needs a bath
                if (dirty)
                  for (final (x, y, s) in [
                    (0.12, 0.70, 0.10),
                    (0.74, 0.28, 0.08),
                    (0.62, 0.78, 0.07),
                  ])
                    Positioned(
                      left: size * x,
                      top: size * y,
                      child: _Dot(
                        size: size * s,
                        color: const Color(0xFF7A5230).withValues(alpha: 0.55),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  const _Eye({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: EcoColors.ink,
        borderRadius: BorderRadius.all(Radius.elliptical(width, height)),
      ),
      alignment: const Alignment(0.4, -0.5),
      child: _Dot(size: width * 0.35, color: Colors.white),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

/// Smile, small smile or frown, depending on the mood.
class _MouthPainter extends CustomPainter {
  _MouthPainter(this.mood);

  final PetMood mood;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = EcoColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.28
      ..strokeCap = StrokeCap.round;
    // Control point below the line = smile, above = frown.
    final curve = switch (mood) {
      PetMood.happy => size.height * 1.4,
      PetMood.ok => size.height * 0.6,
      PetMood.sad => -size.height * 0.4,
    };
    final top = mood == PetMood.sad ? size.height * 0.8 : size.height * 0.1;
    final path = Path()
      ..moveTo(0, top)
      ..quadraticBezierTo(size.width / 2, top + curve, size.width, top);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MouthPainter old) => old.mood != mood;
}
