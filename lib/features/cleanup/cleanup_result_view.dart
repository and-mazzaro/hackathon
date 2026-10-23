import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../core/widgets/eco_button.dart';
import '../../domain/game_controller.dart';
import '../../l10n/app_localizations.dart';

/// The end of a cleanup round: score, coins, XP, combo, cleaner pet.
class CleanupResultView extends StatelessWidget {
  const CleanupResultView({
    super.key,
    required this.outcome,
    required this.onPlayAgain,
    required this.onClose,
  });

  final CleanupOutcome outcome;
  final VoidCallback onPlayAgain;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final score = outcome.score;
    final reward = outcome.claim.reward;
    final hadRepeats = score.correctCount > score.newlyLearned;

    Widget pill(String text, Color color, Color textColor) => Container(
          padding: const EdgeInsets.symmetric(
              horizontal: EcoSpacing.l, vertical: EcoSpacing.s),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(EcoSpacing.radiusPill),
          ),
          child: Text(text,
              style: textTheme.headlineSmall?.copyWith(color: textColor)),
        );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(EcoSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: EcoSpacing.l),
              const Icon(Icons.cleaning_services_rounded,
                  size: 88, color: EcoColors.primary),
              const SizedBox(height: EcoSpacing.m),
              Semantics(
                header: true,
                child: Text(
                  l10n.cleanupResultScore(score.correctCount, score.itemCount),
                  style: textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: EcoSpacing.s),
              Text(
                score.perfect
                    ? l10n.quizResultPerfect
                    : score.correctCount * 2 >= score.itemCount
                        ? l10n.quizResultGood
                        : l10n.quizResultKeepGoing,
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: EcoSpacing.l),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: EcoSpacing.s,
                runSpacing: EcoSpacing.s,
                children: [
                  pill(l10n.cleanupResultCoins(reward.coins), EcoColors.coin,
                      EcoColors.ink),
                  if (reward.xp > 0)
                    pill(l10n.quizResultXp(reward.xp), EcoColors.xp,
                        Colors.white),
                ],
              ),
              if (outcome.claim.leveledUp) ...[
                const SizedBox(height: EcoSpacing.m),
                Text(l10n.quizLevelUp(outcome.claim.levelAfter),
                    style: textTheme.titleMedium, textAlign: TextAlign.center),
              ],
              if (reward.tickets > 0) ...[
                const SizedBox(height: EcoSpacing.s),
                Text(l10n.levelUpTickets(reward.tickets),
                    style: textTheme.bodyLarge, textAlign: TextAlign.center),
              ],
              const SizedBox(height: EcoSpacing.l),
              Text(l10n.cleanupResultBestCombo(score.bestCombo),
                  style: textTheme.bodyLarge, textAlign: TextAlign.center),
              Text(l10n.quizResultNewlyLearned(score.newlyLearned),
                  style: textTheme.bodyLarge, textAlign: TextAlign.center),
              if (outcome.petCleaner) ...[
                const SizedBox(height: EcoSpacing.m),
                Text(l10n.cleanupPetCleaner,
                    style: textTheme.bodyLarge, textAlign: TextAlign.center),
              ],
              if (hadRepeats) ...[
                const SizedBox(height: EcoSpacing.m),
                Text(
                  l10n.cleanupRepeatNote,
                  style:
                      textTheme.bodyMedium?.copyWith(color: EcoColors.inkMuted),
                  textAlign: TextAlign.center,
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
                onPressed: onClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
