import 'package:ecoquest/core/audio/audio_backend.dart';
import 'package:ecoquest/core/audio/audio_catalog.dart';
import 'package:ecoquest/core/audio/sound_id.dart';
import 'package:ecoquest/domain/models/audio_settings.dart';

/// A catalog with a (fake) file for EVERY sound id, so UI tests can check
/// which sound each event asks for: `test/sound/quiz.correct`, ...
AudioCatalog testAudioCatalog() =>
    AudioCatalog({for (final id in SoundId.values) id: 'test/sound/${id.key}'});

/// Records what the audio service asked for, instead of making noise.
/// Each call is one readable line, e.g. `once assets/x.mp3 0.8`.
class FakeAudioBackend implements AudioBackend {
  final List<String> calls = [];

  /// Assets whose playback should fail, to test error handling.
  final Set<String> failing = {};

  bool disposed = false;

  /// The short sounds played so far, by key (with [testAudioCatalog]),
  /// e.g. `['quiz.streak.1', 'quiz.question']`.
  List<String> get played => [
        for (final call in calls)
          if (call.startsWith('once ')) call.split(' ')[1].split('/').last,
      ];

  Future<void> _record(String call, [String? asset]) async {
    calls.add(call);
    if (asset != null && failing.contains(asset)) {
      throw Exception('cannot play $asset');
    }
  }

  @override
  Future<void> playOnce(String asset, double volume) =>
      _record('once $asset ${_v(volume)}', asset);

  @override
  Future<void> startLoop(AudioChannel channel, String asset, double volume) =>
      _record('loop ${channel.id} $asset ${_v(volume)}', asset);

  @override
  Future<void> setLoopVolume(AudioChannel channel, double volume) =>
      _record('volume ${channel.id} ${_v(volume)}');

  @override
  Future<void> pauseLoop(AudioChannel channel) =>
      _record('pause ${channel.id}');

  @override
  Future<void> resumeLoop(AudioChannel channel) =>
      _record('resume ${channel.id}');

  @override
  Future<void> stopLoop(AudioChannel channel) => _record('stop ${channel.id}');

  @override
  Future<void> dispose() async => disposed = true;

  static String _v(double volume) => volume.toStringAsFixed(2);
}
