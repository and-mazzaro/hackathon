import 'package:ecoquest/core/widgets/eco_button.dart';
import 'package:ecoquest/data/save/in_memory_save_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_app.dart';

/// Fixture item names say their bin: "Rifiuto paper 1" → "Carta e cartone".
const _binFor = {
  'plastic_metal': 'Plastica e metalli',
  'paper': 'Carta e cartone',
  'organic': 'Organico',
  'glass': 'Vetro',
  'residual': 'Indifferenziato',
};
const _wrongBinFor = {
  'plastic_metal': 'Vetro',
  'paper': 'Organico',
  'organic': 'Carta e cartone',
  'glass': 'Indifferenziato',
  'residual': 'Plastica e metalli',
};

final _items = find.textContaining(RegExp(r'^Rifiuto '));

Future<void> _openCleanup(WidgetTester tester) async {
  await scrollTo(tester, find.text('Pulisci la stanza'));
  await tester.tap(find.text('Pulisci la stanza'));
  await tester.pumpAndSettle();
}

/// Sorts the first item still in the room; returns its name.
Future<String> _sortFirst(WidgetTester tester, {bool right = true}) async {
  final name = tester.widget<Text>(_items.first).data!;
  final category = name.split(' ')[1];
  await tester.tap(find.text(name));
  await tester.pump();
  await tester.tap(find.text((right ? _binFor : _wrongBinFor)[category]!));
  await tester.pumpAndSettle();
  return name;
}

void main() {
  testWidgets('Home opens Room Cleanup full screen with 8 items',
      (tester) async {
    await pumpEcoQuestApp(tester);
    await _openCleanup(tester);

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('0 di 8 sistemati'), findsOneWidget);
    expect(_items, findsNWidgets(8));
    for (final bin in _binFor.values) {
      expect(find.text(bin), findsOneWidget);
    }
  });

  testWidgets('tap an item, then the right bin: praise and explanation',
      (tester) async {
    await pumpEcoQuestApp(tester);
    await _openCleanup(tester);

    final name = await _sortFirst(tester);

    expect(find.textContaining('Giusto! $name va in:'), findsOneWidget);
    expect(find.text('1 di 8 sistemati'), findsOneWidget);
    expect(find.text(name), findsNothing); // left the room
  });

  testWidgets('a wrong bin gets a kind correction with the right bin',
      (tester) async {
    await pumpEcoQuestApp(tester);
    await _openCleanup(tester);

    final name = await _sortFirst(tester, right: false);
    final rightBin = _binFor[name.split(' ')[1]]!;

    expect(find.text('Quasi! $name va in: $rightBin.'), findsOneWidget);
    expect(find.textContaining('Perché'), findsOneWidget);
    expect(find.text('Fonte: Fonte rifiuti'), findsOneWidget);
  });

  testWidgets('a bin tapped with nothing selected explains what to do',
      (tester) async {
    await pumpEcoQuestApp(tester);
    await _openCleanup(tester);

    await tester.tap(find.text('Vetro'));
    await tester.pump();

    expect(find.text('Prima scegli un rifiuto nella stanza.'), findsOneWidget);
    expect(find.text('0 di 8 sistemati'), findsOneWidget);
  });

  testWidgets('an item can be dragged onto a bin right away, without holding',
      (tester) async {
    await pumpEcoQuestApp(tester);
    await _openCleanup(tester);

    final name = tester.widget<Text>(_items.first).data!;
    final from = tester.getCenter(find.text(name));
    final to = tester.getCenter(find.text(_binFor[name.split(' ')[1]]!));
    // A plain drag, like a finger on a phone: no pause before moving.
    final gesture = await tester.startGesture(from);
    for (var step = 1; step <= 10; step++) {
      await gesture.moveTo(Offset.lerp(from, to, step / 10)!);
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.textContaining('Giusto! $name'), findsOneWidget);
    expect(find.text('1 di 8 sistemati'), findsOneWidget);
  });

  testWidgets('an item dropped outside the bins goes back to the room',
      (tester) async {
    await pumpEcoQuestApp(tester);
    await _openCleanup(tester);

    final name = tester.widget<Text>(_items.first).data!;
    await tester.drag(find.text(name), const Offset(0, 60));
    await tester.pumpAndSettle();

    expect(find.text(name), findsOneWidget);
    expect(find.text('0 di 8 sistemati'), findsOneWidget);
  });

  testWidgets('a full round pays coins and XP once and is saved',
      (tester) async {
    final repository = InMemorySaveRepository(onboardedState());
    await pumpEcoQuestApp(tester, repository: repository);
    await _openCleanup(tester);

    for (var i = 0; i < 8; i++) {
      await _sortFirst(tester);
    }
    expect(find.text('La stanza è pulita!'), findsOneWidget);
    await tester.tap(find.widgetWithText(EcoButton, 'Vedi il risultato'));
    await tester.pumpAndSettle();

    // 8 × 2 coins + 2 combos × 3 = 22 coins; 100% right → +10 XP
    expect(find.text('8 rifiuti su 8 nel bidone giusto'), findsOneWidget);
    expect(find.text('+22 monete'), findsOneWidget);
    expect(find.text('+10 XP'), findsOneWidget);
    expect(repository.saved!.progress.coins, 22);
    expect(repository.saved!.recycling.roundsCompleted, 1);

    await tester.tap(find.widgetWithText(EcoButton, 'Chiudi'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget); // back on Home
  });

  testWidgets('trash shows in the room and is gone after a cleanup',
      (tester) async {
    final semantics = tester.ensureSemantics();
    final repository = InMemorySaveRepository(onboardedState());
    await pumpEcoQuestApp(tester, repository: repository);

    // An old save without a cleanup time: 2 items on the room floor.
    final roomTrash = find.byWidgetPredicate((widget) =>
        widget.key is ValueKey<String> &&
        (widget.key! as ValueKey<String>).value.startsWith('room-trash-'));
    expect(roomTrash, findsNWidgets(2));
    expect(find.bySemanticsLabel(RegExp('Nella stanza ci sono 2 rifiuti: ')),
        findsOneWidget);

    // Tapping the trash opens Room Cleanup.
    await tester.tap(roomTrash.first);
    await tester.pumpAndSettle();
    expect(find.text('0 di 8 sistemati'), findsOneWidget);

    for (var i = 0; i < 8; i++) {
      await _sortFirst(tester);
    }
    await tester.tap(find.widgetWithText(EcoButton, 'Vedi il risultato'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(EcoButton, 'Chiudi'));
    await tester.pumpAndSettle();

    expect(repository.saved!.lastCleanupAt, testNow);
    expect(roomTrash, findsNothing);
    expect(find.bySemanticsLabel(RegExp('Nella stanza')), findsNothing);
    await scrollTo(tester, find.text('La stanza è pulita! Torna più tardi'));
    expect(find.text('La stanza è pulita! Torna più tardi'), findsOneWidget);

    // The Pet tab button says the room is clean and is disabled.
    await tapTab(tester, 'Cucciolo');
    final button =
        find.widgetWithText(EcoButton, 'La stanza è pulita! Torna più tardi');
    await scrollTo(tester, button);
    expect(tester.widget<EcoButton>(button).onPressed, isNull);
    semantics.dispose();
  });

  testWidgets('leaving a started round asks first and saves nothing',
      (tester) async {
    final repository = InMemorySaveRepository(onboardedState());
    await pumpEcoQuestApp(tester, repository: repository);
    await _openCleanup(tester);
    await _sortFirst(tester);

    await pressAndroidBack(tester);
    expect(find.text('Vuoi interrompere la pulizia?'), findsOneWidget);
    await tester.tap(find.text('Esci'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(repository.saveCount, 0);
  });

  testWidgets('the Pet tab also opens Room Cleanup', (tester) async {
    await pumpEcoQuestApp(tester);
    await tapTab(tester, 'Cucciolo');
    final button = find.widgetWithText(EcoButton, 'Pulisci la stanza');
    await scrollTo(tester, button);
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text('0 di 8 sistemati'), findsOneWidget);
  });

  testWidgets('screen readers hear selection and bins', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpEcoQuestApp(tester);
    await _openCleanup(tester);

    final name = tester.widget<Text>(_items.first).data!;
    await tester.tap(find.text(name));
    await tester.pump();

    expect(tester.getSemantics(find.text(name)),
        isSemantics(label: name, isButton: true, isSelected: true));
    expect(tester.getSemantics(find.text('Organico')),
        isSemantics(label: 'Organico', isButton: true));
    semantics.dispose();
  });

  testWidgets('cleanup meets the accessibility guidelines', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpEcoQuestApp(tester);
    await _openCleanup(tester);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    await _sortFirst(tester, right: false); // with feedback card
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
  });

  testWidgets('small phone with 200% text: cleanup and result fit',
      (tester) async {
    useSmallPhoneWithLargeText(tester);
    await pumpEcoQuestApp(tester);
    await _openCleanup(tester);

    for (var i = 0; i < 8; i++) {
      final name = tester.widget<Text>(_items.first).data!;
      await tester.ensureVisible(find.text(name));
      await tester.pumpAndSettle();
      await tester.tap(find.text(name));
      await tester.pump();
      // With large text the bins scroll with the page.
      final bin = find.text(_binFor[name.split(' ')[1]]!);
      await tester.ensureVisible(bin);
      await tester.pumpAndSettle();
      await tester.tap(bin);
      await tester.pumpAndSettle();
    }
    final result = find.widgetWithText(EcoButton, 'Vedi il risultato');
    await tester.ensureVisible(result);
    await tester.pumpAndSettle();
    await tester.tap(result);
    await tester.pumpAndSettle();

    expect(find.text('+22 monete'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
