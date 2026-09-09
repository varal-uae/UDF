// ANSA-014-A04 — Adaptive Navigation Shell.
// Reusable page wrapper that selects the correct Material 3 navigation pattern per screen width: sticky bottom bar under 600dp, side rail above, with 48dp touch targets and active location chip.

import 'package:flutter/material.dart';

/// A destination model for the adaptive navigation shell.
class AdaptiveNavDestination {
  const AdaptiveNavDestination({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.routePath,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final String? routePath;
}

/// Responsive navigation shell that enforces Material 3 touch targets and
/// falls back safely to the first destination when an invalid path is supplied.
class AdaptiveNavigationScaffold extends StatelessWidget {
  const AdaptiveNavigationScaffold({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.child,
    this.onDestinationSelected,
    this.appBar,
    this.floatingActionButton,
    this.showActiveChip = true,
  });

  final List<AdaptiveNavDestination> destinations;
  final int selectedIndex;
  final Widget child;
  final ValueChanged<int>? onDestinationSelected;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final bool showActiveChip;

  static const double _mobileMaxWidth = 600;
  static const double _extendedRailMinWidth = 1200;

  /// Resolves a route path to a safe destination index, returning the
  /// fallback index when the path is invalid or unauthorized.
  static int safeIndexFor(String? path, List<String?> routePaths, {int fallbackIndex = 0}) {
    if (path == null) return fallbackIndex;
    final index = routePaths.indexWhere((route) => route == path);
    return index < 0 ? fallbackIndex : index;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < _mobileMaxWidth;
        final isExtendedRail = width >= _extendedRailMinWidth;

        final activeDestination = _activeDestination(context);

        final body = Column(
          children: [
            if (showActiveChip && activeDestination != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    avatar: Icon(activeDestination.icon, size: 18),
                    label: Text(activeDestination.label),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
              ),
            Expanded(child: child),
          ],
        );

        if (isMobile) {
          return Scaffold(
            appBar: appBar,
            body: body,
            floatingActionButton: floatingActionButton,
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
              height: 72,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: destinations
                  .map(
                    (destination) => NavigationDestination(
                      icon: Icon(destination.icon),
                      selectedIcon: Icon(destination.selectedIcon ?? destination.icon),
                      label: destination.label,
                      tooltip: destination.label,
                    ),
                  )
                  .toList(),
            ),
            drawer: destinations.length > 3
                ? Drawer(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        DrawerHeader(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainer,
                          ),
                          child: const Text('Navigation'),
                        ),
                        for (var i = 0; i < destinations.length; i++)
                          ListTile(
                            leading: Icon(destinations[i].icon),
                            title: Text(destinations[i].label),
                            selected: i == selectedIndex,
                            onTap: () {
                              Navigator.pop(context);
                              onDestinationSelected?.call(i);
                            },
                          ),
                      ],
                    ),
                  )
                : null,
          );
        }

        return Scaffold(
          appBar: appBar,
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
                extended: isExtendedRail,
                labelType: isExtendedRail
                    ? NavigationRailLabelType.all
                    : NavigationRailLabelType.selected,
                minWidth: isExtendedRail ? 180 : 72,
                minExtendedWidth: 180,
                groupAlignment: -1,
                destinations: destinations
                    .map(
                      (destination) => NavigationRailDestination(
                        icon: Icon(destination.icon),
                        selectedIcon: Icon(destination.selectedIcon ?? destination.icon),
                        label: Text(destination.label),
                      ),
                    )
                    .toList(),
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: body),
            ],
          ),
          floatingActionButton: floatingActionButton,
        );
      },
    );
  }

  AdaptiveNavDestination? _activeDestination(BuildContext context) {
    if (selectedIndex < 0 || selectedIndex >= destinations.length) return null;
    return destinations[selectedIndex];
  }
}
