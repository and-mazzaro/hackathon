import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/activity_binding.dart';
import '../core/audio/audio_binding.dart';
import '../features/demo/demo_mode.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class EcoQuestApp extends ConsumerWidget {
  const EcoQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: ref.watch(routerProvider),
      // Sound settings and app lifecycle → audio service (no UI);
      // app opens and clean exits → local activity log (M10);
      // the demo-mode caption over every screen.
      builder: (context, child) =>
          ActivityBinding(
              child: AudioBinding(child: DemoCaptionOverlay(child: child!))),
      // Our strings + Material/Cupertino strings from material_ui.
      // (AppLocalizations.localizationsDelegates still points at the old
      // framework Material library, so we do not use it.)
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      // Only Italian for now. Add app_en.arb later and English appears here.
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
