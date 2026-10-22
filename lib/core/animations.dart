import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Looping decorative animations (idle bobbing, egg wobble).
/// Widget tests turn them off, otherwise `pumpAndSettle` never finishes.
final animationsEnabledProvider = Provider<bool>((ref) => true);

/// True when decorative loops may run: allowed by the app AND the player
/// has not asked the phone to remove animations (accessibility setting).
bool loopingAnimationsAllowed(BuildContext context, WidgetRef ref) =>
    ref.watch(animationsEnabledProvider) &&
    !MediaQuery.disableAnimationsOf(context);
