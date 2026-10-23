import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/game_controller.dart';
import '../domain/models/game_state.dart';
import '../features/profile/reminder_text.dart';
import '../l10n/app_localizations.dart';
import 'notifications/reminder_scheduler.dart';

/// False in most widget tests, so starting the app does not write a save.
final activityTrackingEnabledProvider = Provider<bool>((ref) => true);

/// Feeds the local activity log (comeback score, M10), once, at the top:
///
/// - when the saved game has loaded: one "app opened" entry (from the
///   reminder or not) and a check that the last session ended normally;
/// - app back on screen: another "opened" entry;
/// - app to the background: the session ended normally;
/// - the saved reminder choice → one daily local notification, or none
///   (also after "Cancella la mia attività").
///
/// Only counts and dates, never location, network or device data.
class ActivityBinding extends ConsumerStatefulWidget {
  const ActivityBinding({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ActivityBinding> createState() => _ActivityBindingState();
}

class _ActivityBindingState extends ConsumerState<ActivityBinding> {
  late final AppLifecycleListener _lifecycle;
  bool _startRecorded = false;

  bool get _enabled => ref.read(activityTrackingEnabledProvider);
  GameController get _game => ref.read(gameControllerProvider.notifier);
  bool get _loaded => ref.read(gameControllerProvider).value != null;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onShow: () {
        if (_enabled && _loaded && _startRecorded) _game.recordAppOpen();
      },
      onHide: () {
        if (_enabled && _loaded) _game.recordSessionEnded();
      },
    );
    ref.listenManual(
      gameControllerProvider.select((game) => game.value != null),
      (previous, loaded) {
        if (loaded) _recordStart();
      },
      fireImmediately: true,
    );
    ref.listenManual(
      gameControllerProvider.select((game) => _ReminderPlan.of(game.value)),
      (previous, plan) {
        if (plan != null && plan != previous) _applyReminder(plan);
      },
      fireImmediately: true,
    );
  }

  Future<void> _applyReminder(_ReminderPlan plan) async {
    final scheduler = ref.read(reminderSchedulerProvider);
    if (!plan.enabled) {
      await scheduler.cancelAll();
      return;
    }
    await scheduler.scheduleDaily(
      hour: plan.hour,
      minute: plan.minute,
      title: plan.title,
      body: plan.body,
    );
  }

  Future<void> _recordStart() async {
    if (_startRecorded || !_enabled) return;
    _startRecorded = true;
    var fromNotification = false;
    try {
      fromNotification =
          await ref.read(reminderSchedulerProvider).launchedFromNotification();
    } catch (_) {
      // Unknown how we were opened: count it as a plain start.
    }
    if (!mounted || !_loaded) return;
    await _game.recordAppOpen(
        coldStart: true, fromNotification: fromNotification);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// What the reminder should be right now; equal plans → nothing to do.
class _ReminderPlan {
  const _ReminderPlan(
      this.enabled, this.hour, this.minute, this.title, this.body);

  static _ReminderPlan? of(GameState? game) {
    if (game == null) return null;
    final reminder = game.reminder;
    if (!reminder.enabled) return const _ReminderPlan(false, 0, 0, '', '');
    // The binding sits above the app's Localizations: Italian is the only
    // language (D10), so look it up directly.
    final (title, body) =
        reminderMessage(game, lookupAppLocalizations(const Locale('it')));
    return _ReminderPlan(true, reminder.hour, reminder.minute, title, body);
  }

  final bool enabled;
  final int hour;
  final int minute;
  final String title;
  final String body;

  @override
  bool operator ==(Object other) =>
      other is _ReminderPlan &&
      other.enabled == enabled &&
      other.hour == hour &&
      other.minute == minute &&
      other.title == title &&
      other.body == body;

  @override
  int get hashCode => Object.hash(enabled, hour, minute, title, body);
}
