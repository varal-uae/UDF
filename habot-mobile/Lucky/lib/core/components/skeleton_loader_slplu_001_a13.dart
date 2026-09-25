// SLPLU-001-A13 — Global Skeleton Loader with 10s Timeout Error Fallback.
// Provides animated shimmer skeleton widgets that match final container dimensions, auto-transitioning to an interactive retry state after a 10-second timeout.

import 'dart:async';
import 'package:flutter/material.dart';

/// Configuration for the skeleton loader behavior.
class SkeletonConfig {
  final Duration timeoutDuration;
  final Color baseColor;
  final Color highlightColor;

  const SkeletonConfig({
    this.timeoutDuration = const Duration(seconds: 10),
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });
}

/// A global skeleton loader widget that displays a shimmer effect while data is loading.
/// If the loading exceeds the configured timeout (default 10s), it automatically transitions
/// to an interactive error fallback state guiding the user to retry.
class SkeletonLoader extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final double width;
  final double height;
  final BorderRadiusGeometry borderRadius;
  final SkeletonConfig config;
  final VoidCallback? onRetry;

  const SkeletonLoader({
    super.key,
    required this.isLoading,
    required this.child,
    this.width = double.infinity,
    this.height = 20.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.config = const SkeletonConfig(),
    this.onRetry,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shimmerAnimation;
  Timer? _timeoutTimer;
  bool _isTimedOut = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOutSine),
    );

    if (widget.isLoading) {
      _startLoading();
    }
  }

  void _startLoading() {
    setState(() {
      _isTimedOut = false;
    });
    _animationController.repeat(reverse: true);
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(widget.config.timeoutDuration, () {
      if (mounted && widget.isLoading) {
        setState(() {
          _isTimedOut = true;
        });
        _animationController.stop();
      }
    });
  }

  @override
  void didUpdateWidget(covariant SkeletonLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _startLoading();
      } else {
        _stopLoading();
      }
    }
  }

  void _stopLoading() {
    _timeoutTimer?.cancel();
    _animationController.stop();
    _animationController.reset();
    setState(() {
      _isTimedOut = false;
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    if (_isTimedOut) {
      return _buildTimeoutFallback();
    }

    return _buildShimmerSkeleton();
  }

  Widget _buildShimmerSkeleton() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.config.baseColor,
                widget.config.highlightColor,
                widget.config.baseColor,
              ],
              stops: [
                0.0,
                _shimmerAnimation.value.clamp(0.0, 1.0),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeoutFallback() {
    final theme = Theme.of(context);
    return Container(
      width: widget.width,
      height: widget.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: widget.borderRadius,
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.5),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onRetry ?? () {},
          borderRadius: widget.borderRadius.resolve(Directionality.of(context)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: theme.colorScheme.error,
                  size: 18.0,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'Query Timeout - Retry',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A composite skeleton layout mimicking a standard chart/widget card structure.
/// Dimensions perfectly match final data containers to prevent wild layout shifts.
class ChartCardSkeleton extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final VoidCallback? onRetry;

  const ChartCardSkeleton({
    super.key,
    required this.isLoading,
    required this.child,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      isLoading: isLoading,
      onRetry: onRetry,
      height: 240.0,
      borderRadius: BorderRadius.circular(12.0),
      child: child,
    );
  }
}

/// A list item skeleton for tabular or list-based UDF data representations.
class ListItemSkeleton extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final VoidCallback? onRetry;

  const ListItemSkeleton({
    super.key,
    required this.isLoading,
    required this.child,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      isLoading: isLoading,
      onRetry: onRetry,
      height: 64.0,
      borderRadius: BorderRadius.circular(8.0),
      child: child,
    );
  }
}

/// Mock data provider simulating BigQuery heavy aggregation fetches.
class MockUdfDataProvider {
  static Future<List<Map<String, dynamic>>> fetchChartData() async {
    // Simulate network latency; change to >10s to test timeout fallback
    await Future.delayed(const Duration(seconds: 3));
    return [
      {'timestamp': '2026-09-25T10:00:00Z', 'value': 42.5, 'status': 'normal'},
      {'timestamp': '2026-09-25T11:00:00Z', 'value': 85.2, 'status': 'breached'},
      {'timestamp': '2026-09-25T12:00:00Z', 'value': 31.0, 'status': 'normal'},
    ];
  }
}
