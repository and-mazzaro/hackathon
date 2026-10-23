import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/router.dart';
import '../../app/theme/eco_colors.dart';
import '../../core/animations.dart';
import '../../domain/models/pet_state.dart';
import '../../domain/rules/pet_rules.dart';
import '../../l10n/app_localizations.dart';
import '../pet/otter_geometry.dart';
import '../pet/otter_idle.dart';
import '../pet/pet_art.dart';
import 'intro_painters.dart';

enum _Scene { title, guide, finale }

/// The presentation intro, in the style of the old handheld monster games:
/// a title screen ("Tocca per iniziare"), a guide who introduces the world
/// in a speech box, and a finale with confetti. Opened from the Profile tab
/// (`context.push(AppRoutes.intro)`); "Salta" closes it at any time.
///
/// When animations are off (tests, or the phone's "remove animations"
/// setting) every scene is shown still and complete.
class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen>
    with TickerProviderStateMixin {
  /// The title opening, once.
  late final _opening = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2800));

  /// Twinkle, blink, shine and rays: repeats forever.
  late final _loop =
      AnimationController(vsync: this, duration: const Duration(seconds: 4));

  /// The otter's idle pose.
  late final _pose = AnimationController(vsync: this, duration: otterIdleLoop);

  /// A hop each time the otter speaks.
  late final _hop = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 650));

  /// Typewriter for the current line.
  late final _type = AnimationController(vsync: this);

  /// Finale burst, once.
  late final _burst = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2200));

  var _scene = _Scene.title;
  var _line = 0;
  var _animate = true;
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animate = loopingAnimationsAllowed(context, ref);
    if (_animate) {
      if (!_loop.isAnimating) _loop.repeat();
      if (!_pose.isAnimating) _pose.repeat();
      if (!_started) _opening.forward();
    } else {
      _loop.stop();
      _pose.value = 0;
      _opening.value = 1;
      _type.value = 1;
      _hop.value = 0;
    }
    _started = true;
  }

  @override
  void dispose() {
    _opening.dispose();
    _loop.dispose();
    _pose.dispose();
    _hop.dispose();
    _type.dispose();
    _burst.dispose();
    super.dispose();
  }

  List<String> _lines(AppLocalizations l10n) => [
        l10n.introLine1,
        l10n.introLine2,
        l10n.introLine3,
        l10n.introLine4,
        l10n.introLine5,
      ];

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _startLine(int index) {
    final text = _lines(AppLocalizations.of(context))[index];
    setState(() => _line = index);
    if (!_animate) return;
    _type.duration = Duration(milliseconds: 32 * text.length);
    _type.forward(from: 0);
    _hop.forward(from: 0);
  }

  void _advance() {
    switch (_scene) {
      case _Scene.title:
        if (_opening.isAnimating) {
          _opening.value = 1; // a tap during the opening skips to its end
          return;
        }
        setState(() => _scene = _Scene.guide);
        _startLine(0);
      case _Scene.guide:
        if (_type.isAnimating) {
          _type.value = 1; // finish the line first
          return;
        }
        if (_line < 4) {
          _startLine(_line + 1);
        } else {
          setState(() => _scene = _Scene.finale);
          if (_animate) _burst.forward(from: 0);
        }
      case _Scene.finale:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scene = switch (_scene) {
      _Scene.title => _buildTitle(l10n),
      _Scene.guide => _buildGuide(l10n),
      _Scene.finale => _buildFinale(l10n),
    };
    return Scaffold(
      backgroundColor: const Color(0xFF070B1F),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: _animate
                ? const Duration(milliseconds: 450)
                : Duration.zero,
            child: KeyedSubtree(key: ValueKey(_scene), child: scene),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Semantics(
                  button: true,
                  label: l10n.introSkipLabel,
                  excludeSemantics: true,
                  onTap: _close,
                  child: FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.85),
                      foregroundColor: EcoColors.ink,
                    ),
                    onPressed: _close,
                    icon: const Icon(Icons.fast_forward_rounded),
                    label: Text(l10n.introSkip),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- title

  Widget _buildTitle(AppLocalizations l10n) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTap: _advance,
      child: AnimatedBuilder(
        animation: Listenable.merge([_opening, _loop]),
        builder: (context, _) {
          final t = _opening.value;
          final slam = introInterval(t, 0.4, 0.75);
          final scale = 1 + 3 * (1 - Curves.easeInCubic.transform(
              introInterval(t, 0.4, 0.55)));
          final settle = slam >= 0.43
              ? 1 + 0.08 * math.sin((slam - 0.43) / 0.57 * math.pi * 3) *
                  (1 - slam)
              : 1.0;
          final flash = t > 0.55 && t < 0.72 ? (0.72 - t) / 0.17 : 0.0;
          final shake = t > 0.55 && t < 0.65
              ? math.sin(t * 400) * 8 * (0.65 - t) / 0.1
              : 0.0;
          final subtitle = Curves.easeOut.transform(introInterval(t, 0.7, 0.85));
          final prompt = introInterval(t, 0.85, 1);
          final blinkOn = !_animate || (_loop.value * 4) % 1 < 0.62;
          // Shine: once after the slam, then every loop.
          final double? shine = t < 1
              ? (t > 0.7 && t < 0.9 ? (t - 0.7) / 0.2 : null)
              : (_animate && _loop.value < 0.3 ? _loop.value / 0.3 : null);

          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: IntroSkyPainter(intro: t, loop: _loop.value),
              ),
              Transform.translate(
                offset: Offset(shake, shake * 0.4),
                child: SafeArea(
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      Opacity(
                        opacity: introInterval(t, 0.4, 0.45),
                        child: Transform.scale(
                          scale: scale * settle,
                          child: _Logo(text: l10n.introLogo, shine: shine),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Opacity(
                        opacity: subtitle,
                        child: Transform.translate(
                          offset: Offset(0, 16 * (1 - subtitle)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              l10n.introSubtitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                shadows: const [
                                  Shadow(
                                      color: Colors.black54,
                                      offset: Offset(0, 2),
                                      blurRadius: 4),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(flex: 2),
                      Opacity(
                        opacity: prompt * (blinkOn ? 1 : 0.15),
                        child: Semantics(
                          button: true,
                          onTap: _advance,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: EcoColors.coin, width: 2),
                            ),
                            child: Text(
                              l10n.introPressStart,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      color: EcoColors.coin,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
              if (flash > 0)
                IgnorePointer(
                  child: ColoredBox(
                    color: Colors.white.withValues(alpha: 0.8 * flash),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------- guide

  OtterPose _otterPose({double extraLift = 0}) {
    final idle = idleOtterPose(
        _pose.value * otterIdleLoop.inMilliseconds / 1000);
    final hop = math.sin(math.pi * _hop.value) * 140;
    return OtterPose(
      headTilt: idle.headTilt,
      tailSwing: idle.tailSwing + 0.15 * math.sin(math.pi * _hop.value),
      eyesOpen: idle.eyesOpen,
      earTwitch: idle.earTwitch + 0.1 * math.sin(math.pi * _hop.value),
      bodyLift: math.max(hop, extraLift),
    );
  }

  Widget _otter(AppLocalizations l10n, {double extraLift = 0}) {
    return Semantics(
      image: true,
      label: l10n.introOtterLabel,
      child: ExcludeSemantics(
        child: PetArt(
          stage: PetStage.adult,
          mood: PetMood.happy,
          pose: _otterPose(extraLift: extraLift),
        ),
      ),
    );
  }

  Widget _buildGuide(AppLocalizations l10n) {
    final lines = _lines(l10n);
    final full = lines[_line];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTap: _advance,
      child: AnimatedBuilder(
        animation: Listenable.merge([_loop, _pose, _hop, _type]),
        builder: (context, _) {
          final shown =
              full.substring(0, (full.length * _type.value).round());
          final done = _type.value >= 1;
          final arrowOn = !_animate || (_loop.value * 4) % 1 < 0.6;
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter:
                    IntroMeadowPainter(loop: _loop.value, horizon: 0.5),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: const Alignment(0, 0.7),
                        child: FittedBox(
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              const CustomPaint(
                                size: Size(280, 70),
                                painter: IntroPlatformPainter(),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: _otter(l10n),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                      child: Semantics(
                        key: const ValueKey('intro-speech'),
                        button: true,
                        liveRegion: true,
                        label: full,
                        hint: l10n.introNext,
                        onTap: _advance,
                        excludeSemantics: true,
                        child: _SpeechBox(
                          text: shown,
                          // Reserve the space of the whole line, so the box
                          // does not grow while typing.
                          fullText: full,
                          showArrow: done && arrowOn,
                          step: '${_line + 1}/${lines.length}',
                          name: l10n.introLogo,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------- finale

  Widget _buildFinale(AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: Listenable.merge([_loop, _pose, _burst]),
      builder: (context, _) {
        final b = _animate ? _burst.value : 1.0;
        final confettiT = _animate ? _burst.value : 0.3;
        // One big jump with the burst, then small happy hops.
        final bigJump = math.sin(math.pi * introInterval(b, 0, 0.35)) * 240;
        final phase = (_loop.value * 2) % 1;
        final smallHop =
            _animate && b >= 1 && phase < 0.4 ? math.sin(math.pi * phase / 0.4) * 110 : 0.0;
        final title = Curves.elasticOut.transform(introInterval(b, 0.15, 0.7));
        final button = introInterval(b, 0.5, 0.8);
        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: IntroRaysPainter(turn: _loop.value)),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  Transform.scale(
                    scale: title,
                    child: Semantics(
                      header: true,
                      child: _Logo(text: l10n.introFinaleTitle, shine: null),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 4,
                    child: FittedBox(
                      child: _otter(l10n,
                          extraLift: math.max(bigJump, smallHop)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Opacity(
                    opacity: button,
                    child: Transform.scale(
                      scale: 0.8 + 0.2 * button,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: EcoColors.coin,
                          foregroundColor: EcoColors.ink,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 16),
                          textStyle: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        onPressed: _close,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(l10n.introStart),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            IgnorePointer(
              child: CustomPaint(painter: ConfettiPainter(t: confettiT)),
            ),
          ],
        );
      },
    );
  }
}

/// The game logo: chunky yellow letters with a thick blue outline and a
/// drop shadow; [shine] (0 → 1) sweeps a white band across it.
class _Logo extends StatelessWidget {
  const _Logo({required this.text, required this.shine});

  final String text;
  final double? shine;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.displayLarge!.copyWith(
          fontSize: 76,
          fontWeight: FontWeight.w800,
          letterSpacing: 4,
          height: 1.1,
        );
    final shineAt = shine;
    return Semantics(
      label: text,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FittedBox(
          child: Stack(
            children: [
              // Shadow + outline.
              Transform.translate(
                offset: const Offset(0, 7),
                child: Text(text,
                    textScaler: TextScaler.noScaling,
                    style: base.copyWith(
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 14
                        ..strokeJoin = StrokeJoin.round
                        ..color = const Color(0xFF0B1E3D),
                    )),
              ),
              Text(text,
                  textScaler: TextScaler.noScaling,
                  style: base.copyWith(
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 12
                      ..strokeJoin = StrokeJoin.round
                      ..color = const Color(0xFF1D4F9C),
                  )),
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFE680), EcoColors.coin, EcoColors.satiety],
                  stops: [0, 0.5, 1],
                ).createShader(rect),
                child: Text(text,
                    textScaler: TextScaler.noScaling,
                    style: base.copyWith(color: Colors.white)),
              ),
              if (shineAt != null)
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (rect) {
                    final p = -0.3 + shineAt * 1.6;
                    return LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.95),
                        Colors.white.withValues(alpha: 0),
                      ],
                      stops: [
                        (p - 0.12).clamp(0.0, 1.0),
                        p.clamp(0.0, 1.0),
                        (p + 0.12).clamp(0.0, 1.0),
                      ],
                    ).createShader(rect);
                  },
                  child: Text(text,
                      textScaler: TextScaler.noScaling,
                      style: base.copyWith(color: Colors.white)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The speech box at the bottom of the screen, like the old games: white,
/// rounded, a thick dark border and a bouncing arrow when the line is done.
class _SpeechBox extends StatelessWidget {
  const _SpeechBox({
    required this.text,
    required this.fullText,
    required this.showArrow,
    required this.step,
    required this.name,
  });

  final String text;
  final String fullText;
  final bool showArrow;
  final String step;
  final String name;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: EcoColors.ink,
          fontWeight: FontWeight.w800,
          height: 1.35,
        );
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1D4F9C), width: 5),
        boxShadow: const [
          BoxShadow(color: Color(0x55000000), offset: Offset(0, 5)),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF9CC3F0), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name,
                style: style?.copyWith(
                    color: EcoColors.primary, letterSpacing: 2, fontSize: 13)),
            const SizedBox(height: 4),
            Stack(
              children: [
                Opacity(opacity: 0, child: Text(fullText, style: style)),
                Text(text, style: style),
              ],
            ),
            Row(
              children: [
                Text(step,
                    style: style?.copyWith(
                        color: EcoColors.inkMuted, fontSize: 12)),
                const Spacer(),
                Opacity(
                  opacity: showArrow ? 1 : 0,
                  child: const Icon(Icons.arrow_drop_down_rounded,
                      color: EcoColors.alert, size: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
