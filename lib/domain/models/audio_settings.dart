import 'json_utils.dart';

/// The three sound channels, each with its own volume.
enum AudioChannel {
  /// Calm background music.
  music('music'),

  /// Buttons, quiz feedback, recycling, rewards.
  effects('effects'),

  /// Pet voice and room ambience (sea, forest, ...).
  pet('pet');

  const AudioChannel(this.id);

  /// Stable id used in the save file.
  final String id;
}

/// The player's sound preferences, saved inside GameState.
///
/// Volumes are whole percentages (0–100): easy to save, to show on a
/// slider and to read out by a screen reader ("80 percento").
class AudioSettings {
  const AudioSettings({
    this.muted = false,
    this.musicVolume = 35,
    this.effectsVolume = 80,
    this.petVolume = 60,
  });

  /// Music quieter than effects, so feedback is always heard over it.
  static const defaults = AudioSettings();

  /// Master mute: silences every channel, rewards and pet included.
  final bool muted;
  final int musicVolume;
  final int effectsVolume;
  final int petVolume;

  int volumeOf(AudioChannel channel) => switch (channel) {
        AudioChannel.music => musicVolume,
        AudioChannel.effects => effectsVolume,
        AudioChannel.pet => petVolume,
      };

  /// The volume to play [channel] at, 0.0–1.0 (0 when muted).
  double gainOf(AudioChannel channel) =>
      muted ? 0 : volumeOf(channel) / 100;

  AudioSettings withVolume(AudioChannel channel, int volume) {
    final value = _clamp(volume);
    return AudioSettings(
      muted: muted,
      musicVolume: channel == AudioChannel.music ? value : musicVolume,
      effectsVolume: channel == AudioChannel.effects ? value : effectsVolume,
      petVolume: channel == AudioChannel.pet ? value : petVolume,
    );
  }

  AudioSettings withMuted(bool muted) => AudioSettings(
        muted: muted,
        musicVolume: musicVolume,
        effectsVolume: effectsVolume,
        petVolume: petVolume,
      );

  static int _clamp(int volume) => volume.clamp(0, 100);

  Json toJson() => {
        'muted': muted,
        'musicVolume': musicVolume,
        'effectsVolume': effectsVolume,
        'petVolume': petVolume,
      };

  /// Missing values (older saves) fall back to the defaults.
  factory AudioSettings.fromJson(Json json) => AudioSettings(
        muted: readBool(json, 'muted'),
        musicVolume: _clamp(
            readInt(json, 'musicVolume', fallback: defaults.musicVolume)),
        effectsVolume: _clamp(
            readInt(json, 'effectsVolume', fallback: defaults.effectsVolume)),
        petVolume:
            _clamp(readInt(json, 'petVolume', fallback: defaults.petVolume)),
      );

  @override
  bool operator ==(Object other) =>
      other is AudioSettings &&
      other.muted == muted &&
      other.musicVolume == musicVolume &&
      other.effectsVolume == effectsVolume &&
      other.petVolume == petVolume;

  @override
  int get hashCode => Object.hash(muted, musicVolume, effectsVolume, petVolume);
}
