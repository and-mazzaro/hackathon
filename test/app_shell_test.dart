import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_app.dart';

/// Always visible at the top of Home.
final _homeTop = find.text('Livello 1');

void main() {
  testWidgets('starts on Home with the four Italian tabs', (tester) async {
    await pumpEcoQuestApp(tester);

    for (final label in tabLabels) {
      expect(
        find.descendant(
            of: find.byType(NavigationBar), matching: find.text(label)),
        findsOneWidget,
      );
    }
    expect(_homeTop, findsOneWidget);
    await scrollTo(tester, find.text('Quiz del giorno'));
    expect(find.text('Quiz del giorno'), findsOneWidget);
  });

  testWidgets('tapping a tab shows its screen', (tester) async {
    await pumpEcoQuestApp(tester);

    await tapTab(tester, 'Impara');
    expect(find.text('Impara giocando'), findsOneWidget);

    await tapTab(tester, 'Cucciolo');
    expect(find.text('Uovo misterioso'), findsOneWidget);

    await tapTab(tester, 'Profilo');
    expect(find.text('I tuoi interessi'), findsOneWidget);

    await tapTab(tester, 'Home');
    expect(_homeTop, findsOneWidget);
  });

  testWidgets('home shortcuts open the matching tab', (tester) async {
    await pumpEcoQuestApp(tester);

    await scrollTo(tester, find.text('Pulisci la stanza'));
    await tester.tap(find.text('Pulisci la stanza'));
    await tester.pumpAndSettle();
    // Opens the Room Cleanup game; close it to return to Home.
    expect(find.text('0 di 8 sistemati'), findsOneWidget);
    await tester.tap(find.byTooltip('Esci dalla pulizia'));
    await tester.pumpAndSettle();

    await tapTab(tester, 'Home');
    await scrollTo(tester, find.text('Quiz del giorno'));
    await tester.tap(find.text('Quiz del giorno'));
    await tester.pumpAndSettle();
    // Opens the personal mixed quiz directly.
    expect(find.text('Quiz misto'), findsOneWidget);
  });

  testWidgets('Android back on another tab returns to Home', (tester) async {
    await pumpEcoQuestApp(tester);
    await tapTab(tester, 'Profilo');

    await pressAndroidBack(tester);

    expect(_homeTop, findsOneWidget);
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.selectedIndex, 0);
  });

  testWidgets('on Home the back button is allowed to leave the app',
      (tester) async {
    await pumpEcoQuestApp(tester);

    final popScope = tester.widget<PopScope>(find.byType(PopScope).first);
    expect(popScope.canPop, isTrue);
  });
}
