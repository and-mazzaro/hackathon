import 'package:ecoquest/data/save/in_memory_save_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('demo mode tours the screens without saving the game',
      (tester) async {
    final repository = InMemorySaveRepository(onboardedState());
    await pumpEcoQuestApp(tester, repository: repository);
    await tapTab(tester, 'Profilo');
    await scrollTo(tester, find.text('Modalità demo'));
    final savesBefore = repository.saveCount;
    final saved = repository.saved;

    await tester.tap(find.text('Modalità demo'));
    await tester.pumpAndSettle();
    expect(find.text('Home: la missione del giorno e i tuoi progressi'),
        findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(find.text('Impara: quiz brevi sui temi che ti interessano'),
        findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(find.text('Cucciolo: prenditi cura di Laiqua, la tua lontra'),
        findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(find.text('Guardaroba: premi e vestiti per il tuo cucciolo'),
        findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(find.text('Home: la missione del giorno e i tuoi progressi'),
        findsOneWidget);

    await tester.tap(find.text('Esci dalla demo'));
    await tester.pumpAndSettle();
    expect(find.text('Esci dalla demo'), findsNothing);

    expect(repository.saveCount, savesBefore);
    expect(identical(repository.saved, saved), isTrue);
  });
}
