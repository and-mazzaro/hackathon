/// Spacing, radius and size tokens. Use these instead of magic numbers.
abstract final class EcoSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;

  static const double radiusCard = 24;
  static const double radiusButton = 20;
  static const double radiusPill = 999;

  /// Minimum touch target (Android asks 48, iOS 44: we use the larger).
  static const double minTouchTarget = 48;
  static const double buttonHeight = 56;
}
