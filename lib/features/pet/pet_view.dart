import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../core/animations.dart';
import '../../core/widgets/egg_art.dart';
import '../../domain/game_controller.dart';
import '../../domain/models/look_mode.dart';
import '../../domain/models/pet_state.dart';
import '../../domain/rules/pet_rules.dart';
import '../../domain/rules/time_of_day_rules.dart';
import '../wardrobe/cosmetic_labels.dart';
import 'otter_idle.dart';
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
  // Drives the otter's idle pose (blink, tail wag, head tilt).
  late final _pose = AnimationController(vsync: this, duration: otterIdleLoop);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start or stop the endless idle loop (off in tests and when the
    // player disabled animations on the phone).
    if (loopingAnimationsAllowed(context, ref)) {
      if (!_idle.isAnimating) _idle.repeat(reverse: true);
      if (!_pose.isAnimating) _pose.repeat();
    } else {
      _idle.stop();
      _pose.value = 0; // the rest pose
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
    _pose.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;
    final isEgg = pet.stage == PetStage.egg;
    final look = lookFor(
      ref.watch(gameControllerProvider
              .select((game) => game.value?.lookMode)) ??
          LookMode.auto,
      ref.watch(clockProvider)(),
    );
    final art = isEgg
        ? const EggArt()
        : AnimatedBuilder(
            animation: _pose,
            builder: (context, _) => PetArt(
              stage: pet.stage,
              mood: moodOf(pet),
              dirty: pet.cleanliness < 40,
              outfit: ref.watch(petOutfitProvider),
              pose: idleOtterPose(
                  _pose.value * otterIdleLoop.inMilliseconds / 1000),
            ),
          );

    return Semantics(
      container: true,
      image: true,
      label: widget.semanticLabel,
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(EcoSpacing.radiusCard + 8),
          child: DecoratedBox(
            key: ValueKey('room-${look.name}'),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _skyColors(look),
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _SkyPainter(look)),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 56,
                  child: ColoredBox(color: _floorColor(look)),
                ),
                ..._plants(widget.plants, look),
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

  static List<Color> _skyColors(TimeOfDayLook look) => switch (look) {
        TimeOfDayLook.day => const [
            Color(0xFFBFE6F2),
            EcoColors.primaryContainer,
          ],
        // Warm sunset: orange-pink sky fading to a soft peach.
        TimeOfDayLook.afternoon => const [
            Color(0xFFF79A6B),
            Color(0xFFF9C0A8),
            Color(0xFFFCE3C4),
          ],
        // Deep blue night, a bit lighter near the floor.
        TimeOfDayLook.night => const [
            Color(0xFF14204A),
            Color(0xFF2C3E73),
          ],
      };

  static Color _floorColor(TimeOfDayLook look) => switch (look) {
        TimeOfDayLook.day => const Color(0xFFE3D3B0),
        TimeOfDayLook.afternoon => const Color(0xFFD9BE96),
        TimeOfDayLook.night => const Color(0xFF8C7C62),
      };

  List<Widget> _plants(int count, TimeOfDayLook look) {
    // At night the leaf green would sink into the dark sky: use a lighter
    // green so the plants stay visible.
    final color = look == TimeOfDayLook.night
        ? const Color(0xFF7FD6A0)
        : EcoColors.primary;
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
          child: Icon(icon, size: size, color: color),
        ),
    ];
  }
}

/// Sun, low sunset sun, or moon and stars behind the pet.
class _SkyPainter extends CustomPainter {
  const _SkyPainter(this.look);

  final TimeOfDayLook look;

  @override
  void paint(Canvas canvas, Size size) {
    switch (look) {
      case TimeOfDayLook.day:
        return; // the day sky stays as it always was
      case TimeOfDayLook.afternoon:
        // A big, low sun just above the floor, with a soft glow.
        final center = Offset(size.width * 0.22, size.height - 70);
        canvas.drawCircle(
            center, 46, Paint()..color = const Color(0x55FFE08A));
        canvas.drawCircle(
            center, 30, Paint()..color = const Color(0xFFFFB347));
      case TimeOfDayLook.night:
        final star = Paint()..color = const Color(0xDDFFFFFF);
        const stars = [
          (0.12, 0.10, 2.0),
          (0.30, 0.22, 1.5),
          (0.48, 0.08, 2.2),
          (0.64, 0.30, 1.4),
          (0.90, 0.20, 1.8),
          (0.40, 0.42, 1.2),
          (0.08, 0.36, 1.5),
        ];
        for (final (x, y, r) in stars) {
          canvas.drawCircle(
              Offset(size.width * x, size.height * y), r, star);
        }
        // A crescent moon: a pale disc minus a smaller offset one. Placed
        // mid-right, clear of the otter and of buttons in the corners.
        final moon = Offset(size.width * 0.86, size.height * 0.42);
        final crescent = Path.combine(
          PathOperation.difference,
          Path()..addOval(Rect.fromCircle(center: moon, radius: 20)),
          Path()
            ..addOval(Rect.fromCircle(
                center: moon.translate(9, -6), radius: 17)),
        );
        canvas.drawPath(crescent, Paint()..color = const Color(0xFFF4EBC8));
    }
  }

  @override
  bool shouldRepaint(_SkyPainter old) => old.look != look;
}
