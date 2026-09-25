// SLPLU-008-A05 — AsyncFormSkeletonLoader with Material 3 Pulse Animation.
// Implements a reusable skeleton loading widget for lead generation forms with predictable rhythmic visual motion, blocked gesture interactions, and timeout retry handling.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data representing atomic-level lock fields required during form loading states.
class _MockLockData {
  final String lockType;
  final String lockStatus;
  final String lockedBy;
  final DateTime lockTimestamp;
  final String lockReason;

  const _MockLockData({
    required this.lockType,
    required this.lockStatus,
    required this.lockedBy,
    required this.lockTimestamp,
    required this.lockReason,
  });
}

const List<_MockLockData> mockLockRecords = [
  _MockLockData(
    lockType: 'FORM_EDIT',
    lockStatus: 'LOCKED',
    lockedBy: 'system_daemon',
    lockTimestamp: null as dynamic,
    lockReason: 'Progressive loading in progress',
  ),
];

/// A Material 3 compliant skeleton loader that applies a smooth pulse animation
/// to geometric placeholder blocks. Interactive gestures are completely blocked
/// across skeleton rows to prevent early form submissions (Poka-Yoke).
/// If the simulated query times out, it drops loading frames and shows an inline retry dialog.
class AsyncFormSkeletonLoader extends StatefulWidget {
  /// The expected number of text lines / field rows to render as skeletons.
  final int lineCount;

  /// Optional duration after which a timeout is triggered.
  final Duration timeoutDuration;

  /// Callback invoked when the user taps the retry button on timeout.
  final VoidCallback? onRetry;

  const AsyncFormSkeletonLoader({
    super.key,
    this.lineCount = 5,
    this.timeoutDuration = const Duration(seconds: 15),
    this.onRetry,
  });

  @override
  State<AsyncFormSkeletonLoader> createState() => _AsyncFormSkeletonLoaderState();
}

class _AsyncFormSkeletonLoaderState extends State<AsyncFormSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;
  Timer? _timeoutTimer;
  bool _isTimedOut = false;

  @override
  void initState() {
    super.initState();
    // Enforce identical motion timing curves across all loading states application-wide.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

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
    widget.onRetry?.call();
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

    // Use neutral, desaturated grey background container fills for placeholder blocks.
    final baseColor = colorScheme.surfaceContainerHighest.withOpacity(0.4);
    final highlightColor = colorScheme.surfaceContainer.withOpacity(0.7);

    return AbsorbPointer(
      // Poka-Yoke: Interactive gesture event listeners are blocked completely
      // across skeleton rows, preventing early form submissions.
      absorbing: true,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isTimedOut ? _buildTimeoutView(theme) : _buildSkeletonView(baseColor, highlightColor, theme),
      ),
    );
  }

  Widget _buildSkeletonView(Color baseColor, Color highlightColor, ThemeData theme) {
    return Container(
      key: const ValueKey('skeleton_view'),
      padding: const EdgeInsets.all(16.0),
      // Material 3 Outlined Text Field components enclose user parameter inputs.
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(widget.lineCount, (index) {
          // Set skeleton container heights to equal expected text line properties perfectly.
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: FadeTransition(
              opacity: _pulseAnimation,
              child: Container(
                height: 48.0, // Matches standard M3 OutlinedTextField height
                width: double.infinity,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimeoutView(ThemeData theme) {
    return Container(
      key: const ValueKey('timeout_view'),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.error.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12.0),
      ),
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
            'Network Timeout',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load form parameters. Please check your connection and try again.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          // Action trigger buttons utilize standard typography tokens.
          FilledButton.icon(
            onPressed: _handleRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry Connection'),
            style: FilledButton.styleFrom(
              textStyle: theme.textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}
