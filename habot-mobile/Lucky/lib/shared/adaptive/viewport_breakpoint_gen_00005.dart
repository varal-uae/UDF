// GEN-00005 — Viewport Breakpoint Configuration and Responsive Skeleton Loader.
// Defines the 360px viewport breakpoint baseline and provides responsive layout utilities
// alongside Material 3 skeleton loading placeholders for paginated and adaptive data fetching.

import 'package:flutter/material.dart';

/// Schema and layout constant defining the mobile baseline viewport breakpoint.
const int viewportBreakpointPx = 360;

/// Enumeration representing responsive device viewport classifications.
enum ViewportTier {
  compactSmall,
  compactMobile,
  mediumTablet,
  expandedDesktop,
}

/// Evaluator and provider for viewport breakpoints and responsive decisions.
class ViewportBreakpointConfig {
  const ViewportBreakpointConfig._();

  /// Standard baseline breakpoint in logical pixels.
  static const int baselineBreakpointPx = viewportBreakpointPx;

  /// Resolves the current [ViewportTier] according to standard Material 3 breakpoints
  /// with sub-360px ultra-compact mobile handling.
  static ViewportTier getTier(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width < baselineBreakpointPx) {
      return ViewportTier.compactSmall;
    } else if (width < 600) {
      return ViewportTier.compactMobile;
    } else if (width < 840) {
      return ViewportTier.mediumTablet;
    } else {
      return ViewportTier.expandedDesktop;
    }
  }

  /// Returns true if the device width is below the baseline 360px threshold.
  static bool isBelowBaseline(BuildContext context) {
    return MediaQuery.sizeOf(context).width < baselineBreakpointPx;
  }

  /// Returns true if single-column layout should be enforced (<600dp).
  static bool isSingleColumn(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 600;
  }
}

/// Material 3 skeleton loading widget displaying an animated shimmer placeholder
/// for the next page during asynchronous fetches.
class NextPageLoadingSkeletonGen00005 extends StatefulWidget {
  final int itemCount;
  final EdgeInsetsGeometry padding;

  const NextPageLoadingSkeletonGen00005({
    super.key,
    this.itemCount = 3,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
  });

  @override
  State<NextPageLoadingSkeletonGen00005> createState() =>
      _NextPageLoadingSkeletonGen00005State();
}

class _NextPageLoadingSkeletonGen00005State
    extends State<NextPageLoadingSkeletonGen00005>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCompact = ViewportBreakpointConfig.isBelowBaseline(context);
    final baseColor = colorScheme.surfaceContainerHighest;
    final highlightColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.12);

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Padding(
          padding: widget.padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(widget.itemCount, (index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: EdgeInsets.all(isCompact ? 12.0 : 16.0),
                decoration: BoxDecoration(
                  color: Color.lerp(baseColor, highlightColor, _shimmerAnimation.value),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color.lerp(baseColor, highlightColor, 1 - _shimmerAnimation.value),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 14,
                                width: isCompact ? 120 : 180,
                                decoration: BoxDecoration(
                                  color: Color.lerp(baseColor, highlightColor, 1 - _shimmerAnimation.value),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 10,
                                width: 90,
                                decoration: BoxDecoration(
                                  color: Color.lerp(baseColor, highlightColor, 1 - _shimmerAnimation.value),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color.lerp(baseColor, highlightColor, 1 - _shimmerAnimation.value),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
