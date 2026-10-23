// Paints every cosmetic over the reference picture, in otter coordinates,
// to check where each item sits on the real otter. Skipped in normal test
// runs.
//
//   ECOQUEST_RENDER_DIR=/some/folder flutter test test/tools/render_items_on_reference_test.dart
//
// Files written:
//   default.png       the reference with the default leaf and bandana (and
//                     the leaf's shadow) drawn on top: they should cover
//                     the originals exactly
//   default_only.png  the default leaf and bandana alone on black, same size
//                     as the reference, for an overlay comparison
//   <item id>.png     the reference with that item on top (paws items get
//                     the reference front paws drawn again over them, as
//                     the pet painter does)
//   sheet.png         all of the above, cropped to the otter and scaled down
//                     (order in sheet.txt)
//   bounds.txt        each drawing's bounds next to the box of the pixels it
//                     really paints (thumbnails frame the bounds)
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:ecoquest/data/content/cosmetic_content.dart';
import 'package:ecoquest/domain/models/cosmetic_item.dart';
import 'package:ecoquest/features/pet/otter_geometry.dart';
import 'package:ecoquest/features/wardrobe/cosmetic_art.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

final _outDir = Platform.environment['ECOQUEST_RENDER_DIR'];
const _referencePath = 'docs/art/otter_reference.jpg';
const _width = 1024;
const _height = 1536;

/// Roughly where the pet painter draws the front paws over a paws item.
final _frontPaws = Path()
  ..addOval(Rect.fromCenter(
      center: const Offset(424, 1318), width: 124, height: 140))
  ..addOval(Rect.fromCenter(
      center: const Offset(556, 1318), width: 128, height: 140));

Future<ui.Image> _draw(void Function(Canvas canvas) paint,
    {int width = _width, int height = _height}) {
  final recorder = ui.PictureRecorder();
  paint(Canvas(recorder));
  return recorder.endRecording().toImage(width, height);
}

Future<void> _save(ui.Image image, String name) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  File('$_outDir/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
}

/// The box around the pixels [drawing] paints (alpha above a few percent).
Future<Rect?> _paintedBox(CosmeticDrawing drawing, Color color) async {
  final image = await _draw((canvas) => drawing.paint(canvas, color));
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final bytes = data!.buffer.asUint8List();
  var (left, top, right, bottom) = (_width, _height, -1, -1);
  for (var y = 0; y < _height; y++) {
    for (var x = 0; x < _width; x++) {
      if (bytes[(y * _width + x) * 4 + 3] > 10) {
        if (x < left) left = x;
        if (x > right) right = x;
        if (y < top) top = y;
        if (y > bottom) bottom = y;
      }
    }
  }
  if (right < 0) return null;
  return Rect.fromLTRB(left.toDouble(), top.toDouble(), right + 1.0,
      bottom + 1.0);
}

String _rect(Rect r) => '(${r.left.round()}, ${r.top.round()})-'
    '(${r.right.round()}, ${r.bottom.round()})';

void main() {
  testWidgets('render items on the reference', (tester) async {
    Directory(_outDir!).createSync(recursive: true);
    final catalog = CosmeticCatalog.fromJson(
      (jsonDecode(File(cosmeticContentAsset).readAsStringSync()) as Map)
          .cast<String, Object?>(),
    );
    final leaf = cosmeticDrawing('leaf', CosmeticSlot.head);
    final bandana = cosmeticDrawing('bandana', CosmeticSlot.neck);

    await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(
          File(_referencePath).readAsBytesSync());
      final reference = (await codec.getNextFrame()).image;
      final plain = Paint();

      final shots = <(String, ui.Image)>[];
      Future<void> shoot(String name, void Function(Canvas) paint) async {
        final image = await _draw(paint);
        await _save(image, name);
        shots.add((name, image));
      }

      await shoot('default', (canvas) {
        canvas.drawImage(reference, Offset.zero, plain);
        leaf.paintOnOtter(canvas, OtterPalette.leaf);
        bandana.paintOnOtter(canvas, OtterPalette.bandana);
      });
      await _save(
        await _draw((canvas) {
          canvas.drawColor(const Color(0xFF000000), BlendMode.src);
          leaf.paint(canvas, OtterPalette.leaf);
          bandana.paint(canvas, OtterPalette.bandana);
        }),
        'default_only',
      );

      for (final item in catalog.items) {
        await shoot(item.id, (canvas) {
          canvas.drawImage(reference, Offset.zero, plain);
          paintCosmetic(canvas, item);
          if (item.slot == CosmeticSlot.paws) {
            canvas
              ..save()
              ..clipPath(_frontPaws)
              ..drawImage(reference, Offset.zero, plain)
              ..restore();
          }
        });
      }

      // Contact sheet: each picture cropped to the otter, scaled down.
      const box = OtterGeometry.viewBox;
      const scale = 0.3;
      const perRow = 6;
      final cellW = box.width * scale;
      final cellH = box.height * scale;
      final rows = (shots.length / perRow).ceil();
      await _save(
        await _draw(
          (canvas) {
            for (var i = 0; i < shots.length; i++) {
              final cell = Rect.fromLTWH((i % perRow) * cellW,
                  (i ~/ perRow) * cellH, cellW, cellH);
              canvas.drawImageRect(shots[i].$2, box, cell.deflate(4),
                  Paint()..filterQuality = FilterQuality.medium);
            }
          },
          width: (perRow * cellW).ceil(),
          height: (rows * cellH).ceil(),
        ),
        'sheet',
      );
      File('$_outDir/sheet.txt').writeAsStringSync([
        for (var i = 0; i < shots.length; i++) '${i + 1}. ${shots[i].$1}',
      ].join('\n'));

      // Bounds against the painted pixels.
      final lines = <String>[];
      final drawn = <String>{};
      for (final (key, slot, color) in [
        ('leaf', CosmeticSlot.head, OtterPalette.leaf),
        ('bandana', CosmeticSlot.neck, OtterPalette.bandana),
        for (final item in catalog.items)
          (item.icon, item.slot, Color(item.color)),
      ]) {
        if (!drawn.add(key)) continue;
        final drawing = cosmeticDrawing(key, slot);
        final painted = await _paintedBox(drawing, color);
        final b = drawing.bounds;
        lines.add('$key: bounds ${_rect(b)}, painted '
            '${painted == null ? 'nothing' : _rect(painted)}'
            '${painted == null ? '' : ', delta '
                '(${(painted.left - b.left).round()}, '
                '${(painted.top - b.top).round()}, '
                '${(painted.right - b.right).round()}, '
                '${(painted.bottom - b.bottom).round()})'}');
      }
      File('$_outDir/bounds.txt').writeAsStringSync(lines.join('\n'));
    });
  }, skip: _outDir == null);
}
