// DPNDL-008-A03 — Permanent Desktop Navigation Drawer with strict 256dp width.
// Enforces un-collapsible 256dp width on wide viewports, accordion dropdowns for nested items, and active state highlighting.

import 'package:flutter/material.dart';

class DesktopNavigationDrawer extends StatefulWidget {
  const DesktopNavigationDrawer({super.key});

  @override
  State<DesktopNavigationDrawer> createState() => _DesktopNavigationDrawerState();
}

class _DesktopNavigationDrawerState extends State<DesktopNavigationDrawer> {
  int? _selectedIndex;
  final List<NavItem> _items = [
    NavItem(
      title: 'Dashboard',
      icon: Icons.dashboard,
    ),
    NavItem(
      title: 'Analytics',
      icon: Icons.analytics,
      children: [
        NavItem(title: 'Reports', icon: Icons.report),
        NavItem(title: 'Real-time', icon: Icons.timeline),
      ],
    ),
    NavItem(
      title: 'Settings',
      icon: Icons.settings,
      children: [
        NavItem(title: 'Profile', icon: Icons.person),
        NavItem(title: 'Preferences', icon: Icons.tune),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SizedBox(
      width: 256.0,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
              ),
              child: Text(
                'Menu',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            ..._items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              if (item.children != null && item.children!.isNotEmpty) {
                return ExpansionTile(
                  leading: Icon(item.icon, color: colorScheme.onSurface),
                  title: Text(item.title),
                  children: item.children!.map((child) {
                    return ListTile(
                      leading: Icon(child.icon, color: colorScheme.onSurface),
                      title: Text(child.title),
                      selected: _selectedIndex == _items.indexOf(child),
                      onTap: () {
                        setState(() {
                          _selectedIndex = _items.indexOf(child);
                        });
                      },
                    );
                  }).toList(),
                );
              } else {
                return ListTile(
                  leading: Icon(item.icon, color: colorScheme.onSurface),
                  title: Text(item.title),
                  selected: _selectedIndex == index,
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                );
              }
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class NavItem {
  final String title;
  final IconData icon;
  final List<NavItem>? children;

  NavItem({required this.title, required this.icon, this.children});
}