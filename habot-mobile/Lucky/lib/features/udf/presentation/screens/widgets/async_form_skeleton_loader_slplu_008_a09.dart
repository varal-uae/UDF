// SLPLU-008-A09 — AsyncFormSkeletonLoader for progressive lead generation form loading.
// Implements Material 3 skeleton loading with shimmer animation, blocked gesture interactions, and timeout fallback retry dialog.

import 'dart:async';
import 'package:flutter/material.dart';

/// Reusable skeleton loader component for UDF lead generation forms.
/// Enforces Material Design 3 standards, neutral desaturated grey fills,
/// identical motion timing curves, and blocks all interactive gestures during loading.
class AsyncFormSkeletonLoader extends StatefulWidget {
  final bool isLoading;
  final bool hasError;
  final Duration timeout;
  final VoidCallback? onRetry;
  final Widget? child;

  const AsyncFormSkeletonLoader({
    super.key,
    required this.isLoading,
    this.hasError = false,
    this.timeout = const Duration(seconds: 15),
    this.onRetry,
    this.child,
  });

  @override
  State<AsyncFormSkeletonLoader> createState() => _AsyncFormSkeletonLoaderState();
}

class _AsyncFormSkeletonLoaderState extends State<AsyncFormSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _timeoutTimer;
  bool _isTimedOut = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    if (widget.isLoading) {
      _startLoading();
    }
  }

  void _startLoading() {
    _controller.repeat(reverse: true);
    _isTimedOut = false;
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(widget.timeout, () {
      if (mounted && widget.isLoading) {
        setState(() => _isTimedOut = true);
        _controller.stop();
      }
    });
  }

  @override
  void didUpdateWidget(covariant AsyncFormSkeletonLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _startLoading();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _stopLoading();
    }
  }

  void _stopLoading() {
    _controller.stop();
    _controller.reset();
    _timeoutTimer?.cancel();
    _isTimedOut = false;
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading && !widget.hasError && !_isTimedOut) {
      return widget.child ?? const SizedBox.shrink();
    }

    if (_isTimedOut || widget.hasError) {
      return _buildTimeoutFallback(context);
    }

    // Block all interactive gesture event listeners across skeleton rows
    return IgnorePointer(
      ignoring: true,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return _buildSkeletonLayout(context, _animation.value);
        },
      ),
    );
  }

  Widget _buildTimeoutFallback(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Connection timed out',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your network and try again.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: widget.onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: OutlinedButton.styleFrom(
                textStyle: theme.textTheme.labelLarge?.copyWith(
                  fontFamily: 'Roboto', // md.comp.button.primary.label-text-font equivalent
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLayout(BuildContext context, double animationValue) {
    final theme = Theme.of(context);
    // Neutral, desaturated grey background container fills
    final baseColor = theme.colorScheme.surfaceContainerHighest.withOpacity(0.4);
    final highlightColor = theme.colorScheme.surfaceContainerHighest.withOpacity(0.1);

    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [baseColor, highlightColor, baseColor],
      stops: const [0.0, 0.5, 1.0],
      transform: GradientTranslation(animationValue),
    );

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Skeleton
          _buildShimmerBox(
            width: 200,
            height: 24, // Matches expected text line properties perfectly
            gradient: gradient,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 24),
          // Material 3 Outlined Text Field placeholders
          _buildOutlinedFieldSkeleton(gradient: gradient),
          const SizedBox(height: 16),
          _buildOutlinedFieldSkeleton(gradient: gradient),
          const SizedBox(height: 16),
          _buildOutlinedFieldSkeleton(gradient: gradient),
          const SizedBox(height: 32),
          // Action trigger button placeholder
          Align(
            alignment: Alignment.centerRight,
            child: _buildShimmerBox(
              width: 120,
              height: 40,
              gradient: gradient,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedFieldSkeleton({required Gradient gradient}) {
    return Container(
      height: 56, // Standard M3 Outlined Text Field height
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: _buildShimmerBox(
        width: double.infinity,
        height: 16, // Matches expected text line properties
        gradient: gradient,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    required Gradient gradient,
    required BorderRadius borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
      ),
    );
  }
}

/// Custom gradient transform to apply smooth rhythmic visual motion feedback.
class GradientTranslation extends GradientTransform {
  final double offset;

  const GradientTranslation(this.offset);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * offset, 0, 0);
  }
}

/// Mock data constants representing atomic-level data fields for testing and QA validation.
class SkeletonLoaderMockData {
  static const Map<String, dynamic> testMetrics = {
    'testType': 'Functional UI Rendering Test',
    'testResult': 'Pass',
    'testCoverage': '100%',
    'testTimestamp': '2026-09-25T10:00:00Z',
    'testLogPath': '/logs/slplu_008_a09_skeleton_test.log',
    'completionStatus': 'Pass / Fail',
    'actionEventTimestamp': '2026-09-25T10:00:05Z',
    'userSessionId': 'mock-session-id-12345'
  };

  static const List<Map<String, dynamic>> responsiveParameterArrays = [
    {'directive': 'percentage', 'value': '100%'},
    {'directive': 'flex-grow', 'value': 1},
    {'directive': 'grid-column', 'value': 'span 12'}
  ];
}