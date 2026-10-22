import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/router.dart';
import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../core/widgets/eco_button.dart';
import '../../core/widgets/eco_card.dart';
import '../../core/widgets/game_state_view.dart';
import '../../data/content/quiz_content.dart';
import '../../domain/models/eco_topic.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/quiz_question.dart';
import '../../l10n/app_localizations.dart';
import '../profile/profile_labels.dart';

/// LEARN hub: the personal quiz on top, then one quiz per topic with the
/// player's interests first. Reorders immediately when interests change.
class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return GameStateView(
      builder: (context, game) => ref.watch(quizBankProvider).when(
            data: (bank) => _LearnContent(game: game, bank: bank),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(EcoSpacing.l),
                child: Text(l10n.learnContentError,
                    textAlign: TextAlign.center),
              ),
            ),
          ),
    );
  }
}

class _LearnContent extends StatelessWidget {
  const _LearnContent({required this.game, required this.bank});

  final GameState game;
  final QuizBank bank;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final interests = game.profile.interests;
    final learning = game.learning;

    // Interests first, then the other topics; both in the usual order.
    final topics = [
      ...EcoTopic.values.where(interests.contains),
      ...EcoTopic.values.where((t) => !interests.contains(t)),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(EcoSpacing.m),
        children: [
          Semantics(
            header: true,
            child: Text(l10n.learnTitle, style: textTheme.headlineSmall),
          ),
          const SizedBox(height: EcoSpacing.xs),
          Text(l10n.learnBody,
              style: textTheme.bodyMedium?.copyWith(color: EcoColors.inkMuted)),
          const SizedBox(height: EcoSpacing.m),
          EcoCard(
            color: EcoColors.xp.withValues(alpha: 0.12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        color: EcoColors.xp, size: 28),
                    const SizedBox(width: EcoSpacing.s),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(l10n.learnForYouTitle,
                            style: textTheme.titleLarge),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: EcoSpacing.xs),
                Text(l10n.learnForYouBody, style: textTheme.bodyMedium),
                const SizedBox(height: EcoSpacing.xs),
                Text(
                  l10n.learnQuizzesCompleted(learning.quizzesCompleted),
                  style: textTheme.bodySmall
                      ?.copyWith(color: EcoColors.inkMuted),
                ),
                const SizedBox(height: EcoSpacing.m),
                EcoButton(
                  label: l10n.learnForYouAction,
                  icon: Icons.play_arrow_rounded,
                  expand: true,
                  onPressed: bank.questions.isEmpty
                      ? null
                      : () => context.push(AppRoutes.quiz()),
                ),
              ],
            ),
          ),
          const SizedBox(height: EcoSpacing.l),
          Semantics(
            header: true,
            child: Text(l10n.learnTopicsTitle, style: textTheme.titleLarge),
          ),
          const SizedBox(height: EcoSpacing.s),
          for (final topic in topics) ...[
            _TopicCard(
              topic: topic,
              forYou: interests.contains(topic),
              questionCount: bank.countFor(topic),
              correct: learning.statsByTopic[topic]?.correct ?? 0,
              answered: learning.statsByTopic[topic]?.answered ?? 0,
            ),
            const SizedBox(height: EcoSpacing.s),
          ],
        ],
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.forYou,
    required this.questionCount,
    required this.correct,
    required this.answered,
  });

  final EcoTopic topic;
  final bool forYou;
  final int questionCount;
  final int correct;
  final int answered;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final playable = questionCount > 0;

    return EcoCard(
      onTap: playable ? () => context.push(AppRoutes.quiz(topic)) : null,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: EcoColors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(topic.icon, color: EcoColors.primary),
          ),
          const SizedBox(width: EcoSpacing.s + EcoSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: EcoSpacing.s,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(topic.label(l10n), style: textTheme.titleMedium),
                    if (forYou)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: EcoSpacing.s, vertical: 2),
                        decoration: BoxDecoration(
                          color: EcoColors.coin,
                          borderRadius:
                              BorderRadius.circular(EcoSpacing.radiusPill),
                        ),
                        child: Text(l10n.learnForYouBadge,
                            style: textTheme.labelSmall),
                      ),
                  ],
                ),
                Text(
                  l10n.learnQuestionCount(questionCount),
                  style: textTheme.bodyMedium
                      ?.copyWith(color: EcoColors.inkMuted),
                ),
                if (answered > 0)
                  Text(
                    l10n.learnTopicStats(correct, answered),
                    style: textTheme.bodySmall
                        ?.copyWith(color: EcoColors.inkMuted),
                  ),
              ],
            ),
          ),
          if (playable)
            const Icon(Icons.chevron_right_rounded, color: EcoColors.inkMuted),
        ],
      ),
    );
  }
}
