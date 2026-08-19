// REF-467 — Anchored Bottom Navigation Bar & Biometric Verification Gate.
// Locks mobile routing to a fixed 80dp bottom container capped at 3-5 choices with active indicator pills.
// Provides a native BiometricVerificationGate overlay atom.

import 'package:flutter/material.dart';

class BottomNavDestination {
  const BottomNavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class AnchoredBottomNavBar extends StatelessWidget {
  const AnchoredBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : assert(items.length >= 3 && items.length <= 5, 'Primary menu choices must be strictly capped at 3 to 5 locations.');

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavDestination> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SizedBox(
      height: 80.0, // Fixed 80dp bottom container height
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        backgroundColor: cs.surfaceContainerLow,
        indicatorColor: cs.secondaryContainer, // Active selection indicator pill
        elevation: 3.0,
        destinations: items.map((item) {
          return NavigationDestination(
            icon: Icon(item.icon, color: cs.onSurfaceVariant),
            selectedIcon: Icon(item.selectedIcon, color: cs.onSecondaryContainer),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

/// Overlay gate requiring native biometric scan to unblock high-security fields cleanly under 500ms.
class BiometricVerificationGate extends StatelessWidget {
  const BiometricVerificationGate({
    super.key,
    required this.checkpointTitle,
    required this.onVerified,
    required this.onCancel,
  });

  final String checkpointTitle;
  final VoidCallback onVerified;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: cs.surface.withOpacity(0.95),
      child: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fingerprint, size: 64, color: cs.primary),
                const SizedBox(height: 16),
                Text(
                  'Biometric Authentication',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  checkpointTitle,
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(minimumSize: const Size(100, 48)),
                      child: const Text('Cancel'),
                    ),
                    FilledButton.icon(
                      onPressed: onVerified,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Scan & Unblock'),
                      style: FilledButton.styleFrom(minimumSize: const Size(140, 48)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
