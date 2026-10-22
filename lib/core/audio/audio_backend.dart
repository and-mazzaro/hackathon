import '../../domain/models/audio_settings.dart';

/// The thin layer that really makes noise. [AudioService] decides WHAT to
/// play and how loud; the backend only talks to the audio library.
///
/// Tests use a fake backend that records calls, so they never need real
/// audio output. Paths are full asset paths (`assets/audio/...`); volumes
/// are 0.0–1.0.
abstract interface class AudioBackend {
  /// Plays a short sound once. Several can overlap.
  Future<void> playOnce(String asset, double volume);

  /// Starts a looping sound in the slot of [channel] (one loop per
  /// channel), replacing what was there.
  Future<void> startLoop(AudioChannel channel, String asset, double volume);

  Future<void> setLoopVolume(AudioChannel channel, double volume);
  Future<void> pauseLoop(AudioChannel channel);
  Future<void> resumeLoop(AudioChannel channel);
  Future<void> stopLoop(AudioChannel channel);

  /// Frees every player. Nothing plays afterwards.
  Future<void> dispose();
}
