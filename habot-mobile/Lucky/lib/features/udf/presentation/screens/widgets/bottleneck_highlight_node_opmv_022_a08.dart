// OPMV-022-A08 — Bottleneck Highlight Node & Delay Visualization Wrapper.
// Provides a Material 3 compliant widget for visualizing pipeline latency and processing bottlenecks with mock data, responsive layout, and strict design token usage.

import 'package:flutter/material.dart';

/// Mock data model representing a step execution in the pipeline.
class StepExecutionMock {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final int delayMs;

  const StepExecutionMock({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.delayMs,
  });
}

/// Hardcoded mock repository simulating backend data lakehouse responses.
class BottleneckMockRepository {
  static const List<StepExecutionMock> steps = [
    StepExecutionMock(
      stepExecutionId: 'STEP-001',
      executionStatus: 'CRITICAL',
      executionTimestamp: null as dynamic,
      stepOutcome: 'Timeout exceeded threshold',
      userId: 'USR-992',
      delayMs: 4500,
    ),
    StepExecutionMock(
      stepExecutionId: 'STEP-002',
      executionStatus: 'WARNING',
      executionTimestamp: null as dynamic,
      stepOutcome: 'Processing cost elevated',
      userId: 'USR-104',
      delayMs: 1200,
    ),
    StepExecutionMock(
      stepExecutionId: 'STEP-003',
      executionStatus: 'HEALTHY',
      executionTimestamp: null as dynamic,
      stepOutcome: 'Completed within SLA',
      userId: 'USR-331',
      delayMs: 150,
    ),
  ];

  // Re-initialize timestamps dynamically since const doesn't allow DateTime.now()
  static List<StepExecutionMock> getLiveSteps() {
    final now = DateTime.now();
    return steps.map((s) => StepExecutionMock(
      stepExecutionId: s.stepExecutionId,
      executionStatus: s.executionStatus,
      executionTimestamp: now.subtract(Duration(milliseconds: s.delayMs)),
      stepOutcome: s.stepOutcome,
      userId: s.userId,
      delayMs: s.delayMs,
    )).toList();
  }
}

/// Design system tokens enforcing corporate color style standards (No local overrides).
class BottleneckDesignTokens {
  static Color criticalColor(BuildContext context) => Theme.of(context).colorScheme.error;
  static Color warningColor(BuildContext context) => Theme.of(context).colorScheme.tertiary;
  static Color healthyColor(BuildContext context) => Theme.of(context).colorScheme.primary;
  
  static Color getStatusColor(BuildContext context, String status) {
    switch (status.toUpperCase()) {
      case 'CRITICAL':
        return criticalColor(context);
      case 'WARNING':
        return warningColor(context);
      case 'HEALTHY':
      default:
        return healthyColor(context);
    }
  }

  static TextStyle metricTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall!.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle titleTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.bold,
    );
  }
}

/// The core reusable bottleneck visualization component.
/// Transferable across tracks as a separate design token component.
class BottleneckHighlightNode extends StatelessWidget {
  final StepExecutionMock step;

  const BottleneckHighlightNode({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = BottleneckDesignTokens.getStatusColor(context, step.executionStatus);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    step.stepExecutionId,
                    style: BottleneckDesignTokens.titleTextStyle(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    step.executionStatus,
                    style: BottleneckDesignTokens.metricTextStyle(context).copyWith(
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              step.stepOutcome,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            // Flexbox typography settings to prevent numerical items from horizontal clipping
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: _MetricBadge(
                    label: 'Delay',
                    value: '${step.delayMs}ms',
                    context: context,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _MetricBadge(
                    label: 'User',
                    value: step.userId,
                    context: context,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final String label;
  final String value;
  final BuildContext context;

  const _MetricBadge({
    required this.label,
    required this.value,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: BottleneckDesignTokens.metricTextStyle(context),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Algorithmic delay visualization wrapper inside the platform overview maps.
/// Enforces automated, data-driven bottleneck mapping and clean grid sizing metrics.
class DelayVisualizationWrapper extends StatelessWidget {
  const DelayVisualizationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = BottleneckMockRepository.getLiveSteps();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pipeline Latency Overview'),
        centerTitle: false,
        actions: [
          // Position critical "Override Exception" input controls within clear vertical thumb accessibility grids
          IconButton(
            icon: const Icon(Icons.settings_backup_restore_rounded),
            tooltip: 'Override Exception',
            onPressed: () {
              // Action to trigger override exception modal
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Mobile-First: Consolidated metric visual items reflow fluidly across mobile views
            final isWide = constraints.maxWidth > 600;
            
            if (isWide) {
              return GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisExtent: 180,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  return BottleneckHighlightNode(step: steps[index]);
                },
              );
            }

            // Group related employee profiles/steps into clear Material card layout stacks to conserve viewport space
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                return BottleneckHighlightNode(step: steps[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
