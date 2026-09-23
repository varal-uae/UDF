// RCGLA-017-A10 — Lazy Loading Architecture Wrapper for Visual Core Components.
// Provides a structural loading wrapper with skeleton screens, fade-in animations,
// error boundaries with retry logic, and network-aware predictive preloading.

import 'package:flutter/material.dart';

/// Enum representing the current state of the lazy-loaded component.
enum _LazyLoadState { loading, loaded, error }

/// A reusable wrapper that handles lazy loading, skeleton placeholders,
/// fade-in transitions, error boundaries, and network-aware preloading.
class LazyLoadingWrapper extends StatefulWidget {
  /// The actual heavy widget to render once loaded.
  final Widget child;

  /// Optional custom skeleton widget. If null, a default Material 3 skeleton is used.
  final Widget? skeleton;

  /// The expected height of the skeleton to prevent layout shifts (jarring content jumps).
  final double skeletonHeight;

  /// Duration of the fade-in animation when the component finishes loading.
  final Duration fadeInDuration;

  /// Callback triggered when the component enters the viewport (intersection observer equivalent).
  final VoidCallback? onIntersect;

  /// Whether predictive asset preloading should be paused due to data-saving restrictions.
  final bool pausePredictivePreload;

  const LazyLoadingWrapper({
    super.key,
    required this.child,
    this.skeleton,
    this.skeletonHeight = 200.0,
    this.fadeInDuration = const Duration(milliseconds: 400),
    this.onIntersect,
    this.pausePredictivePreload = false,
  });

  @override
  State<LazyLoadingWrapper> createState() => _LazyLoadingWrapperState();
}

class _LazyLoadingWrapperState extends State<LazyLoadingWrapper>
    with SingleTickerProviderStateMixin {
  _LazyLoadState _state = _LazyLoadState.loading;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: widget.fadeInDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Simulate intersection observer triggering load
    _simulateLazyLoad();
  }

  Future<void> _simulateLazyLoad() async {
    if (!widget.pausePredictivePreload) {
      widget.onIntersect?.call();
    }

    setState(() => _state = _LazyLoadState.loading);

    try {
      // Simulating asynchronous bundle/component resolution
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (!mounted) return;
      
      setState(() => _state = _LazyLoadState.loaded);
      _fadeController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() => _state = _LazyLoadState.error);
    }
  }

  void _retry() {
    _fadeController.reset();
    _simulateLazyLoad();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Enforce exact height matching to prevent jarring content shifts
      height: widget.skeletonHeight,
      width: double.infinity,
      child: _buildStateWidget(),
    );
  }

  Widget _buildStateWidget() {
    switch (_state) {
      case _LazyLoadState.loading:
        return widget.skeleton ?? _DefaultSkeleton(height: widget.skeletonHeight);
      case _LazyLoadState.loaded:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: widget.child,
        );
      case _LazyLoadState.error:
        return _ErrorBoundaryView(onRetry: _retry);
    }
  }
}

/// Default Material Design 3 Skeleton Screen matching structural layout expectations.
class _DefaultSkeleton extends StatelessWidget {
  final double height;

  const _DefaultSkeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceVariant = theme.colorScheme.surfaceContainerHighest;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: surfaceVariant,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 16,
              width: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 12,
              width: MediaQuery.of(context).size.width * 0.4,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Robust Error Boundary catching UI to display error states and retry buttons.
class _ErrorBoundaryView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorBoundaryView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load component',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mock telemetry logger simulating GCP/BigQuery alignment for asset loading metrics.
class LazyLoadTelemetryLogger {
  static void logPerformanceMetric({
    required String stepExecutionId,
    required String componentId,
    required int loadTimeMs,
    required bool success,
  }) {
    // In production, this would stream directly to cloud tracking systems
    debugPrint('[RCGLA-017-A10 Telemetry] '
        'StepID: $stepExecutionId | '
        'Component: $componentId | '
        'LoadTime: ${loadTimeMs}ms | '
        'Success: $success');
  }
}
