import 'package:ecoquest/core/widgets/eco_button.dart';
import 'package:ecoquest/data/save/in_memory_save_repository.dart';
import 'package:ecoquest/domain/models/activity_log.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/fake_reminder_scheduler.dart';
import 'helpers/pump_app.dart';

final _switch = find.text('Ricordamelo ogni giorno');

Future<void> _openProfileReminder(WidgetTester tester,
    {Finder? target}) async {
  await tapTab(tester, 'Profilo');
  await scrollTo(tester, target ?? find.text('Cancella la mia attività'));
}

void main() {
  testWidgets('onboarding never asks for notification permission',
      (tester) async {
    final reminders = FakeReminderScheduler();
    await pumpEcoQuestApp(tester,
        repository: InMemorySaveRepository(),
        reminders: reminders,
        trackActivity: true);

    Future<void> tapButton(String label) async {
      await tester.tap(find.widgetWithText(EcoButton, label));
      await tester.pumpAndSettle();
    }

    await tapButton('Iniziamo');
    await tester.ensureVisible(find.text('Clima'));
    await tester.tap(find.text('Clima'));
    await tester.pump();
    await tapButton('Avanti');
    await tapButton('Salta');

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(reminders.permissionRequests, 0);
    expect(reminders.scheduled, isNull);
  });

  testWidgets('turning the reminder on schedules exactly one daily one; '
      'off cancels it', (tester) async {
    final reminders = FakeReminderScheduler();
    final repository = InMemorySaveRepository(onboardedState());
    await pumpEcoQuestApp(tester,
        repository: repository, reminders: reminders);
    await _openProfileReminder(tester, target: _switch);

    await tester.ensureVisible(_switch);
    await tester.tap(_switch);
    await tester.pumpAndSettle();

    expect(reminders.permissionRequests, 1);
    expect(repository.saved!.reminder.enabled, isTrue);
    expect(reminders.scheduled!.hour, 18);
    expect(reminders.scheduled!.minute, 0);
    expect(reminders.scheduled!.title, 'Il tuo cucciolo ti aspetta!');
    expect(reminders.scheduled!.body, contains('riciclo e rifiuti'));
    expect(find.text('Ora del promemoria: 18:00'), findsOneWidget);

    await tester.tap(_switch);
    await tester.pumpAndSettle();
    expect(repository.saved!.reminder.enabled, isFalse);
    expect(reminders.scheduled, isNull);
  });

  testWidgets('permission denied: stays off, one calm note, app works',
      (tester) async {
    final reminders = FakeReminderScheduler(grantPermission: false);
    final repository = InMemorySaveRepository(onboardedState());
    await pumpEcoQuestApp(tester,
        repository: repository, reminders: reminders);
    await _openProfileReminder(tester, target: _switch);

    await tester.ensureVisible(_switch);
    await tester.tap(_switch);
    await tester.pumpAndSettle();

    expect(reminders.permissionRequests, 1);
    expect(reminders.scheduled, isNull);
    expect(find.textContaining('Le notifiche sono bloccate'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    // Nothing else asks again: moving around the app is fine.
    await tapTab(tester, 'Home');
    await tapTab(tester, 'Impara');
    expect(reminders.permissionRequests, 1);
  });

  testWidgets('"Cancella la mia attività" clears the log and the reminder',
      (tester) async {
    final reminders = FakeReminderScheduler();
    final repository = InMemorySaveRepository(onboardedState().copyWith(
      activity: ActivityLog(days: [
        DayActivity(day: dayKey(testNow), opens: 2, activities: 3),
      ]),
      reminder: const ReminderSettings(enabled: true, hour: 17, minute: 30),
    ));
    await pumpEcoQuestApp(tester,
        repository: repository, reminders: reminders);
    expect(reminders.scheduled!.hour, 17);

    await _openProfileReminder(tester);
    await tester.tap(find.text('Cancella la mia attività'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Cancella'));
    await tester.pumpAndSettle();

    expect(repository.saved!.activity.days, isEmpty);
    expect(repository.saved!.reminder.enabled, isFalse);
    expect(reminders.scheduled, isNull);
    expect(repository.saved!.progress.coins, 0);
    expect(find.text('Attività cancellata.'), findsOneWidget);
  });

  testWidgets('small phone with 200% text: reminder and data cards fit',
      (tester) async {
    useSmallPhoneWithLargeText(tester);
    await pumpEcoQuestApp(tester,
        repository: InMemorySaveRepository(onboardedState().copyWith(
            reminder: const ReminderSettings(enabled: true))));
    await tapTab(tester, 'Profilo');
    await scrollTo(tester, find.text('Cambia ora'));
    await scrollTo(tester, find.text('Cancella la mia attività'));
    expect(tester.takeException(), isNull);
  });
}
