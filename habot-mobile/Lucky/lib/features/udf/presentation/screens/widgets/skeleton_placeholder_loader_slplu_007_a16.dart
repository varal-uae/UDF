// SLPLU-007-A16 — Skeleton Placeholder Loader with Error Alerts and Touch Blocking.
// Implements Material 3 skeleton loading states, 10-second latency error alerts, touch blocking during load, and responsive vertical list layout.

import 'dart:async';
import 'package:flutter/material.dart';

/// Atomic-level data model for step execution tracking.
class StepExecutionData {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;

  const StepExecutionData({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
  });
}

/// Mock repository providing local dummy data to simulate network delay.
class MockSkeletonRepository {
  Future<List<StepExecutionData>> fetchExecutionSteps() async {
    // Simulate network latency. Change duration to test >10s threshold alert.
    await Future.delayed(const Duration(seconds: 3));
    return [
      StepExecutionData(
        stepExecutionId: 'STEP-001',
        executionStatus: 'Completed',
        executionTimestamp: DateTime.now().subtract(const Duration(hours: 2)),
        stepOutcome: 'Success',
        userId: 'USR-9921',
      ),
      StepExecutionData(
        stepExecutionId: 'STEP-002',
        executionStatus: 'Pending',
        executionTimestamp: DateTime.now().subtract(const Duration(hours: 1)),
        stepOutcome: 'In Progress',
        userId: 'USR-9922',
      ),
      StepExecutionData(
        stepExecutionId: 'STEP-003',
        executionStatus: 'Failed',
        executionTimestamp: DateTime.now(),
        stepOutcome: 'Timeout',
        userId: 'USR-9923',
      ),
    ];
  }
}

/// Master Skeleton Box Unit implementing SLPLU-007-A16 requirements.
/// Features: Soft neutral colors, uniform animation, sized blocks matching text,
/// touch blocking during load, red alert on >10s latency, responsive vertical list.
class SkeletonPlaceholderLoader extends StatefulWidget {
  const SkeletonPlaceholderLoader({super.key});

  @override
  State<SkeletonPlaceholderLoader> createState() => _SkeletonPlaceholderLoaderState();
}

class _SkeletonPlaceholderLoaderState extends State<SkeletonPlaceholderLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _shimmerAnimation;
  
  List<StepExecutionData>? _data;
  bool _isLoading = true;
  bool _hasLatencyError = false;
  Timer? _latencyTimer;

  final MockSkeletonRepository _repository = MockSkeletonRepository();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadData();
  }

  void _loadData() {
    setState(() {
      _isLoading = true;
      _hasLatencyError = false;
    });

    // Program automatic error alerts to fire immediately if latency passes 10 seconds
    _latencyTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && _isLoading) {
        setState(() {
          _hasLatencyError = true;
        });
      }
    });

    _repository.fetchExecutionSteps().then((result) {
      _latencyTimer?.cancel();
      if (mounted) {
        setState(() {
          _data = result;
          _isLoading = false;
          _hasLatencyError = false;
        });
      }
    }).catchError((_) {
      _latencyTimer?.cancel();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasLatencyError = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _latencyTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mistake-Proofing (Poka-Yoke): Freeze touch fields while loading graphics are active
    return AbsorbPointer(
      absorbing: _isLoading,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Query Execution Steps'),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        body: Stack(
          children: [
            _isLoading ? _buildSkeletonList(context) : _buildDataList(context),
            if (_hasLatencyError) _buildLatencyAlert(context),
          ],
        ),
      ),
    );
  }

  /// Builds the pulsing skeleton placeholders sized to match coming text dimensions.
  Widget _buildSkeletonList(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            // Material 3 Outlined Card containers isolate individual operational date selections
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title placeholder
                    Container(
                      height: 16,
                      width: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                        color: _hasLatencyError
                            ? Colors.red.withOpacity(_shimmerAnimation.value)
                            : theme.colorScheme.surfaceContainerHighest
                                .withOpacity(_shimmerAnimation.value),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle placeholder
                    Container(
                      height: 14,
                      width: MediaQuery.of(context).size.width * 0.7,
                      decoration: BoxDecoration(
                        color: _hasLatencyError
                            ? Colors.red.withOpacity(_shimmerAnimation.value * 0.7)
                            : theme.colorScheme.surfaceContainerHighest
                                .withOpacity(_shimmerAnimation.value * 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Detail placeholder
                    Container(
                      height: 14,
                      width: MediaQuery.of(context).size.width * 0.5,
                      decoration: BoxDecoration(
                        color: _hasLatencyError
                            ? Colors.red.withOpacity(_shimmerAnimation.value * 0.5)
                            : theme.colorScheme.surfaceContainerHighest
                                .withOpacity(_shimmerAnimation.value * 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Builds the resolved clean text rows as data resolves.
  Widget _buildDataList(BuildContext context) {
    if (_data == null || _data!.isEmpty) {
      return const Center(child: Text('No execution steps found.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: _data!.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _data![index];
        // Interactive states apply standard component container padding and shadow elevation specs
        return Card(
          elevation: 1.0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label text scales follow standard system typography parameters (md.sys.typescale.body-medium)
                Text(
                  'Step ID: ${item.stepExecutionId}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Status: ${item.executionStatus}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Outcome: ${item.stepOutcome}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'User: ${item.userId} | Time: ${item.executionTimestamp.hour}:${item.executionTimestamp.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Red alert overlay if connections fail or latency exceeds 10 seconds.
  Widget _buildLatencyAlert(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Material(
        elevation: 4,
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.red.shade700,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Network latency exceeded 10s threshold. Connection unstable.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 18),
                onPressed: () {
                  setState(() => _hasLatencyError = false);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Explicit one-line validation rule function verifying only ZIP code formatting rules.
/// Included per Setup Step (Action).1 requirement mapping.
bool validateZipCodeFormat(String zipCode) {
  return RegExp(r'^\d{5}(-\d{4})?$').hasMatch(zipCode);
}

/// Threshold-Based Alert Banding Accuracy Evaluator.
enum AlertBand { earlyWarning, elevatedWarning, criticalHardStop }

AlertBand evaluateThresholdBanding(double accuracyPercentage) {
  if (accuracyPercentage >= 100.0) return AlertBand.criticalHardStop;
  if (accuracyPercentage >= 85.0) return AlertBand.elevatedWarning;
  if (accuracyPercentage >= 70.0) return AlertBand.earlyWarning;
  return AlertBand.earlyWarning; // Fallback below floor boundary
}
