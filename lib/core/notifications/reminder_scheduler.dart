import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_reminder_scheduler.dart';

/// Local (on-phone) reminder notifications. No server, no push service.
///
/// The saved `ReminderSettings` are applied only by `ActivityBinding`
/// (which also asks [launchedFromNotification] once at start). Screens
/// call only [requestPermission], when the player turns the reminder on.
abstract interface class ReminderScheduler {
  /// True when this app start came from tapping our reminder.
  Future<bool> launchedFromNotification();

  /// Asks the system permission (Android 13+). Only called when the
  /// player turns the reminder on, never during onboarding.
  /// Returns false when refused: the app keeps working, no nagging.
  Future<bool> requestPermission();

  /// Replaces any earlier reminder with ONE daily notification at
  /// [hour]:[minute] (so at most one per day).
  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required String title,
    required String body,
  });

  /// Removes every scheduled reminder.
  Future<void> cancelAll();
}

/// Does nothing: used where notifications are not available (tests,
/// web preview).
class NoReminderScheduler implements ReminderScheduler {
  const NoReminderScheduler();

  @override
  Future<bool> launchedFromNotification() async => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> cancelAll() async {}
}

/// The real phone notifications; nothing on the web preview (D13).
/// Tests override it with a fake.
final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) =>
    kIsWeb ? const NoReminderScheduler() : LocalReminderScheduler());
