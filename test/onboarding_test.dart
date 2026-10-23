import 'package:ecoquest/core/widgets/eco_button.dart';
import 'package:ecoquest/data/save/in_memory_save_repository.dart';
import 'package:ecoquest/domain/models/eco_topic.dart';
import 'package:ecoquest/domain/models/player_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_app.dart';

final _welcome = find.text('Ti diamo il benvenuto in Laiqua!');
final _interests = find.text('Cosa ti interessa?');
final _about = find.text("Parlaci un po' di te");

Finder _button(String label) => find.widgetWithText(EcoButton, label);

Future<void> _tapButton(WidgetTester tester, String label) async {
  await tester.tap(_button(label));
  await tester.pumpAndSettle();
}

Future<void> _tapTopic(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.tap(find.text(label));
  await tester.pump();
}

void main() {
  testWidgets('a new player starts with onboarding, without tabs',
      (tester) async {
    await pumpEcoQuestApp(tester, repository: InMemorySaveRepository());

    expect(_welcome, findsOneWidget);
    expect(find.text('Passo 1 di 3'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('a player who finished onboarding goes straight to Home',
      (tester) async {
    await pumpEcoQuestApp(tester); // default: onboarding already done

    expect(_welcome, findsNothing);
    expect(find.text('Livello 1'), findsOneWidget);
  });

  testWidgets('at least one interest is needed to continue', (tester) async {
    await pumpEcoQuestApp(tester, repository: InMemorySaveRepository());
    await _tapButton(tester, 'Iniziamo');

    expect(_interests, findsOneWidget);
    expect(find.text('Scegline almeno uno per continuare.'), findsOneWidget);
    expect(tester.widget<EcoButton>(_button('Avanti')).onPressed, isNull);

    await _tapTopic(tester, 'Clima');
    expect(find.text('1 argomento scelto'), findsOneWidget);

    await _tapTopic(tester, 'Clima'); // tap again = deselect
    expect(find.text('Scegline almeno uno per continuare.'), findsOneWidget);
  });

  testWidgets('skip path: interests saved, no nickname or age, then Home',
      (tester) async {
    final repository = InMemorySaveRepository();
    await pumpEcoQuestApp(tester, repository: repository);

    await _tapButton(tester, 'Iniziamo');
    await _tapTopic(tester, 'Oceani e vita marina');
    await _tapTopic(tester, 'Riciclo e rifiuti');
    expect(find.text('2 argomenti scelti'), findsOneWidget);
    await _tapButton(tester, 'Avanti');

    expect(_about, findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Ignorato');
    await _tapButton(tester, 'Salta');

    final profile = repository.saved!.profile;
    expect(profile.onboardingCompleted, isTrue);
    expect(profile.interests, {EcoTopic.oceans, EcoTopic.recycling});
    expect(profile.nickname, isNull);
    expect(profile.ageRange, isNull);
    // The router moved to Home on its own.
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Livello 1'), findsOneWidget);
  });

  testWidgets('fill-in path saves nickname and age range', (tester) async {
    final repository = InMemorySaveRepository();
    await pumpEcoQuestApp(tester, repository: repository);

    await _tapButton(tester, 'Iniziamo');
    await _tapTopic(tester, 'Energia rinnovabile');
    await _tapButton(tester, 'Avanti');
    await tester.enterText(find.byType(TextField), '  EcoAle  ');
    await tester.tap(find.text('16–18 anni'));
    await tester.pump();
    await _tapButton(tester, 'Fine');

    final profile = repository.saved!.profile;
    expect(profile.nickname, 'EcoAle');
    expect(profile.ageRange, AgeRange.age16to18);
    expect(profile.interests, {EcoTopic.energy});
  });

  testWidgets('back arrow and Android back go to the previous step',
      (tester) async {
    await pumpEcoQuestApp(tester, repository: InMemorySaveRepository());
    await _tapButton(tester, 'Iniziamo');
    await _tapTopic(tester, 'Clima');
    await _tapButton(tester, 'Avanti');
    expect(_about, findsOneWidget);

    await pressAndroidBack(tester);
    expect(_interests, findsOneWidget);
    // The choice made before is still there.
    expect(find.text('1 argomento scelto'), findsOneWidget);

    await tester.tap(find.byTooltip('Indietro'));
    await tester.pumpAndSettle();
    expect(_welcome, findsOneWidget);
  });

  testWidgets('nothing is saved until onboarding is finished',
      (tester) async {
    final repository = InMemorySaveRepository();
    await pumpEcoQuestApp(tester, repository: repository);
    await _tapButton(tester, 'Iniziamo');
    await _tapTopic(tester, 'Clima');

    expect(repository.saveCount, 0);
  });
}
