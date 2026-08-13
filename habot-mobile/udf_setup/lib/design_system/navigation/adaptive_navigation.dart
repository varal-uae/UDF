/// AISS: GEN-02334-A01 -- "Integrate M3 Navigation Rails for tablet views and
///   Bottom App Bars for mobile views."
/// AISS: GEN-02676-A01 -- "Add a badge counter to the bottom navigation icon
///   that displays the current unread notification count."
///
/// The first thing in this codebase that lets a user move BETWEEN screens
/// rather than within one. Everything before it -- tokens, grid, scaffold,
/// forms, surfaces -- was a single-screen concern.
///
/// One component, two presentations, chosen by the window class the grid
/// tokens already define. A caller lists destinations; it never decides
/// whether they appear in a rail or a bar, because that decision belongs to
/// the screen size and making it twice is how the two drift apart.
///
/// MUFCE-028 note: every destination passes an empty tooltip. Material builds
/// a tooltip for a navigation destination unless the string is empty, and a
/// hover tooltip is exactly what Step 24 removed from this codebase. The label
/// is already visible and already in the semantics tree.
library;

import 'package:flutter/material.dart';

import '../tokens/grid_tokens.dart';
import '../tokens/spacing_tokens.dart';
import 'nav_badge.dart';

/// One place a user can go.
@immutable
class HabotDestination {
  const HabotDestination({
    required this.route,
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.unreadCount = 0,
  });

  /// The route this destination shows. Deep links resolve to these (Step 43),
  /// which is why a destination carries a route rather than a builder.
  final String route;

  final String label;
  final IconData icon;
  final IconData? selectedIcon;

  /// GEN-02676: the unread count this destination advertises. Zero means no
  /// badge at all -- a badge showing "0" is noise pretending to be signal.
  final int unreadCount;

  HabotDestination copyWith({int? unreadCount}) => HabotDestination(
    route: route,
    label: label,
    icon: icon,
    selectedIcon: selectedIcon,
    unreadCount: unreadCount ?? this.unreadCount,
  );
}

/// Which navigation surface a viewport gets.
enum HabotNavigationSurface {
  /// Compact: a bottom bar, inside the thumb band.
  bottomBar,

  /// Medium and expanded: a leading rail.
  rail,
}

class HabotNavigationPolicy {
  const HabotNavigationPolicy._();

  /// The rail appears once the navigation is no longer collapsed -- the same
  /// 768dp threshold SSTLA-004 recorded in Step 5, not a new one.
  static HabotNavigationSurface surfaceFor(double width) =>
      HabotGrid.navigationIsCollapsed(width)
      ? HabotNavigationSurface.bottomBar
      : HabotNavigationSurface.rail;

  /// MD3 caps a bottom bar at five destinations; past that it is a menu.
  static const int maxBottomBarDestinations = 5;

  /// Rail width at rest, from the MD3 specification.
  static const double railWidth = HabotSpacing.xxl + HabotSpacing.xxl;

  /// Bottom bar height. Also the reason the bar clears the thumb band: it is
  /// anchored to the bottom edge, so its top sits within one bar height of it.
  static const double barHeight = HabotSpacing.xxxl + HabotSpacing.lg;

  static bool fitsBottomBar(int destinationCount) =>
      destinationCount >= 2 && destinationCount <= maxBottomBarDestinations;
}

/// The adaptive navigation surface.
class HabotAdaptiveNavigation extends StatelessWidget {
  const HabotAdaptiveNavigation({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    super.key,
  }) : assert(
         destinations.length >= 2,
         'Navigation with fewer than two destinations is not navigation',
       );

  final List<HabotDestination> destinations;
  final int selectedIndex;
  final void Function(int index) onDestinationSelected;

  /// The current destination's content.
  final Widget body;

  static const Key railKey = Key('habot.nav.rail');
  static const Key barKey = Key('habot.nav.bar');

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (HabotNavigationPolicy.surfaceFor(width) ==
        HabotNavigationSurface.rail) {
      return Row(
        children: <Widget>[
          _Rail(
            destinations: destinations,
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
          ),
          Expanded(child: body),
        ],
      );
    }
    return Column(
      children: <Widget>[
        Expanded(child: body),
        _BottomBar(
          destinations: destinations,
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
        ),
      ],
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<HabotDestination> destinations;
  final int selectedIndex;
  final void Function(int index) onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      key: HabotAdaptiveNavigation.railKey,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      minWidth: HabotNavigationPolicy.railWidth,
      destinations: <NavigationRailDestination>[
        for (final HabotDestination destination in destinations)
          NavigationRailDestination(
            icon: HabotNavBadge(
              count: destination.unreadCount,
              label: destination.label,
              child: Icon(destination.icon),
            ),
            selectedIcon: Icon(destination.selectedIcon ?? destination.icon),
            label: Text(destination.label),
          ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<HabotDestination> destinations;
  final int selectedIndex;
  final void Function(int index) onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      key: HabotAdaptiveNavigation.barKey,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      height: HabotNavigationPolicy.barHeight,
      destinations: <Widget>[
        for (final HabotDestination destination in destinations)
          NavigationDestination(
            icon: HabotNavBadge(
              count: destination.unreadCount,
              label: destination.label,
              child: Icon(destination.icon),
            ),
            selectedIcon: Icon(destination.selectedIcon ?? destination.icon),
            label: destination.label,
            // MUFCE-028: an empty string is how Material is told not to build
            // a tooltip. The label is visible and in the semantics tree.
            tooltip: '',
          ),
      ],
    );
  }
}
