import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../core/notifications/reminder_scheduler.dart';
import '../../core/widgets/eco_card.dart';
import '../../domain/game_controller.dart';
import '../../domain/models/activity_log.dart';
import '../../l10n/app_localizations.dart';

/// Opt-in daily reminder (M10): plain explanation, on/off switch, time.
/// The permission is asked only here, when the player turns it on.
class ReminderCard extends ConsumerStatefulWidget {
  const ReminderCard({super.key, required this.reminder});

  final ReminderSettings reminder;

  @override
  ConsumerState<ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends ConsumerState<ReminderCard> {
  /// Shown after a refusal, once, as plain text (no dialog, no nagging).
  bool _denied = false;

  GameController get _game => ref.read(gameControllerProvider.notifier);

  Future<void> _toggle(bool on) async {
    if (!on) {
      await _game.updateReminder(widget.reminder.copyWith(enabled: false));
      return;
    }
    final granted =
        await ref.read(reminderSchedulerProvider).requestPermission();
    if (!mounted) return;
    setState(() => _denied = !granted);
    if (granted) {
      await _game.updateReminder(widget.reminder.copyWith(enabled: true));
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
          hour: widget.reminder.hour, minute: widget.reminder.minute),
    );
    if (picked == null) return;
    await _game.updateReminder(
        widget.reminder.copyWith(hour: picked.hour, minute: picked.minute));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final reminder = widget.reminder;
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: reminder.hour, minute: reminder.minute),
      alwaysUse24HourFormat: true,
    );

    return EcoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(l10n.reminderTitle, style: textTheme.titleMedium),
          ),
          const SizedBox(height: EcoSpacing.xs),
          Text(l10n.reminderBody, style: textTheme.bodyMedium),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.reminderSwitch),
            value: reminder.enabled,
            onChanged: _toggle,
          ),
          if (_denied && !reminder.enabled)
            Text(
              l10n.reminderPermissionDenied,
              style: textTheme.bodyMedium?.copyWith(color: EcoColors.inkMuted),
            ),
          if (reminder.enabled)
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: EcoSpacing.s,
              children: [
                Text(l10n.reminderTime(time), style: textTheme.bodyLarge),
                TextButton.icon(
                  icon: const Icon(Icons.schedule_rounded),
                  label: Text(l10n.reminderChangeTime),
                  onPressed: _pickTime,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// What the activity log keeps, and the button that wipes it.
class ActivityDataCard extends ConsumerWidget {
  const ActivityDataCard({super.key});

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.activityClearConfirmTitle),
        content: Text(l10n.activityClearConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.activityClearCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.activityClearConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(gameControllerProvider.notifier).clearActivity();
    // The binding cancels it too when the reminder turns off; this also
    // covers a reminder that was already off.
    await ref.read(reminderSchedulerProvider).cancelAll();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.activityCleared)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return EcoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(l10n.activityDataTitle, style: textTheme.titleMedium),
          ),
          const SizedBox(height: EcoSpacing.xs),
          Text(l10n.activityDataBody, style: textTheme.bodyMedium),
          const SizedBox(height: EcoSpacing.s),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(l10n.activityClearAction),
              onPressed: () => _clear(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}
