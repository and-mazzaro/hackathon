import 'json_utils.dart';

/// What the player did on one calendar day. Only counts: no times, no
/// places, no device data.
class DayActivity {
  const DayActivity({
    required this.day,
    this.opens = 0,
    this.notificationOpens = 0,
    this.activities = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.uncleanExits = 0,
  });

  /// The local date as `YYYY-MM-DD` (see [dayKey]).
  final String day;

  /// Times the app was opened or came back to the screen that day.
  final int opens;

  /// Of those, how many came from tapping the reminder notification.
  final int notificationOpens;

  /// Quizzes, cleanup rounds and pet care actions completed.
  final int activities;

  /// Quiz answers and sorted items, right and wrong.
  final int correctAnswers;
  final int wrongAnswers;

  /// Times the app started after the previous session did not end
  /// normally (for example a crash).
  final int uncleanExits;

  bool get isActive => opens > 0 || activities > 0;

  DayActivity copyWith({
    int? opens,
    int? notificationOpens,
    int? activities,
    int? correctAnswers,
    int? wrongAnswers,
    int? uncleanExits,
  }) {
    return DayActivity(
      day: day,
      opens: opens ?? this.opens,
      notificationOpens: notificationOpens ?? this.notificationOpens,
      activities: activities ?? this.activities,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      uncleanExits: uncleanExits ?? this.uncleanExits,
    );
  }

  Json toJson() => {
        'day': day,
        'opens': opens,
        'notificationOpens': notificationOpens,
        'activities': activities,
        'correct': correctAnswers,
        'wrong': wrongAnswers,
        'uncleanExits': uncleanExits,
      };

  factory DayActivity.fromJson(Json json) => DayActivity(
        day: readString(json, 'day') ?? '',
        opens: readInt(json, 'opens'),
        notificationOpens: readInt(json, 'notificationOpens'),
        activities: readInt(json, 'activities'),
        correctAnswers: readInt(json, 'correct'),
        wrongAnswers: readInt(json, 'wrong'),
        uncleanExits: readInt(json, 'uncleanExits'),
      );
}

/// `YYYY-MM-DD` for the local calendar day of [time].
String dayKey(DateTime time) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${time.year.toString().padLeft(4, '0')}-${two(time.month)}-'
      '${two(time.day)}';
}

/// The local activity log used by the comeback score (M10).
///
/// Kept on the phone only, for the last [maxDays] days. "Cancella la mia
/// attività" replaces it with [ActivityLog.empty].
class ActivityLog {
  const ActivityLog({
    this.days = const [],
    this.lastSessionEndedCleanly = true,
  });

  static const empty = ActivityLog();

  /// How many days are kept. Older days are dropped when a new one starts.
  static const maxDays = 14;

  /// Oldest first, one entry per day.
  final List<DayActivity> days;

  /// False while the app is on screen; set to true when it goes to the
  /// background. Still false at the next start → the last session did
  /// not end normally.
  final bool lastSessionEndedCleanly;

  DayActivity? dayOf(DateTime now) {
    final key = dayKey(now);
    for (final day in days) {
      if (day.day == key) return day;
    }
    return null;
  }

  /// Changes today's entry (created if missing) and drops old days.
  ActivityLog updateDay(
      DateTime now, DayActivity Function(DayActivity today) change,
      {bool? lastSessionEndedCleanly}) {
    final key = dayKey(now);
    final today = change(dayOf(now) ?? DayActivity(day: key));
    final next = [
      for (final day in days)
        if (day.day != key) day,
      today,
    ]..sort((a, b) => a.day.compareTo(b.day));
    // Keep only the last 14 calendar days before today. If the clock went
    // backwards, "future" days are kept but the list never grows past
    // [maxDays] entries (the newest ones win).
    final oldest = dayKey(now.subtract(const Duration(days: maxDays - 1)));
    final recent = next.where((day) => day.day.compareTo(oldest) >= 0).toList();
    final trimmed = recent.length > maxDays
        ? recent.sublist(recent.length - maxDays)
        : recent;
    return ActivityLog(
      days: List.unmodifiable(trimmed),
      lastSessionEndedCleanly:
          lastSessionEndedCleanly ?? this.lastSessionEndedCleanly,
    );
  }

  ActivityLog withSessionEndedCleanly(bool value) => ActivityLog(
        days: days,
        lastSessionEndedCleanly: value,
      );

  Json toJson() => {
        'days': [for (final day in days) day.toJson()],
        'lastSessionEndedCleanly': lastSessionEndedCleanly,
      };

  /// Missing (older saves) → empty log.
  factory ActivityLog.fromJson(Json json) {
    final raw = json['days'];
    if (raw != null && raw is! List) {
      throw FormatException('"days" should be a list, found $raw');
    }
    final days = [
      for (final entry in (raw as List?) ?? const [])
        DayActivity.fromJson((entry as Map).cast<String, Object?>()),
    ]..sort((a, b) => a.day.compareTo(b.day));
    return ActivityLog(
      days: List.unmodifiable(days),
      lastSessionEndedCleanly:
          readBool(json, 'lastSessionEndedCleanly', fallback: true),
    );
  }
}

/// The optional daily reminder. Off until the player turns it on in the
/// Profile tab.
class ReminderSettings {
  const ReminderSettings({
    this.enabled = false,
    this.hour = 18,
    this.minute = 0,
  });

  static const defaults = ReminderSettings();

  final bool enabled;
  final int hour;
  final int minute;

  ReminderSettings copyWith({bool? enabled, int? hour, int? minute}) =>
      ReminderSettings(
        enabled: enabled ?? this.enabled,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
      );

  Json toJson() => {'enabled': enabled, 'hour': hour, 'minute': minute};

  factory ReminderSettings.fromJson(Json json) => ReminderSettings(
        enabled: readBool(json, 'enabled'),
        hour: readInt(json, 'hour', fallback: defaults.hour).clamp(0, 23),
        minute: readInt(json, 'minute', fallback: defaults.minute).clamp(0, 59),
      );

  @override
  bool operator ==(Object other) =>
      other is ReminderSettings &&
      other.enabled == enabled &&
      other.hour == hour &&
      other.minute == minute;

  @override
  int get hashCode => Object.hash(enabled, hour, minute);
}
