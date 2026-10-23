import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../core/animations.dart';
import '../../core/widgets/egg_art.dart';
import '../../domain/models/pet_state.dart';
import '../../domain/rules/pet_rules.dart';
import '../wardrobe/cosmetic_labels.dart';
import 'pet_art.dart';

/// A one-off reaction (bounce + floating icon). A new [id] plays it again.
class PetReaction {
  const PetReaction({required this.id, required this.icon});

  final int id;
  final IconData icon;
}

/// The pet in its room. Used on Home and in the Pet tab.
///
/// [pet] must already be the pet "now" (see `petNow`). The room shows
/// [plants] decorations (0–3), which grow with the player's level.
/// A hatched pet wears what is equipped in the wardrobe.
class PetView extends ConsumerStatefulWidget {
  const PetView({
    super.key,
    required this.pet,
    required this.plants,
    required this.semanticLabel,
    this.reaction,
  });

  final PetState pet;
  final int plants;
  final String semanticLabel;
  final PetReaction? reaction;

  @override
  ConsumerState<PetView> createState() => _PetViewState();
}

class _PetViewState extends ConsumerState<PetView>
    with TickerProviderStateMixin {
  late final _idle = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2400));
  late final _react = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start or stop the endless idle loop (off in tests and when the
    // player disabled animations on the phone).
    if (loopingAnimationsAllowed(context, ref)) {
      if (!_idle.isAnimating) _idle.repeat(reverse: true);
    } else {
      _idle.stop();
    }
  }

  @override
  void didUpdateWidget(PetView old) {
    super.didUpdateWidget(old);
    if (widget.reaction != null && widget.reaction?.id != old.reaction?.id) {
      _react.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _idle.dispose();
    _react.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;
    final isEgg = pet.stage == PetStage.egg;
    final art = isEgg
        ? const EggArt()
        : PetArt(
            stage: pet.stage,
            mood: moodOf(pet),
            dirty: pet.cleanliness < 40,
            outfit: ref.watch(petOutfitProvider),
          );

    return Semantics(
      container: true,
      image: true,
      label: widget.semanticLabel,
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(EcoSpacing.radiusCard + 8),
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
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 56,
                  child: ColoredBox(color: Color(0xFFE3D3B0)),
                ),
                ..._plants(widget.plants),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: EcoSpacing.l, bottom: EcoSpacing.m),
                    child: FittedBox(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_idle, _react]),
                        builder: (context, child) {
                          final t = Curves.easeInOut.transform(_idle.value);
                          final bounce = math.sin(math.pi * _react.value);
                          return Transform.translate(
                            offset: Offset(0, isEgg ? 0 : -6 * t),
                            child: Transform.rotate(
                              angle: isEgg ? (t - 0.5) * 0.08 : 0,
                              child: Transform.scale(
                                scale: 1 + 0.12 * bounce,
                                alignment: Alignment.bottomCenter,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: AnimatedSwitcher(
                          // Hatching / growing: the new look pops in.
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: KeyedSubtree(
                            key: ValueKey(pet.stage),
                            child: art,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.reaction != null)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _react,
                      builder: (context, _) {
                        final v = _react.value;
                        if (v == 0 || v == 1) return const SizedBox.shrink();
                        return Align(
                          alignment: Alignment(0.35, 0.1 - v * 0.9),
                          child: Opacity(
                            opacity: 1 - v,
                            child: Icon(widget.reaction!.icon,
                                size: 40, color: EcoColors.happiness),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _plants(int count) {
    const spots = [
      (Alignment(0.88, 0.55), Icons.local_florist_rounded, 48.0),
      (Alignment(-0.88, 0.55), Icons.spa_rounded, 44.0),
      (Alignment(-0.6, -0.75), Icons.grass_rounded, 36.0),
    ];
    // One plant is always there; more appear as the player levels up.
    return [
      for (final (alignment, icon, size) in spots.take(1 + count))
        Align(
          alignment: alignment,
          child: Icon(icon, size: size, color: EcoColors.primary),
        ),
    ];
  }
}
