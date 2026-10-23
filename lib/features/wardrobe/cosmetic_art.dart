import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../domain/models/cosmetic_item.dart';

/// Draws one cosmetic item from its content-file "icon" key, in the item's
/// colour. Used on the pet (sized by `PetArt`) and in the wardrobe lists.
/// Unknown keys draw a simple star, so new content never breaks.
/// Decorative only: screen readers get the item name from the text nearby.
class CosmeticArt extends StatelessWidget {
  const CosmeticArt({super.key, required this.item, required this.size});

  final CosmeticItem item;

  /// The box the item is drawn in.
  final Size size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: size,
        painter: _CosmeticPainter(item.icon, Color(item.color)),
      ),
    );
  }
}

/// A square preview of [item] for lists and the reveal sheet.
class CosmeticThumbnail extends StatelessWidget {
  const CosmeticThumbnail({super.key, required this.item, this.size = 56});

  final CosmeticItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6F2),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: CosmeticArt(
        item: item,
        size: Size(size * 0.76, size * 0.76),
      ),
    );
  }
}

class _CosmeticPainter extends CustomPainter {
  _CosmeticPainter(this.key, this.color);

  final String key;
  final Color color;

  static const _ink = Color(0xFF173A2B);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fill = Paint()..color = color;
    final dark = Paint()..color = Color.lerp(color, _ink, 0.45)!;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2, h * 0.09)
      ..strokeCap = StrokeCap.round;

    switch (key) {
      case 'flower':
        final center = Offset(w / 2, h / 2);
        final r = math.min(w, h) * 0.2;
        for (var i = 0; i < 5; i++) {
          final a = i * 2 * math.pi / 5 - math.pi / 2;
          canvas.drawCircle(
              center + Offset(math.cos(a), math.sin(a)) * r * 1.2, r, fill);
        }
        canvas.drawCircle(center, r * 0.8, Paint()..color = const Color(0xFFFFC93C));
      case 'hat':
        canvas.drawOval(
            Rect.fromLTWH(0, h * 0.62, w, h * 0.32), fill);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(w * 0.24, h * 0.1, w * 0.52, h * 0.66),
                Radius.circular(w * 0.18)),
            fill);
        canvas.drawRect(Rect.fromLTWH(w * 0.24, h * 0.52, w * 0.52, h * 0.12),
            dark);
      case 'party':
        final cone = Path()
          ..moveTo(w / 2, h * 0.14)
          ..lineTo(w * 0.78, h)
          ..lineTo(w * 0.22, h)
          ..close();
        canvas.drawPath(cone, fill);
        canvas.save();
        canvas.clipPath(cone);
        final stripe = Paint()..color = Colors.white.withValues(alpha: 0.55);
        for (var i = 1; i <= 3; i++) {
          canvas.drawRect(Rect.fromLTWH(0, h * (0.14 + i * 0.22), w, h * 0.08),
              stripe);
        }
        canvas.restore();
        canvas.drawCircle(
            Offset(w / 2, h * 0.12), h * 0.12, Paint()..color = const Color(0xFFFFC93C));
      case 'crown':
        final crown = Path()
          ..moveTo(w * 0.08, h)
          ..lineTo(w * 0.08, h * 0.3)
          ..lineTo(w * 0.3, h * 0.6)
          ..lineTo(w * 0.5, h * 0.1)
          ..lineTo(w * 0.7, h * 0.6)
          ..lineTo(w * 0.92, h * 0.3)
          ..lineTo(w * 0.92, h)
          ..close();
        canvas.drawPath(crown, fill);
        final gem = Paint()..color = const Color(0xFF1B7F4C);
        for (final x in [0.3, 0.5, 0.7]) {
          canvas.drawCircle(Offset(w * x, h * 0.8), h * 0.08, gem);
        }
      case 'glasses':
        final r = h * 0.3;
        canvas.drawCircle(Offset(w * 0.23, h / 2), r, stroke);
        canvas.drawCircle(Offset(w * 0.77, h / 2), r, stroke);
        canvas.drawLine(Offset(w * 0.23 + r, h / 2),
            Offset(w * 0.77 - r, h / 2), stroke);
      case 'sunglasses':
        for (final x in [0.06, 0.56]) {
          canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromLTWH(w * x, h * 0.2, w * 0.38, h * 0.62),
                  Radius.circular(h * 0.28)),
              fill);
        }
        canvas.drawLine(
            Offset(w * 0.44, h * 0.4), Offset(w * 0.56, h * 0.4), stroke);
      case 'mask':
        final band = Path()
          ..fillType = PathFillType.evenOdd
          ..addRRect(RRect.fromRectAndRadius(
              Rect.fromLTWH(0, h * 0.1, w, h * 0.8),
              Radius.circular(h * 0.4)))
          ..addOval(Rect.fromCenter(
              center: Offset(w * 0.23, h / 2), width: w * 0.2, height: h * 0.5))
          ..addOval(Rect.fromCenter(
              center: Offset(w * 0.77, h / 2), width: w * 0.2, height: h * 0.5));
        canvas.drawPath(band, fill);
      case 'scarf':
        canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h * 0.42),
                Radius.circular(h * 0.21)),
            fill);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(w * 0.62, h * 0.2, w * 0.18, h * 0.8),
                Radius.circular(w * 0.05)),
            dark);
      case 'bow':
        final left = Path()
          ..moveTo(w / 2, h / 2)
          ..lineTo(w * 0.12, h * 0.1)
          ..lineTo(w * 0.12, h * 0.9)
          ..close();
        final right = Path()
          ..moveTo(w / 2, h / 2)
          ..lineTo(w * 0.88, h * 0.1)
          ..lineTo(w * 0.88, h * 0.9)
          ..close();
        canvas.drawPath(left, fill);
        canvas.drawPath(right, fill);
        canvas.drawCircle(Offset(w / 2, h / 2), h * 0.16, dark);
      case 'bell':
        canvas.drawLine(Offset(w * 0.1, h * 0.12), Offset(w * 0.9, h * 0.12),
            Paint()
              ..color = const Color(0xFFE5578A)
              ..strokeWidth = h * 0.12
              ..strokeCap = StrokeCap.round);
        canvas.drawCircle(Offset(w / 2, h * 0.56), h * 0.34, fill);
        canvas.drawLine(Offset(w / 2, h * 0.6), Offset(w / 2, h * 0.86),
            Paint()
              ..color = _ink
              ..strokeWidth = h * 0.06
              ..strokeCap = StrokeCap.round);
      case 'medal':
        final ribbon = Paint()..color = const Color(0xFFC2410C);
        canvas.drawPath(
            Path()
              ..moveTo(w * 0.28, 0)
              ..lineTo(w * 0.42, 0)
              ..lineTo(w * 0.55, h * 0.5)
              ..lineTo(w * 0.45, h * 0.5)
              ..close(),
            ribbon);
        canvas.drawPath(
            Path()
              ..moveTo(w * 0.72, 0)
              ..lineTo(w * 0.58, 0)
              ..lineTo(w * 0.45, h * 0.5)
              ..lineTo(w * 0.55, h * 0.5)
              ..close(),
            ribbon);
        canvas.drawCircle(Offset(w / 2, h * 0.68), h * 0.3, fill);
        canvas.drawCircle(Offset(w / 2, h * 0.68), h * 0.16,
            Paint()..color = const Color(0xFFFFC93C));
      case 'seeds':
        for (var i = 0; i < 7; i++) {
          final t = i / 6;
          final x = w * (0.08 + 0.84 * t);
          final y = h * (0.15 + 0.6 * math.sin(math.pi * t));
          canvas.drawOval(
              Rect.fromCenter(
                  center: Offset(x, y), width: w * 0.11, height: h * 0.26),
              i == 3 ? (Paint()..color = const Color(0xFF1B7F4C)) : fill);
        }
      default:
        final star = Path();
        for (var i = 0; i < 10; i++) {
          final r = (i.isEven ? 0.5 : 0.22) * math.min(w, h);
          final a = i * math.pi / 5 - math.pi / 2;
          final p = Offset(w / 2 + r * math.cos(a), h / 2 + r * math.sin(a));
          i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(star..close(), fill);
    }
  }

  @override
  bool shouldRepaint(_CosmeticPainter old) =>
      old.key != key || old.color != color;
}
