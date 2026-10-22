import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../core/widgets/eco_button.dart';
import '../../core/widgets/source_sheet.dart';
import '../../data/content/quiz_content.dart';
import '../../domain/game_controller.dart';
import '../../domain/models/eco_topic.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/quiz_question.dart';
import '../../domain/quiz_session.dart';
import '../../domain/rules/quiz_rules.dart';
import '../../l10n/app_localizations.dart';
import '../profile/profile_labels.dart';
import 'quiz_result_view.dart';

/// Plays one quiz of 5 questions, then shows the result.
///
/// [topic] null = personal mixed quiz based on the player's interests.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, this.topic});

  final EcoTopic? topic;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  QuizSession? _session;
  QuizOutcome? _outcome;
  bool _finishing = false;
  final _feedbackKey = GlobalKey();

  QuizSession? _newSession(QuizBank bank, GameState game) {
    final random = ref.read(randomProvider);
    final questions = pickQuizQuestions(
      bank: bank,
      learning: game.learning,
      interests: game.profile.interests,
      topic: widget.topic,
      random: random,
      count: ref.read(economyProvider).quizQuestionCount,
    );
    if (questions.isEmpty) return null;
    final now = ref.read(clockProvider)();
    return QuizSession(
      questions: questions,
      random: random,
      topic: widget.topic,
      sessionId: '${now.microsecondsSinceEpoch}-${random.nextInt(1 << 30)}',
    );
  }

  void _answer(QuizSession session, int option) {
    setState(() => session.answer(option));
    // Bring the explanation into view on small screens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final feedback = _feedbackKey.currentContext;
      if (feedback != null && feedback.mounted) {
        Scrollable.ensureVisible(
          feedback,
          duration: const Duration(milliseconds: 300),
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );
      }
    });
  }

  Future<void> _next(QuizSession session) async {
    if (!session.isLastQuestion) {
      setState(session.next);
      return;
    }
    setState(() => _finishing = true);
    final outcome = await ref
        .read(gameControllerProvider.notifier)
        .completeQuiz(sessionId: session.sessionId, answers: session.answers);
    if (mounted) {
      setState(() {
        _outcome = outcome;
        _finishing = false;
      });
    }
  }

  void _playAgain() => setState(() {
        _session = null; // a new session is picked on the next build
        _outcome = null;
      });

  Future<void> _requestExit(QuizSession session) async {
    final navigator = Navigator.of(context);
    if (!session.hasStarted || await _confirmExit()) navigator.pop();
  }

  Future<bool> _confirmExit() async {
    final l10n = AppLocalizations.of(context);
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.quizExitTitle),
        content: Text(l10n.quizExitBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.quizExitStay),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.quizExitConfirm),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bankAsync = ref.watch(quizBankProvider);
    final bank = bankAsync.value;
    final game = ref.watch(gameControllerProvider).value;

    if (bank == null || game == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: bankAsync.hasError
              ? Padding(
                  padding: const EdgeInsets.all(EcoSpacing.l),
                  child: Text(l10n.learnContentError,
                      textAlign: TextAlign.center),
                )
              : const CircularProgressIndicator(),
        ),
      );
    }

    final session = _session ??= _newSession(bank, game);
    if (session == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.quizNotEnough)),
      );
    }

    final outcome = _outcome;
    if (outcome != null) {
      return QuizResultView(
        outcome: outcome,
        onPlayAgain: _playAgain,
        onBack: () => Navigator.of(context).pop(),
      );
    }

    final shown = session.current;
    final chosen = session.chosenForCurrent;
    final title = widget.topic?.label(l10n) ?? l10n.quizMixedTitle;

    // Back button / swipe: ask before throwing away answers.
    return PopScope(
      canPop: !session.hasStarted,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _requestExit(session);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _QuizHeader(
                title: title,
                index: session.index,
                total: session.length,
                onClose: () => _requestExit(session),
              ),
              Expanded(
                child: SingleChildScrollView(
                  key: ValueKey(session.index), // each question starts at top
                  padding: const EdgeInsets.fromLTRB(
                      EcoSpacing.m, EcoSpacing.s, EcoSpacing.m, EcoSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: EcoSpacing.s,
                        runSpacing: EcoSpacing.s,
                        children: [
                          _DifficultyChip(level: shown.question.difficulty),
                          if (session.currentStreak >= 2)
                            _StreakChip(count: session.currentStreak),
                        ],
                      ),
                      const SizedBox(height: EcoSpacing.m),
                      Semantics(
                        header: true,
                        child: Text(
                          shown.question.question,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: EcoSpacing.l),
                      for (var i = 0; i < shown.options.length; i++) ...[
                        _AnswerOption(
                          text: shown.options[i],
                          state: _optionState(i, chosen, shown.correctIndex),
                          onTap: chosen == null
                              ? () => _answer(session, i)
                              : null,
                        ),
                        const SizedBox(height: EcoSpacing.s),
                      ],
                      if (chosen != null) ...[
                        const SizedBox(height: EcoSpacing.s),
                        _FeedbackCard(
                          key: _feedbackKey,
                          correct: chosen == shown.correctIndex,
                          question: shown.question,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (chosen != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      EcoSpacing.m, EcoSpacing.s, EcoSpacing.m, EcoSpacing.m),
                  child: EcoButton(
                    label: session.isLastQuestion
                        ? l10n.quizSeeResult
                        : l10n.nextAction,
                    icon: Icons.arrow_forward_rounded,
                    expand: true,
                    onPressed: _finishing ? null : () => _next(session),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _OptionState _optionState(int option, int? chosen, int correct) {
    if (chosen == null) return _OptionState.open;
    if (option == correct) return _OptionState.correct;
    if (option == chosen) return _OptionState.wrongChoice;
    return _OptionState.other;
  }
}

class _QuizHeader extends StatelessWidget {
  const _QuizHeader({
    required this.title,
    required this.index,
    required this.total,
    required this.onClose,
  });

  final String title;
  final int index;
  final int total;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          EcoSpacing.xs, EcoSpacing.s, EcoSpacing.m, EcoSpacing.s),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            tooltip: l10n.quizExit,
            icon: const Icon(Icons.close_rounded),
          ),
          const SizedBox(width: EcoSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: textTheme.labelLarge
                        ?.copyWith(color: EcoColors.inkMuted)),
                // Announced by screen readers when the question changes.
                Semantics(
                  liveRegion: true,
                  child: Text(l10n.quizQuestionOf(index + 1, total),
                      style: textTheme.titleMedium),
                ),
                const SizedBox(height: EcoSpacing.xs),
                ExcludeSemantics(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(EcoSpacing.radiusPill),
                    child: LinearProgressIndicator(
                      value: (index + 1) / total,
                      minHeight: 8,
                      color: EcoColors.xp,
                      backgroundColor: EcoColors.xp.withValues(alpha: 0.15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = switch (level) {
      1 => l10n.difficultyEasy,
      2 => l10n.difficultyMedium,
      _ => l10n.difficultyHard,
    };
    return _Pill(
      icon: Icons.eco_rounded,
      text: label,
      color: EcoColors.primaryContainer,
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return _Pill(
      icon: Icons.local_fire_department_rounded,
      text: AppLocalizations.of(context).quizStreak(count),
      color: EcoColors.coin.withValues(alpha: 0.5),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: EcoSpacing.s + EcoSpacing.xs, vertical: EcoSpacing.xs),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(EcoSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: EcoColors.ink),
          const SizedBox(width: EcoSpacing.xs),
          Flexible(
            child: Text(text, style: Theme.of(context).textTheme.labelLarge),
          ),
        ],
      ),
    );
  }
}

enum _OptionState { open, correct, wrongChoice, other }

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String text;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final radius = BorderRadius.circular(16);

    final (background, border) = switch (state) {
      _OptionState.correct => (EcoColors.primaryContainer, EcoColors.primary),
      _OptionState.wrongChoice => (
          EcoColors.alert.withValues(alpha: 0.10),
          EcoColors.alert,
        ),
      _ => (EcoColors.surface, EcoColors.ink.withValues(alpha: 0.15)),
    };
    // Icons carry a semantic label, so screen readers hear the result
    // and never depend on the colour alone.
    final icon = switch (state) {
      _OptionState.correct => Icon(Icons.check_circle_rounded,
          color: EcoColors.primary, semanticLabel: l10n.quizOptionCorrect),
      _OptionState.wrongChoice => Icon(Icons.cancel_rounded,
          color: EcoColors.alert, semanticLabel: l10n.quizOptionWrong),
      _ => null,
    };

    return MergeSemantics(
      child: Semantics(
        button: true,
        child: Material(
          color: background,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: border, width: 2),
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: EcoSpacing.m, vertical: EcoSpacing.s + 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(text,
                          style: Theme.of(context).textTheme.bodyLarge),
                    ),
                    if (icon != null) ...[
                      const SizedBox(width: EcoSpacing.s),
                      icon,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    super.key,
    required this.correct,
    required this.question,
  });

  final bool correct;
  final QuizQuestion question;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      liveRegion: true, // read aloud as soon as it appears
      child: Container(
        padding: const EdgeInsets.all(EcoSpacing.m),
        decoration: BoxDecoration(
          color: correct
              ? EcoColors.primaryContainer
              : EcoColors.coin.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(EcoSpacing.radiusCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  correct
                      ? Icons.celebration_rounded
                      : Icons.lightbulb_rounded,
                  color: EcoColors.ink,
                ),
                const SizedBox(width: EcoSpacing.s),
                Expanded(
                  child: Text(
                    correct ? l10n.quizCorrect : l10n.quizWrong,
                    style: textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (!correct) ...[
              const SizedBox(height: EcoSpacing.xs),
              Text(
                l10n.quizCorrectAnswerIs(question.correctOption),
                style: textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: EcoSpacing.s),
            Text(question.explanation, style: textTheme.bodyLarge),
            const SizedBox(height: EcoSpacing.xs),
            TextButton.icon(
              // Ink, not green: green on the yellow card is only 4.15:1.
              style: TextButton.styleFrom(foregroundColor: EcoColors.ink),
              icon: const Icon(Icons.menu_book_rounded),
              label: Text(l10n.quizSource(question.source.name)),
              onPressed: () => showSourceSheet(context, question.source),
            ),
          ],
        ),
      ),
    );
  }
}
