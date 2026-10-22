import 'package:audioplayers/audioplayers.dart';

import '../../domain/models/audio_settings.dart';
import 'audio_backend.dart';

/// [AudioBackend] on top of the `audioplayers` package (Android + iOS).
///
/// - Short sounds share a small, fixed set of players (round robin), so
///   rapid taps never create unlimited players: the oldest one is reused.
/// - Each loop channel (music, pet/ambience) has its own player.
/// - Players are created lazily: nothing touches the platform until the
///   first sound actually plays.
class AudioplayersBackend implements AudioBackend {
  AudioplayersBackend({this.maxEffectPlayers = 4});

  final int maxEffectPlayers;

  final List<AudioPlayer> _effectPlayers = [];
  int _nextEffect = 0;
  final Map<AudioChannel, AudioPlayer> _loopPlayers = {};
  Future<void>? _setup;

  /// "Ambient" audio: mixes with the player's own music instead of
  /// stopping it, and on iOS follows the silent switch.
  static final _context = AudioContext(
    android: const AudioContextAndroid(
      usageType: AndroidUsageType.game,
      contentType: AndroidContentType.sonification,
      audioFocus: AndroidAudioFocus.none,
    ),
    iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
  );

  Future<void> _ensureSetup() =>
      _setup ??= AudioPlayer.global.setAudioContext(_context);

  /// audioplayers looks for assets under `assets/` by itself.
  static AssetSource _source(String asset) => AssetSource(
      asset.startsWith('assets/') ? asset.substring('assets/'.length) : asset);

  AudioPlayer _effectPlayer() {
    if (_effectPlayers.length < maxEffectPlayers) {
      final player = AudioPlayer();
      _effectPlayers.add(player);
      return player;
    }
    final player = _effectPlayers[_nextEffect];
    _nextEffect = (_nextEffect + 1) % maxEffectPlayers;
    return player;
  }

  @override
  Future<void> playOnce(String asset, double volume) async {
    await _ensureSetup();
    final player = _effectPlayer();
    await player.stop();
    await player.play(_source(asset),
        volume: volume, mode: PlayerMode.lowLatency);
  }

  @override
  Future<void> startLoop(
      AudioChannel channel, String asset, double volume) async {
    await _ensureSetup();
    final player = _loopPlayers[channel] ??= AudioPlayer();
    await player.stop();
    await player.setReleaseMode(ReleaseMode.loop);
    await player.play(_source(asset), volume: volume);
  }

  @override
  Future<void> setLoopVolume(AudioChannel channel, double volume) async =>
      _loopPlayers[channel]?.setVolume(volume);

  @override
  Future<void> pauseLoop(AudioChannel channel) async =>
      _loopPlayers[channel]?.pause();

  @override
  Future<void> resumeLoop(AudioChannel channel) async =>
      _loopPlayers[channel]?.resume();

  @override
  Future<void> stopLoop(AudioChannel channel) async =>
      _loopPlayers[channel]?.stop();

  @override
  Future<void> dispose() async {
    for (final player in [..._effectPlayers, ..._loopPlayers.values]) {
      await player.dispose();
    }
    _effectPlayers.clear();
    _loopPlayers.clear();
  }
}
