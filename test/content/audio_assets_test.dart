import 'dart:io';
import 'dart:typed_data';

import 'package:ecoquest/core/audio/audio_catalog.dart';
import 'package:ecoquest/core/audio/sound_id.dart';
import 'package:flutter_test/flutter_test.dart';

/// Checks the REAL sound files against the catalog, pubspec.yaml and the
/// attribution list. Run `flutter test test/content` after adding a sound.
void main() {
  const catalog = AudioCatalog.ecoQuest;
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final attribution = File('assets/audio/ATTRIBUTION.md').readAsStringSync();

  test('every catalog file exists and is bundled by pubspec.yaml', () {
    catalog.assets.forEach((id, path) {
      expect(File(path).existsSync(), isTrue, reason: '${id.key}: $path');
      final folder = path.substring(0, path.lastIndexOf('/') + 1);
      expect(pubspec, contains('- $folder'),
          reason: '${id.key}: add "$folder" to the assets in pubspec.yaml');
    });
  });

  test('every file in assets/audio is in the catalog and has a licence row',
      () {
    final used = catalog.assets.values.toSet();
    final files = Directory('assets/audio')
        .listSync(recursive: true)
        .whereType<File>()
        .map((f) => f.path.replaceAll(r'\', '/'))
        .where((p) => !p.endsWith('.md'));

    for (final path in files) {
      expect(used, contains(path), reason: 'unused file bloats the app: $path');
      final name = path.substring('assets/audio/'.length);
      expect(attribution, contains('`$name`'),
          reason: '$path needs a row in assets/audio/ATTRIBUTION.md');
    }
  });

  test('short sounds are WAV (plays on iOS too), mono 44.1 kHz, and short',
      () {
    catalog.assets.forEach((id, path) {
      if (id.loops) return;
      expect(path, endsWith('.wav'), reason: '${id.key}: iOS cannot play OGG');
      final bytes = File(path).readAsBytesSync();
      final header = ByteData.sublistView(bytes, 0, 44);
      expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF', reason: path);
      expect(header.getUint16(22, Endian.little), 1, reason: '$path: mono');
      expect(header.getUint32(24, Endian.little), 44100, reason: path);
      final seconds =
          header.getUint32(40, Endian.little) / header.getUint32(28, Endian.little);
      // Feedback 0.1–0.6 s, rewards ~1–1.5 s: nothing drags on.
      expect(seconds, lessThanOrEqualTo(1.5), reason: '${id.key}: ${seconds}s');
    });
  });

  test('sound ids have unique keys', () {
    final keys = SoundId.values.map((id) => id.key).toList();
    expect(keys.toSet().length, keys.length);
  });

  test('sounds still without a file are listed (silent until added)', () {
    // Not a failure: a reminder of what is missing, shown in the log.
    // ignore: avoid_print
    print('Silent sound ids: ${catalog.missing.map((id) => id.key).join(', ')}');
    // Only the background music is still missing (no CC0 loop yet).
    expect(catalog.missing, [SoundId.musicMain]);
  });
}
