import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/router.dart';
import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../core/audio/ambience_loop.dart';
import '../../core/audio/audio_service.dart';
import '../../core/audio/game_sounds.dart';
import '../../core/audio/sound_id.dart';
import '../../core/widgets/eco_button.dart';
import '../../core/widgets/eco_card.dart';
import '../../core/widgets/game_state_view.dart';
import '../../domain/game_controller.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/pet_state.dart';
import '../../domain/rules/pet_rules.dart';
import '../../domain/rules/progression.dart';
import '../../l10n/app_localizations.dart';
import 'egg_progress.dart';
import 'hatch_sheet.dart';
import 'pet_labels.dart';
import 'pet_need_bars.dart';
import 'pet_view.dart';

/// PET tab: the room, the pet's needs and the care buttons.
class PetScreen extends StatelessWidget {
  const PetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Soft sea waves while the room is on screen.
    return AmbienceLoop(
      sound: SoundId.ambienceSea,
      child: GameStateView(builder: (context, game) => _PetContent(game: game)),
    );
  }
}

class _PetContent extends ConsumerStatefulWidget {
  const _PetContent({required this.game});

  final GameState game;

  @override
  ConsumerState<_PetContent> createState() => _PetContentState();
}

class _PetContentState extends ConsumerState<_PetContent> {
  PetReaction? _reaction;
  String? _message;
  int _reactionCount = 0;

  void _show(IconData icon, String message) => setState(() {
        _reaction = PetReaction(id: ++_reactionCount, icon: icon);
        _message = message;
      });

  Future<void> _care(PetState pet, CareAction action) async {
    final l10n = AppLocalizations.of(context);
    final name = petDisplayName(pet, l10n);
    final audio = ref.read(audioServiceProvider);
    if (needFor(pet, action) >= PetState.maxNeed) {
      _show(Icons.thumb_up_rounded, l10n.careAlreadyFull(name));
      audio.play(SoundId.uiUnavailable);
      return;
    }
    await ref.read(gameControllerProvider.notifier).careForPet(action);
    if (!mounted) return;
    audio.play(careSound(action));
    switch (action) {
      case CareAction.feed:
        _show(Icons.restaurant_rounded, l10n.careFedMessage(name));
      case CareAction.play:
        _show(Icons.favorite_rounded, l10n.carePlayedMessage(name));
      case CareAction.clean:
        _show(Icons.bubble_chart_rounded, l10n.careCleanedMessage(name));
    }
  }

  Future<void> _evolve(PetState pet) async {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(gameControllerProvider.notifier);
    final audio = ref.read(audioServiceProvider);
    final PetStage? grownTo;
    if (pet.stage == PetStage.egg) {
      final name = await showHatchSheet(context);
      if (name == null || !mounted) return; // sheet dismissed
      grownTo = await controller.evolvePet(name: name);
    } else {
      grownTo = await controller.evolvePet();
    }
    if (!mounted) return;
    if (grownTo != null) {
      audio.play(pet.stage == PetStage.egg ? SoundId.petHatch : SoundId.petGrow);
    }
    final grown = ref.read(gameControllerProvider).requireValue.pet;
    final name = petDisplayName(grown, l10n);
    _show(
      Icons.auto_awesome_rounded,
      pet.stage == PetStage.egg
          ? l10n.hatchedMessage(name)
          : l10n.grownMessage(name, grown.stage.label(l10n)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final economy = ref.watch(economyProvider);
    final now = ref.watch(clockProvider)();
    final game = widget.game;
    final pet = petNow(game.pet, now, economy);
    final level = levelForTotalXp(game.progress.totalXp, economy).level;
    final canGrow = nextStage(pet.stage, level, economy) != null;
    final isEgg = pet.stage == PetStage.egg;
    final mood = moodOf(pet);

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => ListView(
          padding: const EdgeInsets.all(EcoSpacing.m),
          children: [
            // Name on its own line, chips below: fits with large text.
            Semantics(
              header: true,
              child: Text(petDisplayName(pet, l10n),
                  style: textTheme.headlineSmall),
            ),
            const SizedBox(height: EcoSpacing.xs),
            Wrap(
              spacing: EcoSpacing.xs,
              runSpacing: EcoSpacing.xs,
              children: [
                _Chip(text: pet.stage.label(l10n)),
                if (!isEgg) _Chip(text: mood.label(l10n)),
              ],
            ),
            const SizedBox(height: EcoSpacing.s),
            SizedBox(
              height: math.max(220.0, constraints.maxHeight * 0.42),
              child: PetView(
                pet: pet,
                plants: roomPlants(level, economy),
                semanticLabel: petSemanticLabel(pet, l10n),
                reaction: _reaction,
              ),
            ),
            // Read aloud by screen readers whenever it changes.
            Semantics(
              liveRegion: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: EcoSpacing.s),
                child: Text(
                  _message ?? '',
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium,
                ),
              ),
            ),
            if (canGrow)
              _GrowCard(pet: pet, onPressed: () => _evolve(pet))
            else if (isEgg)
              _EggProgressCard(
                totalXp: game.progress.totalXp,
                onStroke: () {
                  _show(Icons.favorite_rounded, l10n.eggStrokeMessage);
                  ref.read(audioServiceProvider).play(SoundId.petEggPat);
                },
              ),
            const SizedBox(height: EcoSpacing.m),
            // Room Cleanup: sorting waste here also cleans the pet.
            EcoButton(
              label: l10n.cleanupOpenFromPet,
              icon: Icons.recycling_rounded,
              expand: true,
              onPressed: () => context.push(AppRoutes.cleanup),
            ),
            const SizedBox(height: EcoSpacing.m),
            if (!isEgg) ...[
              if (canGrow) const SizedBox(height: EcoSpacing.m),
              EcoCard(child: PetNeedBars(pet: pet)),
              const SizedBox(height: EcoSpacing.m),
              _CareButtons(onCare: (action) => _care(pet, action)),
              if (mood == PetMood.sad) ...[
                const SizedBox(height: EcoSpacing.m),
                Text(l10n.petSadHint,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: EcoColors.inkMuted)),
              ],
              if (!canGrow && levelForNextStage(pet.stage, economy) != null) ...[
                const SizedBox(height: EcoSpacing.s),
                Text(
                  l10n.nextGrowth(levelForNextStage(pet.stage, economy)!),
                  textAlign: TextAlign.center,
                  style:
                      textTheme.bodySmall?.copyWith(color: EcoColors.inkMuted),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: EcoSpacing.s + EcoSpacing.xs, vertical: EcoSpacing.xs),
      decoration: BoxDecoration(
        color: EcoColors.primaryContainer,
        borderRadius: BorderRadius.circular(EcoSpacing.radiusPill),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

/// Before hatching: how much XP is still missing, linked to learning.
class _EggProgressCard extends StatelessWidget {
  const _EggProgressCard({required this.totalXp, required this.onStroke});

  final int totalXp;
  final VoidCallback onStroke;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return EcoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EggProgressBar(totalXp: totalXp),
          const SizedBox(height: EcoSpacing.s),
          Text(l10n.eggHatchHint, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: EcoSpacing.m),
          EcoButton(
            label: l10n.eggStroke,
            icon: Icons.back_hand_rounded,
            variant: EcoButtonVariant.secondary,
            expand: true,
            onPressed: onStroke,
          ),
        ],
      ),
    );
  }
}

class _GrowCard extends StatelessWidget {
  const _GrowCard({required this.pet, required this.onPressed});

  final PetState pet;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEgg = pet.stage == PetStage.egg;

    return EcoCard(
      color: EcoColors.coin.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isEgg ? l10n.eggReady : l10n.growReady(petDisplayName(pet, l10n)),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: EcoSpacing.m),
          EcoButton(
            label: isEgg ? l10n.eggHatchAction : l10n.growAction,
            icon: Icons.auto_awesome_rounded,
            expand: true,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class _CareButtons extends StatelessWidget {
  const _CareButtons({required this.onCare});

  final ValueChanged<CareAction> onCare;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final buttons = [
      (CareAction.feed, Icons.restaurant_rounded, l10n.careFeed),
      (CareAction.play, Icons.sports_soccer_rounded, l10n.carePlay),
      (CareAction.clean, Icons.bathtub_rounded, l10n.careClean),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (action, icon, label) in buttons) ...[
          EcoButton(
            label: label,
            icon: icon,
            variant: EcoButtonVariant.secondary,
            expand: true,
            onPressed: () => onCare(action),
          ),
          const SizedBox(height: EcoSpacing.s),
        ],
      ],
    );
  }
}
