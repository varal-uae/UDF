// GEN-03849 — UI Component Folder Health Dashboard Widget.
// Displays M3 Elevated Cards with step completion state, health indicators, and mock telemetry data for the mobile engineering console.

import 'package:flutter/material.dart';

/// Mock data representing UI Resource Resolution metrics.
class _MockTelemetryData {
  final String stepId;
  final String stepName;
  final String status;
  final double resolutionTimeMs;
  final DateTime timestamp;

  const _MockTelemetryData({
    required this.stepId,
    required this.stepName,
    required this.status,
    required this.resolutionTimeMs,
    required this.timestamp,
  });
}

const List<_MockTelemetryData> _mockSteps = [
  _MockTelemetryData(
    stepId: 'GEN-03848',
    stepName: 'Foundational Baseline Configuration',
    status: 'Complete',
    resolutionTimeMs: 45.2,
    timestamp: null as dynamic,
  ),
  _MockTelemetryData(
    stepId: 'GEN-03849',
    stepName: 'Open Mobile UI Component Folder',
    status: 'Complete',
    resolutionTimeMs: 82.1,
    timestamp: null as dynamic,
  ),
];

/// A Material 3 compliant widget that displays the health and completion
/// state of UI component folder steps in a single-column mobile layout.
class UiComponentFolderDashboardGen03849 extends StatefulWidget {
  const UiComponentFolderDashboardGen03849({super.key});

  @override
  State<UiComponentFolderDashboardGen03849> createState() =>
      _UiComponentFolderDashboardGen03849State();
}

class _UiComponentFolderDashboardGen03849State
    extends State<UiComponentFolderDashboardGen03849> {
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    // Simulate background polling / manual sync delay
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Component Folder'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Runbook Documentation',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Documentation committed to runbook.'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp)
            final bool isDesktop = constraints.maxWidth >= 840;
            final int crossAxisCount = isDesktop ? 2 : 1;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: isDesktop ? 2.5 : 3.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final _MockTelemetryData data = _mockSteps[index];
                        return _StepHealthCard(
                          data: data,
                          colorScheme: colorScheme,
                        );
                      },
                      childCount: _mockSteps.length,
                    ),
                  ),
                ),
                if (_isRefreshing)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StepHealthCard extends StatelessWidget {
  final _MockTelemetryData data;
  final ColorScheme colorScheme;

  const _StepHealthCard({
    required this.data,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final bool isComplete = data.status == 'Complete';
    final bool isOptimal = data.resolutionTimeMs < 100.0;
    final bool isWithinFloor = data.resolutionTimeMs < 1000.0;

    Color chipColor;
    String chipLabel;

    if (isComplete && isOptimal) {
      chipColor = colorScheme.primary;
      chipLabel = 'Optimal';
    } else if (isComplete && isWithinFloor) {
      chipColor = colorScheme.tertiary;
      chipLabel = 'Within Floor';
    } else if (isComplete) {
      chipColor = colorScheme.error;
      chipLabel = 'Above Ceiling';
    } else {
      chipColor = colorScheme.outline;
      chipLabel = 'Incomplete';
    }

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          // Deep-link drill-down simulation
          showModalBottomSheet(
            context: context,
            useMaterial3: true,
            builder: (BuildContext ctx) {
              return _ConfigurationBottomSheet(data: data);
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      data.stepId,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                  Chip(
                    label: Text(chipLabel),
                    backgroundColor: chipColor.withOpacity(0.12),
                    labelStyle: TextStyle(color: chipColor, fontSize: 12),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                data.stepName,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16.0,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    '${data.resolutionTimeMs.toStringAsFixed(1)} ms',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    data.status,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isComplete
                              ? colorScheme.primary
                              : colorScheme.error,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// M3 Bottom Sheet for configuration inputs and deep-link drill-down details.
class _ConfigurationBottomSheet extends StatelessWidget {
  final _MockTelemetryData data;

  const _ConfigurationBottomSheet({required this.data});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Step Details: ${data.stepId}',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            Text(
              data.stepName,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24.0),
            ListTile(
              leading: Icon(Icons.speed, color: theme.colorScheme.primary),
              title: const Text('UI Resource Resolution Time'),
              subtitle: Text('${data.resolutionTimeMs} ms'),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading:
                  Icon(Icons.check_circle, color: theme.colorScheme.primary),
              title: const Text('Completion Status'),
              subtitle: Text(data.status),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading:
                  Icon(Icons.rule_folder, color: theme.colorScheme.primary),
              title: const Text('Standard Reference'),
              subtitle: const Text('Flutter Widget Guidelines (Adapted from React Native)'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              height: 48.0, // 48x48dp touch targets
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}