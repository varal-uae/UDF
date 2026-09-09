// ANSA-001-A13 — Persistent bottom navigation container.
// Reusable Material 3 bottom navigation surface pinned to the lower screen edge with safe-area-aware content padding and 48dp minimum touch targets.

import 'package:flutter/material.dart';

/// Canonical height for the persistent bottom navigation surface.
const double kAnsaBottomNavBarHeight = 80.0;

/// Returns bottom padding equal to the persistent nav bar height plus the system bottom inset.
EdgeInsets ansaBottomNavContentPadding(BuildContext context) {
  final bottomInset = MediaQuery.of(context).padding.bottom;
  return EdgeInsets.only(bottom: kAnsaBottomNavBarHeight + bottomInset);
}

/// Reusable lower navigation container with Material 3 styling and safe-area handling.
class AnsaBottomNavBar extends StatelessWidget {
  const AnsaBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: NavigationBar(
        height: kAnsaBottomNavBarHeight,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: destinations,
      ),
    );
  }
}

/// Scaffold wrapper that pins the bottom nav and applies matching bottom padding to body content.
class AnsaPersistentBottomNavScaffold extends StatelessWidget {
  const AnsaPersistentBottomNavScaffold({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Padding(
        padding: ansaBottomNavContentPadding(context),
        child: body,
      ),
      bottomNavigationBar: AnsaBottomNavBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
      ),
    );
  }
}
