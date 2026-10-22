import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/learn/learn_screen.dart';
import '../features/pet/pet_screen.dart';
import '../features/profile/profile_screen.dart';
import 'app_shell.dart';

/// All route paths in one place, so features never hard-code strings.
abstract final class AppRoutes {
  static const home = '/home';
  static const learn = '/learn';
  static const pet = '/pet';
  static const profile = '/profile';
}

/// The router lives in a provider: every ProviderScope (the app, or each
/// test) gets its own fresh router instead of sharing a global one.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
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
  ref.onDispose(router.dispose);
  return router;
});
