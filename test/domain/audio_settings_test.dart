import 'package:ecoquest/domain/models/audio_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults: sound on, music quieter than effects', () {
    const s = AudioSettings.defaults;

    expect(s.muted, isFalse);
    expect(s.musicVolume, 35);
    expect(s.effectsVolume, 80);
    expect(s.petVolume, 60);
    expect(s.musicVolume, lessThan(s.effectsVolume));
  });

  test('gain is the volume as 0.0–1.0, and 0 everywhere when muted', () {
    const s = AudioSettings.defaults;
    expect(s.gainOf(AudioChannel.effects), 0.8);
    expect(s.gainOf(AudioChannel.music), 0.35);

    final muted = s.withMuted(true);
    for (final channel in AudioChannel.values) {
      expect(muted.gainOf(channel), 0, reason: channel.id);
    }
    // Muting keeps the chosen volumes for when sound comes back.
    expect(muted.withMuted(false), s);
  });

  test('one channel changes, the others stay; volumes stay in 0–100', () {
    final s = AudioSettings.defaults.withVolume(AudioChannel.pet, 0);

    expect(s.petVolume, 0);
    expect(s.gainOf(AudioChannel.pet), 0);
    expect(s.effectsVolume, 80);
    expect(AudioSettings.defaults.withVolume(AudioChannel.music, 140)
        .musicVolume, 100);
    expect(AudioSettings.defaults.withVolume(AudioChannel.music, -5)
        .musicVolume, 0);
  });

  test('JSON round trip; missing or out-of-range values are repaired', () {
    const s = AudioSettings(
        muted: true, musicVolume: 10, effectsVolume: 55, petVolume: 0);
    expect(AudioSettings.fromJson(s.toJson()), s);

    expect(AudioSettings.fromJson(const {}), AudioSettings.defaults);
    expect(AudioSettings.fromJson(const {'musicVolume': 300}).musicVolume, 100);
  });
}
