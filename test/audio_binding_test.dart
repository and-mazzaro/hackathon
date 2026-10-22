import 'package:ecoquest/app/app.dart';
import 'package:ecoquest/core/audio/audio_service.dart';
import 'package:ecoquest/core/audio/sound_id.dart';
import 'package:ecoquest/data/save/in_memory_save_repository.dart';
import 'package:ecoquest/domain/game_controller.dart';
import 'package:ecoquest/domain/models/audio_settings.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_audio_backend.dart';
import 'helpers/pump_app.dart';

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(EcoQuestApp)));

/// Walks the app through the real lifecycle steps, like Android does.
void _setLifecycle(WidgetTester tester, List<AppLifecycleState> states) {
  for (final state in states) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
}

void main() {
  testWidgets('saved sound settings reach the audio service at start',
      (tester) async {
    const quiet = AudioSettings(muted: true, effectsVolume: 40);
    await pumpEcoQuestApp(tester,
        repository:
            InMemorySaveRepository(onboardedState().copyWith(audio: quiet)));

    expect(_container(tester).read(audioServiceProvider).settings, quiet);
  });

  testWidgets('changed settings apply at once, without a restart',
      (tester) async {
    await pumpEcoQuestApp(tester);
    final container = _container(tester);

    await container
        .read(gameControllerProvider.notifier)
        .updateAudioSettings(AudioSettings.defaults.withMuted(true));
    await tester.pump();

    expect(container.read(audioServiceProvider).settings.muted, isTrue);
  });

  testWidgets('the ambience loop pauses in the background and resumes after',
      (tester) async {
    final backend = FakeAudioBackend();
    await pumpEcoQuestApp(tester, audioBackend: backend);
    _container(tester).read(audioServiceProvider).startLoop(SoundId.ambienceSea);

    _setLifecycle(tester, [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]);
    _setLifecycle(tester, [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]);

    expect(backend.calls, [
      'loop pet assets/audio/ambience/sea_waves.mp3 0.60',
      'pause pet',
      'resume pet',
    ]);
  });

  testWidgets('starting the app plays nothing by itself', (tester) async {
    final backend = FakeAudioBackend();
    await pumpEcoQuestApp(tester, audioBackend: backend);

    expect(backend.calls, isEmpty);
  });
}
