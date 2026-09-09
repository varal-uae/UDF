// ANSA-015-A08 — Thumb-Optimized Application Shell: MD3 bottom navigation, elevation-ring FAB, and lower stacked action bar.
// Enforces primary actions in the bottom 40% zone and one-handed thumb interaction targets per Material Design 3.

import 'package:flutter/material.dart';

/// A Material 3 shell that keeps navigation and primary actions within the natural
/// single-handed thumb interaction zone.
class ThumbOptimizedActionShell extends StatelessWidget {
  const ThumbOptimizedActionShell({
    super.key,
    required this.child,
    required this.navigationDestinations,
    required this.primaryActions,
    this.floatingActionButton,
    this.onDestinationSelected,
    this.currentIndex = 0,
  });

  final Widget child;
  final List<NavigationDestination> navigationDestinations;
  final List<Widget> primaryActions;
  final Widget? floatingActionButton;
  final ValueChanged<int>? onDestinationSelected;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomActions = _buildBottomActionBar(theme);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: child,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: navigationDestinations,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      floatingActionButton: floatingActionButton == null
          ? null
          : Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.35),
                    blurRadius: 12,
                    spreadRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: floatingActionButton,
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      persistentFooterButtons: bottomActions.isEmpty ? null : bottomActions,
    );
  }

  List<Widget> _buildBottomActionBar(ThemeData theme) {
    if (primaryActions.isEmpty) return const [];
    return [
      Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant.withOpacity(0.4),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < primaryActions.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: primaryActions[i],
              ),
            ],
          ],
        ),
      ),
    ];
  }
}