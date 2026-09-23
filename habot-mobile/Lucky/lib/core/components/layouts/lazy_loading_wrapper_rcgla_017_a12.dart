// RCGLA-017-A12 — Lazy Loading Architecture Wrapper for Visual Core Components.
// Provides a structural loading wrapper with skeleton screens, fade-in animations, error boundaries, and retry logic for heavy components in Flutter.

import 'package:flutter/material.dart';

/// Enum representing the current state of the lazy-loaded chunk.
enum _LazyLoadState { loading, loaded, error }

/// A structural loading wrapper used across all heavy navigation tabs and rich data layout views.
/// Enforces Material Design 3 Window Size Class profiles and single-axis scroll hierarchy on mobile.
class LazyLoadingWrapper extends StatefulWidget {
  /// The heavy widget to be lazily loaded/rendered.
  final Widget child;

  /// Optional fixed height to prevent jarring content shifts (layout thrashing).
  final double? height;

  /// Duration of the subtle fade-in animation when the component finishes loading.
  final Duration fadeInDuration;

  /// Whether to simulate a network failure for testing fallback/error states.
  final bool simulateFailure;

  const LazyLoadingWrapper({
    super.key,
    required this.child,
    this.height,
    this.fadeInDuration = const Duration(milliseconds: 400),
    this.simulateFailure = false,
  });

  @override
  State<LazyLoadingWrapper> createState() => _LazyLoadingWrapperState();
}

class _LazyLoadingWrapperState extends State<LazyLoadingWrapper>
    with SingleTickerProviderStateMixin {
  _LazyLoadState _state = _LazyLoadState.loading;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.fadeInDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadComponent();
  }

  Future<void> _loadComponent() async {
    setState(() => _state = _LazyLoadState.loading);

    try {
      // Simulate asynchronous chunk fetch / heavy initialization
      await Future.delayed(const Duration(milliseconds: 800));

      if (widget.simulateFailure) {
        throw Exception('Simulated failed chunk fetch.');
      }

      if (!mounted) return;
      setState(() => _state = _LazyLoadState.loaded);
      _animationController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() => _state = _LazyLoadState.error);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: switch (_state) {
        _LazyLoadState.loading => _buildSkeleton(theme, isMobile),
        _LazyLoadState.loaded => _buildLoadedContent(),
        _LazyLoadState.error => _buildErrorState(theme, isMobile),
      },
    );
  }

  Widget _buildSkeleton(ThemeData theme, bool isMobile) {
    // Structural skeleton screen matching exact component heights to prevent shifts
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.0),
      ),
      // Apply dynamic stretch fields (flex-direction: column) under mobile media breakpoints
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBlock(
            width: isMobile ? double.infinity : 120,
            height: isMobile ? 24 : 100,
            theme: theme,
          ),
          const SizedBox(width: 12, height: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBlock(
                  width: double.infinity,
                  height: 16,
                  theme: theme,
                ),
                const SizedBox(height: 8),
                _SkeletonBlock(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 16,
                  theme: theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedContent() {
    // Subtle fade-in animation for smooth transition
    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.child,
    );
  }

  Widget _buildErrorState(ThemeData theme, bool isMobile) {
    // Robust error boundary catching to automatically display error states and retry buttons
    return Container(
      padding: const EdgeInsets.all(24.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        border: Border.all(color: theme.colorScheme.error.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 16, height: 16),
          Text(
            'Failed to load component.',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(width: 16, height: 16),
          FilledButton.icon(
            onPressed: _loadComponent,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

/// Internal helper for rendering skeleton placeholders.
class _SkeletonBlock extends StatelessWidget {
  final double? width;
  final double height;
  final ThemeData theme;

  const _SkeletonBlock({
    this.width,
    required this.height,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}

/// Intersection Observer equivalent for Flutter using NotificationListener.
/// Triggers loading when the component scrolls into view.
class LazyIntersectionLoader extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  final double height;

  const LazyIntersectionLoader({
    super.key,
    required this.builder,
    this.height = 200,
  });

  @override
  State<LazyIntersectionLoader> createState() =>
      _LazyIntersectionLoaderState();
}

class _LazyIntersectionLoaderState extends State<LazyIntersectionLoader> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (!_isVisible && notification.metrics.pixels > 0) {
          // Simplified intersection check; in production, use RenderBox localToGlobal
          setState(() => _isVisible = true);
        }
        return false;
      },
      child: _isVisible
          ? widget.builder(context)
          : SizedBox(height: widget.height),
    );
  }
}

/// Mock Data & Telemetry Logger for GCP/BigQuery Alignment simulation.
class LazyLoadTelemetryLogger {
  static void logPerformanceMetric({
    required String componentName,
    required int loadTimeMs,
    required bool success,
  }) {
    // Simulates logging asset loading performance metrics directly to cloud tracking systems
    final mockPayload = {
      'test_type': 'lazy_load_performance',
      'component_name': componentName,
      'load_time_ms': loadTimeMs,
      'success': success,
      'timestamp': DateTime.now().toIso8601String(),
      'session_id': 'mock_session_12345',
    };
    debugPrint('[LazyLoadTelemetry] $mockPayload');
  }
}
