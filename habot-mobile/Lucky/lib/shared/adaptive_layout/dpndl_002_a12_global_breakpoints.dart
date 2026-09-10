// DPNDL-002-A12 — Mobile-first global breakpoint variable set and adaptive layout skeleton.
// Provides 360dp baseline validation, progressive disclosure metric limits, and responsive navigation shell.

import 'package:flutter/material.dart';

@immutable
class HabotBreakpoints {
  const HabotBreakpoints._();

  static const double mobileBaseline = 360.0;
  static const double compact = 0.0;
  static const double medium = 600.0;
  static const double expanded = 840.0;
  static const double large = 1200.0;
  static const double desktop = 1440.0;
}

enum WindowClass { compact, medium, expanded, large }

class WindowClassTokens {
  const WindowClassTokens._();

  static WindowClass fromWidth(double width) {
    if (width < HabotBreakpoints.medium) return WindowClass.compact;
    if (width < HabotBreakpoints.expanded) return WindowClass.medium;
    if (width < HabotBreakpoints.large) return WindowClass.expanded;
    return WindowClass.large;
  }

  static bool isMobileBaseline(double width) =>
      width <= HabotBreakpoints.mobileBaseline;

  static int activeMetrics(WindowClass windowClass) {
    switch (windowClass) {
      case WindowClass.compact:
        return 3;
      case WindowClass.medium:
        return 5;
      case WindowClass.expanded:
      case WindowClass.large:
        return 8;
    }
  }

  static bool useTopHeaderMonogram(WindowClass windowClass) =>
      windowClass == WindowClass.compact;

  static bool useNavigationRail(WindowClass windowClass) =>
      windowClass != WindowClass.compact;

  static Map<String, Object> toJson() => {
        'mobileBaseline': mobileBaseline,
        'compact': compact,
        'medium': medium,
        'expanded': expanded,
        'large': large,
        'desktop': desktop,
      };
}

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.builder,
    this.mobileBaseline = HabotBreakpoints.mobileBaseline,
  });

  final Widget Function(
    BuildContext context,
    WindowClass windowClass,
    bool isMobileBaseline,
  ) builder;
  final double mobileBaseline;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isBaseline = WindowClassTokens.isMobileBaseline(width);
        final effectiveWidth = isBaseline ? mobileBaseline : width;
        final effectiveClass = WindowClassTokens.fromWidth(effectiveWidth);
        return builder(context, effectiveClass, isBaseline);
      },
    );
  }
}

class AdaptiveScaffoldShell extends StatelessWidget {
  const AdaptiveScaffoldShell({
    super.key,
    required this.title,
    required this.body,
    this.destinations = const [],
    this.selectedIndex = 0,
    this.onDestinationSelected,
  });

  final String title;
  final Widget body;
  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      builder: (context, windowClass, isBaseline) {
        final useRail = WindowClassTokens.useNavigationRail(windowClass);
        final useMonogram = WindowClassTokens.useTopHeaderMonogram(windowClass);
        final nav = useRail
            ? NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                labelType: NavigationRailLabelType.none,
                destinations: [
                  for (final d in destinations)
                    NavigationRailDestination(
                      icon: d.icon,
                      selectedIcon: d.selectedIcon,
                      label: Text(d.label),
                    ),
                ],
              )
            : null;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              useMonogram && title.isNotEmpty ? title.substring(0, 1) : title,
            ),
            centerTitle: useMonogram,
          ),
          body: SafeArea(
            child: Row(
              children: [
                if (nav != null) nav,
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isBaseline ? 16 : 24),
                    child: body,
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: useMonogram && destinations.isNotEmpty
              ? NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  destinations: destinations,
                )
              : null,
        );
      },
    );
  }
}
