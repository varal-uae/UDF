// DPNDL-007-A20 — Desktop Navigation Drawer (MD3) with 256dp structural cap.
// Renders a persistent wide-screen navigation drawer constrained to 256dp, with
// expandable tool branches, active-route highlighting, and responsive visibility.

import 'package:flutter/material.dart';

class DesktopNavItem {
  const DesktopNavItem({
    required this.label,
    required this.icon,
    this.children = const <DesktopNavItem>[],
  });

  final String label;
  final IconData icon;
  final List<DesktopNavItem> children;

  bool get hasChildren => children.isNotEmpty;
}

class DesktopNavigationDrawer extends StatelessWidget {
  const DesktopNavigationDrawer({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.header,
    this.footer,
    this.minDesktopWidth = 1024.0,
  });

  static const double drawerWidth = 256.0;

  final List<DesktopNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget? header;
  final Widget? footer;
  final double minDesktopWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < minDesktopWidth) {
          return const SizedBox.shrink();
        }
        return SizedBox(
          width: drawerWidth,
          child: Material(
            color: colorScheme.surface,
            child: SafeArea(
              child: Column(
                children: [
                  if (header != null) header!,
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        for (var i = 0; i < items.length; i++)
                          _DesktopNavTile(
                            item: items[i],
                            selected: selectedIndex == i,
                            onTap: () => onDestinationSelected(i),
                          ),
                      ],
                    ),
                  ),
                  if (footer != null) footer!,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DesktopNavTile extends StatelessWidget {
  const _DesktopNavTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final DesktopNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (item.hasChildren) {
      return ExpansionTile(
        leading: Icon(item.icon),
        title: Text(item.label),
        childrenPadding: const EdgeInsets.only(left: 16),
        collapsedIconColor: colorScheme.onSurfaceVariant,
        iconColor: colorScheme.primary,
        children: [
          for (final child in item.children)
            ListTile(
              leading: Icon(child.icon, size: 20),
              title: Text(child.label),
              onTap: onTap,
            ),
        ],
      );
    }

    return ListTile(
      leading: Icon(item.icon),
      title: Text(item.label),
      selected: selected,
      selectedTileColor: colorScheme.secondaryContainer,
      selectedColor: colorScheme.onSecondaryContainer,
      onTap: onTap,
    );
  }
}
