import 'package:flutter/material.dart';

import 'shimmer.dart';

// CRSSS-002 — Configure Auto-Scaling Triggers (Mobile UX coverage).
//
// Coverage confirmation: skeleton placeholders during loading/scaling events
// are fully satisfied by Step 22 (GEN-03321 / shimmer.dart):
//   - surfaceContainerHighest + surfaceContainerLow MD3 tokens
//   - ShimmerSwitch swaps placeholder ↔ content on isLoading
//
// This shell is the named entry point for scaling/network reload events.

/// Shows MD3 skeleton placeholders while content loads or rescales.
///
/// ```dart
/// ScalingLoadShell(
///   isLoading: _isScaling,
///   itemCount: 6,
///   child: DashboardContent(),
/// )
/// ```
class ScalingLoadShell extends StatelessWidget {
  const ScalingLoadShell({
    super.key,
    required this.isLoading,
    required this.child,
    this.itemCount = 6,
    this.placeholder,
  });

  final bool isLoading;
  final Widget child;
  final int itemCount;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    return ShimmerSwitch(
      isLoading: isLoading,
      shimmer: placeholder ?? ShimmerList(itemCount: itemCount),
      child: child,
    );
  }
}

/// Compact card grid skeleton for scaling dashboard tiles.
class ScalingCardGridPlaceholder extends StatelessWidget {
  const ScalingCardGridPlaceholder({
    super.key,
    this.columns = 2,
    this.rows = 3,
  });

  final int columns;
  final int rows;

  @override
  Widget build(BuildContext context) {
    return HabotShimmer(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.4,
        ),
        itemCount: columns * rows,
        itemBuilder: (_, __) => const ShimmerCard(height: 100),
      ),
    );
  }
}
