// BPTR-0222-A14 — Mobile Loading Skeleton States.
// Gray pulsing placeholders that mirror incoming database record layout and smoothly transition to final content when data arrives.
import 'package:flutter/material.dart';

/// A Material 3 skeleton loading wrapper that disables interaction gates
/// and animates pulsing gray placeholders until [child] is mounted.
class SkeletonPlaceholder extends StatefulWidget {
  const SkeletonPlaceholder({
    super.key,
    required this.isLoading,
    required this.child,
    this.layoutType = SkeletonLayoutType.list,
    this.gridColumns = 2,
    this.itemCount = 4,
    this.spacing = 12.0,
    this.alignment = Alignment.topLeft,
    this.borderRadius = 12.0,
  });

  final bool isLoading;
  final Widget child;
  final SkeletonLayoutType layoutType;
  final int gridColumns;
  final int itemCount;
  final double spacing;
  final AlignmentGeometry alignment;
  final double borderRadius;

  @override
  State<SkeletonPlaceholder> createState() => _SkeletonPlaceholderState();
}

class _SkeletonPlaceholderState extends State<SkeletonPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: widget.isLoading
          ? AbsorbPointer(
              key: const ValueKey('skeleton-loading'),
              child: _SkeletonLayout(
                controller: _controller,
                layoutType: widget.layoutType,
                gridColumns: widget.gridColumns,
                itemCount: widget.itemCount,
                spacing: widget.spacing,
                alignment: widget.alignment,
                borderRadius: widget.borderRadius,
                baseColor: colorScheme.surfaceContainerHighest,
                highlightColor: colorScheme.surfaceContainerHigh,
              ),
            )
          : KeyedSubtree(
              key: const ValueKey('skeleton-content'),
              child: widget.child,
            ),
    );
  }
}

enum SkeletonLayoutType { list, grid, card }

class _SkeletonLayout extends StatelessWidget {
  const _SkeletonLayout({
    required this.controller,
    required this.layoutType,
    required this.gridColumns,
    required this.itemCount,
    required this.spacing,
    required this.alignment,
    required this.borderRadius,
    required this.baseColor,
    required this.highlightColor,
  });

  final AnimationController controller;
  final SkeletonLayoutType layoutType;
  final int gridColumns;
  final int itemCount;
  final double spacing;
  final AlignmentGeometry alignment;
  final double borderRadius;
  final Color baseColor;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    switch (layoutType) {
      case SkeletonLayoutType.list:
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(spacing),
          itemCount: itemCount,
          separatorBuilder: (_, __) => SizedBox(height: spacing),
          itemBuilder: (_, __) => _SkeletonItem(
            controller: controller,
            borderRadius: borderRadius,
            baseColor: baseColor,
            highlightColor: highlightColor,
            hasLeading: true,
            hasTrailing: true,
          ),
        );
      case SkeletonLayoutType.grid:
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(spacing),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridColumns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: 1.1,
          ),
          itemCount: itemCount,
          itemBuilder: (_, __) => _SkeletonItem(
            controller: controller,
            borderRadius: borderRadius,
            baseColor: baseColor,
            highlightColor: highlightColor,
            hasLeading: false,
            hasTrailing: false,
          ),
        );
      case SkeletonLayoutType.card:
        return Padding(
          padding: EdgeInsets.all(spacing),
          child: Column(
            children: List.generate(
              itemCount,
              (_) => Padding(
                padding: EdgeInsets.only(bottom: spacing),
                child: _SkeletonItem(
                  controller: controller,
                  borderRadius: borderRadius,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  hasLeading: true,
                  hasTrailing: false,
                ),
              ),
            ),
          ),
        );
    }
  }
}

class _SkeletonItem extends StatelessWidget {
  const _SkeletonItem({
    required this.controller,
    required this.borderRadius,
    required this.baseColor,
    required this.highlightColor,
    required this.hasLeading,
    required this.hasTrailing,
  });

  final AnimationController controller;
  final double borderRadius;
  final Color baseColor;
  final Color highlightColor;
  final bool hasLeading;
  final bool hasTrailing;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(controller.value);
        final color = Color.lerp(baseColor, highlightColor, t)!;
        return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              if (hasLeading) ...[
                _SkeletonCircle(
                  color: color,
                  size: 40,
                ),
                const SizedBox(width: 12.0),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonLine(
                      color: color,
                      widthFactor: 0.7,
                      height: 14,
                    ),
                    const SizedBox(height: 8.0),
                    _SkeletonLine(
                      color: color,
                      widthFactor: 0.45,
                      height: 12,
                    ),
                  ],
                ),
              ),
              if (hasTrailing) ...[
                const SizedBox(width: 12.0),
                _SkeletonCircle(
                  color: color,
                  size: 24,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({
    required this.color,
    required this.widthFactor,
    required this.height,
  });

  final Color color;
  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  const _SkeletonCircle({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
