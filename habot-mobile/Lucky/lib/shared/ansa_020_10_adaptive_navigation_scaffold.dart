// ANSA-020-10 — M3 Adaptive Navigation Scaffold for dashboards.
// Animates between a compact NavigationBar and an expanded NavigationRail using
// Material 3 motion, enforces 48dp minimum touch targets, and isolates body repaints.

import 'package:flutter/material.dart';

/// Adaptive Material 3 navigation scaffold for dashboard layouts.
///
/// On compact widths it renders a [NavigationBar] at the bottom; on medium or
/// expanded widths it renders a [NavigationRail] on the left to maximize vertical
/// space. The switch uses [AnimatedSwitcher] with M3 emphasized curves and the
/// body is wrapped in [RepaintBoundary] to help sustain frame rates during rapid
/// pan-and-zoom actions.
class Ansa02010AdaptiveNavigationScaffold extends StatelessWidget {
  const Ansa02010AdaptiveNavigationScaffold({
    super.key,
    required this.body,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.breakpoint = 840,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  /// Main content shown next to or above the navigation component.
  final Widget body;

  /// Navigation destinations shared by both compact and expanded modes.
  final List<NavigationDestination> destinations;

  /// Currently selected destination index.
  final int selectedIndex;

  /// Callback fired when the user selects a navigation destination.
  final ValueChanged<int> onDestinationSelected;

  /// Width threshold that determines whether to use the compact or expanded layout.
  final double breakpoint;

  /// Duration used for the animated switch between navigation states.
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isExpanded = constraints.maxWidth >= breakpoint;

        return AnimatedSwitcher(
          duration: animationDuration,
          switchInCurve: Curves.easeInOutCubicEmphasized,
          switchOutCurve: Curves.easeInOutCubicEmphasized,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1,
                child: child,
              ),
            );
          },
          child: isExpanded
              ? Scaffold(
                  key: const ValueKey('expanded-navigation-scaffold'),
                  body: Row(
                    children: [
                      NavigationRail(
                        selectedIndex: selectedIndex,
                        onDestinationSelected: onDestinationSelected,
                        labelType: NavigationRailLabelType.all,
                        destinations: destinations
                            .map(
                              (destination) => NavigationRailDestination(
                                icon: destination.icon,
                                selectedIcon: destination.selectedIcon,
                                label: Text(destination.label),
                              ),
                            )
                            .toList(),
                      ),
                      const VerticalDivider(thickness: 1, width: 1),
                      Expanded(
                        child: RepaintBoundary(child: body),
                      ),
                    ],
                  ),
                )
              : Scaffold(
                  key: const ValueKey('compact-navigation-scaffold'),
                  body: RepaintBoundary(child: body),
                  bottomNavigationBar: NavigationBar(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: onDestinationSelected,
                    destinations: destinations,
                    // 56dp keeps each destination above the 48dp minimum touch target.
                    height: 56,
                  ),
                ),
        );
      },
    );
  }
}
