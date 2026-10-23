import 'package:ecoquest/domain/models/activity_log.dart';
import 'package:ecoquest/domain/rules/comeback_rules.dart';
import 'package:ecoquest/domain/rules/economy_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 22, 10);
  String daysAgo(int n) => dayKey(DateTime(2026, 10, 22 - n, 9));

  ActivityLog logOf(List<DayActivity> days) => ActivityLog(days: days);

  group('comebackScore table', () {
    final cases = <String, (ActivityLog, int)>{
      'empty log (day 1) is neutral': (ActivityLog.empty, 50),
      'only today in the log is neutral': (
        logOf([DayActivity(day: daysAgo(0), opens: 1)]),
        50,
      ),
      'played yesterday only': (
        logOf([DayActivity(day: daysAgo(1), opens: 1, activities: 1)]),
        65, // 50 + 5 (1 active day) + 10 (yesterday)
      ),
      'played 2 days ago only': (
        logOf([DayActivity(day: daysAgo(2), opens: 1)]),
        55, // 50 + 5 + 0
      ),
      'back after 5 days': (
        logOf([DayActivity(day: daysAgo(5), opens: 1)]),
        40, // 50 + 5 - 15
      ),
      'back after 10 days': (
        logOf([DayActivity(day: daysAgo(10), opens: 1)]),
        20, // 50 + 0 (outside the week) - 30
      ),
      'played every day for a week, good answers': (
        logOf([
          for (var n = 7; n >= 1; n--)
            DayActivity(
                day: daysAgo(n), opens: 1, activities: 2, correctAnswers: 4),
        ]),
        100, // 50 + 35 + 10 + 5
      ),
      'many wrong answers': (
        logOf([
          DayActivity(
              day: daysAgo(1), opens: 1, correctAnswers: 2, wrongAnswers: 6),
        ]),
        55, // 50 + 5 + 10 - 10
      ),
      'opened from the reminder today': (
        logOf([
          DayActivity(day: daysAgo(5), opens: 1),
          DayActivity(day: daysAgo(0), opens: 1, notificationOpens: 1),
        ]),
        45, // 50 + 5 - 15 + 5
      ),
      'crash before today, long gap → clamped': (
        logOf([
          DayActivity(day: daysAgo(13), opens: 1, wrongAnswers: 9),
          DayActivity(day: daysAgo(0), opens: 1, uncleanExits: 1),
        ]),
        0, // 50 - 30 - 10 - 10 = 0
      ),
    };

    cases.forEach((name, data) {
      test(name, () {
        final (log, expected) = data;
        final score = comebackScore(log, now);
        expect(score, expected);
        expect(score, inInclusiveRange(0, 100));
      });
    });
  });

  test('days after today (clock went backwards) are ignored', () {
    final log = logOf([
      DayActivity(day: daysAgo(-3), opens: 5, activities: 5),
    ]);
    expect(comebackScore(log, now), neutralComebackScore);
  });

  test('a day with nothing recorded does not count as active', () {
    final log = logOf([DayActivity(day: daysAgo(1))]);
    expect(comebackScore(log, now), neutralComebackScore);
  });

  test('low threshold and claim id', () {
    const economy = EconomyConfig.defaults;
    expect(isComebackScoreLow(40, economy), isTrue);
    expect(isComebackScoreLow(50, economy), isFalse);
    expect(comebackClaimId(now), 'comeback:2026-10-22');
  });

  test('easier activity: care for a hatched pet, cleanup for an egg', () {
    expect(suggestEasierActivity(petHatched: true), ComebackSuggestion.petCare);
    expect(
        suggestEasierActivity(petHatched: false), ComebackSuggestion.cleanup);
  });

  group('ActivityLog', () {
    test('keeps at most 14 days, oldest dropped', () {
      var log = ActivityLog.empty;
      for (var n = 20; n >= 0; n--) {
        log = log.updateDay(DateTime(2026, 10, 22 - n, 9),
            (today) => today.copyWith(opens: today.opens + 1));
      }
      expect(log.days.length, ActivityLog.maxDays);
      expect(log.days.first.day, daysAgo(13));
      expect(log.days.last.day, daysAgo(0));
    });

    test('clock going backwards adds an earlier day without breaking', () {
      var log = ActivityLog.empty.updateDay(
          now, (today) => today.copyWith(opens: 1));
      log = log.updateDay(DateTime(2026, 10, 20, 9),
          (today) => today.copyWith(opens: 1));
      expect(log.days.map((d) => d.day), [daysAgo(2), daysAgo(0)]);
      expect(comebackScore(log, DateTime(2026, 10, 20, 9)), 50);
    });

    test('toJson → fromJson round trip', () {
      final log = ActivityLog(
        lastSessionEndedCleanly: false,
        days: [
          DayActivity(
            day: daysAgo(1),
            opens: 2,
            notificationOpens: 1,
            activities: 3,
            correctAnswers: 7,
            wrongAnswers: 2,
            uncleanExits: 1,
          ),
        ],
      );
      final copy = ActivityLog.fromJson(log.toJson());
      expect(copy.toJson(), log.toJson());
    });

    test('missing data → empty log, clean session', () {
      final log = ActivityLog.fromJson(const {});
      expect(log.days, isEmpty);
      expect(log.lastSessionEndedCleanly, isTrue);
    });

    test('reminder settings default off at 18:00', () {
      final reminder = ReminderSettings.fromJson(const {});
      expect(reminder, const ReminderSettings());
      expect(reminder.enabled, isFalse);
      expect(reminder.hour, 18);
    });
  });
}
