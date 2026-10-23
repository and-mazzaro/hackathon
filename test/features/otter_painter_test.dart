import 'package:ecoquest/domain/models/cosmetic_item.dart';
import 'package:ecoquest/domain/models/pet_state.dart';
import 'package:ecoquest/domain/rules/pet_rules.dart';
import 'package:ecoquest/features/pet/otter_geometry.dart';
import 'package:ecoquest/features/pet/otter_painter.dart';
import 'package:ecoquest/features/pet/pet_art.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _bow = CosmeticItem(
  id: 'neck_bow',
  name: 'Fiocco',
  slot: CosmeticSlot.neck,
  rarity: CosmeticRarity.common,
  icon: 'bow',
  color: 0xFFE5578A,
);

OtterPainter _painter({
  PetMood mood = PetMood.happy,
  Map<CosmeticSlot, CosmeticItem> outfit = const {},
  OtterPose pose = OtterPose.rest,
}) =>
    OtterPainter(
        stage: PetStage.adult, mood: mood, outfit: outfit, pose: pose);

void main() {
  testWidgets('PetArt grows with the stage and keeps the otter proportions',
      (tester) async {
    for (final (stage, width) in [
      (PetStage.baby, 150.0),
      (PetStage.young, 170.0),
      (PetStage.adult, 190.0),
    ]) {
      await tester.pumpWidget(Center(
        child: PetArt(stage: stage, mood: PetMood.happy),
      ));
      final size = tester.getSize(find.byType(PetArt));
      expect(size.width, width);
      expect(size.width / size.height, closeTo(OtterGeometry.aspectRatio, 1e-6));
    }
  });

  testWidgets('every mood, pose and outfit paints without errors',
      (tester) async {
    for (final mood in PetMood.values) {
      for (final pose in const [
        OtterPose.rest,
        OtterPose(eyesOpen: 0),
        OtterPose(
            headTilt: 0.2,
            tailSwing: -0.3,
            eyesOpen: 0.5,
            earTwitch: 0.3,
            bodyLift: 30),
      ]) {
        await tester.pumpWidget(Center(
          child: PetArt(
            stage: PetStage.baby,
            mood: mood,
            dirty: true,
            outfit: const {CosmeticSlot.neck: _bow},
            pose: pose,
          ),
        ));
        expect(tester.takeException(), isNull);
      }
    }
  });

  test('repaints only when something visible changes', () {
    expect(_painter().shouldRepaint(_painter()), isFalse);
    expect(_painter().shouldRepaint(_painter(mood: PetMood.sad)), isTrue);
    expect(
        _painter().shouldRepaint(
            _painter(outfit: const {CosmeticSlot.neck: _bow})),
        isTrue);
    expect(
        _painter(outfit: const {CosmeticSlot.neck: _bow}).shouldRepaint(
            _painter(outfit: const {CosmeticSlot.neck: _bow})),
        isFalse);
    expect(
        _painter().shouldRepaint(_painter(pose: const OtterPose(eyesOpen: 0))),
        isTrue);
  });
}
