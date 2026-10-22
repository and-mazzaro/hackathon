import 'dart:io';

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

  test('sound ids have unique keys', () {
    final keys = SoundId.values.map((id) => id.key).toList();
    expect(keys.toSet().length, keys.length);
  });

  test('sounds still without a file are listed (silent until added)', () {
    // Not a failure: a reminder of what is missing, shown in the log.
    // ignore: avoid_print
    print('Silent sound ids: ${catalog.missing.map((id) => id.key).join(', ')}');
    expect(catalog.missing, isNot(contains(SoundId.ambienceSea)));
  });
}
