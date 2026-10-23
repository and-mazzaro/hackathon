import 'package:ecoquest/data/save/in_memory_save_repository.dart';
import 'package:ecoquest/domain/models/look_mode.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_app.dart';

Finder _chip(String label) => find.widgetWithText(ChoiceChip, label);

void main() {
  testWidgets('by default the room follows the clock (10:00 → day)',
      (tester) async {
    await pumpEcoQuestApp(tester);
    await tapTab(tester, 'Cucciolo');
    expect(find.byKey(const ValueKey('room-day')), findsOneWidget);
    expect(find.byKey(const ValueKey('room-night')), findsNothing);
  });

  testWidgets('a saved night look shows the night room', (tester) async {
    await pumpEcoQuestApp(tester,
        repository: InMemorySaveRepository(
            onboardedState().copyWith(lookMode: LookMode.night)));
    await tapTab(tester, 'Cucciolo');
    expect(find.byKey(const ValueKey('room-night')), findsOneWidget);
  });

  testWidgets('the Aspetto card changes the look and saves it',
      (tester) async {
    final repository = InMemorySaveRepository(onboardedState());
    await pumpEcoQuestApp(tester, repository: repository);
    await tapTab(tester, 'Profilo');
    await scrollTo(tester, _chip('Notte'));

    expect(find.text('Aspetto'), findsOneWidget);
    expect(tester.widget<ChoiceChip>(_chip('Automatico')).selected, isTrue);

    await tester.tap(_chip('Notte'));
    await tester.pumpAndSettle();

    expect(repository.saved!.lookMode, LookMode.night);
    expect(tester.widget<ChoiceChip>(_chip('Notte')).selected, isTrue);
    expect(tester.widget<ChoiceChip>(_chip('Automatico')).selected, isFalse);
    final notte = tester.widget<Semantics>(find
        .ancestor(of: _chip('Notte'), matching: find.byType(Semantics))
        .first);
    expect(notte.properties.selected, isTrue);

    await tapTab(tester, 'Cucciolo');
    expect(find.byKey(const ValueKey('room-night')), findsOneWidget);

    await tapTab(tester, 'Profilo');
    await scrollTo(tester, _chip('Pomeriggio'));
    await tester.tap(_chip('Pomeriggio'));
    await tester.pumpAndSettle();
    expect(repository.saved!.lookMode, LookMode.afternoon);
  });
}
