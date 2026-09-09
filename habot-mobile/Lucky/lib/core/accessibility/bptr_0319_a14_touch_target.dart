// BPTR-0319-A14 — Touch Target Minimum 48dp & Tab Selector Interaction Gates.
// Enforces a 48x48 logical pixel touch area for every interactive atom and isolates channel-category tabs as immediate interaction gates.

import 'package:flutter/material.dart';

/// Wraps any interactive widget to enforce a minimum 48x48 logical pixel touch target.
class Bptr0319A14TouchTarget extends StatelessWidget {
  const Bptr0319A14TouchTarget({
    super.key,
    required this.child,
    this.minSize = 48,
    this.semanticLabel,
  });

  final Widget child;
  final double minSize;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minSize,
          minHeight: minSize,
        ),
        child: Center(child: child),
      ),
    );
  }
}

/// Horizontal tab selector that acts as an immediate interaction gate.
/// Each tab is constrained to a minimum 48x48 touch target and triggers instantly.
class Bptr0319A14ChannelTabGate extends StatelessWidget {
  const Bptr0319A14ChannelTabGate({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.minTouchSize = 48,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double minTouchSize;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (int index) {
          final bool isSelected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Bptr0319A14TouchTarget(
              minSize: minTouchSize,
              semanticLabel: tabs[index],
              child: InkWell(
                onTap: () => onChanged(index),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    child: Text(
                      tabs[index],
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
