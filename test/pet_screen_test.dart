import 'package:ecoquest/core/widgets/eco_button.dart';
import 'package:ecoquest/data/save/in_memory_save_repository.dart';
import 'package:ecoquest/domain/models/game_state.dart';
import 'package:ecoquest/domain/models/pet_state.dart';
import 'package:ecoquest/domain/models/player_progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_app.dart';

/// A player at level 2 (100 XP), egg ready to hatch.
GameState _readyToHatch() => onboardedState()
    .copyWith(progress: const PlayerProgress(totalXp: 100));

/// A hatched pet with the given needs, last updated "now" in the tests.
GameState _hatched({int satiety = 80, int happiness = 80, int clean = 80}) =>
    _readyToHatch().copyWith(
      pet: PetState(
        name: 'Foglia',
        stage: PetStage.baby,
        satiety: satiety,
        happiness: happiness,
        cleanliness: clean,
        needsUpdatedAt: testNow,
      ),
    );

/// Scrolls the Pet tab until the button is built and visible, then taps.
Future<void> _tapButton(WidgetTester tester, String label) async {
  final button = find.widgetWithText(EcoButton, label);
  await scrollTo(tester, button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

/// Taps something inside the "Prepara la pappa" sheet (it scrolls).
Future<void> _tapInSheet(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// The fixture questions' right answer always starts with "Giusta".
Finder _option({required bool right}) => find.byWidgetPredicate((w) =>
    w is EcoButton && w.label.startsWith('Giusta') == right &&
    (right || w.label.startsWith('Sbagliata A')));

/// Plays the feeding mini-game: [rightAnswers] decides each answer.
Future<void> _playFeedGame(
    WidgetTester tester, List<bool> rightAnswers) async {
  await _tapButton(tester, 'Dai da mangiare');
  expect(find.text('Prepara la pappa'), findsOneWidget);
  for (final (index, right) in rightAnswers.indexed) {
    expect(find.text('Domanda ${index + 1} di 2'), findsOneWidget);
    await _tapInSheet(tester, _option(right: right));
    expect(find.text(right ? 'Corretto!' : 'Non proprio.'), findsOneWidget);
    await _tapInSheet(
        tester,
        find.widgetWithText(EcoButton,
            index == rightAnswers.length - 1
                ? 'Servi la pappa'
                : 'Prossima domanda'));
  }
}

void main() {
  testWidgets('the egg shows how much XP is missing to hatch',
      (tester) async {
    await pumpEcoQuestApp(tester); // 0 XP
    await tapTab(tester, 'Cucciolo');

    expect(find.text('Uovo misterioso'), findsOneWidget);
    expect(find.text('Si schiuderà al livello 2: ti mancano 100 XP.'),
        findsOneWidget);
    expect(find.text('Fai schiudere l\'uovo'), findsNothing);
    expect(find.text('Dai da mangiare'), findsNothing);

    await _tapButton(tester, 'Accarezza l\'uovo');
    expect(find.text('L\'uovo si è mosso un pochino…'), findsOneWidget);
  });

  testWidgets('Home says the egg is ready instead of "0 XP missing"',
      (tester) async {
    await pumpEcoQuestApp(tester,
        repository: InMemorySaveRepository(_readyToHatch()));

    expect(find.text('L\'uovo si muove: è pronto a schiudersi!'),
        findsOneWidget);
    expect(find.textContaining('ti mancano 0 XP'), findsNothing);
  });

  testWidgets('at level 2 the egg hatches and gets a name', (tester) async {
    final repository = InMemorySaveRepository(_readyToHatch());
    await pumpEcoQuestApp(tester, repository: repository);
    await tapTab(tester, 'Cucciolo');

    expect(find.text('L\'uovo si muove: è pronto a schiudersi!'),
        findsOneWidget);
    await _tapButton(tester, 'Fai schiudere l\'uovo');

    expect(find.text('Il tuo cucciolo è nato!'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Foglia');
    await _tapButton(tester, 'Fatto');

    expect(repository.saved!.pet.stage, PetStage.baby);
    expect(repository.saved!.pet.name, 'Foglia');
    expect(find.text('Ecco Foglia, il tuo nuovo cucciolo!'), findsOneWidget);
    await scrollTo(tester, find.text('Dai da mangiare'));
    expect(find.text('Dai da mangiare'), findsOneWidget);
    await scrollTo(tester, find.text('Prossima crescita al livello 5.'));
    expect(find.text('Prossima crescita al livello 5.'), findsOneWidget);
  });

  testWidgets('closing the name sheet does not hatch the egg',
      (tester) async {
    final repository = InMemorySaveRepository(_readyToHatch());
    await pumpEcoQuestApp(tester, repository: repository);
    await tapTab(tester, 'Cucciolo');

    await _tapButton(tester, 'Fai schiudere l\'uovo');
    await tester.tapAt(const Offset(20, 20)); // tap outside the sheet
    await tester.pumpAndSettle();

    expect(repository.saveCount, 0);
    expect(find.text('Fai schiudere l\'uovo'), findsOneWidget); // still an egg
  });

  testWidgets('feeding opens "Prepara la pappa" with 2 interest questions',
      (tester) async {
    final repository = InMemorySaveRepository(_hatched(satiety: 40));
    await pumpEcoQuestApp(tester, repository: repository);
    await tapTab(tester, 'Cucciolo');

    await _tapButton(tester, 'Dai da mangiare');

    expect(find.text('Prepara la pappa'), findsOneWidget);
    expect(find.text('Domanda 1 di 2'), findsOneWidget);
    // The player's interest is recycling: the question comes from there.
    expect(find.textContaining('Domanda recycling'), findsOneWidget);
    expect(find.textContaining('Giusta recycling'), findsOneWidget);
    expect(find.textContaining('Sbagliata'), findsNWidgets(3));
    expect(repository.saveCount, 0); // nothing happens until served
  });

  testWidgets('answering feeds the pet, saves and pays no XP',
      (tester) async {
    final start = _hatched(satiety: 40);
    final repository = InMemorySaveRepository(start);
    await pumpEcoQuestApp(tester, repository: repository);
    await tapTab(tester, 'Cucciolo');

    await _playFeedGame(tester, [true, false]);

    expect(find.text('Prepara la pappa'), findsNothing);
    expect(repository.saved!.pet.satiety, 70);
    expect(repository.saved!.progress.totalXp, start.progress.totalXp);
    expect(repository.saved!.progress.coins, start.progress.coins);
    expect(repository.saved!.learning.toJson(), start.learning.toJson());
    expect(find.text('Gnam! Foglia ha mangiato con gusto.'), findsOneWidget);
    expect(find.text('70%'), findsOneWidget);
  });

  testWidgets('0 right answers still feed the pet, kindly', (tester) async {
    final repository = InMemorySaveRepository(_hatched(satiety: 40));
    await pumpEcoQuestApp(tester, repository: repository);
    await tapTab(tester, 'Cucciolo');

    await _playFeedGame(tester, [false, false]);

    expect(repository.saved!.pet.satiety, 70);
    expect(find.text('Ci riproviamo! Intanto Foglia ha fatto merenda.'),
        findsOneWidget);
  });

  testWidgets('Android back closes the pappa sheet without feeding',
      (tester) async {
    final repository = InMemorySaveRepository(_hatched(satiety: 40));
    await pumpEcoQuestApp(tester, repository: repository);
    await tapTab(tester, 'Cucciolo');

    await _tapButton(tester, 'Dai da mangiare');
    await pressAndroidBack(tester);
    await tester.pumpAndSettle();

    expect(find.text('Prepara la pappa'), findsNothing);
    expect(repository.saveCount, 0);
  });

  testWidgets('a full belly does not open the game', (tester) async {
    final repository = InMemorySaveRepository(_hatched(satiety: 100));
    await pumpEcoQuestApp(tester, repository: repository);
    await tapTab(tester, 'Cucciolo');

    await _tapButton(tester, 'Dai da mangiare');

    expect(find.text('Prepara la pappa'), findsNothing);
    expect(repository.saveCount, 0);
    expect(find.text('Già al massimo: Foglia sta benissimo così!'),
        findsOneWidget);
  });

  testWidgets('small phone with 200% text: the pappa sheet scrolls',
      (tester) async {
    useSmallPhoneWithLargeText(tester);
    final repository = InMemorySaveRepository(_hatched(satiety: 40));
    await pumpEcoQuestApp(tester, repository: repository);
    await tapTab(tester, 'Cucciolo');

    await _playFeedGame(tester, [true, true]);

    expect(tester.takeException(), isNull);
    expect(repository.saved!.pet.satiety, 70);
  });

  testWidgets('a full need is not "used up" again', (tester) async {
    final repository = InMemorySaveRepository(_hatched(clean: 100));
    await pumpEcoQuestApp(tester, repository: repository);
    await tapTab(tester, 'Cucciolo');

    await _tapButton(tester, 'Fai il bagnetto');

    expect(repository.saveCount, 0);
    expect(find.text('Già al massimo: Foglia sta benissimo così!'),
        findsOneWidget);
  });

  testWidgets('a sad pet shows a kind recovery hint', (tester) async {
    await pumpEcoQuestApp(tester,
        repository: InMemorySaveRepository(_hatched(happiness: 25)));
    await tapTab(tester, 'Cucciolo');

    expect(find.text('Un po\' giù'), findsOneWidget);
    final hint = find.textContaining('Non succede niente di grave');
    await scrollTo(tester, hint);
    expect(hint, findsOneWidget);
  });

  testWidgets('Home shows the need bars once the pet has hatched',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpEcoQuestApp(tester,
        repository: InMemorySaveRepository(_hatched()));

    expect(
        find.bySemanticsLabel(
            RegExp(r'^Foglia, Cucciolo, Di buon umore\. Nella stanza ')),
        findsOneWidget);
    expect(find.bySemanticsLabel('Sazietà'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('pet screen meets the accessibility guidelines',
      (tester) async {
    final semantics = tester.ensureSemantics();
    for (final state in [onboardedState(), _readyToHatch(), _hatched()]) {
      await pumpEcoQuestApp(tester,
          repository: InMemorySaveRepository(state));
      await tapTab(tester, 'Cucciolo');
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    }
    semantics.dispose();
  });

  testWidgets('small phone with 200% text: pet screen fits',
      (tester) async {
    useSmallPhoneWithLargeText(tester);
    for (final state in [onboardedState(), _readyToHatch(), _hatched()]) {
      await pumpEcoQuestApp(tester,
          repository: InMemorySaveRepository(state));
      await tapTab(tester, 'Cucciolo');
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
