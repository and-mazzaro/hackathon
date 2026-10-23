// Renders the otter (default look, happy) on a transparent background at
// high resolution, as the source for the app icon. Skipped in normal runs.
//
//   ECOQUEST_RENDER_DIR=/some/folder flutter test test/tools/render_app_icon_test.dart
//
// Writes otter_transparent.png (1720 x 2432, reference coordinates x2).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:ecoquest/domain/models/pet_state.dart';
import 'package:ecoquest/domain/rules/pet_rules.dart';
import 'package:ecoquest/features/pet/otter_geometry.dart';
import 'package:ecoquest/features/pet/pet_art.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final _outDir = Platform.environment['ECOQUEST_RENDER_DIR'];

void main() {
  testWidgets('render otter for the app icon', (tester) async {
    addTearDown(tester.view.reset);
    final box = OtterGeometry.viewBox;
    final size = Size(box.width * 2, box.height * 2);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    final key = GlobalKey();
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(
        key: key,
        child: SizedBox.fromSize(
          size: size,
          child: const FittedBox(
            fit: BoxFit.fill,
            child: PetArt(stage: PetStage.adult, mood: PetMood.happy),
          ),
        ),
      ),
    ));
    await tester.pump();
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage();
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      Directory(_outDir!).createSync(recursive: true);
      File('$_outDir/otter_transparent.png')
          .writeAsBytesSync(data!.buffer.asUint8List());
    });
  }, skip: _outDir == null);
}
