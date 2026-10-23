import 'package:material_ui/material_ui.dart';

import '../../domain/models/cosmetic_item.dart';
import '../../domain/models/pet_state.dart';
import '../../domain/rules/pet_rules.dart';
import '../wardrobe/cosmetic_art.dart';
import 'otter_geometry.dart';

/// Paints the otter of `docs/art/otter_reference.jpg` with flat shapes.
///
/// Everything is drawn in the reference picture's pixel coordinates (see
/// [OtterGeometry]); [paint] maps [OtterGeometry.viewBox] onto the canvas.
/// Every body part is its own layer, so a [pose] can move it. Back to front:
///
/// tail, haunch, body, thighs, belly, hind feet, paws item, front paws,
/// neck item (default: the green bandana), then the head group, turned by
/// [OtterPose.headTilt]: ears, head, muzzle, brows, eyes, nose, mouth,
/// whiskers, face item, head item (default: the green leaf).
///
/// The outlines are built once and shared by every otter on screen.
class OtterPainter extends CustomPainter {
  const OtterPainter({
    required this.stage,
    required this.mood,
    this.dirty = false,
    this.outfit = const {},
    this.pose = OtterPose.rest,
  });

  final PetStage stage;
  final PetMood mood;
  final bool dirty;
  final Map<CosmeticSlot, CosmeticItem> outfit;
  final OtterPose pose;

  /// Younger otters are a touch lighter; the adult has the reference colours.
  Color _fur(Color color) => switch (stage) {
        PetStage.adult => color,
        PetStage.young => Color.lerp(color, _youngFur, 0.05)!,
        _ => Color.lerp(color, _youngFur, 0.1)!,
      };

  /// The baby's head is a little bigger compared with its body.
  double get _headScale => switch (stage) {
        PetStage.adult => 1,
        PetStage.young => 1.025,
        _ => 1.05,
      };

  @override
  void paint(Canvas canvas, Size size) {
    const box = OtterGeometry.viewBox;
    final fill = Paint();
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fur = _fur(OtterPalette.fur);
    final back = _fur(OtterPalette.tail);

    canvas
      ..save()
      ..scale(size.width / box.width, size.height / box.height)
      ..translate(-box.left, -box.top - pose.bodyLift);

    // Tail, swinging around its base.
    canvas.save();
    _turn(canvas, OtterGeometry.tailPivot, pose.tailSwing);
    canvas.drawPath(_Shapes.tail, fill..color = back);
    canvas.restore();

    // Body: the darker haunch shows between the legs, then the chest with
    // the front legs, the right flank and the thighs on top.
    canvas
      ..drawPath(_Shapes.haunch, fill)
      ..drawPath(_Shapes.body, fill..color = fur)
      ..drawPath(_Shapes.rightFlank, fill)
      ..drawPath(_Shapes.leftThigh, fill)
      ..drawPath(_Shapes.thighCrease, fill..color = back)
      ..drawPath(_Shapes.bellyCrease, fill)
      ..drawPath(_Shapes.belly, fill..color = OtterPalette.cream)
      ..drawPath(_Shapes.leftFoot, fill..color = OtterPalette.pawPad)
      ..drawPath(_Shapes.rightFoot, fill)
      ..drawPath(
          _Shapes.footToes,
          line
            ..color = _padLine
            ..strokeWidth = 11);
    if (dirty) {
      canvas.drawPath(_Shapes.bodyMud, fill..color = _mud);
    }

    // Something held in the front paws: the paws overlap its bottom.
    final held = outfit[CosmeticSlot.paws];
    if (held != null) paintCosmetic(canvas, held);
    canvas
      ..drawLine(const Offset(485, 1282), const Offset(485, 1332),
          line..color = back..strokeWidth = 8)
      ..drawPath(_Shapes.frontPaws, fill..color = _fur(OtterPalette.furShade))
      ..drawPath(
          _Shapes.pawToes,
          line
            ..color = OtterPalette.line
            ..strokeWidth = 12);

    // Neck: the item, or the green bandana.
    final neck = outfit[CosmeticSlot.neck];
    if (neck != null) {
      paintCosmetic(canvas, neck);
    } else {
      cosmeticDrawing('bandana', CosmeticSlot.neck)
          .paintOnOtter(canvas, OtterPalette.bandana);
    }

    canvas.save();
    _turn(canvas, OtterGeometry.neckPivot, pose.headTilt);
    const pivot = OtterGeometry.neckPivot;
    canvas
      ..translate(pivot.dx, pivot.dy)
      ..scale(_headScale)
      ..translate(-pivot.dx, -pivot.dy);
    _paintHead(canvas, fill, line);
    canvas
      ..restore()
      ..restore();
  }

  void _paintHead(Canvas canvas, Paint fill, Paint line) {
    final furHead = _fur(OtterPalette.furHead);

    // Ears flick outwards around where they join the head.
    final earFur = _fur(OtterPalette.fur);
    _paintEar(canvas, fill, _Shapes.leftEar, earFur, -pose.earTwitch);
    _paintEar(canvas, fill, _Shapes.rightEar, earFur, pose.earTwitch);

    canvas
      ..drawPath(_Shapes.head, fill..color = furHead)
      ..drawPath(_Shapes.chinShade, fill..color = _chinShade)
      ..drawPath(_Shapes.muzzle, fill..color = OtterPalette.cream);
    if (dirty) canvas.drawPath(_Shapes.cheekMud, fill..color = _mud);

    // Brows: tilted up in the middle when sad.
    final browTilt = mood == PetMood.sad ? 0.32 : 0.0;
    fill.color = OtterPalette.earInner;
    canvas.save();
    _turn(canvas, OtterGeometry.leftBrow, -browTilt);
    canvas
      ..drawPath(_Shapes.leftBrow, fill)
      ..restore()
      ..save();
    _turn(canvas, OtterGeometry.rightBrow, browTilt);
    canvas
      ..drawPath(_Shapes.rightBrow, fill)
      ..restore();

    for (final eye in [_Shapes.leftEye, _Shapes.rightEye]) {
      _paintEye(canvas, fill, line, eye, furHead);
    }

    canvas
      ..drawPath(_Shapes.nose, fill..color = OtterPalette.nose)
      ..drawOval(_Shapes.noseShine, fill..color = OtterPalette.eyeShine);

    line
      ..color = OtterPalette.line
      ..strokeWidth = 9;
    switch (mood) {
      case PetMood.happy:
        canvas
          ..drawPath(_Shapes.openMouth, fill..color = OtterPalette.mouthInside)
          ..drawPath(_Shapes.tongue, fill..color = OtterPalette.tongue)
          ..drawPath(_Shapes.wideSmile, line);
      case PetMood.ok:
        canvas.drawPath(_Shapes.smallSmile, line);
      case PetMood.sad:
        canvas.drawPath(_Shapes.pout, line);
    }
    canvas.drawPath(_Shapes.whiskers, line..strokeWidth = 6);

    final face = outfit[CosmeticSlot.face];
    if (face != null) paintCosmetic(canvas, face);
    final head = outfit[CosmeticSlot.head];
    if (head != null) {
      paintCosmetic(canvas, head);
    } else {
      cosmeticDrawing('leaf', CosmeticSlot.head)
          .paintOnOtter(canvas, OtterPalette.leaf);
    }
  }

  void _paintEar(Canvas canvas, Paint fill, _Ear ear, Color fur, double turn) {
    canvas.save();
    _turn(canvas, ear.base, turn);
    canvas
      ..drawPath(ear.outer, fill..color = fur)
      ..drawOval(ear.inner, fill..color = OtterPalette.earInner)
      ..restore();
  }

  void _paintEye(
      Canvas canvas, Paint fill, Paint line, _Eye eye, Color furHead) {
    final open = pose.eyesOpen.clamp(0.0, 1.0);
    if (open < 0.1) {
      // Closed: a soft curved line where the lids meet.
      canvas.drawPath(
          eye.closed,
          line
            ..color = OtterPalette.eye
            ..strokeWidth = 11);
      return;
    }
    // Blinking squashes the eye towards its lower part.
    final pivot = eye.disc.center.translate(0, eye.disc.height * 0.2);
    canvas
      ..save()
      ..translate(pivot.dx, pivot.dy)
      ..scale(1, open)
      ..translate(-pivot.dx, -pivot.dy)
      ..drawOval(eye.disc, fill..color = OtterPalette.eye)
      ..drawPath(eye.rim, fill..color = OtterPalette.eyeShine)
      ..drawOval(eye.shine, fill)
      ..drawOval(eye.sparkle, fill);
    if (mood == PetMood.sad) canvas.drawPath(eye.sadLid, fill..color = furHead);
    canvas.restore();
  }

  @override
  bool shouldRepaint(OtterPainter old) =>
      old.stage != stage ||
      old.mood != mood ||
      old.dirty != dirty ||
      old.pose != pose ||
      !_sameOutfit(old.outfit, outfit);

  static bool _sameOutfit(Map<CosmeticSlot, CosmeticItem> a,
      Map<CosmeticSlot, CosmeticItem> b) {
    if (a.length != b.length) return false;
    for (final MapEntry(:key, :value) in a.entries) {
      if (b[key]?.id != value.id) return false;
    }
    return true;
  }
}

/// Turns what is drawn next by [angle] radians around [pivot].
void _turn(Canvas canvas, Offset pivot, double angle) {
  if (angle == 0) return;
  canvas
    ..translate(pivot.dx, pivot.dy)
    ..rotate(angle)
    ..translate(-pivot.dx, -pivot.dy);
}

// Colours that are not in [OtterPalette] (sampled from the reference too).
const _youngFur = Color(0xFFDDAA80);
const _padLine = Color(0xFF472B1E);
const _chinShade = Color(0xFFD6BCA1);
const _mud = Color(0x8C6B4A2E); // OtterPalette.mud, 55 % opaque

/// A sharp point in an outline (fur tufts, tips). The other points are
/// joined by smooth curves.
class _Tip extends Offset {
  const _Tip(super.dx, super.dy);
}

/// A closed outline through [points]: smooth (Catmull-Rom) curves, sharp
/// at every [_Tip].
Path _outline(List<Offset> points) {
  final n = points.length;
  Offset tangent(int i) {
    if (points[i % n] is _Tip) return Offset.zero;
    return (points[(i + 1) % n] - points[(i + n - 1) % n]) / 6;
  }

  final path = Path()..moveTo(points.first.dx, points.first.dy);
  for (var i = 0; i < n; i++) {
    final a = points[i] + tangent(i);
    final end = points[(i + 1) % n];
    final b = end - tangent(i + 1);
    path.cubicTo(a.dx, a.dy, b.dx, b.dy, end.dx, end.dy);
  }
  return path..close();
}

/// Mud splashes: a few overlapping blobs per spot, filled once.
Path _spots(List<(double, double, double)> blobs) {
  final path = Path();
  for (final (x, y, r) in blobs) {
    path.addOval(Rect.fromCircle(center: Offset(x, y), radius: r));
  }
  return path;
}

class _Ear {
  _Ear(List<Offset> outer, this.inner, this.base) : outer = _outline(outer);

  /// The furry ear; the head covers its lower half.
  final Path outer;

  /// The dark inside; the head's edge cuts it straight.
  final Rect inner;

  /// Where the ear joins the head: it flicks around this point.
  final Offset base;
}

class _Eye {
  _Eye({
    required this.disc,
    required Rect white,
    required Rect iris,
    required this.shine,
    required this.sparkle,
    required List<Offset> sadLid,
  })  : rim = Path.combine(
          PathOperation.difference,
          Path.combine(PathOperation.intersect, Path()..addOval(disc),
              Path()..addOval(white)),
          Path()..addOval(iris),
        ),
        // A little bigger than the eye, so no dark edge peeks out.
        sadLid = Path.combine(PathOperation.intersect,
            Path()..addOval(disc.inflate(3)), _outline(sadLid)),
        closed = Path()
          ..moveTo(disc.left + 14, disc.center.dy + 6)
          ..quadraticBezierTo(disc.center.dx, disc.center.dy + 44,
              disc.right - 14, disc.center.dy + 6);

  /// The big dark eye.
  final Rect disc;

  /// The white crescent along the outer side.
  final Path rim;

  /// The big and the small shine.
  final Rect shine;
  final Rect sparkle;

  /// Heavier upper lid for the sad mood.
  final Path sadLid;

  /// The line drawn instead when the eye is shut.
  final Path closed;
}

/// Every outline, measured on the reference picture.
abstract final class _Shapes {
  static final tail = _outline(const [
    Offset(930, 932), Offset(948, 935), Offset(959, 948), Offset(964, 972),
    Offset(965, 1002), Offset(962, 1036), Offset(956, 1069),
    Offset(946, 1104), Offset(933, 1139), Offset(917, 1173),
    Offset(898, 1206), Offset(876, 1237), Offset(852, 1263),
    Offset(826, 1286), Offset(795, 1292), Offset(768, 1272),
    Offset(754, 1232), Offset(756, 1178), Offset(768, 1128),
    Offset(785, 1088), Offset(803, 1066), Offset(820, 1042),
    Offset(838, 1015), Offset(857, 988), Offset(879, 961), Offset(903, 942),
  ]);

  /// The back of the body, seen between the legs.
  static final haunch = _outline(const [
    Offset(300, 960), Offset(272, 1000), Offset(262, 1028),
    Offset(245, 1046), Offset(230, 1065), Offset(217, 1086),
    Offset(206, 1110), Offset(198, 1135), Offset(192, 1165),
    Offset(184, 1210), Offset(190, 1270), Offset(240, 1330),
    Offset(300, 1352), Offset(345, 1343), Offset(420, 1340),
    Offset(486, 1334), Offset(560, 1340), Offset(628, 1341),
    Offset(662, 1352), Offset(740, 1330), Offset(815, 1285),
    Offset(832, 1220), Offset(815, 1150), Offset(785, 1095),
    Offset(745, 1030), Offset(715, 970), Offset(600, 940), Offset(420, 940),
  ]);

  /// Chest and front legs, with fluffy notches at the left shoulder.
  static final body = _outline(const [
    Offset(312, 772), Offset(400, 730), Offset(560, 730), Offset(652, 770),
    Offset(681, 815), Offset(697, 873), Offset(706, 913), Offset(718, 955),
    Offset(735, 988), Offset(744, 1004), Offset(722, 1024),
    // Right front leg
    _Tip(700, 1036), Offset(691, 1072), Offset(683, 1102), Offset(674, 1132),
    Offset(664, 1162), Offset(652, 1192), Offset(637, 1222),
    Offset(622, 1250), Offset(612, 1276), Offset(609, 1300),
    Offset(609, 1325), Offset(598, 1346), Offset(530, 1350),
    Offset(486, 1326), Offset(440, 1350), Offset(380, 1346),
    // Left front leg
    Offset(366, 1325), Offset(366, 1308), Offset(367, 1292),
    Offset(362, 1268), Offset(354, 1253), Offset(341, 1227),
    Offset(329, 1201), Offset(317, 1175), Offset(305, 1148),
    Offset(295, 1120), Offset(285, 1092), Offset(278, 1064),
    Offset(272, 1036), Offset(270, 1010), Offset(272, 985), Offset(275, 962),
    // Shoulder fluff
    _Tip(280, 934), _Tip(264, 942), Offset(267, 915), Offset(277, 890),
    _Tip(291, 867), _Tip(275, 872), Offset(281, 856), Offset(295, 830),
    Offset(310, 803),
  ]);

  /// Right flank and thigh, apart from the front leg by a dark crease.
  static final rightFlank = _outline(const [
    Offset(706, 940), Offset(722, 965), Offset(735, 987), Offset(746, 1005),
    Offset(757, 1027), Offset(766, 1048), Offset(775, 1071),
    Offset(786, 1089), Offset(801, 1112), Offset(815, 1133),
    Offset(825, 1153), Offset(832, 1176), Offset(837, 1200),
    Offset(838, 1228), Offset(832, 1262), Offset(800, 1300),
    Offset(720, 1330), Offset(663, 1330), Offset(662, 1301),
    Offset(665, 1281), Offset(669, 1261), Offset(676, 1241),
    Offset(684, 1222), Offset(686, 1200), Offset(686, 1161),
    Offset(694, 1131), Offset(698, 1101), Offset(700, 1071),
    _Tip(701, 1040), Offset(703, 990),
  ]);

  static final leftThigh = _outline(const [
    Offset(190, 1166), Offset(205, 1153), Offset(222, 1147),
    Offset(243, 1143), Offset(264, 1147), Offset(284, 1156),
    Offset(300, 1170), Offset(311, 1186), Offset(320, 1205),
    Offset(327, 1225), Offset(332, 1248), Offset(336, 1272),
    Offset(338, 1300), Offset(338, 1325), Offset(336, 1345),
    Offset(300, 1360), Offset(220, 1350), Offset(165, 1290),
    Offset(163, 1250), Offset(166, 1218), Offset(176, 1190),
  ]);

  /// The fold above the right thigh.
  static final thighCrease = _outline(const [
    _Tip(674, 1196), Offset(689, 1182), Offset(705, 1169),
    Offset(723, 1158), Offset(743, 1150), _Tip(761, 1147),
    Offset(740, 1158), Offset(723, 1172), Offset(708, 1187),
    _Tip(692, 1204),
  ]);

  /// Cream chest and belly, narrowing to a point between the front paws.
  static final belly = _outline(const [
    Offset(380, 780), Offset(486, 792), Offset(590, 782), Offset(593, 830),
    Offset(595, 865), Offset(598, 890), _Tip(601, 919), _Tip(589, 917),
    Offset(586, 942), Offset(578, 968), Offset(566, 999), Offset(556, 1023),
    Offset(546, 1046), Offset(535, 1069), Offset(525, 1093),
    Offset(517, 1117), Offset(511, 1142), Offset(507, 1167),
    Offset(505, 1192), Offset(504, 1217), Offset(499, 1243),
    _Tip(485, 1281), Offset(471, 1244), Offset(466, 1219),
    Offset(464, 1194), Offset(462, 1169), Offset(457, 1144),
    Offset(451, 1119), Offset(442, 1095), Offset(432, 1072),
    Offset(420, 1049), Offset(408, 1026), Offset(395, 1004),
    Offset(383, 981), Offset(373, 957), Offset(367, 932), _Tip(366, 893),
    _Tip(354, 904), Offset(358, 880), Offset(365, 851), Offset(370, 815),
  ]);

  static final leftFoot = _outline(const [
    Offset(220, 1236), Offset(244, 1240), Offset(268, 1245),
    Offset(289, 1261), Offset(305, 1280), Offset(319, 1301),
    Offset(329, 1324), Offset(334, 1348), Offset(328, 1371),
    Offset(308, 1387), Offset(284, 1391), Offset(260, 1389),
    Offset(236, 1381), Offset(213, 1371), Offset(191, 1358),
    Offset(171, 1342), Offset(156, 1323), Offset(148, 1300),
    Offset(151, 1276), Offset(165, 1259), Offset(188, 1251),
    Offset(203, 1241),
  ]);

  static final rightFoot = _outline(const [
    Offset(752, 1232), Offset(776, 1235), Offset(800, 1239),
    Offset(817, 1254), Offset(834, 1270), Offset(843, 1292),
    Offset(837, 1316), Offset(821, 1337), Offset(802, 1354),
    Offset(781, 1368), Offset(759, 1380), Offset(735, 1388),
    Offset(711, 1392), Offset(687, 1389), Offset(667, 1375),
    Offset(656, 1353), Offset(661, 1333), Offset(669, 1309),
    Offset(680, 1287), Offset(696, 1267), Offset(714, 1250),
    Offset(733, 1238),
  ]);

  /// Three toe lines on each hind foot.
  static final footToes = Path()
    ..moveTo(240, 1251)
    ..quadraticBezierTo(246, 1267, 249, 1286)
    ..moveTo(189, 1265)
    ..quadraticBezierTo(198, 1281, 204, 1299)
    ..moveTo(154, 1293)
    ..quadraticBezierTo(165, 1310, 175, 1326)
    ..moveTo(762, 1245)
    ..quadraticBezierTo(753, 1262, 747, 1282)
    ..moveTo(811, 1265)
    ..quadraticBezierTo(797, 1279, 787, 1295)
    ..moveTo(839, 1292)
    ..quadraticBezierTo(825, 1309, 812, 1326);

  /// Darker fur along the lower edges of the belly.
  static final bellyCrease = _outline(const [
    _Tip(466, 1160), Offset(459, 1200), Offset(456, 1228),
    Offset(462, 1248), Offset(474, 1270), _Tip(485, 1292),
    Offset(496, 1270), Offset(507, 1248), Offset(515, 1228),
    Offset(512, 1200), _Tip(506, 1160),
  ]);

  /// Rounded front paws, higher on the inner side.
  static final frontPaws = Path()
    ..addPath(
        _outline(const [
          Offset(368, 1299), Offset(398, 1281), Offset(438, 1271),
          Offset(468, 1269), Offset(480, 1284), Offset(481, 1318),
          Offset(479, 1340), Offset(471, 1353), Offset(458, 1363),
          Offset(438, 1371), Offset(414, 1371), Offset(391, 1362),
          Offset(377, 1350), Offset(369, 1335), Offset(366, 1317),
        ]),
        Offset.zero)
    ..addPath(
        _outline(const [
          Offset(490, 1282), Offset(501, 1265), Offset(522, 1259),
          Offset(554, 1265), Offset(586, 1277), Offset(607, 1295),
          Offset(610, 1320), Offset(605, 1340), Offset(596, 1352),
          Offset(582, 1362), Offset(558, 1371), Offset(534, 1371),
          Offset(513, 1363), Offset(500, 1352), Offset(491, 1338),
          Offset(489, 1315),
        ]),
        Offset.zero);

  /// Two toe lines on each front paw.
  static final pawToes = Path()
    ..moveTo(405, 1300)
    ..quadraticBezierTo(400, 1345, 418, 1365)
    ..moveTo(448, 1298)
    ..quadraticBezierTo(457, 1331, 451, 1364)
    ..moveTo(524, 1299)
    ..quadraticBezierTo(514, 1330, 521, 1364)
    ..moveTo(569, 1304)
    ..quadraticBezierTo(570, 1341, 559, 1364);

  static final bodyMud = _spots(const [
    (318, 985, 26), (298, 1006, 16), (342, 1006, 14), (322, 1017, 12),
    (738, 1072, 24), (760, 1092, 15), (722, 1096, 13), (748, 1108, 9),
    (240, 1196, 23), (262, 1214, 13), (220, 1214, 12),
  ]);

  static final leftEar = _Ear(const [
    Offset(146, 415), Offset(149, 391), Offset(159, 369), Offset(176, 351),
    Offset(198, 339), Offset(222, 336), Offset(246, 340), Offset(268, 349),
    Offset(285, 372), Offset(283, 425), Offset(250, 480), Offset(205, 500),
    Offset(179, 478), Offset(161, 461), Offset(150, 439),
  ], const Rect.fromLTRB(172, 375, 250, 467), const Offset(222, 432));

  static final rightEar = _Ear(const [
    Offset(712, 352), Offset(730, 345), Offset(754, 341), Offset(778, 343),
    Offset(800, 353), Offset(818, 371), Offset(828, 394), Offset(830, 418),
    Offset(826, 442), Offset(815, 464), Offset(798, 481), Offset(780, 500),
    Offset(740, 470), Offset(700, 410), Offset(695, 370),
  ], const Rect.fromLTRB(730, 381, 807, 469), const Offset(756, 436));

  /// The head, with the hair tuft on top and fluffy cheeks. Its edge cuts
  /// the dark inside of the ears; the chin is hidden under the muzzle.
  static final head = _outline(const [
    Offset(203, 458), Offset(219, 422), Offset(236, 388), Offset(252, 362),
    Offset(268, 349), Offset(290, 332), Offset(316, 312), Offset(345, 294),
    Offset(375, 280), Offset(408, 270), Offset(440, 263),
    // Hair tuft
    Offset(462, 247), Offset(486, 233), _Tip(515, 225), Offset(511, 241),
    _Tip(498, 262), Offset(521, 254), _Tip(543, 256), Offset(552, 266),
    // Under the leaf, then the right ear
    Offset(585, 274), Offset(618, 287), Offset(648, 302), Offset(672, 318),
    Offset(692, 334), Offset(712, 355), Offset(728, 372), Offset(743, 393),
    Offset(760, 430), Offset(776, 466),
    // Right cheek
    Offset(784, 498), Offset(789, 525), Offset(795, 550), Offset(805, 572),
    _Tip(820, 590), _Tip(804, 601), Offset(804, 618), _Tip(812, 638),
    Offset(796, 660), Offset(785, 684), Offset(768, 702),
    // Chin, just inside the muzzle
    Offset(750, 712), Offset(727, 730), Offset(700, 745), Offset(672, 757),
    Offset(644, 767), Offset(600, 780), Offset(540, 787), Offset(486, 790),
    Offset(430, 790), Offset(380, 782), Offset(322, 764), Offset(293, 754),
    Offset(266, 742), Offset(240, 727), Offset(217, 709), Offset(198, 688),
    // Left cheek
    Offset(180, 673), Offset(171, 654), _Tip(166, 638), _Tip(152, 644),
    Offset(159, 622), Offset(162, 606), _Tip(166, 594), _Tip(145, 590),
    Offset(163, 571), Offset(176, 548), Offset(183, 522), Offset(189, 498),
    Offset(197, 477),
  ]);

  /// Darker cream under the chin, above the bandana.
  static final chinShade = Path()
    ..moveTo(340, 770)
    ..quadraticBezierTo(486, 844, 632, 770)
    ..close();

  /// The cream lower face, curving up between the eyes to the nose.
  static final muzzle = _outline(const [
    Offset(478, 546), Offset(508, 547), Offset(537, 555), Offset(562, 573),
    Offset(583, 596), Offset(608, 612), Offset(638, 618), Offset(668, 615),
    Offset(698, 608), Offset(728, 605), Offset(758, 611), Offset(780, 632),
    Offset(783, 662), Offset(773, 691), Offset(754, 714), Offset(730, 733),
    Offset(703, 748), Offset(675, 760), Offset(646, 771), Offset(617, 778),
    Offset(587, 786), Offset(555, 791), Offset(520, 793), Offset(486, 795),
    Offset(450, 795), Offset(415, 792), Offset(379, 786), Offset(351, 777),
    Offset(322, 768), Offset(293, 758), Offset(265, 746), Offset(238, 731),
    Offset(214, 712), Offset(194, 689), Offset(184, 660), Offset(188, 630),
    Offset(209, 609), Offset(239, 602), Offset(269, 605), Offset(299, 612),
    Offset(329, 617), Offset(359, 615), Offset(387, 603), Offset(410, 582),
    Offset(433, 563), Offset(455, 552),
  ]);

  static final cheekMud = _spots(const [
    (712, 702, 22), (734, 714, 13), (694, 718, 11), (728, 690, 10),
  ]);

  static final leftBrow = _outline(const [
    Offset(334, 392), Offset(346, 391), _Tip(357, 396), Offset(345, 402),
    Offset(333, 406), Offset(321, 411), Offset(310, 418), _Tip(302, 423),
    Offset(305, 414), Offset(313, 403), Offset(323, 396),
  ]);

  static final rightBrow = _outline(const [
    Offset(624, 391), Offset(636, 390), Offset(648, 394), Offset(659, 401),
    Offset(666, 410), _Tip(671, 420), Offset(662, 416), Offset(650, 409),
    Offset(638, 404), Offset(626, 401), _Tip(615, 397),
  ]);

  static final leftEye = _Eye(
    disc: const Rect.fromLTRB(260, 468, 400, 611),
    white: const Rect.fromLTRB(266, 480, 400, 612),
    iris: const Rect.fromLTRB(286, 487, 420, 619),
    shine: Rect.fromCircle(center: const Offset(361, 518), radius: 16.5),
    sparkle: Rect.fromCircle(center: const Offset(312, 576), radius: 10),
    sadLid: const [
      _Tip(250, 455), _Tip(412, 455), _Tip(412, 487), Offset(330, 493),
      _Tip(250, 507),
    ],
  );

  static final rightEye = _Eye(
    disc: const Rect.fromLTRB(579, 468, 714, 611),
    white: const Rect.fromLTRB(577, 480, 709, 612),
    iris: const Rect.fromLTRB(557, 487, 687, 619),
    shine: Rect.fromCircle(center: const Offset(615, 520), radius: 16),
    sparkle: Rect.fromCircle(center: const Offset(661, 565), radius: 10),
    sadLid: const [
      _Tip(567, 455), _Tip(726, 455), _Tip(726, 507), Offset(646, 493),
      _Tip(567, 487),
    ],
  );

  static final nose = _outline(const [
    Offset(484, 566), Offset(500, 567), Offset(516, 569), Offset(532, 576),
    Offset(543, 588), Offset(544, 600), Offset(535, 611), Offset(521, 621),
    Offset(505, 626), Offset(489, 629), Offset(473, 627), Offset(457, 621),
    Offset(442, 611), Offset(434, 598), Offset(436, 586), Offset(447, 577),
    Offset(463, 570),
  ]);

  static const noseShine = Rect.fromLTRB(476, 576, 500, 586);

  /// Happy: the open mouth under the lip line, with the tongue.
  static final openMouth = _outline(const [
    _Tip(419, 662), Offset(447, 667), Offset(474, 661), _Tip(489, 651),
    Offset(504, 661), Offset(531, 667), _Tip(558, 662), Offset(550, 684),
    Offset(536, 703), Offset(513, 716), Offset(487, 720), Offset(461, 716),
    Offset(438, 703), Offset(425, 684),
  ]);

  static final tongue = Path.combine(
    PathOperation.intersect,
    openMouth,
    Path()
      ..addOval(Rect.fromCenter(
          center: const Offset(487, 722), width: 110, height: 100)),
  );

  static final wideSmile = Path()
    ..moveTo(489, 628)
    ..lineTo(489, 648)
    ..cubicTo(480, 667, 420, 679, 388, 640)
    ..moveTo(489, 648)
    ..cubicTo(498, 667, 558, 679, 588, 640);

  /// Ok: a closed, gentle smile.
  static final smallSmile = Path()
    ..moveTo(489, 628)
    ..lineTo(489, 647)
    ..cubicTo(483, 662, 438, 668, 412, 648)
    ..moveTo(489, 647)
    ..cubicTo(495, 662, 540, 668, 566, 648);

  /// Sad: a small downturned mouth.
  static final pout = Path()
    ..moveTo(489, 628)
    ..lineTo(489, 645)
    ..moveTo(462, 685)
    ..quadraticBezierTo(489, 652, 516, 685);

  static final whiskers = Path()
    ..moveTo(224, 650)
    ..quadraticBezierTo(270, 635, 317, 639)
    ..moveTo(246, 694)
    ..quadraticBezierTo(278, 673, 318, 662)
    ..moveTo(656, 640)
    ..quadraticBezierTo(702, 638, 748, 651)
    ..moveTo(654, 662)
    ..quadraticBezierTo(691, 675, 725, 695);
}
