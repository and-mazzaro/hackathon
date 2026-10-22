import 'package:ecoquest/app/app.dart';
import 'package:ecoquest/app/theme/app_theme.dart';
import 'package:ecoquest/data/save/in_memory_save_repository.dart';
import 'package:ecoquest/data/save/save_repository.dart';
import 'package:ecoquest/domain/game_controller.dart';
import 'package:ecoquest/domain/models/eco_topic.dart';
import 'package:ecoquest/domain/models/game_state.dart';
import 'package:ecoquest/domain/models/player_profile.dart';
import 'package:ecoquest/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const tabLabels = ['Home', 'Impara', 'Cucciolo', 'Profilo'];

/// A fixed "now" so tests never depend on the real date.
final testNow = DateTime(2026, 10, 22, 10);

/// A player who already finished onboarding (interested in recycling).
GameState onboardedState() => GameState.initial(now: testNow).copyWith(
      profile: PlayerProfile(
        createdAt: testNow,
        interests: {EcoTopic.recycling},
        onboardingCompleted: true,
      ),
    );

/// Starts the whole app with a fresh ProviderScope (and so a fresh router).
///
/// The save lives in memory (no files). By default the player has already
/// finished onboarding; pass `InMemorySaveRepository()` for a new player.
Future<void> pumpEcoQuestApp(
  WidgetTester tester, {
  SaveRepository? repository,
}) async {
  await tester.pumpWidget(ProviderScope(
    retry: (retryCount, error) => null,
    overrides: [
      saveRepositoryProvider.overrideWithValue(
          repository ?? InMemorySaveRepository(onboardedState())),
      clockProvider.overrideWithValue(() => testNow),
    ],
    child: const EcoQuestApp(),
  ));
  await tester.pumpAndSettle();
}

/// Wraps a single widget with the theme and Italian strings it needs.
Widget localized(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}

/// Taps a bottom-navigation tab by its label.
Future<void> tapTab(WidgetTester tester, String label) async {
  await tester.tap(find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  ));
  await tester.pumpAndSettle();
}

/// Scrolls the current screen until [finder] is built and visible.
/// Lists only build what is near the screen, so cards further down
/// do not exist until you scroll to them.
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

/// Simulates the Android system back button.
Future<void> pressAndroidBack(WidgetTester tester) async {
  final message = SystemChannels.navigation.codec
      .encodeMethodCall(const MethodCall('popRoute'));
  await tester.binding.defaultBinaryMessenger
      .handlePlatformMessage(SystemChannels.navigation.name, message, (_) {});
  await tester.pumpAndSettle();
}

/// 320 x 568 logical pixels (a small phone) with text at 200%.
void useSmallPhoneWithLargeText(WidgetTester tester) {
  tester.view.physicalSize = const Size(640, 1136);
  tester.view.devicePixelRatio = 2;
  tester.platformDispatcher.textScaleFactorTestValue = 2;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}
