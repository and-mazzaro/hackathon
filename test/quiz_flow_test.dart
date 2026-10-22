import 'package:ecoquest/core/widgets/eco_button.dart';
import 'package:ecoquest/data/save/in_memory_save_repository.dart';
import 'package:ecoquest/domain/models/eco_topic.dart';
import 'package:ecoquest/domain/models/player_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_app.dart';

/// The right answer of every fixture question starts with "Giusta".
final _rightAnswer = find.textContaining(RegExp(r'^Giusta'));
final _wrongAnswer = find.textContaining(RegExp(r'^Sbagliata A'));

Future<void> _tapButton(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(EcoButton, label));
  await tester.pumpAndSettle();
}

/// Answers the current question (right or wrong).
Future<void> _answer(WidgetTester tester, {required bool right}) async {
  final option = right ? _rightAnswer : _wrongAnswer;
  await tester.ensureVisible(option); // large text pushes options down
  await tester.pumpAndSettle();
  await tester.tap(option);
  await tester.pumpAndSettle();
}

Future<void> _openTopicQuiz(WidgetTester tester, String topicLabel) async {
  await tapTab(tester, 'Impara');
  await scrollTo(tester, find.text(topicLabel));
  await tester.tap(find.text(topicLabel));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Learn lists interests first with a "Per te" badge',
      (tester) async {
    // A very tall screen, so every topic card is built at once.
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpEcoQuestApp(tester); // interested in recycling
    await tapTab(tester, 'Impara');

    final recycling = tester.getTopLeft(find.text('Riciclo e rifiuti'));
    final oceans = tester.getTopLeft(find.text('Oceani e vita marina'));
    expect(recycling.dy, lessThan(oceans.dy));
    expect(find.text('Per te'), findsWidgets);
  });

  testWidgets('a whole topic quiz: feedback, explanation, result, XP saved',
      (tester) async {
    final repository = InMemorySaveRepository(onboardedState());
    await pumpEcoQuestApp(tester, repository: repository);
    await _openTopicQuiz(tester, 'Oceani e vita marina');

    expect(find.text('Domanda 1 di 5'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing); // full screen
    expect(find.text('Facile'), findsOneWidget);

    // Q1 right: celebration + explanation + source
    await _answer(tester, right: true);
    expect(find.text('Corretto!'), findsOneWidget);
    // Easy questions are shuffled among themselves: oceans 1 or 2.
    expect(find.textContaining('Spiegazione oceans'), findsOneWidget);
    expect(find.text('Fonte: Fonte di prova'), findsOneWidget);
    await _tapButton(tester, 'Avanti');

    // Q2 wrong: the right answer is shown
    await _answer(tester, right: false);
    expect(find.text('Non proprio.'), findsOneWidget);
    expect(find.textContaining('La risposta giusta è: Giusta oceans'),
        findsOneWidget);
    await _tapButton(tester, 'Avanti');

    // Q3–Q5 right, the last one shows "Vedi il risultato"
    for (var i = 3; i <= 5; i++) {
      expect(find.text('Domanda $i di 5'), findsOneWidget);
      await _answer(tester, right: true);
      await _tapButton(tester, i == 5 ? 'Vedi il risultato' : 'Avanti');
    }

    // ✓ ✗ ✓ ✓ ✓ → 4 × 10 + 2 streak bonuses × 5 = 50 XP
    expect(find.text('4 su 5 risposte giuste'), findsOneWidget);
    expect(find.text('+50 XP'), findsOneWidget);
    expect(repository.saved!.progress.totalXp, 50);
    expect(repository.saved!.learning.quizzesCompleted, 1);
    expect(
        repository.saved!.learning.statsByTopic[EcoTopic.oceans]!.correct, 4);

    // Close → back on the Learn tab, which shows the new stats
    await _tapButton(tester, 'Chiudi');
    expect(find.byType(NavigationBar), findsOneWidget);
    // The Learn tab kept its scroll position: scroll back up to the top.
    await tester.scrollUntilVisible(find.text('1 quiz completato'), -200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('1 quiz completato'), findsOneWidget);
  });

  testWidgets('a second tap on an answer changes nothing', (tester) async {
    await pumpEcoQuestApp(tester);
    await _openTopicQuiz(tester, 'Clima');

    await _answer(tester, right: false);
    await tester.tap(_rightAnswer);
    await tester.pumpAndSettle();

    expect(find.text('Non proprio.'), findsOneWidget);
    expect(find.text('Corretto!'), findsNothing);
  });

  testWidgets('leaving a started quiz asks first and saves nothing',
      (tester) async {
    final repository = InMemorySaveRepository(onboardedState());
    await pumpEcoQuestApp(tester, repository: repository);
    await _openTopicQuiz(tester, 'Clima');
    await _answer(tester, right: true);

    await pressAndroidBack(tester);
    expect(find.text('Vuoi uscire dal quiz?'), findsOneWidget);
    await tester.tap(find.text('Continua il quiz'));
    await tester.pumpAndSettle();
    expect(find.text('Domanda 1 di 5'), findsOneWidget);

    await tester.tap(find.byTooltip('Esci dal quiz'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Esci'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(repository.saveCount, 0);
  });

  testWidgets('a quiz not started yet closes without asking', (tester) async {
    await pumpEcoQuestApp(tester);
    await _openTopicQuiz(tester, 'Clima');

    await tester.tap(find.byTooltip('Esci dal quiz'));
    await tester.pumpAndSettle();

    expect(find.text('Vuoi uscire dal quiz?'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('"Quiz del giorno" on Home opens a quiz on the interests',
      (tester) async {
    final saved = onboardedState().copyWith(
      profile: PlayerProfile(
        createdAt: testNow,
        interests: {EcoTopic.climate},
        onboardingCompleted: true,
      ),
    );
    await pumpEcoQuestApp(tester,
        repository: InMemorySaveRepository(saved));

    await scrollTo(tester, find.text('Quiz del giorno'));
    await tester.tap(find.text('Quiz del giorno'));
    await tester.pumpAndSettle();

    expect(find.text('Quiz misto'), findsOneWidget);
    expect(find.textContaining('Domanda climate'), findsOneWidget);
  });

  testWidgets('"Gioca ancora" starts a fresh quiz', (tester) async {
    await pumpEcoQuestApp(tester);
    await _openTopicQuiz(tester, 'Clima');
    for (var i = 1; i <= 5; i++) {
      await _answer(tester, right: true);
      await _tapButton(tester, i == 5 ? 'Vedi il risultato' : 'Avanti');
    }
    expect(find.text('+70 XP'), findsOneWidget);

    await _tapButton(tester, 'Gioca ancora');

    expect(find.text('Domanda 1 di 5'), findsOneWidget);
    expect(find.text('Corretto!'), findsNothing);
  });

  testWidgets('quiz screen meets the accessibility guidelines',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpEcoQuestApp(tester);
    await _openTopicQuiz(tester, 'Clima');

    Future<void> check() async {
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    }

    await check(); // before answering
    await _answer(tester, right: false);
    await check(); // with feedback
    semantics.dispose();
  });

  testWidgets('screen readers hear whether an answer was right',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpEcoQuestApp(tester);
    await _openTopicQuiz(tester, 'Clima');
    await _answer(tester, right: false);

    expect(
        find.bySemanticsLabel(
            RegExp(r'Giusta climate \d[\s\S]*risposta giusta')),
        findsOneWidget);
    expect(
        find.bySemanticsLabel(
            RegExp(r'Sbagliata A climate \d[\s\S]*risposta sbagliata')),
        findsOneWidget);
    semantics.dispose();
  });

  testWidgets('small phone with 200% text: quiz and result fit',
      (tester) async {
    useSmallPhoneWithLargeText(tester);
    await pumpEcoQuestApp(tester);
    await _openTopicQuiz(tester, 'Clima');
    for (var i = 1; i <= 5; i++) {
      await _answer(tester, right: i.isOdd);
      await _tapButton(tester, i == 5 ? 'Vedi il risultato' : 'Avanti');
    }
    expect(find.text('3 su 5 risposte giuste'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
