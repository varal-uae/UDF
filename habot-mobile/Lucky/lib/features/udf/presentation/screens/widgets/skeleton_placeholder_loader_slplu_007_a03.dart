// SLPLU-007-A03 — Skeleton Placeholder Loader Framework for Query Panels.
// Provides Material 3 compliant skeleton loading states with touch blocking, error state transitions, and responsive layout sizing to prevent layout shifts during data resolution.

import 'package:flutter/material.dart';

/// Enum representing the current execution status of the query placeholder.
enum SkeletonExecutionStatus {
  loading,
  success,
  error,
}

/// Data model representing the atomic-level execution fields required by SLPLU-007-A03.
class SkeletonStepExecutionData {
  final String stepExecutionId;
  final SkeletonExecutionStatus executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;

  const SkeletonStepExecutionData({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
  });
}

/// Master Skeleton Box Unit. Reusable component stored in Shared Front-End UI Repository context.
/// Implements Material 3 Outlined Card containers, standard typography (body-medium),
/// and blocks accidental clicks while loading graphics are active.
class SkeletonPlaceholderLoader extends StatelessWidget {
  final SkeletonExecutionStatus status;
  final int itemCount;
  final VoidCallback? onRetry;

  const SkeletonPlaceholderLoader({
    super.key,
    this.status = SkeletonExecutionStatus.loading,
    this.itemCount = 5,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      // Poka-Yoke: Freezes touch fields while loading graphics are active to block accidental clicks.
      ignoring: status == SkeletonExecutionStatus.loading,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        itemCount: itemCount,
        separatorBuilder: (context, index) => const SizedBox(height: 12.0),
        itemBuilder: (context, index) {
          return _SkeletonCard(
            status: status,
            onRetry: onRetry,
          );
        },
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final SkeletonExecutionStatus status;
  final VoidCallback? onRetry;

  const _SkeletonCard({
    required this.status,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Self-Chasing: Changes placeholder graphics to red alert alerts if connections fail.
    final Color baseColor = status == SkeletonExecutionStatus.error
        ? colorScheme.errorContainer
        : colorScheme.surfaceContainerHighest;
    final Color highlightColor = status == SkeletonExecutionStatus.error
        ? colorScheme.error.withValues(alpha: 0.3)
        : colorScheme.surface.withValues(alpha: 0.6);

    return Card(
      // Material 3 Outlined Card containers isolate individual operational date selections.
      variant: CardVariant.outlined,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: status == SkeletonExecutionStatus.error
              ? colorScheme.error
              : colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        // Interactive states apply standard component container padding specs.
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Skeleton Block
            _ShimmerBlock(
              width: 140.0,
              height: 16.0,
              baseColor: baseColor,
              highlightColor: highlightColor,
              isActive: status == SkeletonExecutionStatus.loading,
            ),
            const SizedBox(height: 12.0),
            // Body Text Line 1 - Sized to match coming text dimensions
            _ShimmerBlock(
              width: double.infinity,
              height: 14.0,
              baseColor: baseColor,
              highlightColor: highlightColor,
              isActive: status == SkeletonExecutionStatus.loading,
            ),
            const SizedBox(height: 8.0),
            // Body Text Line 2
            _ShimmerBlock(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 14.0,
              baseColor: baseColor,
              highlightColor: highlightColor,
              isActive: status == SkeletonExecutionStatus.loading,
            ),
            if (status == SkeletonExecutionStatus.error) ...[
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: colorScheme.error,
                    size: 20.0,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'Connection failed. Tap to retry.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                  if (onRetry != null)
                    TextButton(
                      onPressed: onRetry,
                      child: const Text('Retry'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Calm, shifting blocks that change into clean text rows as data resolves.
/// Maintains uniform animation parameters across app areas.
class _ShimmerBlock extends StatefulWidget {
  final double width;
  final double height;
  final Color baseColor;
  final Color highlightColor;
  final bool isActive;

  const _ShimmerBlock({
    required this.width,
    required this.height,
    required this.baseColor,
    required this.highlightColor,
    required this.isActive,
  });

  @override
  State<_ShimmerBlock> createState() => _ShimmerBlockState();
}

class _ShimmerBlockState extends State<_ShimmerBlock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _ShimmerBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.baseColor,
          borderRadius: BorderRadius.circular(4.0),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Mock repository providing realistic local mock data directly inside the generated file.
/// Used to simulate backend data fetching delays across network endpoints cleanly.
class MockSkeletonQueryRepository {
  static List<SkeletonStepExecutionData> getMockExecutionSteps() {
    return [
      const SkeletonStepExecutionData(
        stepExecutionId: 'STEP-001',
        executionStatus: SkeletonExecutionStatus.loading,
        executionTimestamp: null,
        stepOutcome: 'PENDING',
        userId: 'USR-MOBILE-992',
      ),
      const SkeletonStepExecutionData(
        stepExecutionId: 'STEP-002',
        executionStatus: SkeletonExecutionStatus.success,
        executionTimestamp: null,
        stepOutcome: 'RESOLVED',
        userId: 'USR-MOBILE-992',
      ),
      const SkeletonStepExecutionData(
        stepExecutionId: 'STEP-003',
        executionStatus: SkeletonExecutionStatus.error,
        executionTimestamp: null,
        stepOutcome: 'TIMEOUT',
        userId: 'USR-MOBILE-992',
      ),
    ];
  }

  /// Simulates a network delay resolving into actual data.
  Future<List<SkeletonStepExecutionData>> fetchQueryData() async {
    await Future.delayed(const Duration(seconds: 3));
    return getMockExecutionSteps().map((e) {
      return SkeletonStepExecutionData(
        stepExecutionId: e.stepExecutionId,
        executionStatus: SkeletonExecutionStatus.success,
        executionTimestamp: DateTime.now(),
        stepOutcome: 'COMPLETED',
        userId: e.userId,
      );
    }).toList();
  }
}

/// Usage Example / Preview Wrapper for SLPLU-007-A03
class SkeletonQueryPanelScreen extends StatefulWidget {
  const SkeletonQueryPanelScreen({super.key});

  @override
  State<SkeletonQueryPanelScreen> createState() =>
      _SkeletonQueryPanelScreenState();
}

class _SkeletonQueryPanelScreenState extends State<SkeletonQueryPanelScreen> {
  SkeletonExecutionStatus _currentStatus = SkeletonExecutionStatus.loading;
  final MockSkeletonQueryRepository _repository = MockSkeletonQueryRepository();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _currentStatus = SkeletonExecutionStatus.loading);
    try {
      await _repository.fetchQueryData();
      if (mounted) {
        setState(() => _currentStatus = SkeletonExecutionStatus.success);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _currentStatus = SkeletonExecutionStatus.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Query Panel Skeleton'),
      ),
      body: _currentStatus == SkeletonExecutionStatus.success
          ? const Center(
              child: Text('Data Resolved Successfully'),
            )
          : SkeletonPlaceholderLoader(
              status: _currentStatus,
              itemCount: 6,
              onRetry: _loadData,
            ),
    );
  }
}