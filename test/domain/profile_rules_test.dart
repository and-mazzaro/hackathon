import 'package:ecoquest/domain/rules/profile_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeNickname', () {
    test('trims and keeps normal names', () {
      expect(normalizeNickname('  EcoAle  '), 'EcoAle');
    });

    test('empty, only spaces or null become null', () {
      expect(normalizeNickname(''), isNull);
      expect(normalizeNickname('    '), isNull);
      expect(normalizeNickname(null), isNull);
    });

    test('turns runs of spaces and line breaks into one space', () {
      expect(normalizeNickname('Eco   \n  Ale'), 'Eco Ale');
    });

    test('removes invisible control characters', () {
      expect(normalizeNickname('Eco\u0000Ale\u0007'), 'Eco Ale');
    });

    test('keeps at most 20 visible characters', () {
      final result = normalizeNickname('A' * 30)!;
      expect(result.length, maxNicknameLength);
    });

    test('never cuts an emoji in half', () {
      // 19 letters + a family emoji made of several code points.
      final result = normalizeNickname('${'a' * 19}👨‍👩‍👧x')!;
      expect(result, '${'a' * 19}👨‍👩‍👧');
    });
  });
}
