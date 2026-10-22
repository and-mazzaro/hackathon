import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../core/widgets/eco_button.dart';
import '../../core/widgets/egg_art.dart';
import '../../domain/game_controller.dart';
import '../../domain/models/eco_topic.dart';
import '../../domain/models/player_profile.dart';
import '../../l10n/app_localizations.dart';
import '../profile/about_you_fields.dart';
import '../profile/interest_picker.dart';

/// First launch: welcome → interests → nickname and age (optional).
///
/// The answers stay in this screen (temporary UI state) until the player
/// taps "Fine" or "Salta". Only then they go to GameController and are
/// saved; the router then moves to Home on its own.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _stepCount = 3;

  int _step = 0;
  final Set<EcoTopic> _interests = {};
  AgeRange? _ageRange;
  final _nickname = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    FocusScope.of(context).unfocus(); // close the keyboard
    setState(() => _step = step);
  }

  void _toggle(EcoTopic topic) {
    setState(() {
      if (!_interests.remove(topic)) _interests.add(topic);
    });
  }

  Future<void> _finish({required bool withDetails}) async {
    setState(() => _saving = true);
    try {
      await ref.read(gameControllerProvider.notifier).completeOnboarding(
            interests: {..._interests},
            nickname: withDetails ? _nickname.text : null,
            ageRange: withDetails ? _ageRange : null,
          );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final content = switch (_step) {
      0 => const _WelcomeStep(),
      1 => _StepText(
          title: l10n.interestsTitle,
          body: l10n.interestsBody,
          child: InterestPicker(selected: _interests, onToggle: _toggle),
        ),
      _ => _StepText(
          title: l10n.aboutTitle,
          body: l10n.aboutBody,
          child: AboutYouFields(
            nicknameController: _nickname,
            ageRange: _ageRange,
            onAgeRangeChanged: (range) => setState(() => _ageRange = range),
          ),
        ),
    };

    // Android back button: previous step; on the first step leave the app.
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goTo(_step - 1);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _StepHeader(
                step: _step,
                total: _stepCount,
                onBack: _step == 0 ? null : () => _goTo(_step - 1),
              ),
              Expanded(
                child: SingleChildScrollView(
                  // A new key per step starts each step at the top.
                  key: ValueKey(_step),
                  padding: const EdgeInsets.fromLTRB(
                      EcoSpacing.l, EcoSpacing.s, EcoSpacing.l, EcoSpacing.l),
                  child: content,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    EcoSpacing.l, EcoSpacing.s, EcoSpacing.l, EcoSpacing.m),
                child: _buttons(l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buttons(AppLocalizations l10n) {
    switch (_step) {
      case 0:
        return EcoButton(
          label: l10n.welcomeStartAction,
          icon: Icons.arrow_forward_rounded,
          expand: true,
          onPressed: () => _goTo(1),
        );
      case 1:
        final canContinue = _interests.isNotEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              canContinue
                  ? l10n.interestsSelectedCount(_interests.length)
                  : l10n.interestsMinHint,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: EcoColors.inkMuted),
            ),
            const SizedBox(height: EcoSpacing.s),
            EcoButton(
              label: l10n.nextAction,
              icon: Icons.arrow_forward_rounded,
              expand: true,
              onPressed: canContinue ? () => _goTo(2) : null,
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EcoButton(
              label: l10n.finishAction,
              icon: Icons.check_rounded,
              expand: true,
              onPressed:
                  _saving ? null : () => _finish(withDetails: true),
            ),
            const SizedBox(height: EcoSpacing.s),
            EcoButton(
              label: l10n.skipAction,
              variant: EcoButtonVariant.secondary,
              expand: true,
              onPressed:
                  _saving ? null : () => _finish(withDetails: false),
            ),
          ],
        );
    }
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.step,
    required this.total,
    required this.onBack,
  });

  final int step;
  final int total;

  /// null on the first step (nothing to go back to).
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          EcoSpacing.s, EcoSpacing.s, EcoSpacing.l, EcoSpacing.s),
      child: Row(
        children: [
          // Same width on every step, so the bar does not jump.
          SizedBox(
            width: EcoSpacing.minTouchTarget,
            height: EcoSpacing.minTouchTarget,
            child: onBack == null
                ? null
                : IconButton(
                    onPressed: onBack,
                    tooltip: l10n.backAction,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
          ),
          const SizedBox(width: EcoSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // liveRegion: screen readers announce "Passo 2 di 3"
                // whenever the step changes.
                Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.onboardingStep(step + 1, total),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                const SizedBox(height: EcoSpacing.xs),
                ExcludeSemantics(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(EcoSpacing.radiusPill),
                    child: LinearProgressIndicator(
                      value: (step + 1) / total,
                      minHeight: 8,
                      backgroundColor:
                          EcoColors.primary.withValues(alpha: 0.15),
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

class _StepText extends StatelessWidget {
  const _StepText({
    required this.title,
    required this.body,
    required this.child,
  });

  final String title;
  final String body;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: textTheme.headlineSmall),
        ),
        const SizedBox(height: EcoSpacing.s),
        Text(body,
            style: textTheme.bodyLarge?.copyWith(color: EcoColors.inkMuted)),
        const SizedBox(height: EcoSpacing.l),
        child,
      ],
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        const SizedBox(height: EcoSpacing.l),
        Semantics(
          container: true,
          image: true,
          label: l10n.welcomeEggLabel,
          child: const ExcludeSemantics(
            child: SizedBox(height: 180, child: FittedBox(child: EggArt())),
          ),
        ),
        const SizedBox(height: EcoSpacing.l),
        Semantics(
          header: true,
          child: Text(
            l10n.welcomeTitle,
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: EcoSpacing.m),
        Text(
          l10n.welcomeBody,
          style: textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: EcoSpacing.l),
        Container(
          padding: const EdgeInsets.all(EcoSpacing.m),
          decoration: BoxDecoration(
            color: EcoColors.primaryContainer,
            borderRadius: BorderRadius.circular(EcoSpacing.radiusCard),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_outline_rounded, color: EcoColors.ink),
              const SizedBox(width: EcoSpacing.s + EcoSpacing.xs),
              Expanded(
                child: Text(l10n.welcomePrivacy, style: textTheme.bodyMedium),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
