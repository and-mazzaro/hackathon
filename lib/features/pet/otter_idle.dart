import 'dart:math' as math;

import 'otter_geometry.dart';

/// Length of the idle loop. Every motion below repeats a whole number of
/// times in it, so the loop has no jump.
const otterIdleLoop = Duration(seconds: 12);

/// The otter's pose [seconds] into the idle loop: a slow tail wag, a small
/// head tilt, two blinks and one ear flick. At 0 it is [OtterPose.rest],
/// so a stopped loop (tests, "remove animations") shows the reference.
OtterPose idleOtterPose(double seconds) {
  final t = seconds % otterIdleLoop.inSeconds;
  return OtterPose(
    tailSwing: 0.09 * math.sin(2 * math.pi * t / 2.4),
    headTilt: 0.035 * math.sin(2 * math.pi * t / 6),
    eyesOpen: math.min(_blink(t, 3.2), _blink(t, 8.6)),
    earTwitch: 0.12 * _pulse(t, 10.4, 0.25),
  );
}

/// 1 = open; closes and reopens in 0.18 s starting at [start].
double _blink(double t, double start) => 1 - _pulse(t, start, 0.18);

/// 0 → 1 → 0 over [length] seconds starting at [start], else 0.
double _pulse(double t, double start, double length) {
  final x = (t - start) / length;
  if (x <= 0 || x >= 1) return 0;
  return math.sin(math.pi * x);
}
