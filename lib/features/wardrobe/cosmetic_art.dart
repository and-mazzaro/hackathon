import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../domain/models/cosmetic_item.dart';
import '../pet/otter_geometry.dart';

/// How one cosmetic is drawn.
///
/// Items are drawn straight onto the otter, in the reference-picture
/// coordinates of [OtterGeometry] (the canvas is already scaled), so each
/// item sits exactly where it belongs: a leaf on the leaf spot, glasses on
/// the eyes, a bandana round the neck. Thumbnails frame [bounds].
class CosmeticDrawing {
  const CosmeticDrawing({required this.bounds, required this.paint});

  /// The area the item covers, in otter coordinates.
  final Rect bounds;

  /// Draws the item in [color] (from the content file) on a canvas that is
  /// already in otter coordinates.
  final void Function(Canvas canvas, Color color) paint;
}

/// Drawings by the content file's "icon" key.
final Map<String, CosmeticDrawing> _drawings = {
  'leaf': CosmeticDrawing(
    bounds: OtterGeometry.leafSpot,
    paint: (canvas, color) {
      final r = OtterGeometry.leafSpot;
      canvas.drawOval(r.deflate(12), Paint()..color = color);
    },
  ),
  'bandana': CosmeticDrawing(
    bounds: OtterGeometry.bandanaArea,
    paint: (canvas, color) {
      final r = OtterGeometry.bandanaArea;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTRB(r.left, r.top, r.right, r.top + 80),
            const Radius.circular(40)),
        Paint()..color = color,
      );
    },
  ),
};

/// The "icon" keys that have a real drawing. Checked against the content
/// file by `test/content/cosmetic_content_test.dart`.
final Set<String> cosmeticArtKeys = _drawings.keys.toSet();

/// The drawing for [key]. Unknown keys draw a star in the slot's area, so
/// new content never breaks.
CosmeticDrawing cosmeticDrawing(String key, CosmeticSlot slot) =>
    _drawings[key] ?? _starIn(OtterGeometry.slotArea(slot));

/// Draws [item] on a canvas in otter coordinates (used by the pet painter).
void paintCosmetic(Canvas canvas, CosmeticItem item) =>
    cosmeticDrawing(item.icon, item.slot).paint(canvas, Color(item.color));

CosmeticDrawing _starIn(Rect area) {
  final side = math.min(area.width, area.height);
  final bounds = Rect.fromCenter(center: area.center, width: side, height: side);
  return CosmeticDrawing(
    bounds: bounds,
    paint: (canvas, color) {
      final star = Path();
      for (var i = 0; i < 10; i++) {
        final r = (i.isEven ? 0.5 : 0.22) * side;
        final a = i * math.pi / 5 - math.pi / 2;
        final p = bounds.center + Offset(r * math.cos(a), r * math.sin(a));
        i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(star..close(), Paint()..color = color);
    },
  );
}

/// One item on its own, scaled so its bounds fill [size] (keeping the
/// proportions). Decorative only: screen readers get the item name from
/// the text nearby.
class CosmeticArt extends StatelessWidget {
  const CosmeticArt({super.key, required this.item, required this.size});

  final CosmeticItem item;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(size: size, painter: _ItemPainter(item)),
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
      child: CosmeticArt(item: item, size: Size(size * 0.76, size * 0.76)),
    );
  }
}

class _ItemPainter extends CustomPainter {
  _ItemPainter(this.item);

  final CosmeticItem item;

  @override
  void paint(Canvas canvas, Size size) {
    final drawing = cosmeticDrawing(item.icon, item.slot);
    final bounds = drawing.bounds;
    final scale =
        math.min(size.width / bounds.width, size.height / bounds.height);
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..scale(scale)
      ..translate(-bounds.center.dx, -bounds.center.dy);
    drawing.paint(canvas, Color(item.color));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ItemPainter old) =>
      old.item.icon != item.icon || old.item.color != item.color;
}
