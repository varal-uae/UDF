// DPNDL-007-A08 — Desktop Navigation Drawer (MD3, 256dp persistent).
// Renders a large-screen navigation drawer with icons and labels, constrained to exactly 256dp.
import 'package:flutter/material.dart';

class DesktopNavigationDrawer extends StatelessWidget {
  const DesktopNavigationDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.items,
    this.header,
  });

  static const double drawerWidth = 256.0;

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<DesktopNavigationItem> items;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: drawerWidth,
      child: NavigationDrawer(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        children: [
          if (header != null) header!,
          for (final item in items)
            NavigationDrawerDestination(
              icon: item.icon,
              selectedIcon: item.selectedIcon,
              label: item.label,
            ),
        ],
      ),
    );
  }
}

class DesktopNavigationItem {
  const DesktopNavigationItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final Widget icon;
  final Widget label;
  final Widget? selectedIcon;
}
