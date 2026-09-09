// ANSA-018-A12 — Inertial Drag Inertia Smooth List Scroller.
// A reusable, GPU-friendly list container with momentum physics, 16px scroll-boundary margins,
// repaint boundaries per row, and no nested vertical scroll conflicts.
import 'package:flutter/material.dart';

/// High-performance smooth list scroller for long data directories and logs.
///
/// Applies Material Design scrolling paradigms, keeps rows GPU-friendly with
/// [RepaintBoundary], supports fixed item extents for predictable frame rates,
/// and prevents nested vertical scroll loops by acting as the single scrollable.
class HabotSmoothListScroller extends StatelessWidget {
  const HabotSmoothListScroller({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    this.physics,
    this.itemExtent,
    this.showScrollbar = false,
    this.cacheExtent = 500,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ScrollController? controller;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics? physics;
  final double? itemExtent;
  final bool showScrollbar;
  final double cacheExtent;

  @override
  Widget build(BuildContext context) {
    final effectivePhysics = physics ??
        const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        );

    return Scrollbar(
      controller: controller,
      thumbVisibility: showScrollbar,
      child: ListView.builder(
        controller: controller,
        padding: padding,
        physics: effectivePhysics,
        itemExtent: itemExtent,
        cacheExtent: cacheExtent,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return RepaintBoundary(
            child: itemBuilder(context, index),
          );
        },
      ),
    );
  }
}