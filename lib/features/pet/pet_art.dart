import 'package:material_ui/material_ui.dart';

import '../../domain/models/cosmetic_item.dart';
import '../../domain/models/pet_state.dart';
import '../../domain/rules/pet_rules.dart';
import 'otter_geometry.dart';
import 'otter_painter.dart';

/// The pet: the otter of `docs/art/otter_reference.jpg`, drawn in code
/// (see [OtterPainter]). Its face follows the mood, mud spots show when it
/// needs a bath, and it grows with each stage. It wears the [outfit] (a head
/// item replaces the leaf, a neck item the bandana). Never used for the egg
/// (`EggArt`). Decorative only.
class PetArt extends StatelessWidget {
  const PetArt({
    super.key,
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

  /// For animations later; [OtterPose.rest] is the reference picture.
  final OtterPose pose;

  @override
  Widget build(BuildContext context) {
    final width = switch (stage) {
      PetStage.young => 170.0,
      PetStage.adult => 190.0,
      _ => 150.0,
    };
    // Own layer: the room's idle bob moves it without repainting the otter.
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(width, width / OtterGeometry.aspectRatio),
        painter: OtterPainter(
          stage: stage,
          mood: mood,
          dirty: dirty,
          outfit: outfit,
          pose: pose,
        ),
      ),
    );
  }
}
