import 'package:ecoquest/data/save/in_memory_save_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('every tab meets tap-target, label and contrast guidelines',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpEcoQuestApp(tester);

    for (final tab in tabLabels) {
      await tapTab(tester, tab);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    }
    semantics.dispose();
  });

  testWidgets('small phone with 200% text: no overflow on any tab',
      (tester) async {
    useSmallPhoneWithLargeText(tester);
    await pumpEcoQuestApp(tester);

    // Scroll Home to the last card so every card gets laid out.
    await scrollTo(tester, find.text('Pulisci la stanza'));
    expect(find.text('Pulisci la stanza'), findsOneWidget);

    for (final tab in tabLabels) {
      await tapTab(tester, tab);
    }
    // A RenderFlex overflow is reported as an exception and fails the test.
    expect(tester.takeException(), isNull);
  });

  Future<void> visitOnboardingSteps(
      WidgetTester tester, Future<void> Function() check) async {
    await check(); // welcome
    await tester.tap(find.text('Iniziamo'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Clima'));
    await tester.tap(find.text('Clima'));
    await tester.pumpAndSettle();
    await check(); // interests
    await tester.tap(find.text('Avanti'));
    await tester.pumpAndSettle();
    await check(); // about you
  }

  testWidgets('every onboarding step meets the guidelines', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpEcoQuestApp(tester, repository: InMemorySaveRepository());

    await visitOnboardingSteps(tester, () async {
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    });
    semantics.dispose();
  });

  testWidgets('small phone with 200% text: onboarding does not overflow',
      (tester) async {
    useSmallPhoneWithLargeText(tester);
    await pumpEcoQuestApp(tester, repository: InMemorySaveRepository());

    await visitOnboardingSteps(tester, () async {
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('screen readers hear the balances and pet needs on Home',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpEcoQuestApp(tester);

    // A new player: 0 coins, 1 welcome ticket and an egg with its
    // hatching progress (the need bars appear after hatching).
    expect(find.bySemanticsLabel('0 monete'), findsOneWidget);
    expect(find.bySemanticsLabel('1 biglietto premio'), findsOneWidget);
    // The room also lists its trash (an old save starts with 2 items).
    expect(
        find.bySemanticsLabel(RegExp(r'^Uovo misterioso, Uovo, Di buon umore'
            r'\. Nella stanza ci sono 2 rifiuti: ')),
        findsOneWidget);
    expect(
        find.bySemanticsLabel(
            'Si schiuderà al livello 2: ti mancano 100 XP.'),
        findsOneWidget);
    semantics.dispose();
  });
}
