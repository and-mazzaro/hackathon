import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../core/audio/audio_service.dart';
import '../../core/audio/game_sounds.dart';
import '../../core/widgets/eco_button.dart';
import '../../domain/models/quiz_question.dart';
import '../../l10n/app_localizations.dart';

/// "Prepara la pappa": a couple of quick questions before feeding.
///
/// Returns how many answers were right, or null if the sheet was closed
/// (back button, tap outside) before serving: then nothing happens.
/// The answers give no XP and are not recorded as a quiz (D34).
Future<int?> showFeedGameSheet(
  BuildContext context, {
  required List<QuizQuestion> questions,
  required String petName,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) =>
        _FeedGameSheet(questions: questions, petName: petName),
  );
}

class _FeedGameSheet extends ConsumerStatefulWidget {
  const _FeedGameSheet({required this.questions, required this.petName});

  final List<QuizQuestion> questions;
  final String petName;

  @override
  ConsumerState<_FeedGameSheet> createState() => _FeedGameSheetState();
}

class _FeedGameSheetState extends ConsumerState<_FeedGameSheet> {
  int _index = 0;
  int? _chosen;
  int _correct = 0;
  int _streak = 0;

  QuizQuestion get _question => widget.questions[_index];
  bool get _isLast => _index == widget.questions.length - 1;

  void _answer(int option) {
    if (_chosen != null) return;
    final right = option == _question.correctIndex;
    setState(() {
      _chosen = option;
      if (right) _correct++;
      _streak = right ? _streak + 1 : 0;
    });
    ref
        .read(audioServiceProvider)
        .playAny(answerSounds(correct: right, streak: _streak));
  }

  void _next() {
    if (_isLast) {
      Navigator.of(context).pop(_correct);
      return;
    }
    setState(() {
      _index++;
      _chosen = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final question = _question;
    final chosen = _chosen;
    final right = chosen == question.correctIndex;

    return SingleChildScrollView(
      padding:
          const EdgeInsets.fromLTRB(EcoSpacing.l, 0, EcoSpacing.l, EcoSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.restaurant_rounded,
              size: 48, color: EcoColors.primary),
          const SizedBox(height: EcoSpacing.s),
          Semantics(
            header: true,
            child: Text(l10n.feedGameTitle,
                style: textTheme.titleLarge, textAlign: TextAlign.center),
          ),
          const SizedBox(height: EcoSpacing.xs),
          Text(l10n.feedGameIntro(widget.petName),
              style: textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: EcoSpacing.m),
          Text(
            l10n.quizQuestionOf(_index + 1, widget.questions.length),
            style: textTheme.labelLarge?.copyWith(color: EcoColors.inkMuted),
          ),
          const SizedBox(height: EcoSpacing.xs),
          Text(question.question, style: textTheme.titleMedium),
          const SizedBox(height: EcoSpacing.m),
          for (var i = 0; i < question.options.length; i++) ...[
            EcoButton(
              label: question.options[i],
              icon: chosen == null
                  ? null
                  : i == question.correctIndex
                      ? Icons.check_circle_rounded
                      : i == chosen
                          ? Icons.cancel_rounded
                          : null,
              variant: chosen != null && i == question.correctIndex
                  ? EcoButtonVariant.primary
                  : EcoButtonVariant.secondary,
              expand: true,
              onPressed: chosen == null ? () => _answer(i) : () {},
            ),
            const SizedBox(height: EcoSpacing.s),
          ],
          if (chosen != null) ...[
            // Read aloud as soon as the answer is checked.
            Semantics(
              liveRegion: true,
              child: Text(
                right ? l10n.quizCorrect : l10n.quizWrong,
                style: textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: EcoSpacing.xs),
            Text(question.explanation, style: textTheme.bodyMedium),
            const SizedBox(height: EcoSpacing.m),
            EcoButton(
              label: _isLast ? l10n.feedGameServe : l10n.feedGameNext,
              icon: _isLast
                  ? Icons.restaurant_rounded
                  : Icons.arrow_forward_rounded,
              expand: true,
              onPressed: _next,
            ),
          ],
        ],
      ),
    );
  }
}
