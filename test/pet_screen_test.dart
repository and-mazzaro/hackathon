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

  testWidgets('feeding raises satiety, saves and says what happened',
      (tester) async {
    final repository = InMemorySaveRepository(_hatched(satiety: 40));
    await pumpEcoQuestApp(tester, repository: repository);
    await tapTab(tester, 'Cucciolo');

    await _tapButton(tester, 'Dai da mangiare');

    expect(repository.saved!.pet.satiety, 70);
    expect(find.text('Gnam! Foglia ha mangiato con gusto.'), findsOneWidget);
    expect(find.text('70%'), findsOneWidget);
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

    expect(find.bySemanticsLabel('Foglia, Cucciolo, Di buon umore'),
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
