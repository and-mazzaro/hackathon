import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';

/// Bottom navigation around the four main tabs.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goTo(int index) {
    // Tapping the tab you are already on returns to its first page.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onHomeTab = navigationShell.currentIndex == 0;

    // Android back button: from another tab go back to Home first,
    // and only leave the app when already on Home.
    return PopScope(
      canPop: onHomeTab,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goTo(0);
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _goTo,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: l10n.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.school_outlined),
              selectedIcon: const Icon(Icons.school_rounded),
              label: l10n.navLearn,
            ),
            NavigationDestination(
              icon: const Icon(Icons.pets_outlined),
              selectedIcon: const Icon(Icons.pets_rounded),
              label: l10n.navPet,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: l10n.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}
