// Renders the otter and every cosmetic to PNG files, to compare the drawing
// with docs/art/otter_reference.jpg. Skipped in normal test runs.
//
//   ECOQUEST_RENDER_DIR=/some/folder flutter test test/tools/render_pet_sheet_test.dart
//
// Files written:
//   hero.png      1024 x 1536 on black: the default otter placed exactly over
//                 the reference picture (same coordinates), for side by side
//                 or overlay comparison
//   moods.png     rows baby / young / adult; columns happy, ok, sad,
//                 sad + dirty, blinking (eyes closed)
//   outfits.png   the adult otter wearing each item alone (order in
//                 outfits.txt)
//   full.png      full outfits: one item per slot, one row per rarity
//   thumbs.png    every item's wardrobe thumbnail at 56 and 120 px
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:ecoquest/data/content/cosmetic_content.dart';
import 'package:ecoquest/domain/models/cosmetic_item.dart';
import 'package:ecoquest/domain/models/pet_state.dart';
import 'package:ecoquest/domain/rules/pet_rules.dart';
import 'package:ecoquest/features/pet/otter_geometry.dart';
import 'package:ecoquest/features/pet/pet_art.dart';
import 'package:ecoquest/features/wardrobe/cosmetic_art.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final _outDir = Platform.environment['ECOQUEST_RENDER_DIR'];
const _cream = Color(0xFFF6F3E8);

Future<void> _shoot(
  WidgetTester tester,
  String name,
  Size size,
  Widget child, {
  Color background = _cream,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  final key = GlobalKey();
  await tester.pumpWidget(Directionality(
    textDirection: TextDirection.ltr,
    child: RepaintBoundary(
      key: key,
      child: ColoredBox(color: background, child: child),
    ),
  ));
  await tester.pump();
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_outDir/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
  });
}

Widget _cell(Widget child, {double width = 300, double height = 420}) =>
    SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FittedBox(child: child),
      ),
    );

void main() {
  testWidgets('render pet sheets', (tester) async {
    addTearDown(tester.view.reset);
    Directory(_outDir!).createSync(recursive: true);
    final catalog = CosmeticCatalog.fromJson(
      (jsonDecode(File(cosmeticContentAsset).readAsStringSync()) as Map)
          .cast<String, Object?>(),
    );
    const box = OtterGeometry.viewBox;

    await _shoot(
      tester,
      'hero',
      const Size(1024, 1536),
      Stack(children: [
        Positioned.fromRect(
          rect: box,
          child: const FittedBox(
            fit: BoxFit.fill,
            child: PetArt(stage: PetStage.adult, mood: PetMood.happy),
          ),
        ),
      ]),
      background: const Color(0xFF000000),
    );

    const stages = [PetStage.baby, PetStage.young, PetStage.adult];
    await _shoot(
      tester,
      'moods',
      const Size(1500, 1260),
      Column(children: [
        for (final stage in stages)
          Row(children: [
            for (final mood in PetMood.values) _cell(PetArt(stage: stage, mood: mood)),
            _cell(PetArt(stage: stage, mood: PetMood.sad, dirty: true)),
            _cell(PetArt(
              stage: stage,
              mood: PetMood.ok,
              pose: const OtterPose(eyesOpen: 0),
            )),
          ]),
      ]),
    );

    final items = catalog.items;
    File('$_outDir/outfits.txt').writeAsStringSync([
      for (var i = 0; i < items.length; i++)
        '${i + 1}. ${items[i].id} (${items[i].slot.id}, ${items[i].rarity.id})',
    ].join('\n'));
    const perRow = 6;
    await _shoot(
      tester,
      'outfits',
      Size(perRow * 240.0, (items.length / perRow).ceil() * 336.0),
      Wrap(children: [
        for (final item in items)
          _cell(
            PetArt(
              stage: PetStage.adult,
              mood: PetMood.happy,
              outfit: {item.slot: item},
            ),
            width: 240,
            height: 336,
          ),
      ]),
    );

    final rows = [
      for (final rarity in CosmeticRarity.values)
        {
          for (final slot in CosmeticSlot.values)
            slot: ?items
                .where((i) => i.slot == slot && i.rarity.index <= rarity.index)
                .lastOrNull,
        },
    ];
    await _shoot(
      tester,
      'full',
      Size(rows.length * 240.0, 336),
      Row(children: [
        for (final outfit in rows)
          _cell(
            PetArt(stage: PetStage.adult, mood: PetMood.happy, outfit: outfit),
            width: 240,
            height: 336,
          ),
      ]),
    );

    await _shoot(
      tester,
      'thumbs',
      Size(items.length * 76.0 + 40, 560),
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: CosmeticThumbnail(item: item),
                ),
            ]),
            const SizedBox(height: 20),
            Wrap(spacing: 20, children: [
              for (final item in items.take(10))
                CosmeticThumbnail(item: item, size: 120),
            ]),
          ],
        ),
      ),
    );
  }, skip: _outDir == null);
}
