import '../models/look_mode.dart';

/// How the pet room looks.
enum TimeOfDayLook { day, afternoon, night }

/// The look for the phone's local hour: day 7:00–15:59,
/// afternoon (sunset) 16:00–19:59, night 20:00–6:59.
TimeOfDayLook timeOfDayFor(DateTime now) {
  final hour = now.hour;
  if (hour >= 7 && hour < 16) return TimeOfDayLook.day;
  if (hour >= 16 && hour < 20) return TimeOfDayLook.afternoon;
  return TimeOfDayLook.night;
}

/// The look to show: the player's choice, or the clock when [mode] is auto.
TimeOfDayLook lookFor(LookMode mode, DateTime now) => switch (mode) {
      LookMode.auto => timeOfDayFor(now),
      LookMode.day => TimeOfDayLook.day,
      LookMode.afternoon => TimeOfDayLook.afternoon,
      LookMode.night => TimeOfDayLook.night,
    };
