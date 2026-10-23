import 'package:ecoquest/features/pet/otter_geometry.dart';
import 'package:ecoquest/features/pet/otter_idle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the loop starts and ends at the rest pose (no jump)', () {
    expect(idleOtterPose(0), OtterPose.rest);
    final end = idleOtterPose(otterIdleLoop.inSeconds - 1e-9);
    expect(end.tailSwing, closeTo(0, 1e-6));
    expect(end.headTilt, closeTo(0, 1e-6));
    expect(end.eyesOpen, 1);
  });

  test('the otter blinks twice per loop and the eyes reopen', () {
    expect(idleOtterPose(3.29).eyesOpen, lessThan(0.05));
    expect(idleOtterPose(8.69).eyesOpen, lessThan(0.05));
    expect(idleOtterPose(3.5).eyesOpen, 1);
    expect(idleOtterPose(5).eyesOpen, 1);
  });

  test('motions stay small', () {
    for (var t = 0.0; t < 12; t += 0.05) {
      final pose = idleOtterPose(t);
      expect(pose.tailSwing.abs(), lessThanOrEqualTo(0.09));
      expect(pose.headTilt.abs(), lessThanOrEqualTo(0.035));
      expect(pose.earTwitch, inInclusiveRange(0, 0.12));
      expect(pose.eyesOpen, inInclusiveRange(0, 1));
    }
  });
}
