// OPMV-022-A13 — Bottleneck Highlight Node & Algorithmic Delay Visualization Wrapper.
// Renders pipeline latency metrics using Material 3 design tokens, enforces mobile-first responsive grids,
// hides ambient navigation during visual isolation, and triggers red alerts for simulated delays.

import 'package:flutter/material.dart';

enum ExecutionStatus { pass, fail, pending }

class StepExecutionRecord {
  final String stepExecutionId;
  final ExecutionStatus executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final double latencySeconds;

  const StepExecutionRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.latencySeconds,
  });
}

/// Mock data simulating backend BigQuery analytic pipeline responses.
final List<StepExecutionRecord> mockPipelineRecords = [
  const StepExecutionRecord(
    stepExecutionId: 'STEP-001',
    executionStatus: ExecutionStatus.pass,
    executionTimestamp: DateTime(2026, 9, 23, 10, 15),
    stepOutcome: 'Completed within optimal target',
    userId: 'USR-8821',
    latencySeconds: 1.2,
  ),
  const StepExecutionRecord(
    stepExecutionId: 'STEP-002',
    executionStatus: ExecutionStatus.fail,
    executionTimestamp: DateTime(2026, 9, 23, 10, 16),
    stepOutcome: 'Ceiling boundary exceeded',
    userId: 'USR-8822',
    latencySeconds: 3.5,
  ),
  const StepExecutionRecord(
    stepExecutionId: 'STEP-003',
    executionStatus: ExecutionStatus.pass,
    executionTimestamp: DateTime(2026, 9, 23, 10, 17),
    stepOutcome: 'Fast interactive query',
    userId: 'USR-8823',
    latencySeconds: 0.8,
  ),
  const StepExecutionRecord(
    stepExecutionId: 'STEP-004',
    executionStatus: ExecutionStatus.pending,
    executionTimestamp: DateTime(2026, 9, 23, 10, 18),
    stepOutcome: 'Awaiting validation',
    userId: 'USR-8824',
    latencySeconds: 2.1,
  ),
];

class BottleneckHighlightNode extends StatefulWidget {
  final List<StepExecutionRecord> records;
  final bool isVisualIsolationActive;

  const BottleneckHighlightNode({
    super.key,
    this.records = const [],
    this.isVisualIsolationActive = false,
  });

  @override
  State<BottleneckHighlightNode> createState() => _BottleneckHighlightNodeState();
}

class _BottleneckHighlightNodeState extends State<BottleneckHighlightNode> {
  late List<StepExecutionRecord> _activeRecords;

  static const double floorBoundary = 1.0;
  static const double optimalTarget = 2.0;
  static const double ceilingBoundary = 3.0;

  @override
  void initState() {
    super.initState();
    _activeRecords = widget.records.isEmpty ? mockPipelineRecords : widget.records;
  }

  Color _getLatencyColor(double latency, ColorScheme colorScheme) {
    if (latency >= ceilingBoundary) {
      return colorScheme.error; // Stark red for immediate bottleneck visibility
    } else if (latency >= optimalTarget) {
      return colorScheme.tertiary; // Warning accent
    } else if (latency <= floorBoundary) {
      return colorScheme.primary;
    }
    return colorScheme.secondary;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    // Hide ambient application navigation controls when visual isolation tasks are active
    if (widget.isVisualIsolationActive) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: _buildContent(colorScheme, textTheme),
        ),
      );
    }

    return _buildContent(colorScheme, textTheme);
  }

  Widget _buildContent(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Override Exception control positioned for vertical thumb accessibility
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pipeline Latency Overview',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: () {
                  // Override Exception input control logic
                },
                icon: const Icon(Icons.warning_amber_rounded, size: 18),
                label: const Text('Override'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Clean grid sizing metrics layout view proportions
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final int crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 2.8,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                  ),
                  itemCount: _activeRecords.length,
                  itemBuilder: (context, index) {
                    final record = _activeRecords[index];
                    return _buildBottleneckCard(record, colorScheme, textTheme);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottleneckCard(
    StepExecutionRecord record,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final Color indicatorColor = _getLatencyColor(record.latencySeconds, colorScheme);
    final bool isCritical = record.latencySeconds >= ceilingBoundary;

    // Group related employee profiles into clear Material card layout stacks
    return Card(
      elevation: isCritical ? 4.0 : 1.0,
      color: isCritical ? colorScheme.errorContainer.withOpacity(0.3) : colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: indicatorColor,
          width: isCritical ? 2.0 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    record.stepExecutionId,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: indicatorColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    record.executionStatus.name.toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      color: indicatorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Implement clean flexbox typography settings to prevent numerical items from horizontal clipping
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Latency',
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${record.latencySeconds.toStringAsFixed(2)}s',
                          style: textTheme.headlineSmall?.copyWith(
                            color: indicatorColor,
                            fontWeight: FontWeight.bold,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User / Outcome',
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        '${record.userId} • ${record.stepOutcome}',
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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

/// Wrapper widget that handles algorithmic delay visualization and hides navigation
/// when visual isolation mode is triggered by critical bottlenecks.
class DelayVisualizationWrapper extends StatelessWidget {
  final Widget child;
  final bool hasCriticalBottlenecks;

  const DelayVisualizationWrapper({
    super.key,
    required this.child,
    this.hasCriticalBottlenecks = false,
  });

  @override
  Widget build(BuildContext context) {
    // Structural Poka-Yoke: Throws assertion error if component binds improperly
    assert(child != null, 'DelayVisualizationWrapper requires a valid child component');

    if (hasCriticalBottlenecks) {
      // Hide ambient application navigation controls when visual isolation tasks are active
      return Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              child,
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.05),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return child;
  }
}
