// BPTR-0222-A08 — Mobile Loading Skeleton States & Skeleton Wrapper.
// Provides a reusable skeleton wrapper that defaults `isLoading` to true, blocks all interactions during loading, and pulses gray placeholders to reduce perceived wait time.
import 'package:flutter/material.dart';

/// A wrapper that manages loading skeleton state for mobile screens.
///
/// The [isLoading] flag defaults to `true`, so consumers must explicitly mark
/// content as ready. While loading, interactions are absorbed and either a
/// custom [skeleton] or a default pulsing gray placeholder is shown.
class Bptr0222A08SkeletonWrapper extends StatefulWidget {
  const Bptr0222A08SkeletonWrapper({
    super.key,
    required this.child,
    this.isLoading = true,
    this.skeleton,
  });

  /// The actual content to display when loading completes.
  final Widget child;

  /// Defaults to `true` to block premature interaction and layout shifts.
  final bool isLoading;

  /// Optional custom skeleton layout. If omitted, a default pulsing
  /// gray placeholder is used.
  final Widget? skeleton;

  @override
  State<Bptr0222A08SkeletonWrapper> createState() =>
      _Bptr0222A08SkeletonWrapperState();
}

class _Bptr0222A08SkeletonWrapperState extends State<Bptr0222A08SkeletonWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSkeleton = widget.skeleton ??
        _DefaultSkeleton(pulse: _pulseController);

    return AbsorbPointer(
      absorbing: widget.isLoading,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: widget.isLoading
            ? KeyedSubtree(
                key: const ValueKey('skeleton'),
                child: effectiveSkeleton,
              )
            : KeyedSubtree(
                key: const ValueKey('content'),
                child: widget.child,
              ),
      ),
    );
  }
}

class _DefaultSkeleton extends StatelessWidget {
  const _DefaultSkeleton({required this.pulse});

  final AnimationController pulse;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 0.9).animate(
        CurvedAnimation(parent: pulse, curve: Curves.easeInOut),
      ),
      child: Container(
        height: 120,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
