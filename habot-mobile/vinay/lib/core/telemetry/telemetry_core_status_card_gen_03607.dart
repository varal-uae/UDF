// GEN-03607 — Telemetry Core Library Package Status Card.
// M3 Elevated Card displaying the publish/store status of @habot/telemetry-core with mock SLA metrics, single-column mobile layout, and 48x48dp touch targets.

import 'package:flutter/material.dart';

/// Mock data representing the telemetry core package availability.
class _TelemetryCoreMockData {
  static const String packageName = '@habot/telemetry-core';
  static const String libraryName = '@habot/shared-library';
  static const double metricFloor = 0.999;
  static const double metricOptimal = 0.9999;
  static const double currentAvailability = 0.9999;
  static const String completionStatus = 'Pass';
  static const String lastSynced = '2026-09-28T10:00:00Z';
}

/// A Material 3 Elevated Card (Level 2, 3dp elevation) that displays
/// the health and completion state of the telemetry-core package step.
class TelemetryCoreStatusCardGen03607 extends StatelessWidget {
  const TelemetryCoreStatusCardGen03607({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPassing = _TelemetryCoreMockData.currentAvailability >= _TelemetryCoreMockData.metricFloor;

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAlias,
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
                    'Telemetry Core Package',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12.0),
                Chip(
                  avatar: Icon(
                    isPassing ? Icons.check_circle_outline : Icons.error_outline,
                    size: 18.0,
                    color: isPassing ? colorScheme.primary : colorScheme.error,
                  ),
                  label: Text(
                    isPassing ? 'PASS' : 'FAIL',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isPassing ? colorScheme.primary : colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: isPassing
                      ? colorScheme.primaryContainer.withOpacity(0.3)
                      : colorScheme.errorContainer.withOpacity(0.3),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            _buildInfoRow(
              context,
              label: 'Package',
              value: _TelemetryCoreMockData.packageName,
            ),
            const SizedBox(height: 8.0),
            _buildInfoRow(
              context,
              label: 'Common Library',
              value: _TelemetryCoreMockData.libraryName,
            ),
            const SizedBox(height: 8.0),
            _buildInfoRow(
              context,
              label: 'Availability SLA',
              value: '${(_TelemetryCoreMockData.currentAvailability * 100).toStringAsFixed(2)}%',
            ),
            const SizedBox(height: 8.0),
            _buildInfoRow(
              context,
              label: 'Target Floor',
              value: '${(_TelemetryCoreMockData.metricFloor * 100).toStringAsFixed(2)}%',
            ),
            const SizedBox(height: 8.0),
            _buildInfoRow(
              context,
              label: 'Completion Status',
              value: _TelemetryCoreMockData.completionStatus,
            ),
            const SizedBox(height: 16.0),
            Divider(color: colorScheme.outlineVariant, thickness: 1.0),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last Synced: ${_TelemetryCoreMockData.lastSynced}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                // 48x48dp touch target for deep-link drill-down
                SizedBox(
                  width: 48.0,
                  height: 48.0,
                  child: IconButton(
                    icon: Icon(
                      Icons.open_in_new,
                      color: colorScheme.primary,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Drilling down into telemetry-core details...'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      );
                    },
                    tooltip: 'View Details',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {required String label, required String value}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

/// Responsive wrapper ensuring single-column on mobile (<600dp)
/// and multi-column on desktop (>=840dp) per M3 guidelines.
class TelemetryCoreDashboardLayoutGen03607 extends StatelessWidget {
  const TelemetryCoreDashboardLayoutGen03607({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    if (screenWidth >= 840.0) {
      // Desktop / Tablet multi-column layout
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Expanded(
              child: TelemetryCoreStatusCardGen03607(),
            ),
            SizedBox(width: 24.0),
            Expanded(
              child: TelemetryCoreStatusCardGen03607(),
            ),
          ],
        ),
      );
    }

    // Mobile single-column layout (<600dp or fallback)
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: const [
          TelemetryCoreStatusCardGen03607(),
          SizedBox(height: 16.0),
          TelemetryCoreStatusCardGen03607(),
        ],
      ),
    );
  }
}