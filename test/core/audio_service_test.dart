import 'package:ecoquest/core/audio/audio_catalog.dart';
import 'package:ecoquest/core/audio/audio_service.dart';
import 'package:ecoquest/core/audio/sound_id.dart';
import 'package:ecoquest/domain/models/audio_settings.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_audio_backend.dart';

/// A catalog with a file for some ids only, like the real one.
const _catalog = AudioCatalog({
  SoundId.quizCorrect: 'assets/a/correct.mp3',
  SoundId.quizIncorrect: 'assets/a/soft.mp3',
  SoundId.levelUp: 'assets/a/level.mp3',
  SoundId.petFeed: 'assets/a/feed.mp3',
  SoundId.musicMain: 'assets/a/music.mp3',
  SoundId.ambienceSea: 'assets/a/sea.mp3',
});

void main() {
  late FakeAudioBackend backend;
  late AudioService audio;

  /// Runs [body] with fake time: timers and the cooldown clock only move
  /// when the test calls `async.elapse`.
  void withService(void Function(FakeAsync async) body) {
    fakeAsync((async) {
      backend = FakeAudioBackend();
      audio = AudioService(
        backend: backend,
        catalog: _catalog,
        elapsed: () => async.elapsed,
      );
      body(async);
      audio.dispose();
      async.flushMicrotasks();
    });
  }

  test('a sound plays once at its channel volume', () {
    withService((async) {
      audio.play(SoundId.quizCorrect);
      audio.play(SoundId.petFeed);

      expect(backend.calls, [
        'once assets/a/correct.mp3 0.80', // effects 80
        'once assets/a/feed.mp3 0.60', // pet 60
      ]);
    });
  });

  test('a sound without a file stays silent (no error)', () {
    withService((async) {
      expect(_catalog.assetFor(SoundId.uiTap), isNull);
      audio.play(SoundId.uiTap);
      async.flushMicrotasks();

      expect(backend.calls, isEmpty);
    });
  });

  test('master mute silences effects, pet and loops; unmute brings the '
      'loop back', () {
    withService((async) {
      audio.applySettings(AudioSettings.defaults.withMuted(true));
      audio.play(SoundId.quizCorrect);
      audio.play(SoundId.levelUp);
      audio.play(SoundId.petFeed);
      audio.startLoop(SoundId.musicMain);
      expect(backend.calls, isEmpty);

      audio.applySettings(AudioSettings.defaults);
      expect(backend.calls, ['loop music assets/a/music.mp3 0.35']);
    });
  });

  test('a channel at 0 is silent, the others still play', () {
    withService((async) {
      audio.applySettings(
          AudioSettings.defaults.withVolume(AudioChannel.effects, 0));
      audio.play(SoundId.quizCorrect);
      audio.play(SoundId.petFeed);

      expect(backend.calls, ['once assets/a/feed.mp3 0.60']);
    });
  });

  test('the same sound twice in a row plays once; later it plays again', () {
    withService((async) {
      audio.play(SoundId.quizCorrect);
      async.elapse(const Duration(milliseconds: 30));
      audio.play(SoundId.quizCorrect); // same event reported twice
      audio.play(SoundId.quizIncorrect); // a different sound is fine
      async.elapse(const Duration(milliseconds: 100));
      audio.play(SoundId.quizCorrect); // a new correct answer

      expect(backend.calls.where((c) => c.contains('correct.mp3')).length, 2);
      expect(backend.calls.where((c) => c.contains('soft.mp3')).length, 1);
    });
  });

  test('asking for the playing loop again does not restart it', () {
    withService((async) {
      audio.startLoop(SoundId.musicMain);
      audio.startLoop(SoundId.musicMain); // e.g. another screen opens

      expect(backend.calls, ['loop music assets/a/music.mp3 0.35']);
    });
  });

  test('music and ambience loop side by side; stopping one keeps the other',
      () {
    withService((async) {
      audio.startLoop(SoundId.musicMain);
      audio.startLoop(SoundId.ambienceSea);
      audio.stopLoop(AudioChannel.music);

      expect(backend.calls, [
        'loop music assets/a/music.mp3 0.35',
        'loop pet assets/a/sea.mp3 0.60',
        'stop music',
      ]);
    });
  });

  test('volume changes reach a playing loop at once', () {
    withService((async) {
      audio.startLoop(SoundId.ambienceSea);
      audio.applySettings(
          AudioSettings.defaults.withVolume(AudioChannel.pet, 30));

      expect(backend.calls.last, 'volume pet 0.30');
    });
  });

  test('background: loops pause, sounds are dropped (never replayed later); '
      'back in front: loops resume', () {
    withService((async) {
      audio.startLoop(SoundId.musicMain);
      audio.setForeground(false);
      audio.play(SoundId.quizCorrect);
      audio.setForeground(true);

      expect(backend.calls, [
        'loop music assets/a/music.mp3 0.35',
        'pause music',
        'resume music',
      ]);
    });
  });

  test('a loop asked for in the background starts only in front', () {
    withService((async) {
      audio.setForeground(false);
      audio.startLoop(SoundId.ambienceSea);
      expect(backend.calls, isEmpty);

      audio.setForeground(true);
      expect(backend.calls, ['loop pet assets/a/sea.mp3 0.60']);
    });
  });

  test('important sounds duck the music, which then comes back smoothly',
      () {
    withService((async) {
      audio.startLoop(SoundId.musicMain);
      audio.play(SoundId.levelUp);

      expect(audio.isDucking, isTrue);
      expect(backend.calls.sublist(1, 3),
          ['volume music 0.10', 'once assets/a/level.mp3 0.80']);

      async.elapse(const Duration(milliseconds: 499));
      expect(backend.calls.last, 'once assets/a/level.mp3 0.80'); // holding

      async.elapse(const Duration(milliseconds: 400));
      expect(audio.isDucking, isFalse);
      final steps = backend.calls.where((c) => c.startsWith('volume'));
      expect(steps.length, 1 + 6); // down at once, up in 6 steps
      expect(backend.calls.last, 'volume music 0.35');
    });
  });

  test('a normal sound does not duck the music', () {
    withService((async) {
      audio.startLoop(SoundId.musicMain);
      audio.play(SoundId.quizCorrect);

      expect(audio.isDucking, isFalse);
      expect(backend.calls.where((c) => c.startsWith('volume')), isEmpty);
    });
  });

  test('a second important sound while ducked keeps the music low longer',
      () {
    withService((async) {
      audio.startLoop(SoundId.musicMain);
      audio.play(SoundId.levelUp);
      async.elapse(const Duration(milliseconds: 400));
      audio.play(SoundId.levelUp); // after the cooldown: a new level-up
      async.elapse(const Duration(milliseconds: 400));

      expect(audio.isDucking, isTrue); // 800 ms after the first, still low
      async.elapse(const Duration(milliseconds: 500));
      expect(audio.isDucking, isFalse);
    });
  });

  test('playAny plays the first sound that has a file', () {
    withService((async) {
      audio.playAny([SoundId.quizStreak1, SoundId.quizCorrect]); // no note
      audio.playAny([SoundId.uiTap]); // nothing at all: silent

      expect(backend.calls, ['once assets/a/correct.mp3 0.80']);
    });
  });

  test('playSequence plays one sound after the other, never together; '
      'silent ids leave no gap', () {
    withService((async) {
      audio.playSequence(
          [SoundId.levelUp, SoundId.rewardCoins, SoundId.quizCorrect]);
      expect(backend.played, ['level.mp3']);

      async.elapse(const Duration(milliseconds: 699));
      expect(backend.played, ['level.mp3']);
      async.elapse(const Duration(milliseconds: 1));
      expect(backend.played, ['level.mp3', 'correct.mp3']); // coins skipped
    });
  });

  test('a pending sequence is dropped when the service is disposed', () {
    withService((async) {
      audio.playSequence([SoundId.levelUp, SoundId.quizCorrect]);
      audio.dispose();
      async.elapse(const Duration(seconds: 2));

      expect(backend.played, ['level.mp3']);
    });
  });

  test('a broken file never throws and is not tried again', () {
    withService((async) {
      backend.failing.add('assets/a/correct.mp3');
      audio.play(SoundId.quizCorrect);
      async.flushMicrotasks(); // the failure arrives
      async.elapse(const Duration(seconds: 1));
      audio.play(SoundId.quizCorrect);
      audio.play(SoundId.quizIncorrect);

      expect(backend.calls, [
        'once assets/a/correct.mp3 0.80',
        'once assets/a/soft.mp3 0.80',
      ]);
    });
  });
}
