import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/game_controller.dart';
import '../domain/models/eco_topic.dart';
import '../features/cleanup/cleanup_screen.dart';
import '../features/home/home_screen.dart';
import '../features/intro/intro_screen.dart';
import '../features/learn/learn_screen.dart';
import '../features/learn/quiz_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/pet/pet_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/wardrobe/wardrobe_screen.dart';
import 'app_shell.dart';

/// All route paths in one place, so features never hard-code strings.
abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const learn = '/learn';
  static const pet = '/pet';
  static const profile = '/profile';
  static const quizPath = '/quiz';

  /// Room Cleanup (open with `context.push`).
  static const cleanup = '/cleanup';

  /// The presentation intro (open with `context.push`).
  static const intro = '/intro';

  /// Wardrobe: reward roll, shop and items (open with `context.push`).
  static const wardrobe = '/wardrobe';

  /// `/quiz` for the personal mixed quiz, `/quiz?topic=oceans` for a topic.
  /// Open it with `context.push(...)` so Back returns to where you were.
  static String quiz([EcoTopic? topic]) =>
      topic == null ? quizPath : '$quizPath?topic=${topic.id}';

  /// The "Il mio territorio" quiz, built from today's live data.
  static const territoryQuiz = '$quizPath?territory=1';
}

/// The router lives in a provider: every ProviderScope (the app, or each
/// test) gets its own fresh router instead of sharing a global one.
final routerProvider = Provider<GoRouter>((ref) {
  // Tells go_router to re-check `redirect` whenever the game changes
  // (loaded, onboarding finished, game restarted).
  // A counter whose only job is to "tick" on every change.
  final gameChanged = ValueNotifier(0);
  ref.listen(gameControllerProvider, (previous, next) => gameChanged.value++);

  final router = GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: gameChanged,
    redirect: (context, state) {
      final game = ref.read(gameControllerProvider).value;
      // Still loading, or the save could not be read: stay put, the
      // screen shows the spinner or the error.
      if (game == null) return null;

      final onOnboarding = state.matchedLocation == AppRoutes.onboarding;
      final finished = game.profile.onboardingCompleted;
      if (!finished && !onOnboarding) return AppRoutes.onboarding;
      if (finished && onOnboarding) return AppRoutes.home;
      return null;
    },
    routes: [
      // Outside the tab shell: no bottom navigation during onboarding.
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Full screen above the tabs: the quiz needs the player's attention.
      GoRoute(
        path: AppRoutes.quizPath,
        builder: (context, state) {
          final topicId = state.uri.queryParameters['topic'];
          return QuizScreen(
            topic: topicId == null ? null : EcoTopic.fromId(topicId),
            territory: state.uri.queryParameters['territory'] == '1',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.cleanup,
        builder: (context, state) => const CleanupScreen(),
      ),
      GoRoute(
        path: AppRoutes.intro,
        builder: (context, state) => const IntroScreen(),
      ),
      GoRoute(
        path: AppRoutes.wardrobe,
        builder: (context, state) => const WardrobeScreen(),
      ),
      // One branch per bottom tab. "indexedStack" keeps each tab alive,
      // so switching tabs does not lose scroll position or state.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.learn,
              builder: (context, state) => const LearnScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.pet,
              builder: (context, state) => const PetScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    gameChanged.dispose();
  });
  return router;
});
