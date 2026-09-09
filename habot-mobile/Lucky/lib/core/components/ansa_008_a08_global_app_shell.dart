// ANSA-008-A08 — Global App Shell with responsive navigation drawer/rail.
// Wraps internal cross-departmental views in a persistent master shell. Below 600dp it exposes a temporary drawer via hamburger icon; at 840dp and above it expands into a permanent Material 3 navigation rail using dynamic theme colors.

import 'package:flutter/material.dart';

class AppShellDestination {
  const AppShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class GlobalAppShell extends StatelessWidget {
  const GlobalAppShell({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.child,
    this.title = 'Habot',
  });

  final List<AppShellDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isPermanentRail = constraints.maxWidth >= 840;
        return Scaffold(
          appBar: AppBar(
            title: Text(title, style: theme.textTheme.titleLarge),
            automaticallyImplyLeading: !isPermanentRail,
          ),
          drawer: isPermanentRail
              ? null
              : Drawer(
                  child: SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            children: [
                              for (var i = 0; i < destinations.length; i++)
                                ListTile(
                                  selected: i == currentIndex,
                                  selectedColor: theme.colorScheme.primary,
                                  leading: Icon(
                                    i == currentIndex
                                        ? destinations[i].selectedIcon
                                        : destinations[i].icon,
                                  ),
                                  title: Text(destinations[i].label),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    onDestinationSelected(i);
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          body: isPermanentRail
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: currentIndex,
                      onDestinationSelected: onDestinationSelected,
                      labelType: NavigationRailLabelType.all,
                      backgroundColor: theme.colorScheme.surface,
                      indicatorColor: theme.colorScheme.primaryContainer,
                      destinations: [
                        for (final destination in destinations)
                          NavigationRailDestination(
                            icon: Icon(destination.icon),
                            selectedIcon: Icon(destination.selectedIcon),
                            label: Text(destination.label),
                          ),
                      ],
                    ),
                    const VerticalDivider(width: 1, thickness: 1),
                    Expanded(child: child),
                  ],
                )
              : child,
        );
      },
    );
  }
}
