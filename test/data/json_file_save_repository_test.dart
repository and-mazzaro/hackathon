import 'dart:convert';
import 'dart:io';

import 'package:ecoquest/data/save/json_file_save_repository.dart';
import 'package:ecoquest/data/save/save_format.dart';
import 'package:ecoquest/data/save/save_repository.dart';
import 'package:ecoquest/domain/models/game_state.dart';
import 'package:ecoquest/domain/models/player_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 22, 10);
  late Directory dir;
  late JsonFileSaveRepository repository;

  File file(String name) => File('${dir.path}${Platform.pathSeparator}$name');
  File mainFile() => file(JsonFileSaveRepository.fileName);
  File backupFile() => file(JsonFileSaveRepository.backupName);

  GameState stateWithCoins(int coins) => GameState.initial(now: now)
      .copyWith(progress: PlayerProgress(coins: coins, totalXp: coins * 2));

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('ecoquest_save_test');
    repository =
        JsonFileSaveRepository(directory: () async => dir, clock: () => now);
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  test('first launch: nothing saved yet', () async {
    expect(await repository.load(), isNull);
  });

  test('save then load gives back the same game', () async {
    final state = stateWithCoins(42);
    await repository.save(state);

    final loaded = await repository.load();
    expect(loaded!.toJson(), state.toJson());
  });

  test('a new repository (= app restart) reads the same file', () async {
    await repository.save(stateWithCoins(7));

    final afterRestart =
        JsonFileSaveRepository(directory: () async => dir, clock: () => now);
    expect((await afterRestart.load())!.progress.coins, 7);
  });

  test('the file is versioned JSON and no temp file is left', () async {
    await repository.save(stateWithCoins(1));

    final json = jsonDecode(await mainFile().readAsString()) as Map;
    expect(json['version'], SaveFormat.currentVersion);
    expect(json['savedAt'], now.toIso8601String());
    expect(await file(JsonFileSaveRepository.tempName).exists(), isFalse);
  });

  test('the previous save is kept as a backup', () async {
    await repository.save(stateWithCoins(1));
    await repository.save(stateWithCoins(2));

    final backup = SaveFormat.decode(await backupFile().readAsString(), now: now);
    expect(backup.progress.coins, 1);
  });

  test('a broken save falls back to the backup', () async {
    await repository.save(stateWithCoins(1));
    await repository.save(stateWithCoins(2));
    await mainFile().writeAsString('{ this is not json');

    final loaded = await repository.load();
    expect(loaded!.progress.coins, 1);
    // The broken file was set aside, so the next save cannot copy it
    // over the good backup.
    expect(await mainFile().exists(), isFalse);
  });

  test('save and backup both broken → SaveCorruptedException', () async {
    await mainFile().writeAsString('garbage');
    await backupFile().writeAsString('{"version": 1, "state": {"progress": 5}}');

    await expectLater(
        repository.load(), throwsA(isA<SaveCorruptedException>()));

    // Broken files are kept for debugging, and a fresh start can save.
    final setAside = dir
        .listSync()
        .where((entity) => entity.path.contains('.corrupt-'))
        .length;
    expect(setAside, 2);
    await repository.save(stateWithCoins(3));
    expect((await repository.load())!.progress.coins, 3);
  });

  test('a save from a newer app version is refused, not overwritten',
      () async {
    final newer = jsonEncode({
      'version': SaveFormat.currentVersion + 1,
      'state': stateWithCoins(99).toJson(),
    });
    await mainFile().writeAsString(newer);

    await expectLater(
        repository.load(), throwsA(isA<SaveFromNewerAppException>()));
    expect(await mainFile().readAsString(), newer);
  });

  test('a missing or invalid version counts as broken', () async {
    await mainFile().writeAsString(jsonEncode({'state': {}}));

    await expectLater(
        repository.load(), throwsA(isA<SaveCorruptedException>()));
  });

  test('quick saves in a row are written in order; the last one wins',
      () async {
    final saves = [
      for (var coins = 1; coins <= 5; coins++)
        repository.save(stateWithCoins(coins)),
    ];
    await Future.wait(saves);

    expect((await repository.load())!.progress.coins, 5);
  });

  test('a leftover temp file from a crash is ignored', () async {
    await repository.save(stateWithCoins(4));
    await file(JsonFileSaveRepository.tempName).writeAsString('half writ');

    expect((await repository.load())!.progress.coins, 4);
    await repository.save(stateWithCoins(5));
    expect((await repository.load())!.progress.coins, 5);
  });
}
