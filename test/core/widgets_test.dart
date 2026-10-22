import 'package:ecoquest/app/theme/eco_colors.dart';
import 'package:ecoquest/core/widgets/currency_chip.dart';
import 'package:ecoquest/core/widgets/eco_button.dart';
import 'package:ecoquest/core/widgets/eco_card.dart';
import 'package:ecoquest/core/widgets/stat_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/pump_app.dart';

void main() {
  group('StatBar', () {
    testWidgets('is read as one label with a percent value', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(localized(const StatBar(
        label: 'Sazietà',
        value: 0.4,
        color: EcoColors.satiety,
      )));

      expect(find.text('40%'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(StatBar)),
        isSemantics(label: 'Sazietà', value: '40 percento'),
      );
      semantics.dispose();
    });

    testWidgets('clamps values outside 0..1', (tester) async {
      await tester.pumpWidget(localized(const StatBar(
        label: 'Pulizia',
        value: 1.7,
        color: EcoColors.cleanliness,
      )));

      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('can show and speak custom value texts', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(localized(const StatBar(
        label: 'Livello 1',
        value: 0.4,
        color: EcoColors.xp,
        valueText: '40/100',
        semanticsValue: '40 su 100 punti esperienza',
      )));

      expect(find.text('40/100'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(StatBar)),
        isSemantics(
            label: 'Livello 1', value: '40 su 100 punti esperienza'),
      );
      semantics.dispose();
    });
  });

  group('CurrencyChip', () {
    testWidgets('uses Italian singular', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
          localized(const CurrencyChip(kind: CurrencyKind.coins, amount: 1)));

      expect(find.bySemanticsLabel('1 moneta'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('uses Italian plural and thousands separator', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(localized(
          const CurrencyChip(kind: CurrencyKind.coins, amount: 1250)));

      expect(find.text('1.250'), findsOneWidget);
      expect(find.bySemanticsLabel('1.250 monete'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('EcoCard', () {
    testWidgets('a tappable card is a single button for screen readers',
        (tester) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(localized(EcoCard(
        onTap: () => taps++,
        child: const Column(children: [Text('Quiz'), Text('5 domande')]),
      )));

      expect(
        tester.getSemantics(find.byType(EcoCard)),
        isSemantics(label: 'Quiz\n5 domande', isButton: true),
      );
      await tester.tap(find.byType(EcoCard));
      expect(taps, 1);
      semantics.dispose();
    });
  });

  group('EcoButton', () {
    testWidgets('is at least 56 px tall and calls onPressed', (tester) async {
      var pressed = false;
      await tester.pumpWidget(localized(EcoButton(
        label: 'Inizia',
        icon: Icons.play_arrow_rounded,
        onPressed: () => pressed = true,
      )));

      expect(tester.getSize(find.byType(EcoButton)).height,
          greaterThanOrEqualTo(56));
      await tester.tap(find.text('Inizia'));
      expect(pressed, isTrue);
    });
  });
}
