import 'package:flutter/painting.dart';

/// EcoQuest colour tokens.
///
/// Every text/background pair used in the app was checked against
/// WCAG AA (contrast >= 4.5:1). Ratios are noted next to each colour.
abstract final class EcoColors {
  /// Leaf green. White text on it: 5.0:1.
  static const primary = Color(0xFF1B7F4C);

  /// Mint container. Ink text on it: 10.1:1.
  static const primaryContainer = Color(0xFFCDEFD9);

  /// Main text colour. On background: 11.3:1, on white: 12.5:1.
  static const ink = Color(0xFF173A2B);

  /// Secondary text. On background: 5.1:1.
  static const inkMuted = Color(0xFF5B6B62);

  /// Warm cream app background.
  static const background = Color(0xFFF6F3E8);
  static const surface = Color(0xFFFFFFFF);

  /// Coins. Ink text on it: 8.2:1.
  static const coin = Color(0xFFFFC93C);

  /// XP / learning. White text on it: 4.6:1.
  static const xp = Color(0xFF2A7AB8);

  /// Errors and warnings. White text on it: 5.2:1.
  static const alert = Color(0xFFC2410C);

  // Pet need bars. Used for bars and icons only, never for text.
  static const satiety = Color(0xFFF08A24);
  static const happiness = Color(0xFFE5578A);
  static const cleanliness = Color(0xFF3FA7D6);
}
