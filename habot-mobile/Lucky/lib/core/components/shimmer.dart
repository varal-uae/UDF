import 'package:flutter/material.dart';

// GEN-03321 — UI Shimmer Placeholder System.
// Spec: Material Design 3 Shimmers · 60fps target.
//
// No external package — Flutter AnimationController + LinearGradient.
// All shimmer shapes use surfaceContainerHighest + surfaceContainerLow
// from theme — automatically correct in light + dark mode.
//
// Components:
//   HabotShimmer       — base shimmer animation wrapper
//   ShimmerBox         — plain rectangle (lines, images, buttons)
//   ShimmerLine        — text line placeholder (full or partial width)
//   ShimmerAvatar      — circular avatar placeholder
//   ShimmerCard        — MD3 elevated card skeleton
//   ShimmerListTile    — list row skeleton (avatar + 2 lines)
//   ShimmerList        — N repeated ShimmerListTile rows
//   ShimmerSwitch      — swaps shimmer ↔ real content on isLoading flag

// ── Base shimmer animation ────────────────────────────────────────────────────

class HabotShimmer extends StatefulWidget {
  const HabotShimmer({
    super.key,
    required this.child,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 1200),
  });

  final Widget child;

  /// Set to false to disable shimmer (show content directly).
  final bool enabled;

  /// Sweep duration — 1200ms matches MD3 skeleton animation timing.
  final Duration duration;

  @override
  State<HabotShimmer> createState() => _HabotShimmerState();

  /// Access shimmer gradient from descendant widgets.
  static _HabotShimmerState? of(BuildContext context) =>
      context.findAncestorStateOfType<_HabotShimmerState>();
}

class _HabotShimmerState extends State<HabotShimmer>
    with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

  // Gradient sweep position — 0.0 → 1.0
  double get shimmerValue => _controller.value;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(); // continuous loop at 60fps
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Builds the shimmer gradient at current animation position.
  LinearGradient gradient(BuildContext context) {
    final theme = Theme.of(context);
    final base      = theme.colorScheme.surfaceContainerHighest;
    final highlight = theme.colorScheme.surfaceContainerLow;

    return LinearGradient(
      begin: Alignment.topLeft,
      end:   Alignment.bottomRight,
      colors: [base, highlight, base],
      stops: [
        (_controller.value - 0.3).clamp(0.0, 1.0),
        _controller.value.clamp(0.0, 1.0),
        (_controller.value + 0.3).clamp(0.0, 1.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => child!,
      child: widget.child,
    );
  }
}

// ── Shimmer Box (base shape) ──────────────────────────────────────────────────

/// Plain shimmer rectangle — use for any placeholder shape.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final shimmer = HabotShimmer.of(context);
    final theme   = Theme.of(context);

    // Fallback color when not inside HabotShimmer
    final fallback = theme.colorScheme.surfaceContainerHighest;

    return AnimatedBuilder(
      animation: shimmer?._controller ?? kAlwaysCompleteAnimation,
      builder: (context, _) {
        return Container(
          width:  width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: shimmer?.gradient(context) ??
                LinearGradient(colors: [fallback, fallback]),
          ),
        );
      },
    );
  }
}

// ── Shimmer Line (text placeholder) ──────────────────────────────────────────

/// Text line placeholder — full or partial width.
class ShimmerLine extends StatelessWidget {
  const ShimmerLine({
    super.key,
    this.widthFraction = 1.0,
    this.height = 14.0,
    this.borderRadius = 4.0,
  });

  /// Width as fraction of parent (0.0–1.0). Default = full width.
  final double widthFraction;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ShimmerBox(
        width:        constraints.maxWidth * widthFraction,
        height:       height,
        borderRadius: borderRadius,
      ),
    );
  }
}

// ── Shimmer Avatar ────────────────────────────────────────────────────────────

/// Circular avatar placeholder.
class ShimmerAvatar extends StatelessWidget {
  const ShimmerAvatar({super.key, this.size = 40.0});
  final double size;

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width:        size,
      height:       size,
      borderRadius: size / 2,
    );
  }
}

// ── Shimmer Card (MD3 elevated card skeleton) ─────────────────────────────────

/// MD3 Elevated Card skeleton — header image + 3 text lines.
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({
    super.key,
    this.height = 180.0,
    this.imageHeight = 100.0,
  });

  final double height;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              ShimmerBox(
                width:        double.infinity,
                height:       imageHeight,
                borderRadius: 8,
              ),
              const SizedBox(height: 12),
              // Title line
              const ShimmerLine(widthFraction: 0.7, height: 16),
              const SizedBox(height: 8),
              // Subtitle line
              const ShimmerLine(widthFraction: 0.5, height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shimmer List Tile ─────────────────────────────────────────────────────────

/// List row skeleton — avatar + title + subtitle.
/// Matches MD3 ListTile dimensions exactly.
class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({
    super.key,
    this.showAvatar = true,
    this.showSubtitle = true,
  });

  final bool showAvatar;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showAvatar) ...[
            const ShimmerAvatar(size: 40),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const ShimmerLine(widthFraction: 0.65, height: 14),
                if (showSubtitle) ...[
                  const SizedBox(height: 6),
                  // Subtitle
                  const ShimmerLine(widthFraction: 0.45, height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shimmer List ──────────────────────────────────────────────────────────────

/// Repeated ShimmerListTile rows — drop-in for any list during loading.
class ShimmerList extends StatelessWidget {
  const ShimmerList({
    super.key,
    this.itemCount = 6,
    this.showAvatar = true,
    this.showSubtitle = true,
    this.showDivider = true,
  });

  final int itemCount;
  final bool showAvatar;
  final bool showSubtitle;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return HabotShimmer(
      child: ListView.separated(
        shrinkWrap: true,
        physics:    const NeverScrollableScrollPhysics(),
        itemCount:  itemCount,
        separatorBuilder: (_, __) => showDivider
            ? const Divider(height: 1, indent: 72)
            : const SizedBox.shrink(),
        itemBuilder: (_, __) => ShimmerListTile(
          showAvatar:    showAvatar,
          showSubtitle:  showSubtitle,
        ),
      ),
    );
  }
}

// ── Shimmer Switch ────────────────────────────────────────────────────────────

/// Swaps between shimmer placeholder and real content.
/// Use this on any screen that loads data from network.
///
/// Usage:
/// ```dart
/// ShimmerSwitch(
///   isLoading: _isLoading,
///   shimmer:   ShimmerList(itemCount: 8),
///   child:     MyRealList(items: _items),
/// )
/// ```
class ShimmerSwitch extends StatelessWidget {
  const ShimmerSwitch({
    super.key,
    required this.isLoading,
    required this.shimmer,
    required this.child,
  });

  final bool isLoading;
  final Widget shimmer;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return HabotShimmer(child: shimmer);
    }
    return child;
  }
}
