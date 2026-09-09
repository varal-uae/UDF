// ANSA-021-A06 — Mobile bottom navigation bar with outward-expanding active selection indicators.
// Enforces 3-5 navigation targets, forced filled icon updates, compact mobile-first layout, and standalone reuse.

import 'package:flutter/material.dart';

/// Navigation target model for [MobileNavigationBarAnsa021A06].
class MobileNavigationItemAnsa021A06 {
  const MobileNavigationItemAnsa021A06({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback? onTap;
}

/// A reusable Material 3 mobile bottom navigation bar.
///
/// Active selection indicators scale outward from each icon centre on tap,
/// providing immediate visual confirmation in compact single-hand usage.
class MobileNavigationBarAnsa021A06 extends StatefulWidget {
  const MobileNavigationBarAnsa021A06({
    super.key,
    required this.items,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.height = 72,
    this.backgroundColor,
    this.indicatorColor,
  }) : assert(
         items.length >= 3 && items.length <= 5,
         'Navigation targets count boundaries are strictly restricted to 3-5 items on mobile views.',
       );

  final List<MobileNavigationItemAnsa021A06> items;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final double height;
  final Color? backgroundColor;
  final Color? indicatorColor;

  @override
  State<MobileNavigationBarAnsa021A06> createState() =>
      _MobileNavigationBarAnsa021A06State();
}

class _MobileNavigationBarAnsa021A06State
    extends State<MobileNavigationBarAnsa021A06> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(MobileNavigationBarAnsa021A06 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _selectedIndex = widget.selectedIndex;
    }
  }

  void _handleTap(int index) {
    final item = widget.items[index];
    item.onTap?.call();
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
    widget.onDestinationSelected?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background =
        widget.backgroundColor ?? theme.colorScheme.surface;
    final indicator =
        widget.indicatorColor ?? theme.colorScheme.primaryContainer;
    final activeIconColor = theme.colorScheme.onPrimaryContainer;
    final inactiveIconColor = theme.colorScheme.onSurfaceVariant;

    return Material(
      color: background,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: widget.height,
          child: Row(
            children: List.generate(widget.items.length, (index) {
              final item = widget.items[index];
              final selected = _selectedIndex == index;
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: selected,
                  label: item.label,
                  child: InkWell(
                    onTap: () => _handleTap(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedScale(
                                scale: selected ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutBack,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: indicator,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Icon(
                                selected ? item.selectedIcon : item.icon,
                                size: 24,
                                color: selected
                                    ? activeIconColor
                                    : inactiveIconColor,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: selected
                                ? activeIconColor
                                : inactiveIconColor,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
