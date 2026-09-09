// ANSA-020-11 — M3 Adaptive Navigation Scaffold for dashboards.
// Uses NavigationSuiteScaffold to automatically switch between a Bottom NavigationBar (compact) and NavigationRail (medium/expanded), with destinations sized at a 48dp minimum touch target per WCAG 2.2 SC 2.5.8.
import 'package:flutter/material.dart';

class Ansa02011AdaptiveNavigation extends StatelessWidget {
  const Ansa02011AdaptiveNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.destinations = const [
      NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard', tooltip: 'Dashboard'),
      NavigationDestination(icon: Icon(Icons.assessment_outlined), selectedIcon: Icon(Icons.assessment), label: 'Reports', tooltip: 'Reports'),
      NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings', tooltip: 'Settings'),
    ],
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return NavigationSuiteScaffold(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations,
      body: body,
    );
  }
}
