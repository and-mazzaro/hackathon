import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/router.dart';
import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../core/widgets/currency_chip.dart';
import '../../core/widgets/eco_card.dart';
import '../../core/widgets/egg_art.dart';
import '../../core/widgets/game_state_view.dart';
import '../../core/widgets/stat_bar.dart';
import '../../domain/game_controller.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/pet_state.dart';
import '../../domain/models/reward.dart';
import '../../domain/rules/progression.dart';
import '../../l10n/app_localizations.dart';

/// Home: the pet room on top (about 60%), today's activities below.
/// Shows the saved game; while it loads, a spinner; if it fails, an error.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GameStateView(builder: (context, game) => _HomeContent(game: game));
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.game});

  final GameState game;

  double _need(int value) => value / PetState.maxNeed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final level =
        levelForTotalXp(game.progress.totalXp, ref.watch(economyProvider));
    final pet = game.pet;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The room keeps ~42% of the screen; with the need bars below it
          // the pet part takes ~60%. It scrolls instead of overflowing
          // on small phones or with large text.
          final roomHeight = math.max(200.0, constraints.maxHeight * 0.42);

          return ListView(
            padding: const EdgeInsets.all(EcoSpacing.m),
            children: [
              _TopBar(
                level: level.level,
                xp: level.xpIntoLevel,
                xpTarget: level.xpForNextLevel,
                coins: game.progress.coins,
                tickets: game.progress.tickets,
              ),
              const SizedBox(height: EcoSpacing.m),
              SizedBox(height: roomHeight, child: const _PetRoomPreview()),
              const SizedBox(height: EcoSpacing.s + EcoSpacing.xs),
              EcoCard(
                child: Column(
                  children: [
                    StatBar(
                      label: l10n.statSatiety,
                      value: _need(pet.satiety),
                      color: EcoColors.satiety,
                      icon: Icons.restaurant_rounded,
                    ),
                    const SizedBox(height: EcoSpacing.s + EcoSpacing.xs),
                    StatBar(
                      label: l10n.statHappiness,
                      value: _need(pet.happiness),
                      color: EcoColors.happiness,
                      icon: Icons.favorite_rounded,
                    ),
                    const SizedBox(height: EcoSpacing.s + EcoSpacing.xs),
                    StatBar(
                      label: l10n.statCleanliness,
                      value: _need(pet.cleanliness),
                      color: EcoColors.cleanliness,
                      icon: Icons.water_drop_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: EcoSpacing.l),
              Semantics(
                header: true,
                child: Text(l10n.homeActivitiesTitle,
                    style: textTheme.titleLarge),
              ),
              const SizedBox(height: EcoSpacing.s + EcoSpacing.xs),
              _ActivityShortcut(
                icon: Icons.quiz_rounded,
                color: EcoColors.xp,
                title: l10n.homeQuizTitle,
                subtitle: l10n.homeQuizSubtitle,
                onTap: () => context.go(AppRoutes.learn),
              ),
              const SizedBox(height: EcoSpacing.s + EcoSpacing.xs),
              _ActivityShortcut(
                icon: Icons.recycling_rounded,
                color: EcoColors.primary,
                title: l10n.homeCleanupTitle,
                subtitle: l10n.homeCleanupSubtitle,
                onTap: () => context.go(AppRoutes.pet),
              ),
              // DEBUG ONLY (removed from release builds): earns a test
              // reward so we can check that saving works on a device.
              if (kDebugMode) ...[
                const SizedBox(height: EcoSpacing.m),
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.bug_report_rounded),
                    label: Text(l10n.debugRewardAction),
                    onPressed: () => ref
                        .read(gameControllerProvider.notifier)
                        .claimReward(
                          'debug:${DateTime.now().microsecondsSinceEpoch}',
                          const Reward(xp: 30, coins: 15),
                        ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.level,
    required this.xp,
    required this.xpTarget,
    required this.coins,
    required this.tickets,
  });

  final int level;
  final int xp;
  final int xpTarget;
  final int coins;
  final int tickets;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final levelAndXp = Row(
      children: [
        _LevelBadge(level: level),
        const SizedBox(width: EcoSpacing.s),
        Expanded(
          child: StatBar(
            label: l10n.levelLabel(level),
            value: xp / xpTarget,
            color: EcoColors.xp,
            valueText: '$xp/$xpTarget',
            semanticsValue: l10n.xpProgress(xp, xpTarget),
          ),
        ),
      ],
    );
    final balances = [
      CurrencyChip(kind: CurrencyKind.coins, amount: coins),
      CurrencyChip(kind: CurrencyKind.tickets, amount: tickets),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final largeText = MediaQuery.textScalerOf(context).scale(10) > 12;
        // 360 dp of usable width fits badge + XP bar + both balances
        // (a Pixel 7 has 379 dp after the 16 dp side padding).
        if (constraints.maxWidth >= 360 && !largeText) {
          return Row(
            children: [
              Expanded(child: levelAndXp),
              const SizedBox(width: EcoSpacing.m),
              ...balances.expand((chip) => [chip, const SizedBox(width: 6)]),
            ],
          );
        }
        // Narrow phone or large text: balances go on their own line.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            levelAndXp,
            const SizedBox(height: EcoSpacing.s),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: EcoSpacing.s,
              runSpacing: EcoSpacing.s,
              children: balances,
            ),
          ],
        );
      },
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    // The StatBar next to it already says "Livello N" to screen readers.
    return ExcludeSemantics(
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: EcoColors.xp,
          shape: BoxShape.circle,
        ),
        child: Text(
          '$level',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Colors.white),
          textScaler: TextScaler.noScaling,
        ),
      ),
    );
  }
}

/// Temporary room artwork drawn with plain widgets (no image files).
/// Phase 6 replaces it with the real animated pet and room.
class _PetRoomPreview extends StatelessWidget {
  const _PetRoomPreview();

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(EcoSpacing.radiusCard + 8);

    return Semantics(
      container: true,
      image: true,
      label: AppLocalizations.of(context).homePetPreview,
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: radius,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFBFE6F2), EcoColors.primaryContainer],
              ),
            ),
            child: Stack(
              children: [
                // Floor
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 56,
                  child: ColoredBox(color: Color(0xFFE3D3B0)),
                ),
                // Plant in the corner: the room will get greener over time.
                const Positioned(
                  right: EcoSpacing.m,
                  bottom: 40,
                  child: Icon(Icons.local_florist_rounded,
                      size: 48, color: EcoColors.primary),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: EcoSpacing.l, bottom: EcoSpacing.m),
                    child: const FittedBox(child: EggArt()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _ActivityShortcut extends StatelessWidget {
  const _ActivityShortcut({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return EcoCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: EcoSpacing.s + EcoSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: EcoColors.inkMuted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: EcoColors.inkMuted),
        ],
      ),
    );
  }
}
