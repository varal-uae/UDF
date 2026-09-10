// DPNDL-007-A10 — Desktop Navigation Drawer (256dp fixed sidebar).
// Provides a Material 3 permanent navigation drawer fixed at 256dp on wide screens;
// content scrolls independently while the drawer remains visible.

import 'package:flutter/material.dart';

class DesktopNavigationDrawer extends StatelessWidget {
  const DesktopNavigationDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.header,
  }) : assert(destinations.length > 0);

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDrawerDestination> destinations;
  final Widget? header;

  static const double width = 256.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: NavigationDrawer(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        children: [
          if (header != null) ...[
            header!,
            const Divider(indent: 16, endIndent: 16),
          ],
          ...destinations,
        ],
      ),
    );
  }
}

class DesktopNavigationScaffold extends StatelessWidget {
  const DesktopNavigationScaffold({
    super.key,
    required this.drawer,
    required this.child,
    this.backgroundColor,
  });

  final Widget drawer;
  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            drawer,
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
