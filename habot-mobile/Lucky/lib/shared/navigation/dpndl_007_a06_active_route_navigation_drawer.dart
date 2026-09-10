// DPNDL-007-A06 — Active-route highlighting for the MD3 desktop navigation drawer.
// Enforces a 256dp horizontal cap, expandable tool groups, and high-contrast selected-route highlighting.

import 'package:flutter/material.dart';

class Dpndl007A06NavigationDrawer extends StatefulWidget {
  const Dpndl007A06NavigationDrawer({
    super.key,
    required this.sections,
    required this.activeRoute,
    required this.onRouteSelected,
    this.drawerWidth = 256.0,
  });

  final List<Dpndl007A06NavigationSection> sections;
  final String activeRoute;
  final ValueChanged<String> onRouteSelected;
  final double drawerWidth;

  @override
  State<Dpndl007A06NavigationDrawer> createState() => _Dpndl007A06NavigationDrawerState();
}

class _Dpndl007A06NavigationDrawerState extends State<Dpndl007A06NavigationDrawer> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      width: widget.drawerWidth > 256.0 ? 256.0 : widget.drawerWidth,
      backgroundColor: colorScheme.surface,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                'Navigation',
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            for (final section in widget.sections)
              _Dpndl007A06SectionTile(
                section: section,
                activeRoute: widget.activeRoute,
                onRouteSelected: widget.onRouteSelected,
              ),
          ],
        ),
      ),
    );
  }
}

class Dpndl007A06NavigationSection {
  const Dpndl007A06NavigationSection({
    required this.label,
    required this.icon,
    required this.items,
  });

  final String label;
  final IconData icon;
  final List<Dpndl007A06NavigationItem> items;
}

class Dpndl007A06NavigationItem {
  const Dpndl007A06NavigationItem({
    required this.label,
    required this.route,
    required this.icon,
  });

  final String label;
  final String route;
  final IconData icon;
}

class _Dpndl007A06SectionTile extends StatelessWidget {
  const _Dpndl007A06SectionTile({
    required this.section,
    required this.activeRoute,
    required this.onRouteSelected,
  });

  final Dpndl007A06NavigationSection section;
  final String activeRoute;
  final ValueChanged<String> onRouteSelected;

  @override
  Widget build(BuildContext context) {
    final hasActiveChild = section.items.any((item) => item.route == activeRoute);

    return ExpansionTile(
      initiallyExpanded: hasActiveChild,
      leading: Icon(section.icon),
      title: Text(section.label),
      shape: const Border(),
      collapsedShape: const Border(),
      childrenPadding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
      children: [
        for (final item in section.items)
          _Dpndl007A06RouteTile(
            item: item,
            isActive: item.route == activeRoute,
            onTap: () => onRouteSelected(item.route),
          ),
      ],
    );
  }
}

class _Dpndl007A06RouteTile extends StatelessWidget {
  const _Dpndl007A06RouteTile({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final Dpndl007A06NavigationItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      selected: isActive,
      selectedTileColor: colorScheme.secondaryContainer,
      selectedColor: colorScheme.onSecondaryContainer,
      leading: Icon(item.icon),
      title: Text(item.label),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}
