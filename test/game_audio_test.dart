import 'package:ecoquest/core/widgets/eco_button.dart';
import 'package:ecoquest/data/save/in_memory_save_repository.dart';
import 'package:ecoquest/domain/models/audio_settings.dart';
import 'package:ecoquest/domain/models/game_state.dart';
import 'package:ecoquest/domain/models/pet_state.dart';
import 'package:ecoquest/domain/models/player_progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/fake_audio_backend.dart';
import 'helpers/pump_app.dart';

/// Every sound event of the real screens, checked with the fake backend
/// and a catalog that has a file for every id.

final _rightAnswer = find.textContaining(RegExp(r'^Giusta'));
final _wrongAnswer = find.textContaining(RegExp(r'^Sbagliata A'));
final _wasteItems = find.textContaining(RegExp(r'^Rifiuto '));
const _binFor = {
  'plastic_metal': 'Plastica e metalli',
  'paper': 'Carta e cartone',
  'organic': 'Organico',
  'glass': 'Vetro',
  'residual': 'Indifferenziato',
};

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _openQuiz(WidgetTester tester) async {
  await tapTab(tester, 'Impara');
  await scrollTo(tester, find.text('Oceani e vita marina'));
  await tester.tap(find.text('Oceani e vita marina'));
  await tester.pumpAndSettle();
}

GameState _hatched({int satiety = 40}) => onboardedState().copyWith(
      progress: const PlayerProgress(totalXp: 100),
      pet: PetState(
        name: 'Foglia',
        stage: PetStage.baby,
        satiety: satiety,
        happiness: 80,
        cleanliness: 80,
        needsUpdatedAt: testNow,
      ),
    );

void main() {
  testWidgets('quiz: notes climb with the streak, soft sound when wrong, '
      'swoosh for each question, jingle then XP at the end', (tester) async {
    final audio = FakeAudioBackend();
    await pumpEcoQuestApp(tester, audioBackend: audio);
    await _openQuiz(tester);
    audio.calls.clear(); // forget the tab tap

    await _tap(tester, _rightAnswer);
    await _tap(tester, find.widgetWithText(EcoButton, 'Avanti'));
    await _tap(tester, _rightAnswer);
    await _tap(tester, find.widgetWithText(EcoButton, 'Avanti'));
    await _tap(tester, _wrongAnswer);
    await _tap(tester, find.widgetWithText(EcoButton, 'Avanti'));
    await _tap(tester, _rightAnswer);
    expect(audio.played, [
      'quiz.streak.1', 'quiz.question', //
      'quiz.streak.2', 'quiz.question', //
      'quiz.incorrect', 'quiz.question', //
      'quiz.streak.1', // the streak starts again
    ]);

    await _tap(tester, find.widgetWithText(EcoButton, 'Avanti'));
    await _tap(tester, _rightAnswer);
    audio.calls.clear();
    await _tap(tester, find.widgetWithText(EcoButton, 'Vedi il risultato'));
    expect(audio.played, ['quiz.complete']);
    await tester.pump(const Duration(milliseconds: 700));
    expect(audio.played, ['quiz.complete', 'reward.xp']);
  });

  testWidgets('a second tap on an answer and later rebuilds stay silent',
      (tester) async {
    final audio = FakeAudioBackend();
    await pumpEcoQuestApp(tester, audioBackend: audio);
    await _openQuiz(tester);
    audio.calls.clear();

    await _tap(tester, _rightAnswer);
    await tester.tap(_rightAnswer, warnIfMissed: false); // tapped again
    await tester.pumpAndSettle();
    // Rebuilds (here: open and close the source sheet) replay nothing.
    await _tap(tester, find.text('Fonte: Fonte di prova'));
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(audio.played, ['quiz.streak.1']);
  });

  testWidgets('cleanup: pick up, right bin, combo, wrong bin, empty bin, '
      'then jingle and coins', (tester) async {
    final audio = FakeAudioBackend();
    await pumpEcoQuestApp(tester, audioBackend: audio);
    await scrollTo(tester, find.text('Pulisci la stanza'));
    await tester.tap(find.text('Pulisci la stanza'));
    await tester.pumpAndSettle();
    audio.calls.clear();

    await _tap(tester, find.text('Vetro')); // nothing selected yet
    for (var i = 0; i < 8; i++) {
      final name = tester.widget<Text>(_wasteItems.first).data!;
      final bin = _binFor[name.split(' ')[1]]!;
      await _tap(tester, find.text(name));
      // Item 4 goes in a wrong bin on purpose.
      await _tap(tester,
          find.text(i == 3 ? (bin == 'Vetro' ? 'Organico' : 'Vetro') : bin));
    }
    expect(audio.played, [
      'ui.unavailable',
      'recycling.select', 'recycling.correct', //
      'recycling.select', 'recycling.correct', //
      'recycling.select', 'recycling.combo', // 3 in a row
      'recycling.select', 'recycling.incorrect', //
      'recycling.select', 'recycling.correct', //
      'recycling.select', 'recycling.correct', //
      'recycling.select', 'recycling.combo', //
      'recycling.select', 'recycling.correct', //
    ]);

    audio.calls.clear();
    await _tap(tester, find.widgetWithText(EcoButton, 'Vedi il risultato'));
    await tester.pump(const Duration(milliseconds: 700));
    expect(audio.played, ['recycling.complete', 'reward.coins']);
  });

  testWidgets('pet: sea ambience only while the room is on screen',
      (tester) async {
    final audio = FakeAudioBackend();
    await pumpEcoQuestApp(tester,
        audioBackend: audio, repository: InMemorySaveRepository(_hatched()));
    expect(audio.calls.where((c) => c.startsWith('loop')), isEmpty);

    await tapTab(tester, 'Cucciolo');
    expect(audio.calls.last, 'loop pet test/sound/ambience.sea 0.60');

    await tapTab(tester, 'Home');
    expect(audio.calls.last, 'stop pet');

    await tapTab(tester, 'Cucciolo');
    final cleanup = find.widgetWithText(EcoButton, 'Pulisci la stanza');
    await _tap(tester, cleanup); // a full-screen page covers the room
    expect(audio.calls.last, 'stop pet');
  });

  testWidgets('pet: care sounds, a soft "already full", egg and hatch',
      (tester) async {
    // An egg far from hatching can be stroked.
    final eggAudio = FakeAudioBackend();
    await pumpEcoQuestApp(tester, audioBackend: eggAudio);
    await tapTab(tester, 'Cucciolo');
    await _tap(tester, find.widgetWithText(EcoButton, 'Accarezza l\'uovo'));
    expect(eggAudio.played, ['ui.tap', 'pet.egg_pat']);

    // An egg ready to hatch (level 2).
    final audio = FakeAudioBackend();
    final egg = PetState(
        needsUpdatedAt: testNow, satiety: 80, happiness: 80, cleanliness: 80);
    await pumpEcoQuestApp(tester,
        audioBackend: audio,
        repository: InMemorySaveRepository(_hatched().copyWith(pet: egg)));
    await tapTab(tester, 'Cucciolo');
    audio.calls.clear();

    await _tap(tester, find.widgetWithText(EcoButton, 'Fai schiudere l\'uovo'));
    await tester.enterText(find.byType(TextField), 'Foglia');
    await _tap(tester, find.widgetWithText(EcoButton, 'Fatto'));
    // The care buttons are further down the list: scroll them into view.
    final feed = find.widgetWithText(EcoButton, 'Dai da mangiare');
    final bath = find.widgetWithText(EcoButton, 'Fai il bagnetto');
    await scrollTo(tester, bath);
    await _tap(tester, feed);
    // Feeding is a 2-question "Prepara la pappa" first.
    for (final next in ['Prossima domanda', 'Servi la pappa']) {
      await tester.ensureVisible(_rightAnswer.first);
      await tester.pumpAndSettle();
      await _tap(tester, _rightAnswer.first);
      final button = find.widgetWithText(EcoButton, next);
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await _tap(tester, button);
    }
    await scrollTo(tester, bath);
    await _tap(tester, bath);
    await _tap(tester, bath);
    await _tap(tester, bath);

    expect(audio.played, [
      'pet.hatch',
      'quiz.streak.1', // right answers in the pappa game
      'quiz.streak.2',
      'pet.feed',
      'pet.bath',
      'ui.unavailable', // already clean: no fake "care" sound
      'ui.unavailable',
    ]);
  });

  testWidgets('tabs tap softly; with master mute nothing plays at all',
      (tester) async {
    final audio = FakeAudioBackend();
    await pumpEcoQuestApp(tester, audioBackend: audio);
    await tapTab(tester, 'Profilo');
    expect(audio.played, ['ui.tap']);

    final muted = FakeAudioBackend();
    await pumpEcoQuestApp(tester,
        audioBackend: muted,
        repository: InMemorySaveRepository(onboardedState()
            .copyWith(audio: AudioSettings.defaults.withMuted(true))));
    await tapTab(tester, 'Cucciolo');
    await _openQuiz(tester);
    await _tap(tester, _rightAnswer);

    expect(muted.calls, isEmpty);
  });
}
