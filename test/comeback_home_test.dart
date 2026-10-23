import 'package:ecoquest/data/save/in_memory_save_repository.dart';
import 'package:ecoquest/domain/models/activity_log.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_app.dart';

void main() {
  // Last played 10 days before testNow → low score.
  final lowScoreLog = ActivityLog(days: [
    DayActivity(day: dayKey(DateTime(2026, 10, 12)), opens: 1, activities: 1),
  ]);

  testWidgets('low score: friendly message, easier activity, gift once',
      (tester) async {
    final repository = InMemorySaveRepository(
        onboardedState().copyWith(activity: lowScoreLog));
    await pumpEcoQuestApp(tester, repository: repository);

    expect(find.text('Mi sei mancato!'), findsOneWidget);
    // The egg cannot be cared for yet → the cleanup is suggested.
    expect(find.text('Idea facile: un giro di Pulisci la stanza'),
        findsOneWidget);
    // Nothing is blocked: the usual activities are still on Home.
    await scrollTo(tester, find.text('Pulisci la stanza'));
    expect(find.text('Quiz del giorno'), findsOneWidget);

    final gift = find.text('Prendi il regalo: +10 monete');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await tester.pumpAndSettle();
    await scrollTo(tester, gift);
    await tester.tap(gift);
    await tester.pumpAndSettle();

    expect(repository.saved!.progress.coins, 10);
    expect(repository.saved!.progress.claimedRewardIds,
        contains('comeback:2026-10-22'));
    expect(gift, findsNothing);
    expect(find.text('Regalo preso! Che bello giocare di nuovo insieme.'),
        findsOneWidget);
  });

  testWidgets('new player: no comeback card (neutral score)', (tester) async {
    await pumpEcoQuestApp(tester);
    expect(find.text('Mi sei mancato!'), findsNothing);
  });

  testWidgets('opening the app records one entry in the activity log',
      (tester) async {
    final repository = InMemorySaveRepository(onboardedState());
    await pumpEcoQuestApp(tester, repository: repository, trackActivity: true);

    final today = repository.saved!.activity.dayOf(testNow)!;
    expect(today.opens, 1);
    expect(today.notificationOpens, 0);
    expect(repository.saved!.activity.lastSessionEndedCleanly, isFalse);
  });
}
