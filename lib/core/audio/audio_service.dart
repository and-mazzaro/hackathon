import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/audio_settings.dart';
import 'audio_backend.dart';
import 'audio_catalog.dart';
import 'audioplayers_backend.dart';
import 'sound_id.dart';

/// Timing of music ducking and repeat protection. Tests and play-testers
/// can change these numbers without touching the service.
class AudioTiming {
  const AudioTiming({
    this.duckLevel = 0.3,
    this.duckHold = const Duration(milliseconds: 500),
    this.duckRelease = const Duration(milliseconds: 300),
    this.duckSteps = 6,
    this.repeatCooldown = const Duration(milliseconds: 80),
  });

  /// Music volume during an important sound, as a share of normal.
  final double duckLevel;

  /// How long the music stays low.
  final Duration duckHold;

  /// How long the music takes to come back (in [duckSteps] small steps).
  final Duration duckRelease;
  final int duckSteps;

  /// The same sound asked for again within this time plays only once
  /// (e.g. two events for one tap).
  final Duration repeatCooldown;
}

/// The one place that decides what is heard.
///
/// Screens ask for sounds by meaning ([play], [startLoop]); this service
/// applies the player's settings (master mute, three channel volumes),
/// ducks the music for important moments, ignores duplicates, pauses loops
/// in the background and swallows every audio error, so a missing or broken
/// file can never crash the game. Sound is always an extra: everything it
/// says is also shown on screen and read by screen readers.
class AudioService {
  AudioService({
    required this.backend,
    required this.catalog,
    this.timing = const AudioTiming(),
    Duration Function()? elapsed,
  }) : _elapsed = elapsed ?? (Stopwatch()..start()).elapsedFunction;

  final AudioBackend backend;
  final AudioCatalog catalog;
  final AudioTiming timing;
  final Duration Function() _elapsed;

  AudioSettings _settings = AudioSettings.defaults;
  bool _foreground = true;

  /// The loop each channel should play (set by [startLoop]).
  final Map<AudioChannel, SoundId> _wantedLoops = {};

  /// The loop each channel's player currently holds, and whether paused.
  final Map<AudioChannel, SoundId> _activeLoops = {};
  final Set<AudioChannel> _pausedLoops = {};
  final Map<AudioChannel, double> _loopVolumes = {};

  final Map<SoundId, Duration> _lastPlayed = {};
  final Set<String> _brokenAssets = {};

  double _duckFactor = 1;
  Timer? _duckHoldTimer;
  Timer? _duckReleaseTimer;

  AudioSettings get settings => _settings;

  /// Whether the music is currently lowered for an important sound.
  bool get isDucking => _duckFactor < 1;

  void applySettings(AudioSettings settings) {
    if (settings == _settings) return;
    _settings = settings;
    _syncLoops();
  }

  /// Called by the app lifecycle: loops pause in the background. Short
  /// sounds are never queued or replayed later.
  void setForeground(bool foreground) {
    if (foreground == _foreground) return;
    _foreground = foreground;
    _syncLoops();
  }

  /// Plays a short sound once. Silent when the sound has no file, its
  /// channel is muted, the app is in the background or the same sound
  /// just played.
  void play(SoundId id) {
    assert(!id.loops, '${id.key} is a loop: use startLoop');
    if (!_foreground) return;
    final volume = _settings.gainOf(id.channel);
    if (volume == 0) return;
    final asset = catalog.assetFor(id);
    if (asset == null || _brokenAssets.contains(asset)) return;

    final now = _elapsed();
    final last = _lastPlayed[id];
    if (last != null && now - last < timing.repeatCooldown) return;
    _lastPlayed[id] = now;

    if (id.ducksMusic) _duckMusic();
    _safely(asset, () => backend.playOnce(asset, volume));
  }

  /// Starts a music or ambience loop. Asking for the loop that is already
  /// playing changes nothing (no restart when changing screens).
  void startLoop(SoundId id) {
    assert(id.loops, '${id.key} plays once: use play');
    _wantedLoops[id.channel] = id;
    _syncLoops();
  }

  void stopLoop(AudioChannel channel) {
    _wantedLoops.remove(channel);
    _syncLoops();
  }

  /// Brings every loop in line with what is wanted and allowed now.
  void _syncLoops() {
    for (final channel in AudioChannel.values) {
      final wanted = _wantedLoops[channel];
      final active = _activeLoops[channel];
      final asset = wanted == null ? null : catalog.assetFor(wanted);

      if (active != null && active != wanted) {
        _activeLoops.remove(channel);
        _pausedLoops.remove(channel);
        _loopVolumes.remove(channel);
        _safely(null, () => backend.stopLoop(channel));
      }
      if (wanted == null || asset == null || _brokenAssets.contains(asset)) {
        continue;
      }

      final volume = _loopVolume(channel);
      final audible = _foreground && volume > 0;
      if (!_activeLoops.containsKey(channel)) {
        if (!audible) continue; // start it later, when it can be heard
        _activeLoops[channel] = wanted;
        _loopVolumes[channel] = volume;
        _safely(asset, () => backend.startLoop(channel, asset, volume));
      } else if (!audible) {
        if (_pausedLoops.add(channel)) {
          _safely(null, () => backend.pauseLoop(channel));
        }
      } else {
        _setLoopVolume(channel, volume);
        if (_pausedLoops.remove(channel)) {
          _safely(null, () => backend.resumeLoop(channel));
        }
      }
    }
  }

  double _loopVolume(AudioChannel channel) {
    final gain = _settings.gainOf(channel);
    return channel == AudioChannel.music ? gain * _duckFactor : gain;
  }

  void _setLoopVolume(AudioChannel channel, double volume) {
    if (_loopVolumes[channel] == volume) return;
    _loopVolumes[channel] = volume;
    _safely(null, () => backend.setLoopVolume(channel, volume));
  }

  /// Lowers the music at once, holds it, then brings it back smoothly.
  /// A new important sound during a duck simply extends it.
  void _duckMusic() {
    _duckHoldTimer?.cancel();
    _duckReleaseTimer?.cancel();
    _setDuckFactor(timing.duckLevel);
    _duckHoldTimer = Timer(timing.duckHold, () {
      var step = 0;
      final steps = timing.duckSteps;
      _duckReleaseTimer = Timer.periodic(timing.duckRelease ~/ steps, (timer) {
        step++;
        if (step >= steps) {
          timer.cancel();
          _setDuckFactor(1); // exactly back, no rounding left over
        } else {
          _setDuckFactor(
              timing.duckLevel + (1 - timing.duckLevel) * step / steps);
        }
      });
    });
  }

  void _setDuckFactor(double factor) {
    _duckFactor = factor;
    if (_activeLoops.containsKey(AudioChannel.music) &&
        !_pausedLoops.contains(AudioChannel.music)) {
      _setLoopVolume(AudioChannel.music, _loopVolume(AudioChannel.music));
    }
  }

  /// Runs a backend call without ever letting an error reach the game.
  /// A file that fails is not tried again in this session.
  void _safely(String? asset, Future<void> Function() action) {
    Future.sync(action).catchError((Object error) {
      if (asset != null) _brokenAssets.add(asset);
      debugPrint('Audio: ${asset ?? 'player'} failed: $error');
    });
  }

  void dispose() {
    _duckHoldTimer?.cancel();
    _duckReleaseTimer?.cancel();
  }
}

extension on Stopwatch {
  Duration Function() get elapsedFunction => () => elapsed;
}

/// The real audio library. Tests override this with a fake.
final audioBackendProvider = Provider<AudioBackend>((ref) {
  final backend = AudioplayersBackend();
  ref.onDispose(backend.dispose);
  return backend;
});

/// The game's sound system. Screens call `ref.read(audioServiceProvider)
/// .play(SoundId.quizCorrect)` when something HAPPENS (in an event handler),
/// never in `build`, so a rebuild can never replay a sound.
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService(
    backend: ref.watch(audioBackendProvider),
    catalog: ref.watch(audioCatalogProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});
