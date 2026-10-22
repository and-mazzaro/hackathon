import 'package:ecoquest/data/save/in_memory_save_repository.dart';
import 'package:ecoquest/domain/models/eco_topic.dart';
import 'package:ecoquest/domain/models/player_profile.dart';
import 'package:ecoquest/domain/models/player_progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_app.dart';

void main() {
  late InMemorySaveRepository repository;

  Future<void> openProfile(WidgetTester tester) async {
    final saved = onboardedState();
    repository = InMemorySaveRepository(saved.copyWith(
      profile: PlayerProfile(
        createdAt: testNow,
        nickname: 'EcoAle',
        ageRange: AgeRange.age16to18,
        interests: {EcoTopic.recycling, EcoTopic.oceans},
        onboardingCompleted: true,
      ),
      progress: const PlayerProgress(totalXp: 260, coins: 77, tickets: 2),
    ));
    await pumpEcoQuestApp(tester, repository: repository);
    await tapTab(tester, 'Profilo');
  }

  Future<void> tapTopic(WidgetTester tester, String label) async {
    await scrollTo(tester, find.text(label));
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('shows nickname, level and age range', (tester) async {
    await openProfile(tester);

    expect(find.text('EcoAle'), findsOneWidget);
    expect(find.text('Livello 3 · profilo su questo telefono'), findsOneWidget);
    expect(find.text('Età: 16–18 anni'), findsOneWidget);
  });

  testWidgets('a guest without nickname is called "Ospite"', (tester) async {
    await pumpEcoQuestApp(tester);
    await tapTab(tester, 'Profilo');

    expect(find.text('Ospite'), findsOneWidget);
  });

  testWidgets('toggling an interest saves at once and keeps progress',
      (tester) async {
    await openProfile(tester);

    await tapTopic(tester, 'Clima');
    await tapTopic(tester, 'Oceani e vita marina');

    final saved = repository.saved!;
    expect(saved.profile.interests, {EcoTopic.recycling, EcoTopic.climate});
    expect(saved.progress.totalXp, 260);
    expect(saved.progress.coins, 77);
    expect(saved.progress.tickets, 2);
    expect(saved.profile.onboardingCompleted, isTrue);
    expect(saved.profile.nickname, 'EcoAle');
    // Still on the profile tab, not sent back to onboarding.
    expect(find.text('Ti diamo il benvenuto in EcoQuest!'), findsNothing);
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.selectedIndex, 3);
  });

  testWidgets('the last interest cannot be removed', (tester) async {
    await openProfile(tester);
    await tapTopic(tester, 'Oceani e vita marina');

    await tapTopic(tester, 'Riciclo e rifiuti');

    expect(find.text('Tieni almeno un interesse.'), findsOneWidget);
    expect(repository.saved!.profile.interests, {EcoTopic.recycling});
  });

  testWidgets('nickname and age can be edited in the sheet', (tester) async {
    await openProfile(tester);

    await tester.tap(find.text('Modifica soprannome ed età'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Luna');
    await tester.tap(find.text('Preferisco non dirlo'));
    await tester.pump();
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    expect(find.text('Luna'), findsOneWidget);
    expect(find.textContaining('Età:'), findsNothing);
    expect(repository.saved!.profile.nickname, 'Luna');
    expect(repository.saved!.profile.ageRange, isNull);
    expect(repository.saved!.progress.coins, 77);
  });

  testWidgets('cancel leaves the profile unchanged', (tester) async {
    await openProfile(tester);

    await tester.tap(find.text('Modifica soprannome ed età'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Altro');
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();

    expect(find.text('EcoAle'), findsOneWidget);
    expect(repository.saveCount, 0);
  });

  testWidgets('interest tiles tell screen readers if they are selected',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await openProfile(tester);
    await scrollTo(tester, find.text('Clima'));

    expect(
      tester.getSemantics(find.text('Oceani e vita marina')),
      isSemantics(label: 'Oceani e vita marina', isChecked: true),
    );
    expect(
      tester.getSemantics(find.text('Clima')),
      isSemantics(label: 'Clima', isChecked: false),
    );
    semantics.dispose();
  });
}
