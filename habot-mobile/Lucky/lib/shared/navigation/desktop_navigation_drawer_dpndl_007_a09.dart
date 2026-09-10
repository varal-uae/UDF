// DPNDL-007-A09 — Desktop Navigation Drawer.
// Responsive M3 drawer for wide layouts: 256dp cap, expandable tool branches, active route highlight, router wiring.
import 'package:flutter/material.dart';

class DesktopNavigationDrawerDpndl007A09 extends StatelessWidget {
  const DesktopNavigationDrawerDpndl007A09({
    super.key,
    required this.items,
    required this.selectedRoute,
    required this.onNavigate,
    this.width = fixedWidth,
  });

  static const double fixedWidth = 256.0;

  final List<DrawerNavItem> items;
  final String selectedRoute;
  final ValueChanged<String> onNavigate;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
                child: Text(
                  'Habot Lucky',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              for (final item in items) _buildItem(context, item),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, DrawerNavItem item) {
    if (item.children.isNotEmpty) {
      return ExpansionTile(
        leading: Icon(item.icon),
        title: Text(item.label),
        initiallyExpanded: item.children.any(
          (child) => child.route == selectedRoute,
        ),
        childrenPadding: const EdgeInsets.only(left: 16),
        children: [
          for (final child in item.children) _buildLeaf(context, child),
        ],
      );
    }
    return _buildLeaf(context, item);
  }

  Widget _buildLeaf(BuildContext context, DrawerNavItem item) {
    final isSelected = item.route == selectedRoute;
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(isSelected ? (item.selectedIcon ?? item.icon) : item.icon),
      title: Text(item.label),
      selected: isSelected,
      selectedTileColor: colorScheme.secondaryContainer,
      selectedColor: colorScheme.onSecondaryContainer,
      onTap: () {
        final route = item.route;
        if (route != null && route.isNotEmpty) {
          onNavigate(route);
        }
      },
    );
  }
}

class DrawerNavItem {
  const DrawerNavItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.route,
    this.children = const <DrawerNavItem>[],
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final String? route;
  final List<DrawerNavItem> children;
}
