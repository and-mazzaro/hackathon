import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'reminder_scheduler.dart';

/// [ReminderScheduler] with `flutter_local_notifications`: everything
/// happens on the phone. Errors are logged and swallowed: a reminder that
/// cannot be scheduled must never break the game.
class LocalReminderScheduler implements ReminderScheduler {
  LocalReminderScheduler([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _ready;

  /// The one and only reminder id: scheduling again replaces it.
  static const _reminderId = 1;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'daily_reminder',
      'Promemoria giornaliero',
      channelDescription: 'Un solo avviso al giorno, se lo hai attivato.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> _init() => _ready ??= _initialize();

  Future<void> _initialize() async {
    tz_data.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (error) {
      debugPrint('Reminder: unknown time zone, using UTC ($error)');
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Never ask on iOS at start: only when the player turns it on.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  @override
  Future<bool> launchedFromNotification() async {
    try {
      await _init();
      final details = await _plugin.getNotificationAppLaunchDetails();
      return details?.didNotificationLaunchApp ?? false;
    } catch (error) {
      debugPrint('Reminder: launch details failed ($error)');
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      await _init();
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        return await ios.requestPermissions(alert: true, sound: true) ??
            false;
      }
      return false;
    } catch (error) {
      debugPrint('Reminder: permission request failed ($error)');
      return false;
    }
  }

  @override
  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    try {
      await _init();
      final now = tz.TZDateTime.now(tz.local);
      var next =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
      await _plugin.cancelAll();
      await _plugin.zonedSchedule(
        id: _reminderId,
        scheduledDate: next,
        notificationDetails: _details,
        // Inexact: no exact-alarm permission needed; a few minutes late
        // is fine for a gentle reminder.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: title,
        body: body,
        // Repeats every day at this time: at most one per day.
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (error) {
      debugPrint('Reminder: scheduling failed ($error)');
    }
  }

  @override
  Future<void> cancelAll() async {
    try {
      await _init();
      await _plugin.cancelAll();
    } catch (error) {
      debugPrint('Reminder: cancel failed ($error)');
    }
  }
}
