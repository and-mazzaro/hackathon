import 'package:ecoquest/core/widgets/eco_button.dart';
import 'package:ecoquest/data/save/in_memory_save_repository.dart';
import 'package:ecoquest/data/territory/territory_client.dart';
import 'package:ecoquest/domain/models/territory.dart';
import 'package:ecoquest/domain/rules/territory_rules.dart';
import 'package:ecoquest/features/territory/territory_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_app.dart';
import 'helpers/territory_fixtures.dart';

final _quizButton = find.text('Quiz del territorio');

Future<void> _openHomeQuiz(WidgetTester tester) async {
  await scrollTo(tester, _quizButton);
  await tester.tap(_quizButton);
  await tester.pumpAndSettle();
}

/// Answers the 3 fixture questions right: Schio "Buona", PM10 below the
/// limit, Valdagno cleanest.
Future<void> _answerAllRight(WidgetTester tester) async {
  for (final (answer, button) in [
    ('Buona', 'Avanti'),
    ('Sotto il limite', 'Avanti'),
    ('Valdagno', 'Vedi il risultato'),
  ]) {
    final option = find.text(answer);
    await tester.ensureVisible(option);
    await tester.pumpAndSettle();
    await tester.tap(option);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(EcoButton, button));
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('Home card shows the live values, tip and attribution',
      (tester) async {
    await pumpEcoQuestApp(tester);
    await scrollTo(tester, find.text('Il mio territorio · Schio'));

    expect(find.text('Aria Buona · indice 20'), findsOneWidget);
    expect(find.text('PM10 5,5 µg/m³'), findsOneWidget);
    expect(find.text('PM2,5 4,9 µg/m³'), findsOneWidget);
    expect(find.text('10,3 °C'), findsOneWidget);
    expect(find.text('aggiornato alle 09:00'), findsOneWidget);
    await scrollTo(tester, find.textContaining('Dati: Open-Meteo.com'));
    expect(
        find.text('Azione di oggi: Aria buona: oggi vai a scuola in bici o a '
            'piedi'),
        findsOneWidget);
    expect(_quizButton, findsOneWidget);
  });

  testWidgets('the territory quiz has 3 questions and completes',
      (tester) async {
    final repository = InMemorySaveRepository(onboardedState());
    await pumpEcoQuestApp(tester, repository: repository);
    await _openHomeQuiz(tester);

    expect(find.text('Domanda 1 di 3'), findsOneWidget);
    expect(find.textContaining("Com'è oggi l'aria a Schio"), findsOneWidget);
    await _answerAllRight(tester);

    expect(find.text('3 su 3 risposte giuste'), findsOneWidget);
    final saved = repository.saved!;
    expect(saved.learning.quizzesCompleted, 1);
    expect(saved.progress.totalXp, greaterThan(0));
    expect(saved.learning.learnedQuestionIds,
        containsAll(['territory_20261022_1', 'territory_20261022_3']));
  });

  testWidgets('Learn has a territory tile that opens the same quiz',
      (tester) async {
    await pumpEcoQuestApp(tester);
    await tapTab(tester, 'Impara');
    await scrollTo(tester, find.text('Il mio territorio (dati live)'));
    await tester.tap(find.text('Il mio territorio (dati live)'));
    await tester.pumpAndSettle();

    expect(find.text('Quiz del territorio'), findsOneWidget);
    expect(find.text('Domanda 1 di 3'), findsOneWidget);
  });

  testWidgets('"L\'ho fatto!" pays once per day', (tester) async {
    final repository = InMemorySaveRepository(onboardedState());
    await pumpEcoQuestApp(tester, repository: repository);
    final coinsBefore = repository.saved!.progress.coins;
    await scrollTo(tester, find.text("L'ho fatto!"));
    await tester.tap(find.text("L'ho fatto!"));
    await tester.pumpAndSettle();

    expect(repository.saved!.progress.coins, coinsBefore + 5);
    expect(repository.saved!.progress.claimedRewardIds,
        contains(territoryClaimId(testNow)));
    expect(find.text("L'ho fatto!"), findsNothing);
    expect(find.text('Fatto oggi, grazie! Domani una nuova azione.'),
        findsOneWidget);
  });

  testWidgets('choosing a town updates the card and is saved',
      (tester) async {
    final repository = InMemorySaveRepository(onboardedState());
    await pumpEcoQuestApp(tester, repository: repository);
    await scrollTo(tester, find.widgetWithText(ChoiceChip, 'Thiene'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Thiene'));
    await tester.pumpAndSettle();

    expect(repository.saved!.territory.town, TerritoryTown.thiene);
    await scrollTo(tester, find.text('Il mio territorio · Thiene'));
    expect(find.text('Aria Discreta · indice 35'), findsOneWidget);
  });

  testWidgets('offline with a cache: last readings are marked offline',
      (tester) async {
    await pumpEcoQuestApp(tester,
        territory:
            TerritoryData(readings: testTerritoryReadings(), live: false));
    await scrollTo(tester, find.text('offline: ultimi dati delle 09:00'));
    expect(find.text('offline: ultimi dati delle 09:00'), findsOneWidget);
  });

  testWidgets('no data: "Dati non disponibili ora" and no quiz button',
      (tester) async {
    await pumpEcoQuestApp(tester, territoryAvailable: false);
    await scrollTo(tester, find.text('Dati non disponibili ora'));
    expect(find.text('Dati non disponibili ora'), findsOneWidget);
    expect(_quizButton, findsNothing);
    expect(find.text("L'ho fatto!"), findsNothing);
  });

  testWidgets('screen readers hear the reading as one block',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpEcoQuestApp(tester);
    await scrollTo(tester, find.text('Il mio territorio · Schio'));
    expect(
        find.bySemanticsLabel(RegExp(r'^Il mio territorio · Schio\. Aria '
            r'Buona · indice 20\. PM10 5,5 µg/m³, PM2,5 4,9 µg/m³, '
            r'temperatura 10,3 °C\. aggiornato alle 09:00\.$')),
        findsOneWidget);
    semantics.dispose();
  });

  testWidgets('small phone with 200% text: the card fits', (tester) async {
    useSmallPhoneWithLargeText(tester);
    await pumpEcoQuestApp(tester);
    await scrollTo(tester, find.textContaining('Dati: Open-Meteo.com'));
    expect(tester.takeException(), isNull);
  });

  test('band badge text keeps at least 4.5:1 contrast', () {
    double contrast(Color a, Color b) {
      final la = a.computeLuminance();
      final lb = b.computeLuminance();
      final (hi, lo) = la > lb ? (la, lb) : (lb, la);
      return (hi + 0.05) / (lo + 0.05);
    }

    for (final band in AqiBand.values) {
      final (background, text) = aqiBandColors(band);
      expect(contrast(background, text), greaterThanOrEqualTo(4.5),
          reason: band.name);
    }
  });
}
