// ANSA-015-A07 — Thumb-Optimized Application Shell.
// Implements MD3 bottom navigation, an elevated floating action button, and a lower action bar
// with precise spacing to keep interactive zones within natural single-handed thumb reach.

import 'package:flutter/material.dart';

/// Spacing parameters enforced across the shell to keep interactive zones separated.
class Ansa015A07LayoutSpacing {
  static const double screenHorizontalMargin = 16.0;
  static const double bottomActionBarPadding = 12.0;
  static const double actionGap = 12.0;
  static const double fabElevationRing = 6.0;
  static const double bottomNavHeight = 80.0;
}

class Ansa015A07ThumbLayoutShell extends StatelessWidget {
  const Ansa015A07ThumbLayoutShell({
    super.key,
    required this.destinations,
    required this.body,
    this.floatingActionButton,
    this.lowerActions = const [],
    this.onDestinationSelected,
    this.currentIndex = 0,
  });

  final List<NavigationDestination> destinations;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget> lowerActions;
  final ValueChanged<int>? onDestinationSelected;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: body),
            if (lowerActions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Ansa015A07LayoutSpacing.screenHorizontalMargin,
                  Ansa015A07LayoutSpacing.bottomActionBarPadding,
                  Ansa015A07LayoutSpacing.screenHorizontalMargin,
                  Ansa015A07LayoutSpacing.bottomActionBarPadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < lowerActions.length; i++) ...[
                      if (i > 0) const SizedBox(height: Ansa015A07LayoutSpacing.actionGap),
                      lowerActions[i],
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton == null
          ? null
          : Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withOpacity(0.3),
                    blurRadius: Ansa015A07LayoutSpacing.fabElevationRing * 2,
                    spreadRadius: Ansa015A07LayoutSpacing.fabElevationRing,
                  ),
                ],
              ),
              child: floatingActionButton,
            ),
      bottomNavigationBar: NavigationBar(
        height: Ansa015A07LayoutSpacing.bottomNavHeight,
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
      ),
    );
  }
}
