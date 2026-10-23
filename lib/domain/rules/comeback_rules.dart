import '../models/activity_log.dart';
import 'economy_config.dart';

/// The score when there is nothing to judge (first day, cleared log).
const neutralComebackScore = 50;

/// How likely the player is to come back, 0-100, from the local
/// [ActivityLog] only. A DAILY number: it looks at the days BEFORE today
/// plus how today started, so playing today does not move it.
///
/// Formula (every step is a plain addition, then clamped to 0-100):
///
/// | Signal                                        | Points           |
/// |-----------------------------------------------|------------------|
/// | start                                         | 50               |
/// | each active day in the 7 days before today    | +5 (max +35)     |
/// | last active day was yesterday                 | +10              |
/// | last active day 2 days ago                    | 0                |
/// | last active day 3-6 days ago                  | -15              |
/// | last active day 7 or more days ago            | -30              |
/// | ≥ 5 answers in the log and more wrong than ok | -10              |
/// | ≥ 5 answers in the log and ≥ 80% right        | +5               |
/// | today opened from the reminder notification   | +5               |
/// | today started after a session that crashed    | -10              |
///
/// No day before today in the log (day 1, or log just cleared) →
/// [neutralComebackScore]. Days "after" today (the clock went backwards)
/// are ignored, so a wrong clock can never crash or skew it badly.
int comebackScore(ActivityLog log, DateTime now) {
  final todayKey = dayKey(now);
  final today = DateTime(now.year, now.month, now.day);
  final history = log.days
      .where((day) => day.day.compareTo(todayKey) < 0 && day.isActive)
      .toList();
  if (history.isEmpty) return neutralComebackScore;

  var score = neutralComebackScore;

  final weekStart = dayKey(today.subtract(const Duration(days: 7)));
  final activeThisWeek =
      history.where((day) => day.day.compareTo(weekStart) >= 0).length;
  score += 5 * activeThisWeek.clamp(0, 7);

  final gap = _daysBetween(history.last.day, today);
  if (gap <= 1) {
    score += 10;
  } else if (gap == 2) {
    // neutral
  } else if (gap < 7) {
    score -= 15;
  } else {
    score -= 30;
  }

  var correct = 0;
  var wrong = 0;
  for (final day in history) {
    correct += day.correctAnswers;
    wrong += day.wrongAnswers;
  }
  if (correct + wrong >= 5) {
    if (wrong > correct) {
      score -= 10;
    } else if (correct * 100 >= (correct + wrong) * 80) {
      score += 5;
    }
  }

  final todayEntry = log.dayOf(now);
  if (todayEntry != null) {
    if (todayEntry.notificationOpens > 0) score += 5;
    if (todayEntry.uncleanExits > 0) score -= 10;
  }

  return score.clamp(0, 100);
}

/// Whole calendar days from [dayKeyText] to [today] (at least 1 here,
/// because history only holds days before today).
int _daysBetween(String dayKeyText, DateTime today) {
  final day = DateTime.parse(dayKeyText);
  // Noon avoids daylight-saving hours turning 1 day into 0.96.
  final from = DateTime(day.year, day.month, day.day, 12);
  final to = DateTime(today.year, today.month, today.day, 12);
  return (to.difference(from).inHours / 24).round();
}

/// True when Home should greet the player gently and offer the bonus.
bool isComebackScoreLow(int score, EconomyConfig economy) =>
    score < economy.comebackLowScore;

/// The once-per-day claim id for the comeback bonus (D17).
String comebackClaimId(DateTime now) => 'comeback:${dayKey(now)}';

/// The easier activity Home suggests when the score is low.
enum ComebackSuggestion {
  /// One tap, cannot go wrong.
  petCare,

  /// Sorting by tap; a wrong bin teaches and costs nothing.
  cleanup,
}

/// A hatched pet → care (easiest); an egg cannot be cared for → cleanup.
ComebackSuggestion suggestEasierActivity({required bool petHatched}) =>
    petHatched ? ComebackSuggestion.petCare : ComebackSuggestion.cleanup;
