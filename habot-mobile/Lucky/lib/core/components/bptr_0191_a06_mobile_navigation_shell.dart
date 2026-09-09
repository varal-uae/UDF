// BPTR-0191-A06 — Mobile Bottom Navigation Shell Component.
// Material 3 NavigationBar shell with 3–5 destinations, 80dp height, 56x48 touch targets, and invalid index fallback to primary workspace.

import 'package:flutter/material.dart';

/// A persistent Material 3 bottom navigation shell for core mobile views.
///
/// Wraps the active view in an [IndexedStack] and renders a [NavigationBar]
/// with a strict limit of 3–5 destinations. Each destination requires a
/// distinct icon, selected icon, label, and page.
class Bptr0191A06MobileNavigationShell extends StatefulWidget {
  const Bptr0191A06MobileNavigationShell({
    super.key,
    required this.destinations,
    this.initialIndex = 0,
  }) : assert(destinations.length >= 3 && destinations.length <= 5,
            'Bottom navigation must contain between 3 and 5 destinations.');

  final List<Bptr0191A06NavigationDestination> destinations;
  final int initialIndex;

  @override
  State<Bptr0191A06MobileNavigationShell> createState() =>
      _Bptr0191A06MobileNavigationShellState();
}

class _Bptr0191A06MobileNavigationShellState
    extends State<Bptr0191A06MobileNavigationShell> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _validateIndex(widget.initialIndex);
  }

  int _validateIndex(int index) {
    if (index < 0 || index >= widget.destinations.length) {
      return 0; // Auto-fallback to primary workspace view.
    }
    return index;
  }

  void _onDestinationSelected(int index) {
    final validIndex = _validateIndex(index);
    if (validIndex != _selectedIndex) {
      setState(() => _selectedIndex = validIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: widget.destinations.map((d) => d.page).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: widget.destinations
            .map(
              (d) => NavigationDestination(
                icon: d.icon,
                selectedIcon: d.selectedIcon,
                label: d.label,
                tooltip: d.tooltip,
              ),
            )
            .toList(),
      ),
    );
  }
}

/// Data holder for a single navigation destination.
class Bptr0191A06NavigationDestination {
  const Bptr0191A06NavigationDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.page,
    this.tooltip,
  });

  final Widget icon;
  final Widget selectedIcon;
  final String label;
  final String? tooltip;
  final Widget page;
}
