import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../core/widgets/eco_button.dart';
import '../../core/widgets/source_sheet.dart';
import '../../data/content/waste_content.dart';
import '../../domain/cleanup_round.dart';
import '../../domain/game_controller.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/waste_item.dart';
import '../../domain/rules/recycling_rules.dart';
import '../../l10n/app_localizations.dart';
import 'cleanup_result_view.dart';
import 'waste_labels.dart';

/// Room Cleanup: sort the waste in the pet's room into the right bins.
///
/// Tap an item, then a bin (works with screen readers), or drag an item
/// onto a bin.
class CleanupScreen extends ConsumerStatefulWidget {
  const CleanupScreen({super.key});

  @override
  ConsumerState<CleanupScreen> createState() => _CleanupScreenState();
}

class _CleanupScreenState extends ConsumerState<CleanupScreen> {
  CleanupRound? _round;
  SortFeedback? _feedback;
  String? _hint;
  CleanupOutcome? _outcome;
  bool _finishing = false;

  CleanupRound? _newRound(WasteBank bank, GameState game) {
    final random = ref.read(randomProvider);
    final economy = ref.read(economyProvider);
    final items = pickCleanupItems(
      bank: bank,
      progress: game.recycling,
      random: random,
      count: economy.cleanupItemCount,
    );
    if (items.isEmpty) return null;
    final now = ref.read(clockProvider)();
    return CleanupRound(
      items: items,
      roundId: '${now.microsecondsSinceEpoch}-${random.nextInt(1 << 30)}',
      comboLength: economy.sortComboLength,
    );
  }

  void _select(CleanupRound round, WasteItem item) => setState(() {
        round.select(item);
        final l10n = AppLocalizations.of(context);
        _hint = round.selected == null ? null : l10n.cleanupSelected(item.name);
      });

  void _sort(CleanupRound round, WasteCategory bin, {WasteItem? item}) {
    final feedback = round.sortInto(bin, item: item);
    setState(() {
      if (feedback == null) {
        _hint = AppLocalizations.of(context).cleanupPickFirst;
      } else {
        _feedback = feedback;
        _hint = null;
      }
    });
  }

  Future<void> _finish(CleanupRound round) async {
    setState(() => _finishing = true);
    final outcome = await ref
        .read(gameControllerProvider.notifier)
        .completeCleanup(roundId: round.roundId, sorted: round.results);
    if (mounted) {
      setState(() {
        _outcome = outcome;
        _finishing = false;
      });
    }
  }

  void _playAgain() => setState(() {
        _round = null;
        _outcome = null;
        _feedback = null;
        _hint = null;
      });

  Future<void> _requestExit(CleanupRound round) async {
    final navigator = Navigator.of(context);
    if (!round.hasStarted || await _confirmExit()) navigator.pop();
  }

  Future<bool> _confirmExit() async {
    final l10n = AppLocalizations.of(context);
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cleanupExitTitle),
        content: Text(l10n.cleanupExitBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cleanupExitStay),
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
    final textTheme = Theme.of(context).textTheme;
    final bankAsync = ref.watch(wasteBankProvider);
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

    final round = _round ??= _newRound(bank, game);
    if (round == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.cleanupNoItems)),
      );
    }

    final outcome = _outcome;
    if (outcome != null) {
      return CleanupResultView(
        outcome: outcome,
        onPlayAgain: _playAgain,
        onClose: () => Navigator.of(context).pop(),
      );
    }

    // Bins (or the result button) stay fixed at the bottom with normal
    // text. With large text they would not fit, so they scroll along.
    final largeText = MediaQuery.textScalerOf(context).scale(10) > 13;
    final bottom = round.isFinished
        ? EcoButton(
            label: l10n.quizSeeResult,
            icon: Icons.arrow_forward_rounded,
            expand: true,
            onPressed: _finishing ? null : () => _finish(round),
          )
        : _Bins(onSort: (bin, {item}) => _sort(round, bin, item: item));

    return PopScope(
      canPop: !round.hasStarted,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _requestExit(round);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _Header(round: round, onClose: () => _requestExit(round)),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                      EcoSpacing.m, 0, EcoSpacing.m, EcoSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.cleanupLocalRules,
                        style: textTheme.bodySmall
                            ?.copyWith(color: EcoColors.inkMuted),
                      ),
                      const SizedBox(height: EcoSpacing.s),
                      _Room(
                        round: round,
                        onSelect: (item) => _select(round, item),
                        doneText: l10n.cleanupRoomClean,
                      ),
                      const SizedBox(height: EcoSpacing.s),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          _hint ??
                              (round.isFinished ? '' : l10n.cleanupHowTo),
                          style: textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (_feedback != null) ...[
                        const SizedBox(height: EcoSpacing.s),
                        _FeedbackCard(feedback: _feedback!),
                      ],
                      if (largeText) ...[
                        const SizedBox(height: EcoSpacing.m),
                        bottom,
                      ],
                    ],
                  ),
                ),
              ),
              if (!largeText)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      EcoSpacing.m, EcoSpacing.s, EcoSpacing.m, EcoSpacing.m),
                  child: bottom,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.round, required this.onClose});

  final CleanupRound round;
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
            tooltip: l10n.cleanupExit,
            icon: const Icon(Icons.close_rounded),
          ),
          const SizedBox(width: EcoSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.homeCleanupTitle, style: textTheme.titleMedium),
                Text(
                  l10n.cleanupProgress(round.sortedCount, round.total),
                  style:
                      textTheme.bodyMedium?.copyWith(color: EcoColors.inkMuted),
                ),
                // Below the text, not beside it: beside it, large text
                // squeezed the title into a one-letter-wide column.
                if (round.combo >= 2) ...[
                  const SizedBox(height: EcoSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: EcoSpacing.s + EcoSpacing.xs,
                        vertical: 2),
                    decoration: BoxDecoration(
                      color: EcoColors.coin.withValues(alpha: 0.5),
                      borderRadius:
                          BorderRadius.circular(EcoSpacing.radiusPill),
                    ),
                    child: Text(l10n.cleanupCombo(round.combo),
                        style: textTheme.labelLarge),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The pet's room with the waste lying around.
class _Room extends StatelessWidget {
  const _Room({
    required this.round,
    required this.onSelect,
    required this.doneText,
  });

  final CleanupRound round;
  final ValueChanged<WasteItem> onSelect;
  final String doneText;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.all(EcoSpacing.m),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFBFE6F2), Color(0xFFE3D3B0)],
        ),
        borderRadius: BorderRadius.circular(EcoSpacing.radiusCard),
      ),
      child: round.isFinished
          ? Center(
              child: Text(doneText,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center),
            )
          : Wrap(
              spacing: EcoSpacing.s,
              runSpacing: EcoSpacing.s,
              alignment: WrapAlignment.center,
              children: [
                for (final item in round.remaining)
                  _WasteChip(
                    item: item,
                    selected: identical(item, round.selected),
                    onTap: () => onSelect(item),
                  ),
              ],
            ),
    );
  }
}

class _WasteChip extends StatelessWidget {
  const _WasteChip({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final WasteItem item;
  final bool selected;
  final VoidCallback onTap;

  Widget _chip(BuildContext context, {bool dragging = false}) {
    return Material(
      color: selected ? EcoColors.primaryContainer : EcoColors.surface,
      elevation: dragging ? 6 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? EcoColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: dragging ? null : onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: EcoSpacing.s + EcoSpacing.xs,
                vertical: EcoSpacing.s),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(wasteIcon(item.icon), color: EcoColors.ink, size: 22),
                const SizedBox(width: EcoSpacing.s),
                Flexible(
                  child: Text(item.name,
                      style: Theme.of(context).textTheme.labelLarge),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Drag starts at once: a long press first was invisible to players and
    // a plain drag only scrolled the page. Dragging next to the items still
    // scrolls.
    return Draggable<WasteItem>(
      data: item,
      feedback: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260),
        child: _chip(context, dragging: true),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _chip(context)),
      child: MergeSemantics(
        child: Semantics(
          button: true,
          selected: selected,
          child: _chip(context),
        ),
      ),
    );
  }
}

typedef _SortCallback = void Function(WasteCategory bin, {WasteItem? item});

class _Bins extends StatelessWidget {
  const _Bins({required this.onSort});

  final _SortCallback onSort;

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(10) > 13;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = largeText ? 2 : 3;
        const gap = EcoSpacing.s;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          alignment: WrapAlignment.center,
          children: [
            for (final bin in WasteCategory.values)
              SizedBox(
                width: width,
                child: _BinButton(bin: bin, onSort: onSort),
              ),
          ],
        );
      },
    );
  }
}

class _BinButton extends StatelessWidget {
  const _BinButton({required this.bin, required this.onSort});

  final WasteCategory bin;
  final _SortCallback onSort;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final radius = BorderRadius.circular(16);

    return DragTarget<WasteItem>(
      onAcceptWithDetails: (details) => onSort(bin, item: details.data),
      builder: (context, candidates, rejected) {
        final hovering = candidates.isNotEmpty;
        return MergeSemantics(
          child: Semantics(
            button: true,
            child: Material(
              color: bin.tint,
              shape: RoundedRectangleBorder(
                borderRadius: radius,
                side: BorderSide(
                  color: hovering
                      ? EcoColors.ink
                      : EcoColors.ink.withValues(alpha: 0.15),
                  width: hovering ? 3 : 1,
                ),
              ),
              child: InkWell(
                borderRadius: radius,
                onTap: () => onSort(bin),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 64),
                  child: Padding(
                    padding: const EdgeInsets.all(EcoSpacing.s),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(bin.icon, color: EcoColors.ink),
                        const SizedBox(height: 2),
                        Text(
                          bin.label(l10n),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.feedback});

  final SortFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final item = feedback.item;
    final bin = item.category.label(l10n);

    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(EcoSpacing.m),
        decoration: BoxDecoration(
          color: feedback.correct
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
                  feedback.correct
                      ? Icons.check_circle_rounded
                      : Icons.lightbulb_rounded,
                  color: EcoColors.ink,
                ),
                const SizedBox(width: EcoSpacing.s),
                Expanded(
                  child: Text(
                    feedback.correct
                        ? l10n.cleanupCorrect(item.name, bin)
                        : l10n.cleanupWrong(item.name, bin),
                    style: textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (feedback.comboBonus) ...[
              const SizedBox(height: EcoSpacing.xs),
              Text(l10n.cleanupComboBonus(feedback.combo),
                  style: textTheme.labelLarge),
            ],
            const SizedBox(height: EcoSpacing.s),
            Text(item.explanation, style: textTheme.bodyMedium),
            if (item.localNote != null) ...[
              const SizedBox(height: EcoSpacing.s),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_city_rounded,
                      size: 20, color: EcoColors.ink),
                  const SizedBox(width: EcoSpacing.s),
                  Expanded(
                    child: Text(item.localNote!, style: textTheme.bodySmall),
                  ),
                ],
              ),
            ],
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: EcoColors.ink),
              icon: const Icon(Icons.menu_book_rounded),
              label: Text(l10n.quizSource(item.source.name)),
              onPressed: () => showSourceSheet(context, item.source),
            ),
          ],
        ),
      ),
    );
  }
}
