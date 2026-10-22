import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_spacing.dart';
import '../../domain/models/quiz_question.dart';
import '../../l10n/app_localizations.dart';

/// Shows where a fact comes from: publisher, address and check date.
/// Used by the quiz and by Room Cleanup.
void showSourceSheet(BuildContext context, ContentSource source) {
  final l10n = AppLocalizations.of(context);
  final date = source.verifiedOn;
  final dateText = '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final textTheme = Theme.of(context).textTheme;
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              EcoSpacing.l, 0, EcoSpacing.l, EcoSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(source.name, style: textTheme.titleLarge),
              ),
              const SizedBox(height: EcoSpacing.s),
              SelectableText(source.url, style: textTheme.bodyMedium),
              const SizedBox(height: EcoSpacing.s),
              Text(l10n.quizSourceVerified(dateText),
                  style: textTheme.bodySmall),
              Text(l10n.quizSourceCopyHint, style: textTheme.bodySmall),
            ],
          ),
        ),
      );
    },
  );
}
