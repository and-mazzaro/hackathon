import 'package:ecoquest/core/notifications/reminder_scheduler.dart';

/// Records what the app asks of the notification system.
class FakeReminderScheduler implements ReminderScheduler {
  FakeReminderScheduler({this.grantPermission = true, this.fromNotification = false});

  bool grantPermission;
  bool fromNotification;

  int permissionRequests = 0;
  int cancelCount = 0;

  /// The daily reminder currently scheduled (at most one), or null.
  ({int hour, int minute, String title, String body})? scheduled;

  @override
  Future<bool> launchedFromNotification() async => fromNotification;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return grantPermission;
  }

  @override
  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    scheduled = (hour: hour, minute: minute, title: title, body: body);
  }

  @override
  Future<void> cancelAll() async {
    cancelCount++;
    scheduled = null;
  }
}
