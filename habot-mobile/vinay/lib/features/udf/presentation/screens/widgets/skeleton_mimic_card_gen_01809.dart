// GEN-01809 — Structural Mimic Skeleton Widget for Data Fetch Latency Elimination.
// Displays M3 Elevated Card skeleton placeholders instantly during data fetches to eliminate perceived latency. Single-column on mobile (<600dp), multi-column on desktop (>=840dp). 48x48dp touch targets. Material You dynamic color.

import 'package:flutter/material.dart';

/// Mock data representing step completion states for local rendering
/// when backend API is unavailable or during initial load.
class _MockStepData {
  final String id;
  final String name;
  final String status; // 'Complete', 'Partial', 'Not Complete'
  final double completionRate;

  const _MockStepData({
    required this.id,
    required this.name,
    required this.status,
    required this.completionRate,
  });
}

const List<_MockStepData> _mockSteps = [
  _MockStepData(id: 'GEN-01808', name: 'Foundational Setup', status: 'Complete', completionRate: 100.0),
  _MockStepData(id: 'GEN-01809', name: 'Structural Mimics Display', status: 'Partial', completionRate: 75.0),
  _MockStepData(id: 'GEN-01810', name: 'Telemetry Streaming', status: 'Not Complete', completionRate: 0.0),
];

/// A widget that displays structural mimics (skeleton loaders) inside M3 Elevated Cards.
/// Used during data fetches to provide instant visual feedback and eliminate perceived latency.
class SkeletonMimicCardGen01809 extends StatelessWidget {
  const SkeletonMimicCardGen01809({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDesktop = MediaQuery.sizeOf(context).width >= 840;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Engineering Console'),
        centerTitle: false,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Simulates pull-to-refresh manual sync
          await Future.delayed(const Duration(seconds: 1));
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    if (index < _mockSteps.length) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildMimicCard(
                          context,
                          _mockSteps[index],
                          colorScheme,
                          isDesktop,
                        ),
                      );
                    }
                    // Additional skeleton placeholders while "loading"
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildSkeletonPlaceholder(colorScheme),
                    );
                  },
                  childCount: _mockSteps.length + 3, // 3 extra skeleton mimics
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMimicCard(
    BuildContext context,
    _MockStepData step,
    ColorScheme colorScheme,
    bool isDesktop,
  ) {
    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          // Deep-link drill-down interaction placeholder
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Drill-down triggered for ${step.id}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Status Chip
              _buildStatusChip(step.status, colorScheme),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'ID: ${step.id}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8.0),
                    // Completion Rate Indicator
                    LinearProgressIndicator(
                      value: step.completionRate / 100.0,
                      minHeight: 4.0,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        step.completionRate >= 90
                            ? colorScheme.primary
                            : colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '${step.completionRate.toStringAsFixed(0)}% Completion',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              // 48x48dp touch target icon
              SizedBox(
                width: 48.0,
                height: 48.0,
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  iconSize: 24.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ColorScheme colorScheme) {
    Color chipColor;
    IconData icon;

    switch (status) {
      case 'Complete':
        chipColor = colorScheme.primaryContainer;
        icon = Icons.check_circle_outline;
        break;
      case 'Partial':
        chipColor = colorScheme.tertiaryContainer;
        icon = Icons.pending_outlined;
        break;
      case 'Not Complete':
      default:
        chipColor = colorScheme.errorContainer;
        icon = Icons.cancel_outlined;
        break;
    }

    return Chip(
      avatar: Icon(icon, size: 18.0, color: colorScheme.onSurface),
      label: Text(status),
      backgroundColor: chipColor,
      labelStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  /// Structural mimic skeleton placeholder rendered instantly during data fetches.
  Widget _buildSkeletonPlaceholder(ColorScheme colorScheme) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80.0,
              height: 32.0,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16.0,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: 120.0,
                    height: 12.0,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Container(
                    width: double.infinity,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16.0),
            Container(
              width: 48.0,
              height: 48.0,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}