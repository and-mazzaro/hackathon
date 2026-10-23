import 'package:ecoquest/core/widgets/eco_button.dart';
import 'package:ecoquest/data/save/in_memory_save_repository.dart';
import 'package:ecoquest/domain/models/cosmetic_item.dart';
import 'package:ecoquest/domain/models/game_state.dart';
import 'package:ecoquest/domain/models/pet_state.dart';
import 'package:ecoquest/features/pet/pet_art.dart';
import 'package:ecoquest/features/wardrobe/wardrobe_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/cosmetic_fixtures.dart';
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

const _rarityLabels = {
  CosmeticRarity.common: 'Comune',
  CosmeticRarity.uncommon: 'Non comune',
  CosmeticRarity.rare: 'Raro',
  CosmeticRarity.epic: 'Epico',
  CosmeticRarity.legendary: 'Leggendario',
  CosmeticRarity.mythic: 'Mitico',
};

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

/// A very tall window, so the whole wardrobe list is built at once.
void _useTallWindow(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// [text] inside the reveal sheet (the wardrobe stays built below it).
Finder _inSheet(String text) =>
    find.descendant(of: find.byType(BottomSheet), matching: find.text(text));

/// Looks only at what the pet is given to wear, so it works however
/// PetArt draws the items.
final _petWearsSomething = find.byWidgetPredicate(
  (widget) => widget is PetArt && widget.outfit.isNotEmpty,
  description: 'PetArt wearing an item',
);

void main() {
  testWidgets('the Pet room opens the wardrobe with odds and duplicate rule',
      (tester) async {
    await pumpEcoQuestApp(tester,
        repository: InMemorySaveRepository(_player()));
    await _openFromPetTab(tester);

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Armadio'), findsOneWidget);
    expect(find.text('Comune: 40%'), findsOneWidget);
    expect(find.text('Mitico: 2%'), findsOneWidget);
    expect(find.textContaining('ricevi monete al suo posto: comune 15,'),
        findsOneWidget);
    expect(_petWearsSomething, findsNothing);
  });

  testWidgets('the roll card shows all six odds and all six refunds',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpEcoQuestApp(tester,
        repository: InMemorySaveRepository(_player()));
    await _openFromPetTab(tester);

    for (final line in [
      'Comune: 40%',
      'Non comune: 25%',
      'Raro: 17%',
      'Epico: 10%',
      'Leggendario: 6%',
      'Mitico: 2%',
    ]) {
      expect(find.text(line), findsOneWidget, reason: line);
    }
    // The chips are one screen-reader item, in words.
    expect(
        find.bySemanticsLabel('Probabilità: comune 40 percento, '
            'non comune 25 percento, raro 17 percento, epico 10 percento, '
            'leggendario 6 percento, mitico 2 percento'),
        findsOneWidget);
    expect(
        find.text('Se esce un oggetto che hai già, ricevi monete al suo '
            'posto: comune 15, non comune 25, raro 40, epico 60, '
            'leggendario 90, mitico 150.'),
        findsOneWidget);

    // The shop note is built from the rarities the shop does not sell.
    await _scrollTo(
        tester,
        find.text('Gli oggetti epici, leggendari e mitici si trovano solo '
            'nella ruota dei premi.'));
    semantics.dispose();
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

  testWidgets('a seeded roll reveals the saved item with its rarity',
      (tester) async {
    // pumpEcoQuestApp rolls with Random(42), so this run is repeatable.
    final repository = InMemorySaveRepository(_player());
    await pumpEcoQuestApp(tester, repository: repository);
    await _openFromPetTab(tester);

    await _tapButton(tester, 'Usa 1 biglietto');

    final item = testCosmeticCatalog()
        .byId(repository.saved!.inventory.ownedItemIds.single)!;
    final label = _rarityLabels[item.rarity]!;
    final special = item.rarity.index >= CosmeticRarity.legendary.index;
    expect(_inSheet('Nuovo oggetto!'), findsOneWidget);
    expect(_inSheet(item.name), findsOneWidget);
    expect(_inSheet(label), findsOneWidget);
    expect(_inSheet('$label!'), special ? findsOneWidget : findsNothing);
  });

  testWidgets('a mythic item gets its own heading, announced at once',
      (tester) async {
    final semantics = tester.ensureSemantics();
    final pebble = testCosmetic(CosmeticSlot.paws, CosmeticRarity.mythic);
    final repository = InMemorySaveRepository(_player());
    // With a single item every roll gives it.
    await pumpEcoQuestApp(tester,
        repository: repository, cosmetics: CosmeticCatalog([pebble]));
    await _openFromPetTab(tester);

    await _tapButton(tester, 'Usa 1 biglietto');

    expect(_inSheet('Mitico!'), findsOneWidget);
    expect(_inSheet('Nuovo oggetto!'), findsOneWidget);
    expect(_inSheet('Oggetto paws mythic'), findsOneWidget);
    expect(_inSheet('Mitico'), findsOneWidget);
    // Heading and "new item" are one header, read out when the sheet opens.
    expect(
      tester.getSemantics(_inSheet('Mitico!')),
      isSemantics(
        label: 'Mitico!\nNuovo oggetto!',
        isHeader: true,
        isLiveRegion: true,
      ),
    );
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    await tester.tap(find.text('Indossa ora'));
    await tester.pumpAndSettle();
    expect(repository.saved!.inventory.equippedBySlot, {'paws': pebble.id});
    semantics.dispose();
  });

  testWidgets('buy an item in the shop, wear it, take it off',
      (tester) async {
    final repository = InMemorySaveRepository(_player(coins: 70));
    await pumpEcoQuestApp(tester, repository: repository);
    await _openFromPetTab(tester);

    // 70 coins: commons (60) can be bought, uncommons (100) cannot.
    await _scrollTo(tester, find.text('Oggetto head common'));
    await tester.tap(find.widgetWithText(EcoButton, 'Compra (60 monete)').first);
    await tester.pumpAndSettle();

    expect(repository.saved!.progress.coins, 10);
    expect(find.textContaining('Ti servono altre 90 monete'), findsWidgets);
    expect(repository.saved!.inventory.ownedItemIds, {'head_common'});
    expect(find.text('Hai comprato: Oggetto head common!'), findsOneWidget);

    await _tapButton(tester, 'Indossa');
    expect(repository.saved!.inventory.equippedBySlot,
        {'head': 'head_common'});

    await _tapButton(tester, 'Togli');
    expect(repository.saved!.inventory.equippedBySlot, isEmpty);
  });

  testWidgets('the shop sells 60/100/160 and never roll-only items',
      (tester) async {
    _useTallWindow(tester);
    await pumpEcoQuestApp(tester,
        repository: InMemorySaveRepository(_player(coins: 500)),
        cosmetics: CosmeticCatalog([
          for (final rarity in CosmeticRarity.values)
            testCosmetic(CosmeticSlot.head, rarity),
        ]));
    await _openFromPetTab(tester);
    await _scrollTo(tester, find.text('I miei oggetti'));

    for (final (name, price) in [
      ('Oggetto head common', 60),
      ('Oggetto head uncommon', 100),
      ('Oggetto head rare', 160),
    ]) {
      expect(find.text(name), findsOneWidget, reason: name);
      expect(find.widgetWithText(EcoButton, 'Compra ($price monete)'),
          findsOneWidget);
    }
    expect(find.textContaining('Compra ('), findsNWidgets(3));
    for (final rarity in ['epic', 'legendary', 'mythic']) {
      expect(find.text('Oggetto head $rarity'), findsNothing, reason: rarity);
    }
  });

  testWidgets('my items are grouped by slot: head, face, neck, paws',
      (tester) async {
    _useTallWindow(tester);
    // Catalog order on purpose different from the slot order.
    final items = [
      testCosmetic(CosmeticSlot.paws, CosmeticRarity.epic),
      testCosmetic(CosmeticSlot.face, CosmeticRarity.mythic),
      testCosmetic(CosmeticSlot.neck, CosmeticRarity.legendary),
      testCosmetic(CosmeticSlot.head, CosmeticRarity.epic),
    ];
    final state = _player();
    var inventory = state.inventory;
    for (final item in items) {
      inventory = inventory.add(item.id);
    }
    await pumpEcoQuestApp(tester,
        repository: InMemorySaveRepository(state.copyWith(inventory: inventory)),
        cosmetics: CosmeticCatalog(items));
    await _openFromPetTab(tester);
    await _scrollTo(tester, find.text('Zampe'));

    double top(String text) => tester.getTopLeft(find.text(text)).dy;
    final headers = ['Testa', 'Viso', 'Collo', 'Zampe'];
    final names = [
      'Oggetto head epic',
      'Oggetto face mythic',
      'Oggetto neck legendary',
      'Oggetto paws epic',
    ];
    for (var i = 0; i < headers.length; i++) {
      expect(top(names[i]), greaterThan(top(headers[i])), reason: names[i]);
      if (i + 1 < headers.length) {
        expect(top(headers[i + 1]), greaterThan(top(names[i])),
            reason: headers[i + 1]);
      }
    }
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

  testWidgets('small phone with 200% text: a legendary reveal fits',
      (tester) async {
    useSmallPhoneWithLargeText(tester);
    await pumpEcoQuestApp(tester,
        repository: InMemorySaveRepository(_player()),
        cosmetics: CosmeticCatalog(
            [testCosmetic(CosmeticSlot.neck, CosmeticRarity.legendary)]));
    await _openFromPetTab(tester);

    await _tapButton(tester, 'Usa 1 biglietto');
    expect(find.text('Leggendario!'), findsOneWidget);
    await tester.ensureVisible(find.text('Chiudi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chiudi'));
    await tester.pumpAndSettle();
    expect(find.text('Leggendario!'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
