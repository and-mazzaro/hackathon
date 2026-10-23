import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../domain/models/cosmetic_item.dart';

/// Where everything sits on the otter.
///
/// The otter is drawn in the pixel coordinates of the reference artwork
/// `docs/art/otter_reference.jpg` (1024 x 1536). Every number here was
/// measured on that picture, so a part can be compared with the original
/// by its coordinates. Painters scale [viewBox] to the widget size.
abstract final class OtterGeometry {
  /// The part of the reference picture the otter fills (860 x 1216).
  static const viewBox = Rect.fromLTRB(128, 196, 988, 1412);
  static const aspectRatio = 860 / 1216;

  // Animation pivots (see [OtterPose]).
  /// The head (ears, face, leaf, face items) turns around this point.
  static const neckPivot = Offset(490, 790);

  /// The tail swings around its base.
  static const tailPivot = Offset(812, 1236);

  // Measured feature centres.
  static const leftEye = Offset(328, 540);
  static const rightEye = Offset(646, 540);
  static const eyeRadius = 68.0;
  static const leftBrow = Offset(330, 406);
  static const rightBrow = Offset(642, 406);
  static const nose = Offset(492, 598);
  static const mouth = Offset(486, 690);
  static const leftEar = Offset(200, 412);
  static const rightEar = Offset(777, 417);

  /// Where the default green leaf grows (top right of the head).
  static const leafSpot = Rect.fromLTRB(540, 205, 705, 330);

  /// Where the default green bandana is tied.
  static const bandanaArea = Rect.fromLTRB(300, 760, 795, 960);

  /// The front paws, resting together at the bottom.
  static const frontPaws = Rect.fromLTRB(360, 1240, 620, 1380);

  /// The area items of [slot] are drawn in. Also frames the thumbnails
  /// when an item does not give its own bounds.
  static Rect slotArea(CosmeticSlot slot) => switch (slot) {
        CosmeticSlot.head => const Rect.fromLTRB(300, 150, 760, 345),
        CosmeticSlot.face => const Rect.fromLTRB(235, 440, 755, 640),
        CosmeticSlot.neck => const Rect.fromLTRB(290, 750, 800, 970),
        CosmeticSlot.paws => const Rect.fromLTRB(395, 1150, 590, 1320),
      };

  /// Head and face items move with the head; neck and paws items with the
  /// body.
  static bool movesWithHead(CosmeticSlot slot) =>
      slot == CosmeticSlot.head || slot == CosmeticSlot.face;
}

/// The otter's colours, sampled from the reference artwork.
abstract final class OtterPalette {
  static const fur = Color(0xFF9C6546);
  static const furHead = Color(0xFFA26C4A);
  static const furShade = Color(0xFF8A5638);
  static const tail = Color(0xFF794B33);
  static const earInner = Color(0xFF5A3628);
  static const pawPad = Color(0xFF613C2C);
  static const cream = Color(0xFFF5DFC7);
  static const eye = Color(0xFF361D16);
  static const eyeShine = Color(0xFFFFFFFF);
  static const nose = Color(0xFF4F2F22);
  static const line = Color(0xFF563526);
  static const mouthInside = Color(0xFF7A3328);
  static const tongue = Color(0xFFE88379);
  static const leaf = Color(0xFF7A9F36);
  static const bandana = Color(0xFF6D9233);
  static const mud = Color(0xFF6B4A2E);
}

/// A body pose, for animations later (blink, tail wag, head tilt).
/// [OtterPose.rest] is the reference picture. Painters must draw every
/// value in between, so a controller can animate any field.
@immutable
class OtterPose {
  const OtterPose({
    this.headTilt = 0,
    this.tailSwing = 0,
    this.eyesOpen = 1,
    this.earTwitch = 0,
    this.bodyLift = 0,
  });

  static const rest = OtterPose();

  /// Radians around [OtterGeometry.neckPivot]; positive turns clockwise.
  final double headTilt;

  /// Radians around [OtterGeometry.tailPivot]; positive swings outwards.
  final double tailSwing;

  /// 1 = eyes open, 0 = closed (a blink animates 1 → 0 → 1).
  final double eyesOpen;

  /// Extra radians for both ears (a small flick).
  final double earTwitch;

  /// Upward shift of the whole otter in reference pixels (a hop).
  final double bodyLift;

  static OtterPose lerp(OtterPose a, OtterPose b, double t) => OtterPose(
        headTilt: lerpDouble(a.headTilt, b.headTilt, t)!,
        tailSwing: lerpDouble(a.tailSwing, b.tailSwing, t)!,
        eyesOpen: lerpDouble(a.eyesOpen, b.eyesOpen, t)!,
        earTwitch: lerpDouble(a.earTwitch, b.earTwitch, t)!,
        bodyLift: lerpDouble(a.bodyLift, b.bodyLift, t)!,
      );

  @override
  bool operator ==(Object other) =>
      other is OtterPose &&
      other.headTilt == headTilt &&
      other.tailSwing == tailSwing &&
      other.eyesOpen == eyesOpen &&
      other.earTwitch == earTwitch &&
      other.bodyLift == bodyLift;

  @override
  int get hashCode =>
      Object.hash(headTilt, tailSwing, eyesOpen, earTwitch, bodyLift);
}
