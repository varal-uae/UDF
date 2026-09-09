// BPTR-0222-A09 — Mobile Loading Skeleton States: reusable pulsing gray placeholders that mirror incoming data and block interactions during loading.
// Provides SkeletonPulse, SkeletonBox, SkeletonList, and LoadingSkeleton widgets following Material 3 design tokens.
import 'package:flutter/material.dart';

/// Animates opacity to create a pulsing skeleton effect.
class SkeletonPulse extends StatefulWidget {
  const SkeletonPulse({super.key, required this.child});

  final Widget child;

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}

/// A single gray placeholder box.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface.withOpacity(0.12);
    return SkeletonPulse(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// A vertical list of skeleton boxes to mimic record placeholders.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 72,
    this.spacing = 12,
    this.padding = const EdgeInsets.all(16),
  });

  final int itemCount;
  final double itemHeight;
  final double spacing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: spacing),
      itemBuilder: (_, __) => SkeletonBox(
        height: itemHeight,
        borderRadius: 12,
      ),
    );
  }
}

/// Wraps content and blocks all interactions while [isLoading] is true.
/// Shows a skeleton placeholder instead of [child] during loading.
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({
    super.key,
    required this.isLoading,
    required this.child,
    this.skeleton,
  });

  final bool isLoading;
  final Widget child;
  final Widget? skeleton;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;
    return AbsorbPointer(
      child: skeleton ?? const SkeletonList(),
    );
  }
}
