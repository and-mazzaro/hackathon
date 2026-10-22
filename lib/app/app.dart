import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

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
