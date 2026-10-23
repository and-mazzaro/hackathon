import 'package:ecoquest/core/widgets/eco_button.dart';
import 'package:ecoquest/data/save/in_memory_save_repository.dart';
import 'package:ecoquest/domain/models/game_state.dart';
import 'package:ecoquest/domain/models/pet_state.dart';
import 'package:ecoquest/features/pet/pet_art.dart';
import 'package:ecoquest/features/wardrobe/cosmetic_art.dart';
import 'package:ecoquest/features/wardrobe/wardrobe_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_app.dart';

/// A hatched pet "Foglia", with [coins] and [tickets].
GameState _player({int coins = 0, int tickets = 1}) {
  final state = onboardedState();
  return state.copyWith(
    progress: state.progress.copyWith(coins: coins, tickets: tickets),
    pet: PetState(
      name: 'Foglia',
      stage: PetStage.baby,
      satiety: 80,
      happiness: 80,
      cleanliness: 80,
      needsUpdatedAt: testNow,
    ),
  );
}

Future<void> _openFromPetTab(WidgetTester tester) async {
  await tapTab(tester, 'Cucciolo');
  await tester.tap(find.byTooltip('Apri l\'armadio'));
  await tester.pumpAndSettle();
}

/// Scrolls the wardrobe list (not the tab still alive below it).
Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find
        .descendant(
            of: find.byType(WardrobeScreen), matching: find.byType(Scrollable))
        .first,
  );
  await tester.pumpAndSettle();
}

Future<void> _tapButton(WidgetTester tester, String label) async {
  final button = find.widgetWithText(EcoButton, label);
  await _scrollTo(tester, button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

EcoButton _button(WidgetTester tester, String label) =>
    tester.widget<EcoButton>(find.widgetWithText(EcoButton, label));

final _petWearsSomething = find.descendant(
  of: find.byType(PetArt),
  matching: find.byType(CosmeticArt),
);

void main() {
  testWidgets('the Pet room opens the wardrobe with odds and duplicate rule',
      (tester) async {
    await pumpEcoQuestApp(tester,
        repository: InMemorySaveRepository(_player()));
    await _openFromPetTab(tester);

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Armadio'), findsOneWidget);
    expect(find.text('Comune: 60%'), findsOneWidget);
    expect(find.text('Raro: 30%'), findsOneWidget);
    expect(find.text('Epico: 10%'), findsOneWidget);
    expect(find.textContaining('ricevi monete al suo posto: 20 (comune)'),
        findsOneWidget);
    expect(_petWearsSomething, findsNothing);
  });

  testWidgets('Home opens the wardrobe too', (tester) async {
    await pumpEcoQuestApp(tester);
    await scrollTo(tester, find.text('Armadio del cucciolo'));
    await tester.tap(find.text('Armadio del cucciolo'));
    await tester.pumpAndSettle();

    expect(find.text('Ruota dei premi'), findsOneWidget);
  });

  testWidgets('a roll reveals a new item that the pet can wear at once',
      (tester) async {
    final repository = InMemorySaveRepository(_player());
    await pumpEcoQuestApp(tester, repository: repository);
    await _openFromPetTab(tester);

    await _tapButton(tester, 'Usa 1 biglietto');
    expect(find.text('Nuovo oggetto!'), findsOneWidget);

    await tester.tap(find.text('Indossa ora'));
    await tester.pumpAndSettle();

    final saved = repository.saved!;
    expect(saved.progress.tickets, 0);
    expect(saved.inventory.ownedItemIds, hasLength(1));
    expect(saved.inventory.equippedBySlot.values,
        [saved.inventory.ownedItemIds.single]);
    expect(find.textContaining('Foglia indossa: Oggetto '), findsOneWidget);
    await tester.scrollUntilVisible(find.byType(PetArt), -200,
        scrollable: find
            .descendant(
                of: find.byType(WardrobeScreen),
                matching: find.byType(Scrollable))
            .first);
    expect(_petWearsSomething, findsOneWidget);
    // No tickets left: the roll button is disabled and says why.
    expect(_button(tester, 'Usa 1 biglietto').onPressed, isNull);
    expect(find.textContaining('Non hai biglietti'), findsOneWidget);
  });

  testWidgets('buy an item in the shop, wear it, take it off',
      (tester) async {
    final repository = InMemorySaveRepository(_player(coins: 70));
    await pumpEcoQuestApp(tester, repository: repository);
    await _openFromPetTab(tester);

    // 70 coins: commons (60) can be bought, rares (150) cannot.
    await _scrollTo(tester, find.text('Oggetto head common'));
    await tester.tap(find.widgetWithText(EcoButton, 'Compra (60 monete)').first);
    await tester.pumpAndSettle();

    expect(repository.saved!.progress.coins, 10);
    expect(find.textContaining('Ti servono altre 140 monete'), findsWidgets);
    expect(repository.saved!.inventory.ownedItemIds, {'head_common'});
    expect(find.text('Hai comprato: Oggetto head common!'), findsOneWidget);

    await _tapButton(tester, 'Indossa');
    expect(repository.saved!.inventory.equippedBySlot,
        {'head': 'head_common'});

    await _tapButton(tester, 'Togli');
    expect(repository.saved!.inventory.equippedBySlot, isEmpty);
  });

  testWidgets('not enough coins for a ticket: the button is disabled',
      (tester) async {
    await pumpEcoQuestApp(tester,
        repository: InMemorySaveRepository(_player(coins: 99)));
    await _openFromPetTab(tester);

    await _scrollTo(
        tester, find.widgetWithText(EcoButton, 'Compra un biglietto (100 monete)'));
    expect(_button(tester, 'Compra un biglietto (100 monete)').onPressed,
        isNull);
  });

  testWidgets('a worn item shows on the pet in the Pet tab', (tester) async {
    final state = _player();
    await pumpEcoQuestApp(tester,
        repository: InMemorySaveRepository(state.copyWith(
          inventory: state.inventory.add('face_rare').equip('face', 'face_rare'),
        )));
    await tapTab(tester, 'Cucciolo');

    expect(_petWearsSomething, findsOneWidget);
  });

  testWidgets('wardrobe meets the accessibility guidelines', (tester) async {
    await pumpEcoQuestApp(tester,
        repository: InMemorySaveRepository(_player(coins: 200)));
    await _openFromPetTab(tester);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  });

  testWidgets('small phone with 200% text: wardrobe and reveal fit',
      (tester) async {
    useSmallPhoneWithLargeText(tester);
    await pumpEcoQuestApp(tester,
        repository: InMemorySaveRepository(_player(coins: 70)));
    await _openFromPetTab(tester);

    await _tapButton(tester, 'Usa 1 biglietto');
    expect(find.text('Nuovo oggetto!'), findsOneWidget);
    await tester.ensureVisible(find.text('Chiudi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chiudi'));
    await tester.pumpAndSettle();
    expect(find.text('Nuovo oggetto!'), findsNothing);
    await _scrollTo(tester, find.text('I miei oggetti'));
    expect(tester.takeException(), isNull);
  });
}
