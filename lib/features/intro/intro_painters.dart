import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';

/// Night sky for the title scene: twinkling stars, shooting stars that
/// streak in at the start, and a green-blue planet rising at the bottom.
///
/// [intro] runs 0 → 1 once (the opening), [loop] 0 → 1 forever (twinkle).
class IntroSkyPainter extends CustomPainter {
  IntroSkyPainter({required this.intro, required this.loop});

  final double intro;
  final double loop;

  static final List<_Star> _stars = _makeStars();

  static List<_Star> _makeStars() {
    final random = math.Random(3);
    return List.generate(
      80,
      (_) => _Star(
        x: random.nextDouble(),
        y: random.nextDouble() * 0.8,
        radius: 0.6 + random.nextDouble() * 1.8,
        phase: random.nextDouble(),
        speed: 1 + random.nextInt(3).toDouble(),
      ),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF070B1F), Color(0xFF10264A), Color(0xFF14513F)],
          stops: [0, 0.6, 1],
        ).createShader(rect),
    );

    // Stars fade in during the first part of the opening.
    final starsIn = _interval(intro, 0, 0.35);
    final star = Paint();
    for (final s in _stars) {
      final twinkle =
          0.55 + 0.45 * math.sin(2 * math.pi * (loop * s.speed + s.phase));
      star.color = Colors.white.withValues(alpha: starsIn * twinkle);
      canvas.drawCircle(
          Offset(s.x * size.width, s.y * size.height), s.radius, star);
    }

    // Shooting stars: they cross the screen during the opening.
    for (var i = 0; i < 9; i++) {
      final start = i * 0.045;
      final t = _interval(intro, start, start + 0.3);
      if (t <= 0 || t >= 1) continue;
      final from = Offset(size.width * (1.1 + 0.08 * (i % 3)),
          size.height * (-0.05 + 0.06 * i));
      final dir = const Offset(-1, 0.55);
      final travel = size.width * 1.5;
      final head = from + dir * (travel * Curves.easeIn.transform(t));
      final tail = head - dir * (size.width * 0.35);
      canvas.drawLine(
        tail,
        head,
        Paint()
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..shader = LinearGradient(colors: [
            Colors.white.withValues(alpha: 0),
            i.isEven ? EcoColors.coin : Colors.white,
          ]).createShader(Rect.fromPoints(tail, head)),
      );
      canvas.drawCircle(head, 3.5, Paint()..color = Colors.white);
    }

    // The planet rises from below.
    final rise = Curves.easeOutCubic.transform(_interval(intro, 0.05, 0.5));
    final r = size.width * 0.95;
    final center = Offset(
        size.width / 2, size.height + r * 0.62 + (1 - rise) * r * 0.5);
    final planet = Rect.fromCircle(center: center, radius: r);
    canvas.drawCircle(
      center,
      r + 18,
      Paint()
        ..color = const Color(0xFF5FD3F3).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.2, -0.8),
          radius: 1.1,
          colors: [Color(0xFF4FB3E8), Color(0xFF1C5FA6)],
        ).createShader(planet),
    );
    canvas.save();
    canvas.clipPath(Path()..addOval(planet));
    final land = Paint()..color = const Color(0xFF3FAE5A);
    final drift = loop * r * 0.15;
    for (final (dx, dy, w, h) in const [
      (-0.55, -0.93, 0.42, 0.16),
      (0.1, -0.97, 0.3, 0.1),
      (0.45, -0.86, 0.36, 0.2),
      (-0.15, -0.8, 0.22, 0.12),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center + Offset(dx * r + drift, dy * r),
          width: w * r,
          height: h * r,
        ),
        land,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(IntroSkyPainter old) =>
      old.intro != intro || old.loop != loop;
}

class _Star {
  const _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.phase,
    required this.speed,
  });

  final double x;
  final double y;
  final double radius;
  final double phase;
  final double speed;
}

/// Daytime meadow for the guide scene: sky, drifting clouds, a green hill
/// (the otter stands on an [IntroPlatformPainter] in front of it).
class IntroMeadowPainter extends CustomPainter {
  IntroMeadowPainter({required this.loop, required this.horizon});

  final double loop;

  /// Where the hills start, 0 = top, 1 = bottom.
  final double horizon;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7CC8F2), Color(0xFFCDEFD9)],
        ).createShader(rect),
    );
    // Sun.
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.1), 34,
        Paint()..color = EcoColors.coin);
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.1),
      50,
      Paint()..color = EcoColors.coin.withValues(alpha: 0.3),
    );
    // Clouds.
    final cloud = Paint()..color = Colors.white.withValues(alpha: 0.9);
    for (final (x, y, s) in const [(0.15, 0.12, 1.0), (0.6, 0.22, 0.7)]) {
      final cx = ((x + loop * 0.2) % 1.3 - 0.15) * size.width;
      final cy = y * size.height;
      for (final (dx, dy, rr) in const [
        (0.0, 0.0, 22.0),
        (24.0, -10.0, 26.0),
        (50.0, 0.0, 20.0),
      ]) {
        canvas.drawCircle(Offset(cx + dx * s, cy + dy * s), rr * s, cloud);
      }
    }
    // Hills.
    final hillTop = size.height * (horizon - 0.06);
    canvas.drawPath(
      Path()
        ..moveTo(0, hillTop + 30)
        ..quadraticBezierTo(
            size.width * 0.3, hillTop - 40, size.width * 0.6, hillTop + 10)
        ..quadraticBezierTo(
            size.width * 0.85, hillTop + 40, size.width, hillTop)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      Paint()..color = const Color(0xFF6CC27A),
    );
    canvas.drawRect(
      Rect.fromLTRB(0, hillTop + 50, size.width, size.height),
      Paint()..color = const Color(0xFF4FAE63),
    );
  }

  @override
  bool shouldRepaint(IntroMeadowPainter old) =>
      old.loop != loop || old.horizon != horizon;
}

/// The round grass platform the otter stands on, like the battle
/// platforms of the old games. Fills its size.
class IntroPlatformPainter extends CustomPainter {
  const IntroPlatformPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final platform = Offset.zero & Size(size.width, size.height - 6);
    canvas.drawOval(platform.shift(const Offset(0, 6)),
        Paint()..color = const Color(0xFF2F7D45));
    canvas.drawOval(platform, Paint()..color = const Color(0xFF9BDC8A));
    canvas.drawOval(
      platform.deflate(platform.height * 0.18),
      Paint()..color = const Color(0xFFB9EAA4),
    );
  }

  @override
  bool shouldRepaint(IntroPlatformPainter old) => false;
}

/// Finale background: a turning sunburst of rays.
class IntroRaysPainter extends CustomPainter {
  IntroRaysPainter({required this.turn});

  /// 0 → 1 = one ray step.
  final double turn;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF2FA866), EcoColors.primary, Color(0xFF0F4A2D)],
          stops: [0, 0.55, 1],
        ).createShader(rect),
    );
    const rays = 16;
    final center = Offset(size.width / 2, size.height * 0.4);
    final reach = size.longestSide;
    final ray = Paint()..color = Colors.white.withValues(alpha: 0.1);
    for (var i = 0; i < rays; i += 2) {
      final a = (i + turn * 2) * 2 * math.pi / rays;
      final b = a + 2 * math.pi / rays;
      canvas.drawPath(
        Path()
          ..moveTo(center.dx, center.dy)
          ..lineTo(center.dx + reach * math.cos(a), center.dy + reach * math.sin(a))
          ..lineTo(center.dx + reach * math.cos(b), center.dy + reach * math.sin(b))
          ..close(),
        ray,
      );
    }
  }

  @override
  bool shouldRepaint(IntroRaysPainter old) => old.turn != turn;
}

/// A burst of confetti and leaves from [origin] (fractions of the size).
/// [t] 0 → 1: thrown out, then falling and fading.
class ConfettiPainter extends CustomPainter {
  ConfettiPainter({required this.t, this.origin = const Offset(0.5, 0.4)});

  final double t;
  final Offset origin;

  static final List<_Bit> _bits = _makeBits();

  static List<_Bit> _makeBits() {
    final random = math.Random(7);
    const colors = [
      EcoColors.coin,
      EcoColors.happiness,
      EcoColors.cleanliness,
      EcoColors.satiety,
      Colors.white,
      Color(0xFF7A9F36),
      Color(0xFF9BDC8A),
    ];
    return List.generate(70, (i) {
      final angle = -math.pi / 2 + (random.nextDouble() - 0.5) * math.pi * 1.6;
      return _Bit(
        angle: angle,
        speed: 0.45 + random.nextDouble() * 0.7,
        color: colors[i % colors.length],
        leaf: i % 3 == 0,
        spin: (random.nextDouble() - 0.5) * 14,
        size: 6 + random.nextDouble() * 8,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final o = Offset(origin.dx * size.width, origin.dy * size.height);
    final fade = t < 0.75 ? 1.0 : (1 - t) / 0.25;
    final paint = Paint();
    for (final b in _bits) {
      final d = size.shortestSide * b.speed;
      final x = o.dx + math.cos(b.angle) * d * Curves.easeOut.transform(t);
      final y = o.dy +
          math.sin(b.angle) * d * Curves.easeOut.transform(t) +
          size.height * 0.5 * t * t;
      paint.color = b.color.withValues(alpha: fade);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(b.spin * t);
      if (b.leaf) {
        canvas.drawPath(
          Path()
            ..moveTo(0, -b.size)
            ..quadraticBezierTo(b.size * 0.8, 0, 0, b.size)
            ..quadraticBezierTo(-b.size * 0.8, 0, 0, -b.size),
          paint..color = const Color(0xFF6D9233).withValues(alpha: fade),
        );
      } else {
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: b.size, height: b.size * 0.55),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter old) => old.t != t;
}

class _Bit {
  const _Bit({
    required this.angle,
    required this.speed,
    required this.color,
    required this.leaf,
    required this.spin,
    required this.size,
  });

  final double angle;
  final double speed;
  final Color color;
  final bool leaf;
  final double spin;
  final double size;
}

/// [t] mapped to 0 → 1 between [begin] and [end], clamped.
double _interval(double t, double begin, double end) =>
    ((t - begin) / (end - begin)).clamp(0.0, 1.0);

/// Public for the screen: the same clamp as the painters use.
double introInterval(double t, double begin, double end) =>
    _interval(t, begin, end);
