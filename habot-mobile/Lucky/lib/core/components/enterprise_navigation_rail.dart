// TNRML-011 — Build Enterprise Adaptive Navigation Rail.
// Anchors a vertical NavigationRail container strictly to the leading edge for medium viewports (600dp <= width < 840dp).
// Maps elevation setting to Material Design Level 1 specifications.

import 'package:flutter/material.dart';

class NavigationRailDestinationItem {
  const NavigationRailDestinationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class EnterpriseNavigationRail extends StatelessWidget {
  const EnterpriseNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.header,
    this.trailing,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationRailDestinationItem> destinations;
  final Widget? header;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Condition checking for medium window size classes (600dp <= width < 840dp)
    final bool isMediumClass = screenWidth >= 600 && screenWidth < 840;

    return Material(
      elevation: 1.0, // MD Level 1 elevation
      color: cs.surface,
      child: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        extended: false, // Vertical compact rail on medium viewports
        labelType: isMediumClass ? NavigationRailLabelType.all : NavigationRailLabelType.selected,
        leading: header,
        trailing: trailing,
        backgroundColor: cs.surfaceContainerLow,
        indicatorColor: cs.primaryContainer,
        destinations: destinations.map((item) {
          return NavigationRailDestination(
            icon: Icon(item.icon, color: cs.onSurfaceVariant),
            selectedIcon: Icon(item.selectedIcon, color: cs.onPrimaryContainer),
            label: Text(
              item.label,
              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          );
        }).toList(),
      ),
    );
  }
}
