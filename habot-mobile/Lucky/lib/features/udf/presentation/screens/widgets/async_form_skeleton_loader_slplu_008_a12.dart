// SLPLU-008-A12 — AsyncFormSkeletonLoader for Lead Generation Form Progressive Loading.
// Implements Material 3 compliant skeleton loading with theme-aware pulsating animations, blocked interactions, and timeout retry handling.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data representing theme configuration for the skeleton loader.
class SkeletonThemeMock {
  static const String themeName = 'UDF_Light_Theme';
  static const Map<String, dynamic> themeConfiguration = {
    'skeleton_base_color': 0xFFE0E0E0,
    'skeleton_highlight_color': 0xFFF5F5F5,
    'animation_duration_ms': 1500,
  };
}

/// A reusable skeleton loader widget that mimics form fields during data fetching.
/// Interactions are completely blocked to prevent premature submissions (Poka-Yoke).
class AsyncFormSkeletonLoader extends StatefulWidget {
  final int fieldCount;
  final VoidCallback? onTimeoutRetry;
  final Duration timeoutDuration;

  const AsyncFormSkeletonLoader({
    super.key,
    this.fieldCount = 4,
    this.onTimeoutRetry,
    this.timeoutDuration = const Duration(seconds: 15),
  });

  @override
  State<AsyncFormSkeletonLoader> createState() => _AsyncFormSkeletonLoaderState();
}

class _AsyncFormSkeletonLoaderState extends State<AsyncFormSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  Timer? _timeoutTimer;
  bool _isTimedOut = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: SkeletonThemeMock.themeConfiguration['animation_duration_ms'] as int? ?? 1500,
      ),
    );

    // Standardized easing curve for rhythmic visual motion feedback application-wide
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    );

    _controller.repeat(reverse: true);
    _startTimeoutTimer();
  }

  void _startTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(widget.timeoutDuration, () {
      if (mounted) {
        setState(() {
          _isTimedOut = true;
        });
        _controller.stop();
      }
    });
  }

  void _handleRetry() {
    setState(() {
      _isTimedOut = false;
    });
    _controller.repeat(reverse: true);
    _startTimeoutTimer();
    widget.onTimeoutRetry?.call();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Desaturated grey background container fills mapped to M3 surfaceContainer
    final baseColor = colorScheme.surfaceContainerHighest.withOpacity(0.4);
    final highlightColor = colorScheme.surfaceContainer.withOpacity(0.7);

    return IgnorePointer(
      // Poka-Yoke: Interactive gesture event listeners are blocked completely across skeleton rows
      ignoring: true,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isTimedOut ? _buildTimeoutView(theme) : _buildSkeletonView(baseColor, highlightColor),
      ),
    );
  }

  Widget _buildSkeletonView(Color baseColor, Color highlightColor) {
    return Container(
      key: const ValueKey('skeleton_view'),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.fieldCount, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildSkeletonField(baseColor, highlightColor, index),
          );
        }),
      ),
    );
  }

  Widget _buildSkeletonField(Color baseColor, Color highlightColor, int index) {
    // Material 3 Outlined Text Field components dimensions mimicry
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label placeholder
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              height: 12.0,
              width: 80.0 + (index * 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                gradient: LinearGradient(
                  colors: [baseColor, highlightColor, baseColor],
                  stops: [
                    0.0,
                    _animation.value,
                    1.0,
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8.0),
        // Input container placeholder matching exact text line properties
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              height: 56.0, // Standard M3 OutlinedTextField height
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(
                  color: baseColor,
                  width: 1.0,
                ),
                gradient: LinearGradient(
                  colors: [baseColor, highlightColor, baseColor],
                  stops: [
                    0.0,
                    _animation.value,
                    1.0,
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimeoutView(ThemeData theme) {
    return Container(
      key: const ValueKey('timeout_view'),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: theme.colorScheme.error.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 48.0,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16.0),
          Text(
            'Network Timeout',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Failed to load form data. Please check your connection.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24.0),
          // Action trigger buttons utilizing standard typography tokens
          IgnorePointer(
            ignoring: false, // Re-enable interaction ONLY for the retry button
            child: OutlinedButton.icon(
              onPressed: _handleRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: OutlinedButton.styleFrom(
                textStyle: theme.textTheme.labelLarge, // md.comp.button.primary.label-text-font equivalent
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper widget to rebuild on animation ticks.
class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder2(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}

class AnimatedBuilder2 extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder2({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}