import 'package:material_ui/material_ui.dart';

import 'eco_colors.dart';
import 'eco_spacing.dart';

/// Builds the Material 3 theme from the EcoQuest tokens.
abstract final class AppTheme {
  static const fontFamily = 'Nunito';

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: EcoColors.primary).copyWith(
      primary: EcoColors.primary,
      onPrimary: Colors.white,
      primaryContainer: EcoColors.primaryContainer,
      onPrimaryContainer: EcoColors.ink,
      secondary: EcoColors.xp,
      onSecondary: Colors.white,
      tertiary: EcoColors.coin,
      onTertiary: EcoColors.ink,
      error: EcoColors.alert,
      onError: Colors.white,
      surface: EcoColors.surface,
      onSurface: EcoColors.ink,
      onSurfaceVariant: EcoColors.inkMuted,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: EcoColors.background,
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(EcoSpacing.radiusButton),
    );
    const buttonText = TextStyle(
      fontFamily: fontFamily,
      fontSize: 17,
      fontWeight: FontWeight.w800,
    );

    return base.copyWith(
      textTheme: base.textTheme
          .copyWith(
            headlineSmall: base.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
            titleLarge:
                base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            titleMedium:
                base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            labelLarge:
                base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          )
          .apply(bodyColor: EcoColors.ink, displayColor: EcoColors.ink),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, EcoSpacing.buttonHeight),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, EcoSpacing.buttonHeight),
          shape: buttonShape,
          textStyle: buttonText,
          foregroundColor: EcoColors.primary,
          side: const BorderSide(color: EcoColors.primary, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: EcoColors.surface,
        indicatorColor: EcoColors.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: fontFamily,
            fontSize: 13,
            color: EcoColors.ink,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? EcoColors.primary
                : EcoColors.inkMuted,
          ),
        ),
      ),
    );
  }
}
