// SLPLU-003-A10 — Asynchronous BigQuery Skeleton Loaders with Shimmer Animation.
// Implements MD3-compliant skeleton placeholders that map to expected content bounding boxes, featuring shimmer animations, fade transitions, input blocking during loading, and automatic timeout error banners.

import 'dart:async';
import 'package:flutter/material.dart';

/// Configuration for the skeleton loader behavior.
class SkeletonConfig {
  final Duration shimmerDuration;
  final Duration fadeDuration;
  final Duration timeoutThreshold;
  final Color baseColor;
  final Color highlightColor;

  const SkeletonConfig({
    this.shimmerDuration = const Duration(milliseconds: 1500),
    this.fadeDuration = const Duration(milliseconds: 400),
    this.timeoutThreshold = const Duration(seconds: 15),
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });
}

/// A widget that displays a skeleton placeholder with shimmer animation,
/// blocks user interaction while loading, fades into actual content upon resolution,
/// and shows an error banner if the operation times out.
class AsyncSkeletonLoader<T> extends StatefulWidget {
  /// The future representing the asynchronous data fetch (e.g., BigQuery streaming tap).
  final Future<T> future;

  /// Builder for the skeleton placeholder UI matching anticipated content bounding boxes.
  final WidgetBuilder skeletonBuilder;

  /// Builder for the actual content once data resolves successfully.
  final Widget Function(BuildContext context, T data) contentBuilder;

  /// Optional custom error builder. Defaults to an MD3-styled timeout/error banner.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Configuration for shimmer, fade, and timeout behaviors.
  final SkeletonConfig config;

  const AsyncSkeletonLoader({
    super.key,
    required this.future,
    required this.skeletonBuilder,
    required this.contentBuilder,
    this.errorBuilder,
    this.config = const SkeletonConfig(),
  });

  @override
  State<AsyncSkeletonLoader<T>> createState() => _AsyncSkeletonLoaderState<T>();
}

class _AsyncSkeletonLoaderState<T> extends State<AsyncSkeletonLoader<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnimation;
  Timer? _timeoutTimer;
  bool _isTimedOut = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: widget.config.shimmerDuration,
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOutSine),
    );

    _startTimeoutTimer();
    _resolveFuture();
  }

  void _startTimeoutTimer() {
    _timeoutTimer = Timer(widget.config.timeoutThreshold, () {
      if (mounted) {
        setState(() {
          _isTimedOut = true;
          _error = TimeoutException('BigQuery streaming tap failed to resolve past threshold.');
        });
      }
    });
  }

  Future<void> _resolveFuture() async {
    try {
      await widget.future;
      _timeoutTimer?.cancel();
      if (mounted && !_isTimedOut) {
        // FutureBuilder handles the transition; we just ensure timer is cancelled.
      }
    } catch (e) {
      _timeoutTimer?.cancel();
      if (mounted) {
        setState(() {
          _error = e;
        });
      }
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: widget.future,
      builder: (context, snapshot) {
        // If timed out or errored before completion
        if (_isTimedOut || (_error != null && snapshot.connectionState != ConnectionState.done)) {
          return _buildErrorBanner(context);
        }

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return _buildErrorBanner(context);
          }
          if (snapshot.hasData) {
            return _buildFadeTransition(
              child: widget.contentBuilder(context, snapshot.data as T),
            );
          }
        }

        // Loading state: wrap in IgnorePointer to prevent taps/double-submits
        return IgnorePointer(
          ignoring: true,
          child: AnimatedBuilder(
            animation: _shimmerAnimation,
            builder: (context, child) {
              return ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
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
                    tileMode: TileMode.clamp,
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcATop,
                child: child,
              );
            },
            child: widget.skeletonBuilder(context),
          ),
        );
      },
    );
  }

  Widget _buildFadeTransition({required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: widget.config.fadeDuration,
      curve: Curves.easeInOut,
      builder: (context, opacity, child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: child,
    );
  }

  Widget _buildErrorBanner(BuildContext context) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, _error ?? Exception('Unknown error'));
    }

    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.errorContainer,
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: theme.colorScheme.onErrorContainer,
              size: 24.0,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Data Unavailable',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'The request took too long to complete. Please check your connection and try again.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable generic skeleton block container layout modifier.
/// Maps perfectly to the boundary configurations of expected components.
class SkeletonBlock extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonBlock({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white, // Shimmer ShaderMask will override this visually
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Pre-built MD3 standard skeleton layout for list items/cards.
class SkeletonListItem extends StatelessWidget {
  const SkeletonListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBlock(
            width: 56.0,
            height: 56.0,
            borderRadius: 28.0,
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBlock(height: 14.0, width: 180.0, margin: EdgeInsets.only(bottom: 8.0)),
                SkeletonBlock(height: 12.0, width: double.infinity, margin: EdgeInsets.only(bottom: 6.0)),
                SkeletonBlock(height: 12.0, width: 120.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mock repository simulating BigQuery asynchronous fetch delays.
class MockBigQueryRepository {
  /// Simulates a successful data fetch with artificial delay.
  static Future<List<Map<String, dynamic>>> fetchAnalyticalRecords({
    Duration delay = const Duration(seconds: 3),
  }) async {
    await Future.delayed(delay);
    return [
      {'id': '1', 'title': 'Q3 Revenue Analysis', 'status': 'Completed', 'timestamp': '2026-09-25T10:00:00Z'},
      {'id': '2', 'title': 'User Retention Metrics', 'status': 'Processing', 'timestamp': '2026-09-25T10:05:00Z'},
      {'id': '3', 'title': 'Infrastructure Cost Report', 'status': 'Completed', 'timestamp': '2026-09-25T10:12:00Z'},
    ];
  }

  /// Simulates a timeout scenario for testing error banner self-chasing.
  static Future<List<Map<String, dynamic>>> fetchWithTimeout() async {
    await Future.delayed(const Duration(seconds: 20));
    return [];
  }
}

/// Example usage demonstrating integration within the UDF feature screens.
class SkeletonLoaderDemoScreen extends StatelessWidget {
  const SkeletonLoaderDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skeleton Loader Demo'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return AsyncSkeletonLoader<List<Map<String, dynamic>>>(
            future: MockBigQueryRepository.fetchAnalyticalRecords(
              delay: Duration(seconds: 2 + index),
            ),
            config: SkeletonConfig(
              baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              highlightColor: Theme.of(context).colorScheme.surface,
              timeoutThreshold: const Duration(seconds: 10),
            ),
            skeletonBuilder: (context) => const SkeletonListItem(),
            contentBuilder: (context, data) {
              final item = data.isNotEmpty ? data.first : <String, dynamic>{};
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(item['id']?.toString() ?? '?'),
                ),
                title: Text(item['title']?.toString() ?? 'Untitled'),
                subtitle: Text(item['status']?.toString() ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
