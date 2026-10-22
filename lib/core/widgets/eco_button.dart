import 'package:material_ui/material_ui.dart';

enum EcoButtonVariant { primary, secondary }

/// The app's standard button: 56 px tall, rounded, bold label.
/// Size and shape come from the theme, so all buttons stay consistent.
class EcoButton extends StatelessWidget {
  const EcoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = EcoButtonVariant.primary,
    this.expand = false,
  });

  final String label;

  /// Null disables the button (screen readers announce it as disabled).
  final VoidCallback? onPressed;
  final IconData? icon;
  final EcoButtonVariant variant;

  /// Stretch to the full available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final text = Text(label, textAlign: TextAlign.center);
    final iconWidget = icon == null ? null : Icon(icon);

    final button = switch (variant) {
      EcoButtonVariant.primary => iconWidget == null
          ? FilledButton(onPressed: onPressed, child: text)
          : FilledButton.icon(
              onPressed: onPressed, icon: iconWidget, label: text),
      EcoButtonVariant.secondary => iconWidget == null
          ? OutlinedButton(onPressed: onPressed, child: text)
          : OutlinedButton.icon(
              onPressed: onPressed, icon: iconWidget, label: text),
    };

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
