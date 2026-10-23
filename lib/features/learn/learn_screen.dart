import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/router.dart';
import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../core/widgets/eco_card.dart';
import '../../core/widgets/game_state_view.dart';
import '../../data/content/quiz_content.dart';
import '../../domain/models/eco_topic.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/quiz_question.dart';
import '../../l10n/app_localizations.dart';
import '../profile/profile_labels.dart';
import 'topic_colors.dart';

/// LEARN hub: a big "Gioca subito" card that starts the personal mixed quiz
/// with one tap, then a grid of topic tiles with the player's interests
/// first. Reorders immediately when interests change.
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

    Widget tile(EcoTopic topic, {required bool fill}) {
      final questions = bank.forTopic(topic);
      return _TopicTile(
        topic: topic,
        forYou: interests.contains(topic),
        questionCount: questions.length,
        learned: questions
            .where((q) => learning.learnedQuestionIds.contains(q.id))
            .length,
        fill: fill,
      );
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(EcoSpacing.m),
        children: [
          Semantics(
            header: true,
            child: Text(l10n.learnTitle, style: textTheme.headlineSmall),
          ),
          const SizedBox(height: EcoSpacing.s),
          Wrap(
            spacing: EcoSpacing.s,
            runSpacing: EcoSpacing.s,
            children: [
              _StatPill(
                icon: Icons.emoji_events_rounded,
                color: EcoColors.xp,
                text: l10n.learnQuizzesCompleted(learning.quizzesCompleted),
              ),
              _StatPill(
                icon: Icons.school_rounded,
                color: EcoColors.primary,
                text: l10n.learnLearnedTotal(
                    learning.learnedQuestionIds.length),
              ),
            ],
          ),
          const SizedBox(height: EcoSpacing.m),
          _PlayNowCard(
            onTap: bank.questions.isEmpty
                ? null
                : () => context.push(AppRoutes.quiz()),
          ),
          const SizedBox(height: EcoSpacing.s),
          const _TerritoryTile(),
          const SizedBox(height: EcoSpacing.l),
          Semantics(
            header: true,
            child: Text(l10n.learnTopicsHint, style: textTheme.titleLarge),
          ),
          const SizedBox(height: EcoSpacing.s),
          LayoutBuilder(builder: (context, constraints) {
            // Two tiles per row while each one is at least 150 px wide
            // (scaled with the text size), otherwise one.
            final scale = MediaQuery.textScalerOf(context).scale(1);
            final twoColumns =
                constraints.maxWidth >= 2 * 150 * scale + EcoSpacing.s;
            if (!twoColumns) {
              return Column(
                children: [
                  for (final topic in topics) ...[
                    tile(topic, fill: false),
                    const SizedBox(height: EcoSpacing.s),
                  ],
                ],
              );
            }
            return Column(
              children: [
                for (var i = 0; i < topics.length; i += 2) ...[
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: tile(topics[i], fill: true)),
                        const SizedBox(width: EcoSpacing.s),
                        Expanded(
                          child: i + 1 < topics.length
                              ? tile(topics[i + 1], fill: true)
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: EcoSpacing.s),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}

/// A small stat ("3 quiz completati"), read on its own (D15).
class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: EcoSpacing.s, vertical: EcoSpacing.xs),
        decoration: BoxDecoration(
          color: EcoColors.surface,
          borderRadius: BorderRadius.circular(EcoSpacing.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: EcoSpacing.xs),
            Flexible(
              child: Text(text,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: EcoColors.ink)),
            ),
          ],
        ),
      ),
    );
  }
}

/// The big one-tap entry: starts the personal mixed quiz. The whole card
/// is one button for screen readers.
class _PlayNowCard extends StatelessWidget {
  const _PlayNowCard({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(EcoSpacing.radiusCard);
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;

    final playBadge = Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: EcoColors.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: EcoColors.ink.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.play_arrow_rounded,
          color: EcoColors.primary, size: 48),
    );

    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.learnPlayNowTitle,
          style: textTheme.headlineSmall?.copyWith(
              color: EcoColors.surface, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: EcoSpacing.xs),
        Text(
          l10n.learnPlayNowBody,
          style: textTheme.bodyMedium?.copyWith(color: EcoColors.surface),
        ),
        const SizedBox(height: EcoSpacing.s + EcoSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: EcoSpacing.s + EcoSpacing.xs,
              vertical: EcoSpacing.xs),
          decoration: BoxDecoration(
            color: EcoColors.coin,
            borderRadius: BorderRadius.circular(EcoSpacing.radiusPill),
          ),
          child: Text(
            l10n.learnPlayNowAction,
            style: textTheme.labelLarge?.copyWith(color: EcoColors.ink),
          ),
        ),
      ],
    );

    return MergeSemantics(
      child: Semantics(
        button: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: EcoColors.primary.withValues(alpha: 0.3),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: Ink(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [EcoColors.primary, EcoColors.xp],
                ),
              ),
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(EcoSpacing.m + EcoSpacing.xs),
                  child: largeText
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ExcludeSemantics(child: playBadge),
                            const SizedBox(height: EcoSpacing.s),
                            texts,
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: texts),
                            const SizedBox(width: EcoSpacing.m),
                            ExcludeSemantics(child: playBadge),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One topic: coloured icon, name, "Per te" badge, question count and how
/// many of its questions the player has learned. One button for screen
/// readers (EcoCard merges the texts).
class _TopicTile extends StatelessWidget {
  const _TopicTile({
    required this.topic,
    required this.forYou,
    required this.questionCount,
    required this.learned,
    required this.fill,
  });

  final EcoTopic topic;
  final bool forYou;
  final int questionCount;
  final int learned;

  /// True inside a grid row of equal height: the progress bar sits at the
  /// bottom of the tile.
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final playable = questionCount > 0;
    // One clear label, name first (the badge is drawn above the name).
    final label = [
      topic.label(l10n),
      if (forYou) l10n.learnForYouBadge,
      l10n.learnQuestionCount(questionCount),
      if (playable) l10n.learnTopicLearned(learned, questionCount),
    ].join('\n');

    return EcoCard(
      color: topic.tint,
      padding: const EdgeInsets.all(EcoSpacing.s + EcoSpacing.xs),
      onTap: playable ? () => context.push(AppRoutes.quiz(topic)) : null,
      child: Semantics(
        label: label,
        child: ExcludeSemantics(child: _content(context)),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final playable = questionCount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: topic.color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(topic.icon, color: EcoColors.surface, size: 28),
            ),
            const Spacer(),
            if (forYou)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: EcoSpacing.s, vertical: 2),
                decoration: BoxDecoration(
                  color: EcoColors.coin,
                  borderRadius: BorderRadius.circular(EcoSpacing.radiusPill),
                ),
                child: Text(l10n.learnForYouBadge,
                    style:
                        textTheme.labelSmall?.copyWith(color: EcoColors.ink)),
              ),
          ],
        ),
        const SizedBox(height: EcoSpacing.s),
        Text(topic.label(l10n), style: textTheme.titleMedium),
        Text(
          l10n.learnQuestionCount(questionCount),
          style: textTheme.bodySmall?.copyWith(color: EcoColors.ink),
        ),
        if (fill) const Spacer() else const SizedBox(height: EcoSpacing.s),
        if (playable) ...[
          const SizedBox(height: EcoSpacing.s),
          ClipRRect(
            borderRadius: BorderRadius.circular(EcoSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: learned / questionCount,
              minHeight: 8,
              color: topic.color,
              backgroundColor: EcoColors.surface,
            ),
          ),
          const SizedBox(height: EcoSpacing.xs),
          Text(
            l10n.learnTopicLearned(learned, questionCount),
            style: textTheme.bodySmall?.copyWith(color: EcoColors.ink),
          ),
        ],
      ],
    );
  }
}

/// Opens the "Il mio territorio" quiz (questions from today's live data).
class _TerritoryTile extends StatelessWidget {
  const _TerritoryTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return EcoCard(
      onTap: () => context.push(AppRoutes.territoryQuiz),
      child: Row(
        children: [
          const Icon(Icons.location_city_rounded,
              color: EcoColors.primary, size: 32),
          const SizedBox(width: EcoSpacing.s + EcoSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.territoryLearnTitle, style: textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(l10n.territoryLearnSubtitle,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: EcoColors.inkMuted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: EcoColors.inkMuted),
        ],
      ),
    );
  }
}
