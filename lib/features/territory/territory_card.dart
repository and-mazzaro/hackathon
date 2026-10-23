import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/router.dart';
import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../core/widgets/eco_card.dart';
import '../../data/territory/territory_client.dart';
import '../../domain/game_controller.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/territory.dart';
import '../../domain/rules/territory_rules.dart';
import '../../l10n/app_localizations.dart';

/// EEA colours for the air-quality bands, with a text colour that keeps
/// at least 4.5:1 contrast on each of them.
(Color background, Color text) aqiBandColors(AqiBand band) => switch (band) {
      AqiBand.good => (const Color(0xFF50F0E6), EcoColors.ink),
      AqiBand.fair => (const Color(0xFF50CCAA), EcoColors.ink),
      AqiBand.moderate => (const Color(0xFFF0E641), EcoColors.ink),
      AqiBand.poor => (const Color(0xFFFF5050), Colors.black),
      AqiBand.veryPoor => (const Color(0xFF960032), Colors.white),
      AqiBand.extremelyPoor => (const Color(0xFF7D2181), Colors.white),
    };

String _clock(DateTime time) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(time.hour)}:${two(time.minute)}';
}

/// Home card "Il mio territorio": live air quality and weather for the
/// chosen Alto Vicentino town, a daily action and the territory quiz.
/// Screen readers hear the reading as one block, then the buttons.
class TerritoryCard extends ConsumerWidget {
  const TerritoryCard({super.key, required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final town = game.territory.town;
    final async = ref.watch(territoryProvider);
    final data = async.value;
    final reading = data == null ? null : readingFor(data.readings, town);
    final title = l10n.territoryTitle(town.label);

    final Widget body;
    if (async.isLoading && !async.hasValue) {
      body = Text(l10n.territoryLoading, style: textTheme.bodyMedium);
    } else if (reading == null) {
      body = Text(l10n.territoryUnavailable, style: textTheme.bodyLarge);
    } else {
      body = _ReadingView(reading: reading, live: data!.live, game: game);
    }

    return EcoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: textTheme.titleLarge),
          ),
          const SizedBox(height: EcoSpacing.s),
          body,
          const SizedBox(height: EcoSpacing.s),
          Text(l10n.territoryTownLabel, style: textTheme.labelLarge),
          const SizedBox(height: EcoSpacing.xs),
          Wrap(
            spacing: EcoSpacing.s,
            runSpacing: EcoSpacing.xs,
            children: [
              for (final t in TerritoryTown.values)
                ChoiceChip(
                  label: Text(t.label),
                  selected: t == town,
                  onSelected: (_) => ref
                      .read(gameControllerProvider.notifier)
                      .selectTerritoryTown(t),
                ),
            ],
          ),
          const SizedBox(height: EcoSpacing.s),
          Text(
            l10n.territoryAttribution,
            style: textTheme.bodySmall?.copyWith(color: EcoColors.inkMuted),
          ),
        ],
      ),
    );
  }
}

class _ReadingView extends ConsumerWidget {
  const _ReadingView({
    required this.reading,
    required this.live,
    required this.game,
  });

  final TownReading reading;
  final bool live;
  final GameState game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final now = ref.watch(clockProvider)();
    final band = aqiBand(reading.aqi);
    final (badgeColor, badgeText) = aqiBandColors(band);
    final aqiText = l10n.territoryAqi(band.label, reading.aqi);
    final pm10 = l10n.territoryPm10(formatMeasure(reading.pm10));
    final pm25 = l10n.territoryPm25(formatMeasure(reading.pm25));
    final temperature =
        l10n.territoryTemperature(formatMeasure(reading.temperature));
    final updated = live
        ? l10n.territoryUpdatedAt(_clock(reading.time))
        : l10n.territoryCachedAt(_clock(reading.time));
    final tip = territoryTip(reading);
    final doneToday =
        game.progress.claimedRewardIds.contains(territoryClaimId(now));

    Future<void> didIt() async {
      final messenger = ScaffoldMessenger.of(context);
      final result = await ref
          .read(gameControllerProvider.notifier)
          .claimTerritoryAction();
      if (result.applied) {
        messenger.showSnackBar(SnackBar(
            content: Text(l10n.territoryDidItReward(result.reward.coins))));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // One block for screen readers; the visible parts are excluded.
        Semantics(
          container: true,
          label: l10n.territorySummary(l10n.territoryTitle(reading.town.label),
              aqiText, pm10, pm25, temperature, updated),
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: EcoSpacing.s + EcoSpacing.xs,
                      vertical: EcoSpacing.xs),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(EcoSpacing.radiusPill),
                  ),
                  child: Text(
                    aqiText,
                    style: textTheme.titleMedium?.copyWith(color: badgeText),
                  ),
                ),
                const SizedBox(height: EcoSpacing.s),
                Wrap(
                  spacing: EcoSpacing.m,
                  runSpacing: EcoSpacing.xs,
                  children: [
                    Text(pm10, style: textTheme.bodyLarge),
                    Text(pm25, style: textTheme.bodyLarge),
                    Text(temperature, style: textTheme.bodyLarge),
                  ],
                ),
                const SizedBox(height: EcoSpacing.xs),
                Text(updated,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: EcoColors.inkMuted)),
              ],
            ),
          ),
        ),
        const SizedBox(height: EcoSpacing.s + EcoSpacing.xs),
        Container(
          padding: const EdgeInsets.all(EcoSpacing.s + EcoSpacing.xs),
          decoration: BoxDecoration(
            color: EcoColors.primaryContainer,
            borderRadius: BorderRadius.circular(EcoSpacing.radiusCard),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.territoryTipTitle(tip.text),
                  style: textTheme.bodyLarge),
              const SizedBox(height: EcoSpacing.s),
              if (doneToday)
                Text(l10n.territoryDoneToday, style: textTheme.bodyMedium)
              else
                FilledButton.icon(
                  icon: const Icon(Icons.check_circle_rounded),
                  label: Text(l10n.territoryDidIt),
                  onPressed: didIt,
                ),
            ],
          ),
        ),
        const SizedBox(height: EcoSpacing.s),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.quiz_rounded),
            label: Text(l10n.territoryQuizAction),
            onPressed: () => context.push(AppRoutes.territoryQuiz),
          ),
        ),
      ],
    );
  }
}
