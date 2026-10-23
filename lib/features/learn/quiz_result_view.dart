import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../core/widgets/eco_button.dart';
import '../../domain/game_controller.dart';
import '../../l10n/app_localizations.dart';

/// The end of a quiz: score, XP earned, streak and what was learned.
class QuizResultView extends StatelessWidget {
  const QuizResultView({
    super.key,
    required this.outcome,
    required this.onPlayAgain,
    required this.onBack,
  });

  final QuizOutcome outcome;
  final VoidCallback onPlayAgain;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final score = outcome.score;
    final claim = outcome.claim;

    final message = score.perfect
        ? l10n.quizResultPerfect
        : score.correctCount >= 3
            ? l10n.quizResultGood
            : l10n.quizResultKeepGoing;
    final hadRepeats = score.correctCount > score.newlyLearned;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(EcoSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: EcoSpacing.l),
              const Icon(Icons.emoji_events_rounded,
                  size: 88, color: EcoColors.coin),
              const SizedBox(height: EcoSpacing.m),
              Semantics(
                header: true,
                child: Text(
                  l10n.quizResultScore(score.correctCount, score.questionCount),
                  style: textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: EcoSpacing.s),
              Text(message,
                  style: textTheme.bodyLarge, textAlign: TextAlign.center),
              const SizedBox(height: EcoSpacing.l),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: EcoSpacing.l, vertical: EcoSpacing.s),
                  decoration: BoxDecoration(
                    color: EcoColors.xp,
                    borderRadius: BorderRadius.circular(EcoSpacing.radiusPill),
                  ),
                  child: Text(
                    l10n.quizResultXp(claim.reward.xp),
                    style: textTheme.headlineSmall
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ),
              if (claim.leveledUp) ...[
                const SizedBox(height: EcoSpacing.m),
                Container(
                  padding: const EdgeInsets.all(EcoSpacing.m),
                  decoration: BoxDecoration(
                    color: EcoColors.coin.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(EcoSpacing.radiusCard),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up_rounded,
                          color: EcoColors.ink),
                      const SizedBox(width: EcoSpacing.s),
                      Expanded(
                        child: Text(l10n.quizLevelUp(claim.levelAfter),
                            style: textTheme.titleMedium),
                      ),
                    ],
                  ),
                ),
              ],
              if (claim.reward.tickets > 0) ...[
                const SizedBox(height: EcoSpacing.s),
                Text(l10n.levelUpTickets(claim.reward.tickets),
                    style: textTheme.bodyLarge, textAlign: TextAlign.center),
              ],
              const SizedBox(height: EcoSpacing.l),
              Text(l10n.quizResultBestStreak(score.bestStreak),
                  style: textTheme.bodyLarge, textAlign: TextAlign.center),
              Text(l10n.quizResultNewlyLearned(score.newlyLearned),
                  style: textTheme.bodyLarge, textAlign: TextAlign.center),
              if (hadRepeats) ...[
                const SizedBox(height: EcoSpacing.m),
                Text(
                  l10n.quizResultRepeatNote,
                  style:
                      textTheme.bodyMedium?.copyWith(color: EcoColors.inkMuted),
                  textAlign: TextAlign.center,
                ),
              ],
              if (outcome.petHappier) ...[
                const SizedBox(height: EcoSpacing.m),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite_rounded,
                        color: EcoColors.happiness),
                    const SizedBox(width: EcoSpacing.s),
                    Flexible(
                      child: Text(l10n.quizPetHappier,
                          style: textTheme.bodyLarge,
                          textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: EcoSpacing.xl),
              EcoButton(
                label: l10n.quizPlayAgain,
                icon: Icons.replay_rounded,
                expand: true,
                onPressed: onPlayAgain,
              ),
              const SizedBox(height: EcoSpacing.s),
              EcoButton(
                label: l10n.quizClose,
                variant: EcoButtonVariant.secondary,
                expand: true,
                onPressed: onBack,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
