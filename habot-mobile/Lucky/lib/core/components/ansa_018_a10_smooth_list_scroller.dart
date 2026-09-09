// ANSA-018-A10 — Inertial Drag Inertia Smooth List Scroller.
// Provides touch and mouse momentum scrolling with stable frame rates, 16px content boundaries, and per-row repaint isolation.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Ansa018A10ScrollBehavior extends MaterialScrollBehavior {
  const Ansa018A10ScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

class Ansa018A10SmoothListScroller extends StatelessWidget {
  const Ansa018A10SmoothListScroller({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.itemExtent,
    this.padding = const EdgeInsets.all(16),
    this.scrollController,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double? itemExtent;
  final EdgeInsetsGeometry padding;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Poka-yoke: block nested vertical scroll boxes to prevent conflicting loops.
    final parentScrollable = Scrollable.maybeOf(context);
    if (parentScrollable != null && parentScrollable.axis == Axis.vertical) {
      throw FlutterError(
        'ANSA-018-A10: This smooth list scroller must not be nested inside another vertical scrollable.',
      );
    }

    return ScrollConfiguration(
      behavior: const Ansa018A10ScrollBehavior(),
      child: RepaintBoundary(
        child: ScrollbarTheme(
          data: ScrollbarThemeData(
            thumbColor: WidgetStatePropertyAll(colorScheme.outlineVariant),
            trackColor: WidgetStatePropertyAll(colorScheme.surfaceContainerHighest),
            thickness: WidgetStatePropertyAll(4.0),
            radius: const Radius.circular(8),
          ),
          child: Scrollbar(
            thumbVisibility: false,
            child: ListView.builder(
              controller: scrollController,
              padding: padding,
              itemCount: itemCount,
              itemExtent: itemExtent,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemBuilder: (context, index) {
                return RepaintBoundary(
                  child: itemBuilder(context, index),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
