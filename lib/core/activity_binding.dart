import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/game_controller.dart';
import 'notifications/reminder_scheduler.dart';

/// False in most widget tests, so starting the app does not write a save.
final activityTrackingEnabledProvider = Provider<bool>((ref) => true);

/// Feeds the local activity log (comeback score, M10), once, at the top:
///
/// - when the saved game has loaded: one "app opened" entry (from the
///   reminder or not) and a check that the last session ended normally;
/// - app back on screen: another "opened" entry;
/// - app to the background: the session ended normally.
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
