import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/router.dart';
import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../core/widgets/eco_card.dart';
import '../../core/widgets/game_state_view.dart';
import '../../domain/game_controller.dart';
import '../../domain/models/eco_topic.dart';
import '../../domain/models/game_state.dart';
import '../../domain/rules/progression.dart';
import '../../l10n/app_localizations.dart';
import '../demo/demo_mode.dart';
import 'interest_picker.dart';
import 'look_card.dart';
import 'profile_details_sheet.dart';
import 'profile_labels.dart';
import 'reminder_section.dart';

/// Profile: who you are, your interests (editable, saved at once) and
/// what data EcoQuest keeps.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GameStateView(
      builder: (context, game) => _ProfileContent(game: game),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.game});

  final GameState game;

  void _toggle(BuildContext context, WidgetRef ref, EcoTopic topic) {
    final interests = {...game.profile.interests};
    if (interests.contains(topic)) {
      if (interests.length == 1) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).profileKeepOneInterest),
          ));
        return;
      }
      interests.remove(topic);
    } else {
      interests.add(topic);
    }
    ref.read(gameControllerProvider.notifier).updateInterests(interests);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final profile = game.profile;
    final level =
        levelForTotalXp(game.progress.totalXp, ref.watch(economyProvider));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(EcoSpacing.m),
        children: [
          EcoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ExcludeSemantics(
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: EcoColors.primaryContainer,
                        foregroundColor: EcoColors.primary,
                        child: Text(
                          profile.nickname?.characters.first.toUpperCase() ??
                              '?',
                          style: textTheme.titleLarge
                              ?.copyWith(color: EcoColors.primary),
                          textScaler: TextScaler.noScaling,
                        ),
                      ),
                    ),
                    const SizedBox(width: EcoSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              profile.nickname ?? l10n.profileGuestName,
                              style: textTheme.titleLarge,
                            ),
                          ),
                          Text(
                            l10n.profileLevelLine(level.level),
                            style: textTheme.bodyMedium
                                ?.copyWith(color: EcoColors.inkMuted),
                          ),
                          if (profile.ageRange != null)
                            Text(
                              l10n.profileAgeLine(
                                  profile.ageRange!.label(l10n)),
                              style: textTheme.bodyMedium
                                  ?.copyWith(color: EcoColors.inkMuted),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: EcoSpacing.s),
                TextButton.icon(
                  icon: const Icon(Icons.edit_rounded),
                  label: Text(l10n.profileEditDetails),
                  onPressed: () => showProfileDetailsSheet(context, profile),
                ),
              ],
            ),
          ),
          const SizedBox(height: EcoSpacing.m),
          FilledButton.tonalIcon(
            icon: const Icon(Icons.auto_awesome_rounded),
            label: Text(l10n.introProfileButton),
            onPressed: () => context.push(AppRoutes.intro),
          ),
          const SizedBox(height: EcoSpacing.s),
          OutlinedButton.icon(
            icon: const Icon(Icons.slideshow_rounded),
            label: Text(l10n.demoStart),
            onPressed: () => ref.read(demoModeProvider.notifier).start(),
          ),
          const SizedBox(height: EcoSpacing.l),
          Semantics(
            header: true,
            child: Text(l10n.profileInterestsTitle,
                style: textTheme.titleLarge),
          ),
          const SizedBox(height: EcoSpacing.xs),
          Text(
            l10n.profileInterestsBody,
            style: textTheme.bodyMedium?.copyWith(color: EcoColors.inkMuted),
          ),
          const SizedBox(height: EcoSpacing.m),
          InterestPicker(
            selected: profile.interests,
            onToggle: (topic) => _toggle(context, ref, topic),
          ),
          const SizedBox(height: EcoSpacing.l),
          ReminderCard(reminder: game.reminder),
          const SizedBox(height: EcoSpacing.m),
          const ActivityDataCard(),
          const SizedBox(height: EcoSpacing.l),
          EcoCard(
            color: EcoColors.primaryContainer,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_outline_rounded, color: EcoColors.ink),
                const SizedBox(width: EcoSpacing.s + EcoSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(l10n.profileDataTitle,
                            style: textTheme.titleMedium),
                      ),
                      const SizedBox(height: EcoSpacing.xs),
                      Text(l10n.profileDataBody, style: textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: EcoSpacing.m),
          LookCard(mode: game.lookMode),
        ],
      ),
    );
  }
}
