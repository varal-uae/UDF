// ANSA-020-08 — M3 Adaptive Navigation for Dashboards. Dynamically switches between a bottom NavigationBar (Compact) and a NavigationRail (Medium/Expanded) based on viewport width, with M3 motion transitions and 48dp minimum touch targets.
import 'package:flutter/material.dart';

/// A Material 3 adaptive navigation scaffold for dashboard-level navigation.
///
/// Follows the NavigationSuiteScaffold pattern:
/// - Width < 600dp: uses [NavigationBar] at the bottom.
/// - Width >= 600dp: uses [NavigationRail] on the start edge.
/// The body cross-fades/scale transitions when the layout switches.
/// All destinations use Material defaults that guarantee 48dp touch targets.
class Ansa02008AdaptiveNavigationScaffold extends StatelessWidget {
  const Ansa02008AdaptiveNavigationScaffold({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.appBar,
    this.floatingActionButton,
  });

  /// Navigation destinations to display.
  final List<Ansa02008NavigationDestination> destinations;

  /// Currently selected destination index.
  final int selectedIndex;

  /// Callback when a destination is tapped.
  final ValueChanged<int> onDestinationSelected;

  /// The dashboard body content.
  final Widget body;

  /// Optional app bar.
  final PreferredSizeWidget? appBar;

  /// Optional floating action button.
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final navigationBar = isCompact
            ? _CompactNavigationBar(
                destinations: destinations,
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
              )
            : null;
        final navigationRail = !isCompact
            ? _ExpandedNavigationRail(
                destinations: destinations,
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
              )
            : null;

        return Scaffold(
          appBar: appBar,
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: KeyedSubtree(
              key: ValueKey(isCompact ? 'compact-body' : 'expanded-body'),
              child: navigationRail == null
                  ? body
                  : Row(
                      children: [
                        navigationRail,
                        const VerticalDivider(thickness: 1, width: 1),
                        Expanded(child: body),
                      ],
                    ),
            ),
          ),
          bottomNavigationBar: navigationBar,
          floatingActionButton: floatingActionButton,
        );
      },
    );
  }
}

/// Lightweight destination model for adaptive navigation.
class Ansa02008NavigationDestination {
  const Ansa02008NavigationDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.tooltip,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String? tooltip;
}

class _CompactNavigationBar extends StatelessWidget {
  const _CompactNavigationBar({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<Ansa02008NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        for (final destination in destinations)
          NavigationDestination(
            icon: Icon(destination.icon),
            selectedIcon: Icon(destination.selectedIcon),
            label: destination.label,
            tooltip: destination.tooltip ?? destination.label,
          ),
      ],
    );
  }
}

class _ExpandedNavigationRail extends StatelessWidget {
  const _ExpandedNavigationRail({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<Ansa02008NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      minWidth: 80,
      groupAlignment: -0.9,
      destinations: [
        for (final destination in destinations)
          NavigationRailDestination(
            icon: Icon(destination.icon),
            selectedIcon: Icon(destination.selectedIcon),
            label: Text(destination.label),
          ),
      ],
    );
  }
}
