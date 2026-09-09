// ANSA-022-A02 — Expanded Wide Navigation Container Block.
// A Material 3 responsive navigation surface that expands to a persistent 256dp drawer at >=840dp, exposing advanced options without cluttering layout areas.

import 'package:flutter/material.dart';

/// A responsive navigation container that switches between a modal drawer and
/// a persistent expanded drawer based on the available width (>=840dp).
class Ansa022A02NavigationDrawer extends StatelessWidget {
  const Ansa022A02NavigationDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.destinations = const [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
      NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
    ],
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 840;
        if (isWide) {
          return _ExpandedNavigationLayout(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: destinations,
            body: body,
          );
        }
        return _CompactNavigationLayout(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: destinations,
          body: body,
        );
      },
    );
  }
}

class _ExpandedNavigationLayout extends StatelessWidget {
  const _ExpandedNavigationLayout({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 256,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
          ),
          clipBehavior: Clip.antiAlias,
          child: NavigationDrawer(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Navigation', style: theme.textTheme.titleMedium),
              ),
              ...destinations.map((destination) => NavigationDrawerDestination(
                icon: destination.icon,
                selectedIcon: destination.selectedIcon,
                label: Text(destination.label),
              )),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: body),
      ],
    );
  }
}

class _CompactNavigationLayout extends StatelessWidget {
  const _CompactNavigationLayout({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      drawer: NavigationDrawer(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Navigation', style: Theme.of(context).textTheme.titleMedium),
          ),
          ...destinations.map((destination) => NavigationDrawerDestination(
            icon: destination.icon,
            selectedIcon: destination.selectedIcon,
            label: Text(destination.label),
          )),
        ],
      ),
    );
  }
}