import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_app.dart';

void main() {
  Future<void> openIntro(WidgetTester tester) async {
    await pumpEcoQuestApp(tester);
    await tapTab(tester, 'Profilo');
    await scrollTo(tester, find.text("Guarda l'introduzione"));
    await tester.tap(find.text("Guarda l'introduzione"));
    await tester.pumpAndSettle();
  }

  testWidgets('opens from Profile and "Salta" closes it', (tester) async {
    await openIntro(tester);

    expect(find.bySemanticsLabel('LAIQUA'), findsOneWidget);
    expect(find.text('Tocca per iniziare'), findsOneWidget);

    await tester.tap(find.text('Salta'));
    await tester.pumpAndSettle();

    expect(find.text('Tocca per iniziare'), findsNothing);
    expect(find.text("Guarda l'introduzione"), findsOneWidget);
  });

  testWidgets('tapping through reaches "Inizia l\'avventura"',
      (tester) async {
    await openIntro(tester);

    await tester.tap(find.text('Tocca per iniziare'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Ciao! Benvenuto nel mondo di Laiqua!'),
        findsOneWidget);
    expect(find.bySemanticsLabel('Laiqua, la lontra, saluta felice'),
        findsOneWidget);

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byKey(const ValueKey('intro-speech')));
      await tester.pumpAndSettle();
    }

    expect(find.bySemanticsLabel('Laiqua!'), findsOneWidget);
    await tester.tap(find.text("Inizia l'avventura"));
    await tester.pumpAndSettle();

    expect(find.text("Inizia l'avventura"), findsNothing);
    expect(find.text("Guarda l'introduzione"), findsOneWidget);
  });

  testWidgets('small phone with 200% text: every scene fits',
      (tester) async {
    useSmallPhoneWithLargeText(tester);
    await openIntro(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Tocca per iniziare'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 5; i++) {
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('intro-speech')));
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
    expect(find.text("Inizia l'avventura"), findsOneWidget);
  });

  testWidgets('"Salta" works from the guide scene too', (tester) async {
    await openIntro(tester);
    await tester.tap(find.text('Tocca per iniziare'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel("Salta l'introduzione"));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('intro-speech')), findsNothing);
    expect(find.text("Guarda l'introduzione"), findsOneWidget);
  });
}
