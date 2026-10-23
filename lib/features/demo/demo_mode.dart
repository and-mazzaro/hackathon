import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/router.dart';
import '../../app/theme/eco_colors.dart';
import '../../l10n/app_localizations.dart';

/// One stop of the demo tour.
enum DemoStep {
  home(AppRoutes.home),
  learn(AppRoutes.learn),
  pet(AppRoutes.pet),
  wardrobe(AppRoutes.wardrobe);

  const DemoStep(this.path);
  final String path;

  String caption(AppLocalizations l10n) => switch (this) {
        DemoStep.home => l10n.demoCaptionHome,
        DemoStep.learn => l10n.demoCaptionLearn,
        DemoStep.pet => l10n.demoCaptionPet,
        DemoStep.wardrobe => l10n.demoCaptionWardrobe,
      };
}

/// How long the demo stays on each screen.
final demoStepDurationProvider =
    Provider<Duration>((ref) => const Duration(seconds: 6));

/// Demo mode for projecting the app: it only moves between screens
/// (Home → Impara → Cucciolo → Guardaroba, then again) and shows a caption.
/// It never calls the game controller, so the saved game does not change.
/// State: the current step, or null when the demo is off.
final demoModeProvider =
    NotifierProvider<DemoModeController, DemoStep?>(DemoModeController.new);

class DemoModeController extends Notifier<DemoStep?> {
  Timer? _timer;

  @override
  DemoStep? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  void start() {
    _timer?.cancel();
    _show(DemoStep.home);
    _timer = Timer.periodic(ref.read(demoStepDurationProvider), (_) {
      final next = DemoStep.values[
          (state!.index + 1) % DemoStep.values.length];
      _show(next);
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    if (state == null) return;
    state = null;
    ref.read(routerProvider).go(AppRoutes.home);
  }

  void _show(DemoStep step) {
    state = step;
    ref.read(routerProvider).go(step.path);
  }
}

/// The caption banner shown over every screen while the demo runs, with
/// a button to leave it. Placed above the router in `EcoQuestApp.builder`.
class DemoCaptionOverlay extends ConsumerWidget {
  const DemoCaptionOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(demoModeProvider);
    if (step == null) return child;
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        child,
        Positioned(
          left: 12,
          right: 12,
          bottom: 96,
          child: SafeArea(
            top: false,
            child: Material(
              color: EcoColors.ink.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(18),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                child: Row(
                  children: [
                    const Icon(Icons.slideshow_rounded,
                        color: EcoColors.coin),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          step.caption(l10n),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: EcoColors.coin),
                      onPressed: () =>
                          ref.read(demoModeProvider.notifier).stop(),
                      child: Text(l10n.demoStop),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
