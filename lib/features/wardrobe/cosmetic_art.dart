import 'dart:math' as math;
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';

import '../../domain/models/cosmetic_item.dart';
import '../pet/otter_geometry.dart';
import 'cosmetic_labels.dart';

/// How one cosmetic is drawn.
///
/// Items are drawn straight onto the otter, in the reference-picture
/// coordinates of [OtterGeometry] (the canvas is already scaled), so each
/// item sits exactly where it belongs: a leaf on the leaf spot, glasses on
/// the eyes, a bandana round the neck. Thumbnails frame [bounds].
class CosmeticDrawing {
  const CosmeticDrawing({
    required this.bounds,
    required this.paint,
    this.shadow,
  });

  /// The area the item covers, in otter coordinates.
  final Rect bounds;

  /// Draws the item in [color] (from the content file) on a canvas that is
  /// already in otter coordinates.
  final void Function(Canvas canvas, Color color) paint;

  /// Where the item shades the fur under it (head items, like the leaf in
  /// the reference), already kept inside the head. Drawn only on the
  /// otter: thumbnails leave it out.
  final Path? shadow;

  /// Draws the item on the otter: its shadow on the fur, then the item.
  void paintOnOtter(Canvas canvas, Color color) {
    if (shadow case final shadow?) {
      canvas.drawPath(shadow, Paint()..color = _furShadowColor);
    }
    paint(canvas, color);
  }
}

/// Drawings by the content file's "icon" key. The two defaults ('leaf' and
/// 'bandana', in [OtterPalette.leaf] and [OtterPalette.bandana]) are traced
/// on the reference picture; the pet painter draws them when the head or
/// neck slot is empty.
final Map<String, CosmeticDrawing> _drawings = {
  // Head: the leaf-like items grow on the leaf spot, crowns and the cap
  // sit on top of the head and hide the hair tuft.
  'leaf': CosmeticDrawing(
    bounds: const Rect.fromLTRB(542, 216, 702, 323),
    paint: _paintLeaf,
    shadow: _furShadow(_leafShape),
  ),
  'maple_leaf': CosmeticDrawing(
    bounds: const Rect.fromLTRB(547, 198, 698, 342),
    paint: _paintMapleLeaf,
    shadow: _furShadow(_mapleShape),
  ),
  'flower': CosmeticDrawing(
    bounds: const Rect.fromLTRB(558, 200, 704, 324),
    paint: _paintFlower,
    shadow: _furShadow(_flowerShape),
  ),
  'acorn_cap': CosmeticDrawing(
    bounds: const Rect.fromLTRB(371, 163, 609, 328),
    paint: _paintAcornCap,
    shadow: _furShadow(_acornShape, const Offset(0, 10)),
  ),
  'seaweed_crown': CosmeticDrawing(
    bounds: const Rect.fromLTRB(364, 180, 618, 330),
    paint: _paintSeaweedCrown,
    shadow: _furShadow(_crownBand, const Offset(0, 9)),
  ),
  'twig_crown': CosmeticDrawing(
    bounds: const Rect.fromLTRB(329, 176, 651, 333),
    paint: _paintTwigCrown,
    shadow: _furShadow(_crownBand, const Offset(0, 9)),
  ),
  'legendary_leaf': CosmeticDrawing(
    bounds: const Rect.fromLTRB(538, 200, 718, 324),
    paint: _paintLegendaryLeaf,
    shadow: _furShadow(_leafShape),
  ),

  // Face: on the eyes (centres in OtterGeometry), arms to the head sides.
  'round_glasses': CosmeticDrawing(
    bounds: const Rect.fromLTRB(181, 451, 793, 629),
    paint: _paintRoundGlasses,
  ),
  'sunglasses': CosmeticDrawing(
    bounds: const Rect.fromLTRB(181, 467, 793, 615),
    paint: _paintSunglasses,
  ),
  'swim_goggles': CosmeticDrawing(
    bounds: const Rect.fromLTRB(180, 455, 792, 625),
    paint: _paintSwimGoggles,
  ),
  'hero_mask': CosmeticDrawing(
    bounds: const Rect.fromLTRB(206, 443, 846, 630),
    paint: _paintHeroMask,
  ),
  'monocle': CosmeticDrawing(
    bounds: const Rect.fromLTRB(557, 447, 735, 749),
    paint: _paintMonocle,
  ),

  // Neck: in place of the bandana.
  'bandana': CosmeticDrawing(
    bounds: const Rect.fromLTRB(302, 758, 795, 957),
    paint: _paintBandana,
  ),
  'bandana_dots': CosmeticDrawing(
    bounds: const Rect.fromLTRB(302, 758, 795, 957),
    paint: _paintDottedBandana,
  ),
  'scarf': CosmeticDrawing(
    bounds: const Rect.fromLTRB(302, 758, 693, 985),
    paint: _paintScarf,
  ),
  'bow_tie': CosmeticDrawing(
    bounds: const Rect.fromLTRB(324, 765, 654, 851),
    paint: _paintBowTie,
  ),
  'shell_necklace': CosmeticDrawing(
    bounds: const Rect.fromLTRB(316, 780, 664, 905),
    paint: _paintShellNecklace,
  ),
  'eco_medal': CosmeticDrawing(
    bounds: const Rect.fromLTRB(356, 776, 624, 959),
    paint: _paintEcoMedal,
  ),

  // Paws: held between the front paws, which are drawn over the bottom.
  'pebble': CosmeticDrawing(
    bounds: const Rect.fromLTRB(426, 1177, 558, 1275),
    paint: _paintPebble,
  ),
  'shell': CosmeticDrawing(
    bounds: const Rect.fromLTRB(400, 1193, 584, 1306),
    paint: _paintShell,
  ),
  'starfish': CosmeticDrawing(
    bounds: const Rect.fromLTRB(426, 1152, 562, 1290),
    paint: _paintStarfish,
  ),
  'fish_toy': CosmeticDrawing(
    bounds: const Rect.fromLTRB(408, 1158, 603, 1275),
    paint: _paintFishToy,
  ),
  'pearl': CosmeticDrawing(
    bounds: const Rect.fromLTRB(418, 1172, 566, 1286),
    paint: _paintPearl,
  ),
  'rainbow_pebble': CosmeticDrawing(
    bounds: const Rect.fromLTRB(410, 1162, 577, 1279),
    paint: _paintRainbowPebble,
  ),
};

/// The "icon" keys that have a real drawing. Checked against the content
/// file by `test/content/cosmetic_content_test.dart`.
final Set<String> cosmeticArtKeys = _drawings.keys.toSet();

/// The drawing for [key]. Unknown keys draw a star in the slot's area, so
/// new content never breaks.
CosmeticDrawing cosmeticDrawing(String key, CosmeticSlot slot) =>
    _drawings[key] ?? _starIn(OtterGeometry.slotArea(slot));

/// Draws [item] on a canvas in otter coordinates (used by the pet painter),
/// with its shadow on the fur.
void paintCosmetic(Canvas canvas, CosmeticItem item) => cosmeticDrawing(
        item.icon, item.slot)
    .paintOnOtter(canvas, Color(item.color));

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

// ---------------------------------------------------------------------------
// Shared helpers. The reference is flat cartoon art: plain fills, folds and
// veins in a darker shade of the same colour, no gradients.

/// The leaf's shadow on the head fur, sampled on the reference: the line
/// colour at half strength.
const _furShadowColor = Color(0x80563526);

const _gold = Color(0xFFE0A526);
const _goldLight = Color(0xFFF7D774);
const _white = Color(0xFFFFFFFF);

Paint _fill(Color color) => Paint()..color = color;

Paint _line(Color color, double width) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

/// A darker shade of [color] for folds and details (the reference's
/// bandana folds are about 11 % darker than the cloth).
Color _shade(Color color, [double amount = 0.11]) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness(math.max(0, hsl.lightness - amount)).toColor();
}

/// A lighter tint of [color] for highlights.
Color _tint(Color color, [double amount = 0.12]) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness(math.min(1, hsl.lightness + amount)).toColor();
}

/// [local] (drawn around the origin) turned by [angle] and moved to [at].
Path _placed(Path local, Offset at, double angle, [double scale = 1]) {
  final c = math.cos(angle) * scale;
  final s = math.sin(angle) * scale;
  return local.transform(Float64List.fromList(
      [c, s, 0, 0, -s, c, 0, 0, 0, 0, 1, 0, at.dx, at.dy, 0, 1]));
}

/// A fold or vein: [width] wide and rounded at [from], pointed at [to],
/// bowed sideways by [bend].
Path _taper(Offset from, Offset to, double width, {double bend = 0}) {
  final d = to - from;
  final n = Offset(-d.dy, d.dx) / d.distance;
  final mid = Offset.lerp(from, to, 0.5)! + n * bend;
  final a = from + n * (width / 2);
  final b = from - n * (width / 2);
  final ca = mid + n * (width / 2);
  final cb = mid - n * (width / 2);
  return Path()
    ..moveTo(a.dx, a.dy)
    ..quadraticBezierTo(ca.dx, ca.dy, to.dx, to.dy)
    ..quadraticBezierTo(cb.dx, cb.dy, b.dx, b.dy)
    ..arcToPoint(a, radius: Radius.circular(width / 2), clockwise: false)
    ..close();
}

/// A lens shape pointed at both ends (leaf veins, small leaves).
Path _spindle(Offset a, Offset b, double width, {double bend = 0}) {
  final d = b - a;
  final n = Offset(-d.dy, d.dx) / d.distance;
  final mid = Offset.lerp(a, b, 0.5)! + n * bend;
  final c1 = mid + n * width;
  final c2 = mid - n * width;
  return Path()
    ..moveTo(a.dx, a.dy)
    ..quadraticBezierTo(c1.dx, c1.dy, b.dx, b.dy)
    ..quadraticBezierTo(c2.dx, c2.dy, a.dx, a.dy)
    ..close();
}

/// A four-pointed twinkle (mythic items).
void _sparkle(Canvas canvas, Offset c, double r, Color color) {
  final p = Path()
    ..moveTo(c.dx, c.dy - r)
    ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
    ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
    ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
    ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
    ..close();
  canvas.drawPath(p, _fill(color));
}

/// A soft halo behind [shape] (mythic items).
void _glow(Canvas canvas, Path shape, Color color, double blur) =>
    canvas.drawPath(
      shape,
      Paint()
        ..color = color.withValues(alpha: 0.6)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    );

/// A point on the cubic curve p0 → p3.
Offset _cubicAt(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
  final u = 1 - t;
  return p0 * (u * u * u) +
      p1 * (3 * u * u * t) +
      p2 * (3 * u * t * t) +
      p3 * (t * t * t);
}

/// The top of the head, measured on the reference (a little beyond the
/// fur under the leaf). Shadows are kept inside it.
final _headTop = Path()
  ..addPolygon(const [
    Offset(296, 352),
    Offset(300, 326),
    Offset(304, 318),
    Offset(330, 300),
    Offset(366, 284),
    Offset(398, 272),
    Offset(440, 263),
    Offset(500, 260),
    Offset(560, 263),
    Offset(612, 270),
    Offset(652, 278),
    Offset(679, 290),
    Offset(670, 302),
    Offset(664, 308),
    Offset(667, 314),
    Offset(675, 320),
    Offset(689, 332),
    Offset(708, 352),
  ], true);

/// The shadow [shape] casts on the head fur. The default leaf's shadow in
/// the reference is the leaf a little bigger and lower.
Path _furShadow(Path shape, [Offset offset = const Offset(-3, 9)]) =>
    Path.combine(PathOperation.intersect, shape.shift(offset), _headTop);

// ---------------------------------------------------------------------------
// Head.

/// The green leaf of the reference, traced: its stalk end at the left,
/// in the fur, the tip up at the top right.
final _leafShape = Path()
  ..moveTo(542, 281)
  ..cubicTo(549, 238, 590, 218, 701, 216)
  ..cubicTo(706, 262, 676, 322, 618, 323)
  ..cubicTo(584, 324, 556, 302, 542, 281)
  ..close();

/// The leaf's midrib: thick and round at the stalk end, thinner and round
/// at the far end.
void _paintLeafVein(Canvas canvas, Color vein) => canvas
  ..drawPath(_taper(const Offset(581, 287), const Offset(661, 250), 12,
          bend: -1.5),
      _fill(vein))
  ..drawLine(const Offset(612, 273), const Offset(657, 252), _line(vein, 6));

void _paintLeaf(Canvas canvas, Color color) {
  canvas.drawPath(_leafShape, _fill(color));
  _paintLeafVein(canvas, _shade(color, 0.12));
}

void _paintLegendaryLeaf(Canvas canvas, Color color) {
  final vein = _shade(color, 0.16);
  _glow(canvas, _leafShape, _tint(color, 0.2), 12);
  canvas.drawPath(_leafShape, _fill(color));
  // Side veins from the midrib, then a light edge along the top.
  final veins = _line(vein, 3.5);
  for (final (from, to) in const [
    (Offset(592, 282), Offset(574, 254)),
    (Offset(612, 273), Offset(600, 236)),
    (Offset(632, 264), Offset(628, 226)),
    (Offset(652, 255), Offset(660, 222)),
    (Offset(596, 280), Offset(604, 312)),
    (Offset(618, 270), Offset(636, 306)),
    (Offset(640, 260), Offset(664, 292)),
  ]) {
    canvas.drawLine(from, to, veins);
  }
  _paintLeafVein(canvas, vein);
  canvas.drawPath(
      Path()
        ..moveTo(556, 262)
        ..cubicTo(570, 238, 610, 226, 680, 224),
      _line(_tint(color, 0.22), 5),
    );
  for (final (at, r, c) in const [
    (Offset(551, 226), 13.0, _white),
    (Offset(708, 270), 10.0, _goldLight),
    (Offset(690, 316), 8.0, _white),
    (Offset(593, 207), 7.0, _goldLight),
  ]) {
    _sparkle(canvas, at, r, c);
  }
}

/// A maple leaf around the origin, main lobe up, stalk down.
final _mapleLocal = () {
  const right = [
    Offset(0, -54),
    Offset(8, -33),
    Offset(19, -38),
    Offset(15, -8),
    Offset(35, -18),
    Offset(42, -28),
    Offset(47, -15),
    Offset(65, -13),
    Offset(53, 2),
    Offset(58, 12),
    Offset(23, 20),
    Offset(39, 34),
    Offset(45, 47),
    Offset(27, 43),
    Offset(16, 47),
    Offset(0, 32),
  ];
  return Path()
    ..addPolygon([
      ...right,
      for (final p in right.reversed.skip(1).take(right.length - 2))
        Offset(-p.dx, p.dy),
    ], true);
}();

const _mapleAt = Offset(626, 262);
const _mapleAngle = 0.7;
const _mapleScale = 1.18;

final _mapleShape = _placed(_mapleLocal, _mapleAt, _mapleAngle, _mapleScale);

void _paintMapleLeaf(Canvas canvas, Color color) {
  final dark = _shade(color, 0.14);
  final stalk = Path()
    ..moveTo(0, 28)
    ..quadraticBezierTo(4, 50, -2, 70);
  canvas
    ..drawPath(_placed(stalk, _mapleAt, _mapleAngle, _mapleScale),
        _line(dark, 7))
    // Fill and a same-colour round stroke: softly rounded points.
    ..drawPath(_mapleShape, _fill(color))
    ..drawPath(_mapleShape, _line(color, 5));
  final veins = Path();
  for (final tip in const [
    Offset(0, -40),
    Offset(52, -10),
    Offset(35, 37),
    Offset(-52, -10),
    Offset(-35, 37),
  ]) {
    veins
      ..moveTo(0, 26)
      ..lineTo(tip.dx, tip.dy);
  }
  canvas.drawPath(
      _placed(veins, _mapleAt, _mapleAngle, _mapleScale), _line(dark, 4));
}

const _flowerCentre = Offset(614, 262);

/// Five petals round [_flowerCentre].
final _flowerShape = () {
  final petals = Path();
  for (var i = 0; i < 5; i++) {
    petals.addPath(
      _placed(
        Path()
          ..addOval(Rect.fromCenter(
              center: const Offset(0, -34), width: 46, height: 60)),
        _flowerCentre,
        0.3 + i * 2 * math.pi / 5,
      ),
      Offset.zero,
    );
  }
  return petals;
}();

void _paintFlower(Canvas canvas, Color color) {
  final dark = _shade(color, 0.12);
  const green = OtterPalette.leaf;
  final leaf = _spindle(const Offset(626, 284), const Offset(704, 306), 30,
      bend: 8);
  canvas
    ..drawLine(_flowerCentre, const Offset(566, 316),
        _line(_shade(green, 0.1), 8))
    ..drawPath(leaf, _fill(green))
    ..drawLine(const Offset(640, 290), const Offset(696, 304),
        _line(_shade(green, 0.12), 3.5))
    ..drawPath(_flowerShape, _fill(color));
  // A crease down each petal, a yellow heart with darker seeds.
  for (var i = 0; i < 5; i++) {
    final a = 0.3 + i * 2 * math.pi / 5 - math.pi / 2;
    final dir = Offset(math.cos(a), math.sin(a));
    canvas.drawPath(
        _taper(_flowerCentre + dir * 22, _flowerCentre + dir * 54, 7),
        _fill(dark));
  }
  const heart = Color(0xFFF6C744);
  canvas
    ..drawCircle(_flowerCentre, 20, _fill(_shade(heart, 0.12)))
    ..drawCircle(_flowerCentre + const Offset(-1, -2), 17, _fill(heart));
  for (final seed in const [Offset(-6, -4), Offset(5, -6), Offset(1, 5)]) {
    canvas.drawCircle(_flowerCentre + seed, 3, _fill(const Color(0xFFC98A1E)));
  }
}

/// The acorn cap: a dome over the top of the head (hiding the tuft) and a
/// rim curving round the front.
final _acornShape = Path()
  ..moveTo(374, 300)
  ..cubicTo(378, 236, 430, 202, 490, 202)
  ..cubicTo(550, 202, 602, 236, 606, 300)
  ..cubicTo(608, 312, 604, 318, 594, 318)
  ..cubicTo(530, 328, 450, 328, 386, 318)
  ..cubicTo(376, 318, 372, 312, 374, 300)
  ..close();

void _paintAcornCap(Canvas canvas, Color color) {
  final dark = _shade(color, 0.1);
  final light = _tint(color, 0.1);
  canvas
    ..drawPath(
      Path()
        ..moveTo(486, 206)
        ..quadraticBezierTo(484, 182, 502, 170),
      _line(_shade(color, 0.14), 13),
    )
    ..drawPath(_acornShape, _fill(color))
    ..save()
    ..clipPath(_acornShape);
  // Rows of overlapping scales.
  final scales = _line(dark, 4);
  for (var row = 0; row < 5; row++) {
    final y = 218.0 + row * 21;
    final shift = row.isEven ? 0.0 : 14.0;
    for (var x = 364.0 + shift; x < 620; x += 28) {
      canvas.drawArc(Rect.fromCenter(center: Offset(x, y), width: 28, height: 24),
          0.15, math.pi - 0.3, false, scales);
    }
  }
  canvas
    ..drawPath(
      Path()
        ..moveTo(404, 252)
        ..quadraticBezierTo(426, 222, 466, 214),
      _line(light, 8),
    )
    ..restore();
  // The rim, a lighter band with a dark line on top.
  final rim = Path()
    ..moveTo(372, 296)
    ..cubicTo(440, 316, 540, 316, 608, 296)
    ..cubicTo(610, 310, 606, 318, 594, 320)
    ..cubicTo(530, 330, 450, 330, 386, 320)
    ..cubicTo(374, 318, 370, 310, 372, 296)
    ..close();
  canvas
    ..drawPath(rim, _fill(light))
    ..drawPath(
      Path()
        ..moveTo(374, 298)
        ..cubicTo(440, 318, 540, 318, 606, 298),
      _line(dark, 3.5),
    );
}

/// The base of both crowns: a band resting on the top of the head.
final _crownBand = Path()
  ..moveTo(368, 285)
  ..cubicTo(430, 303, 550, 303, 612, 285)
  ..lineTo(616, 308)
  ..cubicTo(552, 330, 428, 330, 364, 308)
  ..close();

const _bandStart = Offset(366, 297);
const _bandC1 = Offset(430, 317);
const _bandC2 = Offset(550, 317);
const _bandEnd = Offset(614, 297);

Offset _onBand(double t) => _cubicAt(_bandStart, _bandC1, _bandC2, _bandEnd, t);

/// A wavy seaweed blade rising from [base].
Path _frond(Offset base, double height, double width, double wave) {
  final left = <Offset>[];
  final right = <Offset>[];
  const steps = 16;
  for (var i = 0; i <= steps; i++) {
    final t = i / steps;
    final x = base.dx + wave * math.sin(t * 2 * math.pi) * (0.3 + t);
    final y = base.dy - height * t;
    final half = width / 2 * (1 - 0.7 * t);
    left.add(Offset(x - half, y));
    right.add(Offset(x + half, y));
  }
  return Path()
    ..addPolygon([
      ...left,
      Offset(base.dx, base.dy - height - width * 0.25),
      ...right.reversed,
    ], true);
}

void _paintSeaweedCrown(Canvas canvas, Color color) {
  final dark = _shade(color, 0.1);
  final light = _tint(color, 0.1);
  // Fronds: the back ones darker, the middle one tallest.
  for (final (i, t, height, wave) in const [
    (0, 0.06, 64.0, 7.0),
    (1, 0.2, 96.0, -9.0),
    (2, 0.35, 80.0, 9.0),
    (3, 0.5, 118.0, -10.0),
    (4, 0.65, 80.0, 9.0),
    (5, 0.8, 96.0, -9.0),
    (6, 0.94, 64.0, 7.0),
  ]) {
    final base = _onBand(t) + const Offset(0, -2);
    final frond = _frond(base, height, i.isEven ? 28 : 34, wave);
    canvas
      ..drawPath(frond, _fill(i.isEven ? dark : color))
      ..drawPath(
        _frond(base, height * 0.8, 4, wave),
        _fill(i.isEven ? _shade(color, 0.2) : dark),
      );
  }
  canvas.drawPath(_crownBand, _fill(color));
  // Braided band: short diagonal strokes, then two pearls and a starfish.
  final braid = _line(dark, 4);
  for (var t = 0.03; t < 0.99; t += 0.05) {
    final p = _onBand(t);
    canvas.drawLine(p + const Offset(-5, -8), p + const Offset(5, 8), braid);
  }
  canvas.drawPath(
    Path()
      ..moveTo(372, 289)
      ..cubicTo(432, 306, 548, 306, 608, 289),
    _line(light, 3.5),
  );
  const pearl = Color(0xFFF4EEF8);
  for (final t in const [0.27, 0.73]) {
    final p = _onBand(t) + const Offset(0, 1);
    canvas
      ..drawCircle(p, 12, _fill(_shade(pearl, 0.12)))
      ..drawCircle(p + const Offset(-1, -1), 10, _fill(pearl))
      ..drawCircle(p + const Offset(-3.5, -4), 3, _fill(_white));
  }
  const coral = Color(0xFFF07A4B);
  final star = _star(_onBand(0.5) + const Offset(0, -1), 15, 7, 0.1);
  canvas
    ..drawPath(star.shift(const Offset(0, 2)), _line(_shade(coral), 7))
    ..drawPath(star, _fill(coral))
    ..drawPath(star, _line(coral, 6))
    ..drawCircle(_onBand(0.5) + const Offset(0, -1), 3, _fill(_tint(coral)));
  // Bubbles rising.
  final bubble = _line(_white.withValues(alpha: 0.85), 3);
  for (final (at, r) in const [
    (Offset(400, 214), 7.0),
    (Offset(392, 194), 4.5),
    (Offset(584, 202), 6.0),
    (Offset(452, 186), 4.0),
  ]) {
    canvas.drawCircle(at, r, bubble);
  }
}

void _paintTwigCrown(Canvas canvas, Color color) {
  final dark = _shade(color, 0.14);
  final leafGold = _tint(color, 0.08);
  // Branches rising from the band, each with a side twig and gold leaves.
  for (final (t, lean, length, turn) in const [
    (0.08, -0.6, 56.0, 0.75),
    (0.29, -0.3, 80.0, -0.75),
    (0.5, 0.0, 100.0, -0.75),
    (0.71, 0.3, 80.0, 0.75),
    (0.92, 0.6, 56.0, -0.75),
  ]) {
    final base = _onBand(t);
    final dir = Offset(math.sin(lean), -math.cos(lean));
    final tip = base + dir * length;
    final side = Offset(math.sin(lean + turn), -math.cos(lean + turn));
    final fork = base + dir * (length * 0.5);
    canvas
      ..drawPath(_taper(base, tip, 15), _fill(dark))
      ..drawPath(_taper(fork, fork + side * 28, 8), _fill(dark))
      ..drawPath(_spindle(fork + side * 22, fork + side * 50, 15),
          _fill(leafGold))
      ..drawPath(_spindle(tip - dir * 6, tip + dir * 36, 22),
          _fill(leafGold))
      ..drawLine(tip, tip + dir * 26, _line(dark, 2.5))
      ..drawCircle(tip - dir * 14 - side * 10, 5.5, _fill(_goldLight));
  }
  // Two twigs twisted round each other make the band.
  for (final (phase, paint) in [
    (0.0, _line(dark, 13)),
    (math.pi, _line(color, 13)),
  ]) {
    final twig = Path();
    for (var i = 0; i <= 40; i++) {
      final t = i / 40;
      final p = _onBand(t) + Offset(0, 6 * math.sin(t * 6 * math.pi + phase));
      i == 0 ? twig.moveTo(p.dx, p.dy) : twig.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(twig, paint);
  }
  // Gold glints on the front twig, then an emerald in a gold setting.
  final glint = _line(_goldLight, 3);
  for (var t = 0.06; t < 0.95; t += 1 / 6) {
    final a = _onBand(t) + Offset(-6, 3 * math.sin(t * 6 * math.pi + math.pi));
    canvas.drawLine(a, a + const Offset(10, -2), glint);
  }
  final gem = _onBand(0.5) + const Offset(0, 1);
  canvas
    ..drawCircle(gem, 20, _fill(dark))
    ..drawCircle(gem, 16.5, _fill(_goldLight))
    ..drawOval(Rect.fromCenter(center: gem, width: 22, height: 26),
        _fill(const Color(0xFF2FA36B)))
    ..drawOval(
        Rect.fromCenter(
            center: gem + const Offset(-3, -5), width: 7, height: 10),
        _fill(_white.withValues(alpha: 0.7)));
}

// ---------------------------------------------------------------------------
// Face.

const _eyeL = OtterGeometry.leftEye;
const _eyeR = OtterGeometry.rightEye;

void _paintRoundGlasses(Canvas canvas, Color color) {
  const r = 84.0;
  final frame = _line(color, 9);
  for (final eye in const [_eyeL, _eyeR]) {
    canvas
      ..drawCircle(eye, r, _fill(_white.withValues(alpha: 0.12)))
      ..drawArc(Rect.fromCircle(center: eye, radius: r - 16), 3.55, 0.85,
          false, _line(_white.withValues(alpha: 0.6), 7))
      ..drawCircle(eye, r, frame);
  }
  canvas
    ..drawPath(
      Path()
        ..moveTo(404, 505)
        ..quadraticBezierTo(487, 470, 570, 505),
      frame,
    )
    ..drawLine(const Offset(246, 520), const Offset(186, 506), frame)
    ..drawLine(const Offset(728, 520), const Offset(788, 506), frame);
}

/// A sunglasses lens round [eye]: flat top, round bottom.
Path _sunLens(Offset eye) => Path()
  ..moveTo(eye.dx - 84, eye.dy - 64)
  ..lineTo(eye.dx + 84, eye.dy - 64)
  ..cubicTo(eye.dx + 90, eye.dy + 18, eye.dx + 56, eye.dy + 70, eye.dx,
      eye.dy + 70)
  ..cubicTo(eye.dx - 56, eye.dy + 70, eye.dx - 90, eye.dy + 18, eye.dx - 84,
      eye.dy - 64)
  ..close();

void _paintSunglasses(Canvas canvas, Color color) {
  final frame = _line(color, 9);
  final glare = _fill(_white.withValues(alpha: 0.32));
  canvas
    ..drawLine(const Offset(246, 484), const Offset(186, 500), frame)
    ..drawLine(const Offset(728, 484), const Offset(788, 500), frame);
  for (final eye in const [_eyeL, _eyeR]) {
    final lens = _sunLens(eye);
    canvas
      ..drawPath(lens, _fill(_tint(color, 0.06).withValues(alpha: 0.93)))
      ..save()
      ..clipPath(lens)
      ..drawPath(
          Path()
            ..addPolygon([
              eye + const Offset(-70, 10),
              eye + const Offset(-30, -60),
              eye + const Offset(-6, -60),
              eye + const Offset(-46, 10),
            ], true),
          glare)
      ..drawPath(
          Path()
            ..addPolygon([
              eye + const Offset(-36, 30),
              eye + const Offset(10, -50),
              eye + const Offset(20, -50),
              eye + const Offset(-26, 30),
            ], true),
          glare)
      ..restore()
      ..drawPath(lens, frame)
      ..drawLine(eye + const Offset(-88, -66), eye + const Offset(88, -66),
          _line(color, 14));
  }
  canvas.drawPath(
    Path()
      ..moveTo(412, 482)
      ..quadraticBezierTo(487, 466, 562, 482),
    _line(color, 11),
  );
}

void _paintSwimGoggles(Canvas canvas, Color color) {
  final strap = _shade(color, 0.2);
  final light = _tint(color, 0.16);
  Rect cupOf(Offset eye) => Rect.fromCenter(center: eye, width: 164, height: 152);
  // The strap runs behind the cups (the lenses are see-through, so it is
  // cut out there).
  canvas
    ..save()
    ..clipPath(Path.combine(
      PathOperation.difference,
      Path()..addRect(const Rect.fromLTRB(170, 500, 800, 580)),
      Path()
        ..addOval(cupOf(_eyeL))
        ..addOval(cupOf(_eyeR)),
    ))
    ..drawRRect(
        RRect.fromLTRBR(180, 526, 792, 554, const Radius.circular(6)),
        _fill(strap))
    ..drawLine(const Offset(186, 540), const Offset(786, 540),
        _line(_tint(strap, 0.1), 3))
    // Buckles on the strap, the nose piece between the cups.
    ..drawRRect(RRect.fromLTRBR(212, 518, 236, 562, const Radius.circular(6)),
        _fill(light))
    ..drawRRect(RRect.fromLTRBR(738, 518, 762, 562, const Radius.circular(6)),
        _fill(light))
    ..drawRRect(RRect.fromLTRBR(400, 528, 574, 552, const Radius.circular(12)),
        _fill(color))
    ..restore();
  for (final eye in const [_eyeL, _eyeR]) {
    final cup = cupOf(eye);
    canvas
      ..drawOval(cup, _fill(_tint(color, 0.3).withValues(alpha: 0.35)))
      ..drawOval(cup, _line(color, 18))
      ..drawArc(cup.deflate(9), 0, 2 * math.pi, false, _line(_shade(color), 3))
      ..drawArc(cup.inflate(2), 3.4, 1.3, false, _line(light, 5))
      ..drawArc(cup.deflate(24), 3.6, 0.8, false,
          _line(_white.withValues(alpha: 0.7), 7))
      ..drawCircle(eye + const Offset(36, -34), 5,
          _fill(_white.withValues(alpha: 0.7)));
  }
}

/// The hero mask: a band over both eyes, pointed at the sides, with holes
/// so the eyes stay visible.
final _heroMask = Path.combine(
  PathOperation.difference,
  Path()
    ..moveTo(206, 488)
    ..cubicTo(250, 450, 300, 440, 340, 444)
    ..cubicTo(400, 450, 440, 470, 487, 474)
    ..cubicTo(534, 470, 574, 450, 634, 444)
    ..cubicTo(674, 440, 724, 450, 768, 488)
    ..cubicTo(750, 560, 710, 626, 646, 630)
    ..cubicTo(600, 632, 560, 606, 530, 580)
    ..cubicTo(510, 564, 464, 564, 444, 580)
    ..cubicTo(414, 606, 374, 632, 328, 630)
    ..cubicTo(264, 626, 224, 560, 206, 488)
    ..close(),
  Path()
    ..addOval(Rect.fromCenter(center: _eyeL, width: 148, height: 146))
    ..addOval(Rect.fromCenter(center: _eyeR, width: 148, height: 146)),
);

void _paintHeroMask(Canvas canvas, Color color) {
  final dark = _shade(color, 0.1);
  // Ribbon tails knotted on the otter's left side, behind the mask.
  canvas
    ..drawPath(_spindle(const Offset(770, 494), const Offset(846, 528), 26,
            bend: -8),
        _fill(dark))
    ..drawPath(_spindle(const Offset(768, 500), const Offset(824, 578), 26,
            bend: 8),
        _fill(color))
    ..drawLine(const Offset(784, 512), const Offset(812, 556),
        _line(dark, 3));
  // The mask in a darker shade, then the colour a little higher: a thicker
  // look along the bottom edge and inside the top of the eye holes.
  canvas
    ..drawPath(_heroMask, _fill(dark))
    ..save()
    ..clipPath(_heroMask)
    ..drawPath(_heroMask.shift(const Offset(0, -7)), _fill(color))
    ..restore()
    ..drawPath(
      Path()
        ..moveTo(232, 476)
        ..cubicTo(270, 452, 310, 448, 340, 450),
      _line(_tint(color, 0.14), 5),
    )
    ..drawPath(
      Path()
        ..moveTo(634, 450)
        ..cubicTo(670, 448, 710, 456, 742, 476),
      _line(_tint(color, 0.14), 5),
    )
    ..drawCircle(const Offset(770, 494), 14, _fill(dark));
}

void _paintMonocle(Canvas canvas, Color color) {
  const r = 80.0;
  final dark = _shade(color, 0.14);
  const anchor = Offset(692, 606);
  // The chain hangs from the rim down the cheek; links alternate shades.
  for (var i = 0; i <= 13; i++) {
    final p = _cubicAt(anchor, const Offset(722, 640),
        const Offset(724, 700), const Offset(702, 738), i / 13);
    canvas.drawCircle(p, 4.6, _line(i.isEven ? color : dark, 3));
  }
  canvas
    ..drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: const Offset(702, 744), width: 26, height: 10),
            const Radius.circular(5)),
        _fill(dark))
    ..drawCircle(_eyeR, r, _fill(_white.withValues(alpha: 0.14)))
    ..drawArc(Rect.fromCircle(center: _eyeR, radius: r - 16), 3.6, 0.9,
        false, _line(_white.withValues(alpha: 0.7), 6))
    ..drawCircle(_eyeR + const Offset(-24, -52), 4,
        _fill(_white.withValues(alpha: 0.7)))
    ..drawCircle(_eyeR, r + 2, _line(dark, 14))
    ..drawCircle(_eyeR, r, _line(color, 10))
    ..drawArc(Rect.fromCircle(center: _eyeR, radius: r - 2), 2.7, 2.0, false,
        _line(_goldLight, 3))
    // A knob on top and a ruby where the chain hangs.
    ..drawCircle(_eyeR + const Offset(0, -r - 6), 7, _fill(color))
    ..drawCircle(_eyeR + const Offset(0, -r - 6), 3, _fill(_goldLight))
    ..drawCircle(anchor, 8, _fill(dark))
    ..drawCircle(anchor, 5.5, _fill(const Color(0xFFD8433B)));
}

// ---------------------------------------------------------------------------
// Neck.

// The reference bandana, traced: the band under the chin (its back end
// shows round the left of the neck), a round knot on the otter's left side
// and two leaf-shaped tails.

final _bandBack = Path()
  ..moveTo(302, 758)
  ..cubicTo(325, 767, 345, 775, 364, 781)
  ..lineTo(374, 850)
  ..cubicTo(340, 830, 312, 805, 302, 758)
  ..close();

final _bandFront = Path()
  ..moveTo(344, 777)
  ..cubicTo(340, 800, 345, 825, 362, 842)
  ..cubicTo(400, 872, 450, 888, 490, 885)
  ..cubicTo(540, 881, 585, 850, 618, 818)
  ..lineTo(622, 786)
  ..cubicTo(570, 800, 520, 808, 480, 806)
  ..cubicTo(430, 804, 385, 792, 344, 777)
  ..close();

final _bandTailRight = Path()
  ..moveTo(650, 795)
  ..cubicTo(668, 770, 712, 770, 742, 795)
  ..cubicTo(768, 818, 785, 850, 795, 878)
  ..cubicTo(770, 883, 715, 882, 688, 870)
  ..cubicTo(672, 860, 658, 840, 648, 822)
  ..close();

final _bandTailDown = Path()
  ..moveTo(612, 820)
  ..cubicTo(595, 845, 595, 890, 625, 925)
  ..cubicTo(645, 945, 665, 952, 684, 957)
  ..cubicTo(694, 925, 692, 880, 678, 850)
  ..cubicTo(668, 832, 655, 822, 640, 818)
  ..close();

/// Where the lower tail shades the right one.
final _bandTailShadow = Path.combine(PathOperation.intersect,
    _bandTailDown.shift(const Offset(8, -3)), _bandTailRight);

const _bandKnot = Rect.fromLTRB(611, 780, 655, 826);

/// The cloth that shows in front (dots are printed on it).
final _bandCloth = [
  _bandFront,
  _bandTailRight,
  _bandTailDown,
  Path()..addOval(_bandKnot),
].reduce((a, b) => Path.combine(PathOperation.union, a, b));

void _paintBandana(Canvas canvas, Color color) {
  final dark = _shade(color);
  canvas
    ..drawPath(_bandBack, _fill(dark))
    ..drawPath(_bandFront, _fill(color))
    ..drawPath(
        _taper(const Offset(612, 806), const Offset(457, 860), 13, bend: -6),
        _fill(dark))
    ..drawPath(_bandTailRight, _fill(color))
    ..drawPath(
        _taper(const Offset(652, 806), const Offset(745, 842), 11, bend: 10),
        _fill(dark))
    ..drawPath(_bandTailShadow, _fill(dark))
    ..drawPath(_bandTailDown, _fill(color))
    ..drawPath(
        _taper(const Offset(628, 830), const Offset(666, 921), 11, bend: 3),
        _fill(dark))
    ..drawOval(_bandKnot.inflate(5).shift(const Offset(-3, 6)), _fill(dark))
    ..drawOval(_bandKnot, _fill(color));
}

void _paintDottedBandana(Canvas canvas, Color color) {
  _paintBandana(canvas, color);
  final dot = _fill(const Color(0xFFFFF8E8));
  canvas
    ..save()
    ..clipPath(_bandCloth);
  for (var row = 0; row < 7; row++) {
    for (var col = 0; col < 15; col++) {
      final x = 310.0 + col * 34 + (row.isOdd ? 17 : 0);
      final y = 778.0 + row * 30;
      canvas.drawCircle(Offset(x, y), 7.5, dot);
    }
  }
  canvas.restore();
}

/// The wool scarf's band round the neck.
final _scarfBand = Path()
  ..moveTo(306, 760)
  ..cubicTo(380, 800, 600, 812, 654, 776)
  ..cubicTo(668, 796, 670, 818, 662, 834)
  ..cubicTo(600, 884, 420, 892, 346, 850)
  ..cubicTo(316, 832, 300, 800, 306, 760)
  ..close();

/// The end hanging down the chest, on the otter's left side.
final _scarfEnd = Path()
  ..moveTo(594, 820)
  ..lineTo(660, 812)
  ..lineTo(692, 950)
  ..lineTo(610, 960)
  ..close();

void _paintScarf(Canvas canvas, Color color) {
  final dark = _shade(color, 0.1);
  final stripe = _tint(color, 0.22);
  final rib = _line(dark, 3.5);
  canvas
    ..drawPath(_bandBack, _fill(dark))
    ..drawPath(_scarfEnd, _fill(color))
    ..save()
    ..clipPath(_scarfEnd);
  for (final y in const [868.0, 904.0]) {
    canvas.drawPath(
        Path()
          ..addPolygon([
            Offset(580, y),
            Offset(720, y - 6),
            Offset(720, y + 10),
            Offset(580, y + 16),
          ], true),
        _fill(stripe));
  }
  for (var x = 604.0; x < 700; x += 18) {
    canvas.drawLine(Offset(x - 4, 812), Offset(x + 12, 962), rib);
  }
  canvas.restore();
  // Fringe.
  for (var i = 0; i < 6; i++) {
    final a = Offset.lerp(const Offset(616, 960), const Offset(688, 952), i / 5)!;
    canvas.drawLine(a, a + const Offset(2, 22), _line(dark, 6));
  }
  canvas
    ..drawPath(_scarfBand, _fill(color))
    ..save()
    ..clipPath(_scarfBand);
  // Knit ribs across the band, following its curve.
  for (var i = 0; i <= 24; i++) {
    final t = i / 24;
    final top = _cubicAt(const Offset(306, 760), const Offset(380, 800),
        const Offset(600, 812), const Offset(654, 776), t);
    canvas.drawLine(top + const Offset(0, -4), top + const Offset(-6, 96), rib);
  }
  canvas
    ..restore()
    // The loop where the end comes out.
    ..drawOval(Rect.fromCenter(
            center: const Offset(626, 826), width: 64, height: 50),
        _fill(dark))
    ..drawOval(Rect.fromCenter(
            center: const Offset(624, 822), width: 58, height: 44),
        _fill(color));
  for (final x in const [610.0, 624.0, 638.0]) {
    canvas.drawLine(Offset(x, 806), Offset(x + 2, 838), rib);
  }
}

void _paintBowTie(Canvas canvas, Color color) {
  final dark = _shade(color, 0.12);
  final light = _tint(color, 0.12);
  const k = Offset(490, 808);
  // A thin band round the neck, just under the chin, holds the bow.
  canvas.drawPath(
    Path()
      ..moveTo(330, 782)
      ..quadraticBezierTo(490, 834, 648, 786),
    _line(dark, 11),
  );
  for (final side in const [-1.0, 1.0]) {
    Offset p(double x, double y) => Offset(k.dx + side * x, k.dy + y);
    final wing = Path()
      ..moveTo(p(18, -14).dx, p(18, -14).dy)
      ..cubicTo(p(50, -38).dx, p(50, -38).dy, p(80, -50).dx, p(80, -50).dy,
          p(92, -34).dx, p(92, -34).dy)
      ..cubicTo(p(102, -16).dx, p(102, -16).dy, p(102, 22).dx,
          p(102, 22).dy, p(90, 38).dx, p(90, 38).dy)
      ..cubicTo(p(78, 50).dx, p(78, 50).dy, p(48, 34).dx, p(48, 34).dy,
          p(18, 14).dx, p(18, 14).dy)
      ..close();
    canvas
      ..drawPath(wing, _fill(color))
      ..drawPath(_taper(p(20, -6), p(78, -30), 9), _fill(dark))
      ..drawPath(_taper(p(20, 8), p(76, 28), 9), _fill(dark))
      ..drawPath(
          Path()
            ..moveTo(p(56, -36).dx, p(56, -36).dy)
            ..quadraticBezierTo(
                p(80, -46).dx, p(80, -46).dy, p(90, -30).dx, p(90, -30).dy),
          _line(light, 5));
  }
  final knot = RRect.fromRectAndRadius(
      Rect.fromCenter(center: k, width: 40, height: 38),
      const Radius.circular(11));
  canvas
    ..drawRRect(knot.shift(const Offset(0, 3)), _fill(dark))
    ..drawRRect(knot, _fill(color))
    ..drawLine(k + const Offset(-7, -11), k + const Offset(-5, 11),
        _line(dark, 3))
    ..drawLine(k + const Offset(7, -11), k + const Offset(5, 11),
        _line(dark, 3));
}

/// A scallop shell with its hinge at [hinge], opening towards [angle]
/// (0 = straight down), [size] long.
void _scallop(Canvas canvas, Offset hinge, double size, double angle,
    Color color, {Color? outline}) {
  final local = Path()..moveTo(0, 0);
  const ribs = 6;
  for (var i = 0; i <= ribs; i++) {
    final a = math.pi / 2 + (i / ribs - 0.5) * 1.6;
    final p = Offset(math.cos(a), math.sin(a)) * size;
    if (i == 0) {
      local.lineTo(p.dx, p.dy);
    } else {
      local.arcToPoint(p,
          radius: Radius.circular(size * 0.16), clockwise: false);
    }
  }
  local.close();
  final shell = _placed(local, hinge, angle);
  final ears = _placed(
      Path()
        ..addRRect(RRect.fromLTRBR(-size * 0.3, -size * 0.12, size * 0.3,
            size * 0.14, Radius.circular(size * 0.06))),
      hinge,
      angle);
  final dark = _shade(color, 0.14);
  canvas
    ..drawPath(ears, _fill(dark))
    ..drawPath(shell, _fill(color));
  if (outline != null) canvas.drawPath(shell, _line(outline, 2.5));
  final rib = Path();
  for (var i = 1; i < ribs; i++) {
    final a = math.pi / 2 + (i / ribs - 0.5) * 1.6;
    final d = Offset(math.cos(a), math.sin(a));
    rib
      ..moveTo(d.dx * size * 0.22, d.dy * size * 0.22)
      ..lineTo(d.dx * size * 0.86, d.dy * size * 0.86);
  }
  canvas.drawPath(
      _placed(rib, hinge, angle), _line(dark, math.max(2, size * 0.07)));
}

void _paintShellNecklace(Canvas canvas, Color color) {
  const p0 = Offset(318, 782);
  const p1 = Offset(370, 872);
  const p2 = Offset(610, 872);
  const p3 = Offset(662, 782);
  Offset at(double t) => _cubicAt(p0, p1, p2, p3, t);
  final outline = _shade(color, 0.3);
  canvas.drawPath(
    Path()
      ..moveTo(p0.dx, p0.dy)
      ..cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, p3.dx, p3.dy),
    _line(OtterPalette.line, 4),
  );
  // Beads between the shells: teal and pearl.
  for (final (t, r, c) in const [
    (0.08, 8.0, Color(0xFFF4EEF8)),
    (0.24, 9.5, Color(0xFF4FB6B2)),
    (0.4, 9.5, Color(0xFF4FB6B2)),
    (0.6, 9.5, Color(0xFF4FB6B2)),
    (0.76, 9.5, Color(0xFF4FB6B2)),
    (0.92, 8.0, Color(0xFFF4EEF8)),
  ]) {
    canvas
      ..drawCircle(at(t), r, _fill(_shade(c, 0.16)))
      ..drawCircle(at(t) + const Offset(-1, -1), r - 1.8, _fill(c))
      ..drawCircle(at(t) + const Offset(-3, -3), r * 0.3, _fill(_white));
  }
  // Little cone shells, two scallops and a big one in the middle.
  for (final t in const [0.16, 0.84]) {
    final p = at(t);
    final cone = _spindle(p, p + const Offset(0, 44), 22);
    canvas
      ..drawPath(cone, _fill(_tint(color, 0.06)))
      ..drawPath(cone, _line(outline, 2.5))
      ..drawLine(p + const Offset(-8, 15), p + const Offset(8, 11),
          _line(outline, 2.5))
      ..drawLine(p + const Offset(-8, 27), p + const Offset(8, 23),
          _line(outline, 2.5));
  }
  _scallop(canvas, at(0.32), 38, 0.2, color, outline: outline);
  _scallop(canvas, at(0.68), 38, -0.2, color, outline: outline);
  _scallop(canvas, at(0.5) + const Offset(0, -2), 56, 0, color,
      outline: outline);
}

void _paintEcoMedal(Canvas canvas, Color color) {
  const ribbon = Color(0xFF3F9A55);
  const m = Offset(490, 912);
  final dark = _shade(color, 0.14);
  // The ribbon: two straps from behind the neck down to the medal.
  for (final (from, to) in const [
    (Offset(366, 790), Offset(482, 872)),
    (Offset(614, 790), Offset(498, 872)),
  ]) {
    canvas
      ..drawLine(from, to, _line(ribbon, 34)..strokeCap = StrokeCap.butt)
      ..drawLine(from, to, _line(const Color(0xFFF4F1E4), 9)
        ..strokeCap = StrokeCap.butt)
      ..drawLine(from, Offset.lerp(from, to, 0.18)!,
          _line(_shade(ribbon, 0.1), 34)..strokeCap = StrokeCap.butt);
  }
  canvas
    ..drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: const Offset(490, 868), width: 54, height: 26),
            const Radius.circular(5)),
        _fill(_shade(ribbon, 0.06)))
    ..drawCircle(const Offset(490, 872), 9, _line(dark, 5))
    // The medal: dark edge, gold face, a light inner ring, a green leaf.
    ..drawCircle(m, 47, _fill(dark))
    ..drawCircle(m, 42, _fill(color))
    ..drawCircle(m, 33, _line(_goldLight, 3.5))
    ..drawPath(
        _spindle(const Offset(472, 932), const Offset(510, 890), 28, bend: 3),
        _fill(const Color(0xFF4E9A3A)))
    ..drawLine(const Offset(476, 927), const Offset(503, 897),
        _line(const Color(0xFF2F6E2A), 3))
    ..drawArc(Rect.fromCircle(center: m, radius: 42), 3.5, 1.0, false,
        _line(_goldLight, 4));
  _sparkle(canvas, m + const Offset(28, -26), 9, _white);
}

// ---------------------------------------------------------------------------
// Paws. The bottom of each item is hidden behind the front paws.

final _pebbleShape = _placed(
    Path()
      ..addOval(Rect.fromCenter(center: Offset.zero, width: 132, height: 96)),
    const Offset(492, 1226),
    -0.12);

void _paintPebble(Canvas canvas, Color color) {
  final dark = _shade(color, 0.12);
  canvas
    ..drawPath(_pebbleShape, _fill(dark))
    ..save()
    ..clipPath(_pebbleShape)
    ..drawPath(_pebbleShape.shift(const Offset(-5, -10)), _fill(color))
    ..restore()
    ..drawPath(
        _placed(
            Path()
              ..addOval(Rect.fromCenter(
                  center: Offset.zero, width: 34, height: 15)),
            const Offset(458, 1204),
            -0.3),
        _fill(_tint(color, 0.16)));
  for (final (at, r) in const [
    (Offset(510, 1214), 4.0),
    (Offset(530, 1236), 3.0),
    (Offset(476, 1246), 3.5),
    (Offset(540, 1210), 2.5),
  ]) {
    canvas.drawCircle(at, r, _fill(dark));
  }
}

void _paintShell(Canvas canvas, Color color) {
  final dark = _shade(color, 0.14);
  final light = _tint(color, 0.08);
  const hinge = Offset(492, 1300);
  const radius = 98.0;
  const ribs = 7;
  final shell = Path()..moveTo(hinge.dx, hinge.dy);
  for (var i = 0; i <= ribs; i++) {
    final a = -math.pi / 2 + (i / ribs - 0.5) * 2.3;
    final p = hinge + Offset(math.cos(a), math.sin(a)) * radius;
    if (i == 0) {
      shell.lineTo(p.dx, p.dy);
    } else {
      shell.arcToPoint(p, radius: const Radius.circular(18));
    }
  }
  shell.close();
  canvas
    ..drawRRect(
        RRect.fromLTRBR(452, 1286, 532, 1306, const Radius.circular(6)),
        _fill(dark))
    ..drawPath(shell, _fill(color))
    ..save()
    ..clipPath(shell);
  // Lighter and darker ribs fanning out from the hinge.
  for (var i = 0; i < ribs; i++) {
    final a = -math.pi / 2 + ((i + 0.5) / ribs - 0.5) * 2.3;
    final d = Offset(math.cos(a), math.sin(a));
    canvas.drawPath(
        _spindle(hinge + d * 10, hinge + d * (radius + 20), 12),
        _fill(light));
    if (i > 0) {
      final b = -math.pi / 2 + (i / ribs - 0.5) * 2.3;
      final e = Offset(math.cos(b), math.sin(b));
      canvas.drawLine(hinge + e * 16, hinge + e * (radius + 4), _line(dark, 3));
    }
  }
  canvas.restore();
}

/// A five-armed star round [c]; drawn with a round stroke of the same
/// colour its points come out soft.
Path _star(Offset c, double outer, double inner, double turn) {
  final star = Path();
  for (var i = 0; i < 10; i++) {
    final r = i.isEven ? outer : inner;
    final a = -math.pi / 2 + turn + i * math.pi / 5;
    final p = c + Offset(math.cos(a), math.sin(a)) * r;
    i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
  }
  return star..close();
}

void _paintStarfish(Canvas canvas, Color color) {
  const c = Offset(492, 1222);
  const turn = 0.12;
  final star = _star(c, 60, 27, turn);
  final dark = _shade(color, 0.12);
  final light = _tint(color, 0.14);
  canvas
    ..drawPath(star.shift(const Offset(0, 4)), _line(dark, 22))
    ..drawPath(star, _fill(color))
    ..drawPath(star, _line(color, 20));
  // Dots along each arm and a darker middle.
  for (var i = 0; i < 5; i++) {
    final a = -math.pi / 2 + turn + i * 2 * math.pi / 5;
    final d = Offset(math.cos(a), math.sin(a));
    canvas
      ..drawCircle(c + d * 30, 5.5, _fill(light))
      ..drawCircle(c + d * 48, 4.5, _fill(light))
      ..drawCircle(c + d * 62, 3.5, _fill(light));
  }
  canvas
    ..drawCircle(c, 12, _fill(dark))
    ..drawCircle(c + const Offset(-1, -1), 6, _fill(light));
}

void _paintFishToy(Canvas canvas, Color color) {
  final dark = _shade(color, 0.12);
  final light = _tint(color, 0.18);
  final stitch = _line(_white.withValues(alpha: 0.9), 3);
  final body = Path()
    ..addOval(Rect.fromCenter(
        center: const Offset(478, 1222), width: 140, height: 90));
  final tail = Path()
    ..moveTo(534, 1222)
    ..lineTo(598, 1176)
    ..quadraticBezierTo(584, 1222, 598, 1270)
    ..close();
  final fin = Path()
    ..moveTo(446, 1184)
    ..quadraticBezierTo(470, 1150, 510, 1170)
    ..lineTo(504, 1186)
    ..close();
  canvas
    ..drawPath(tail, _fill(dark))
    ..drawPath(tail, _line(dark, 10))
    ..drawPath(fin, _fill(dark))
    ..drawPath(fin, _line(dark, 8))
    ..drawPath(body, _fill(color))
    ..save()
    ..clipPath(body)
    // Lighter belly and two darker stripes.
    ..drawOval(Rect.fromCenter(
            center: const Offset(478, 1262), width: 150, height: 60),
        _fill(light))
    ..drawLine(const Offset(500, 1170), const Offset(492, 1280),
        _line(dark, 10))
    ..drawLine(const Offset(526, 1170), const Offset(518, 1280),
        _line(dark, 8))
    ..restore();
  // Gill seam with stitches, a sewn-on patch, a button eye and a smile.
  for (var i = 0; i < 5; i++) {
    final t = i / 4;
    final p = _cubicAt(const Offset(452, 1186), const Offset(466, 1204),
        const Offset(466, 1240), const Offset(452, 1258), t);
    canvas.drawLine(p + const Offset(-3, -3), p + const Offset(3, 3), stitch);
  }
  final patch = _placed(
      Path()
        ..addRRect(RRect.fromLTRBR(-13, -13, 13, 13, const Radius.circular(4))),
      const Offset(520, 1232),
      0.25);
  canvas
    ..drawPath(patch, _fill(const Color(0xFFF0B429)))
    ..drawPath(patch, _line(_shade(const Color(0xFFF0B429), 0.2), 2))
    ..drawCircle(const Offset(432, 1210), 13, _fill(_white))
    ..drawCircle(const Offset(430, 1211), 7.5, _fill(OtterPalette.eye))
    ..drawCircle(const Offset(427, 1207), 2.5, _fill(_white))
    ..drawPath(
      Path()
        ..moveTo(412, 1232)
        ..quadraticBezierTo(420, 1240, 428, 1234),
      _line(OtterPalette.line, 3),
    );
}

void _paintPearl(Canvas canvas, Color color) {
  const hinge = Offset(492, 1262);
  final goldDark = _shade(_gold, 0.14);
  // The back half of a golden clam, open behind the pearl.
  final back = Path()
    ..moveTo(hinge.dx - 72, hinge.dy - 4)
    ..arcToPoint(Offset(hinge.dx + 72, hinge.dy - 4),
        radius: const Radius.circular(74))
    ..close();
  canvas
    ..drawPath(back, _fill(_gold))
    ..save()
    ..clipPath(back);
  for (var i = 1; i < 7; i++) {
    final a = math.pi + i * math.pi / 7;
    canvas.drawLine(hinge, hinge + Offset(math.cos(a), math.sin(a)) * 80,
        _line(goldDark, 4));
  }
  canvas.restore();
  // The pearl, with a soft glow, a shaded side and a shine.
  const p = Offset(492, 1222);
  canvas
    ..drawCircle(
        p,
        44,
        Paint()
          ..color = _white.withValues(alpha: 0.7)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8))
    ..drawCircle(p, 38, _fill(_shade(color, 0.12)))
    ..drawCircle(p + const Offset(-4, -4), 33, _fill(color))
    ..drawCircle(p + const Offset(-15, -15), 10, _fill(_white))
    ..drawCircle(p + const Offset(12, 18), 4, _fill(_white.withValues(alpha: 0.8)));
  // The front lip of the clam with a scalloped edge.
  final lip = Path()..moveTo(418, 1246);
  for (var i = 1; i <= 6; i++) {
    lip.arcToPoint(Offset(418 + i * 148 / 6, 1246),
        radius: const Radius.circular(14));
  }
  lip
    ..cubicTo(560, 1290, 424, 1290, 418, 1246)
    ..close();
  canvas
    ..drawPath(lip, _fill(_gold))
    ..drawPath(
      Path()
        ..moveTo(426, 1252)
        ..cubicTo(440, 1278, 544, 1278, 558, 1252),
      _line(goldDark, 3.5),
    );
  for (var i = 1; i < 6; i++) {
    final x = 418 + i * 148 / 6;
    canvas.drawLine(Offset(x, 1246), Offset(492 + (x - 492) * 0.6, 1284),
        _line(_goldLight, 3));
  }
}

void _paintRainbowPebble(Canvas canvas, Color color) {
  _glow(canvas, _pebbleShape, _tint(color, 0.18), 14);
  canvas
    ..drawPath(_pebbleShape, _fill(color))
    ..save()
    ..clipPath(_pebbleShape)
    ..translate(492, 1226)
    ..rotate(-0.6);
  // Rainbow bands across the stone, the item's own colour last.
  final bands = [
    const Color(0xFFE85D5D),
    const Color(0xFFF29A4A),
    const Color(0xFFF2D04A),
    const Color(0xFF6CC36C),
    const Color(0xFF4FA3E0),
    color,
  ];
  for (var i = 0; i < bands.length; i++) {
    canvas.drawRect(
        Rect.fromLTWH(-90, -63 + i * 21.0, 180, 21.5), _fill(bands[i]));
  }
  canvas
    ..restore()
    ..save()
    ..clipPath(_pebbleShape)
    ..drawPath(
      Path.combine(PathOperation.difference, _pebbleShape,
          _pebbleShape.shift(const Offset(-5, -10))),
      _fill(_shade(color, 0.08).withValues(alpha: 0.75)),
    )
    ..restore()
    ..drawPath(
        _placed(
            Path()
              ..addOval(Rect.fromCenter(
                  center: Offset.zero, width: 34, height: 15)),
            const Offset(458, 1204),
            -0.3),
        _fill(_white.withValues(alpha: 0.6)));
  for (final (at, r, c) in const [
    (Offset(422, 1174), 12.0, _white),
    (Offset(568, 1190), 9.0, _goldLight),
    (Offset(562, 1272), 7.0, _white),
    (Offset(416, 1256), 6.0, _goldLight),
  ]) {
    _sparkle(canvas, at, r, c);
  }
}

// ---------------------------------------------------------------------------
// Widgets.

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

/// A square preview of [item] for lists and the reveal sheet, with a thin
/// border in its rarity's tint.
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
        border: Border.all(
          color: item.rarity.tint,
          width: math.max(2, size * 0.04),
        ),
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
