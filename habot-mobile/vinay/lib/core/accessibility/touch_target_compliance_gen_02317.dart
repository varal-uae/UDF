// GEN-02317 — Minimum 48x48dp Touch Target Compliance Utility.
// Enforces Material Design 3 and WCAG 2.2 AA minimum interactive element sizing across the UDF engineering console.

import 'package:flutter/material.dart';

/// Core compliance constants for touch target sizing per M3 and WCAG 2.2 AA.
class TouchTargetCompliance {
  TouchTargetCompliance._();

  static const double minTouchTargetDp = 48.0;
  static const double metricFloorThreshold = 0.95;
  static const String metricName = 'UI Compliance Rate (%)';
}

/// Wraps any interactive widget to guarantee a minimum 48x48dp touch target.
/// Uses [ConstrainedBox] to enforce sizing without altering visual appearance.
class CompliantTouchTarget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const CompliantTouchTarget({
    super.key,
    required this.child,
    this.onTap,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      container: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: TouchTargetCompliance.minTouchTargetDp,
          minHeight: TouchTargetCompliance.minTouchTargetDp,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(
            padding: padding,
            child: Center(
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Mock telemetry event model for BigQuery streaming alignment.
class ComplianceTelemetryEvent {
  final String atomicId;
  final String traceId;
  final DateTime eventDate;
  final bool passed;
  final double complianceRate;

  const ComplianceTelemetryEvent({
    required this.atomicId,
    required this.traceId,
    required this.eventDate,
    required this.passed,
    required this.complianceRate,
  });

  Map<String, dynamic> toJson() => {
        'atomic_id': atomicId,
        'trace_id': traceId,
        'event_date': eventDate.toIso8601String(),
        'passed': passed,
        'compliance_rate': complianceRate,
      };
}

/// Mock repository providing local data for UI Compliance Rate validation.
/// Simulates backend data as required by implementation constraints.
class MockComplianceRepository {
  static List<ComplianceTelemetryEvent> fetchMockEvents() {
    return [
      ComplianceTelemetryEvent(
        atomicId: 'GEN-02317',
        traceId: 'trace-001-gen-02317',
        eventDate: DateTime.now(),
        passed: true,
        complianceRate: 1.0,
      ),
      ComplianceTelemetryEvent(
        atomicId: 'GEN-02317',
        traceId: 'trace-002-gen-02317',
        eventDate: DateTime.now().subtract(const Duration(minutes: 30)),
        passed: true,
        complianceRate: 0.98,
      ),
    ];
  }

  static bool evaluateCompliance(double rate) {
    return rate >= TouchTargetCompliance.metricFloorThreshold;
  }
}

/// M3 Elevated Card displaying step health and compliance status.
/// Implements single-column mobile layout (<600dp) with inline status chip.
class ComplianceStatusCard extends StatelessWidget {
  const ComplianceStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final events = MockComplianceRepository.fetchMockEvents();
    final latestEvent = events.first;
    final isPassing = MockComplianceRepository.evaluateCompliance(latestEvent.complianceRate);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step Health: ${latestEvent.atomicId}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Chip(
                  label: Text(isPassing ? 'PASS' : 'FAIL'),
                  backgroundColor: isPassing
                      ? colorScheme.primaryContainer
                      : colorScheme.errorContainer,
                  labelStyle: TextStyle(
                    color: isPassing
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Text(
              '${TouchTargetCompliance.metricName}: ${(latestEvent.complianceRate * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 4.0),
            Text(
              'Standard: Material Design 3, WCAG 2.2 AA, W3C Web Standards',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Minimum Touch Target: ${TouchTargetCompliance.minTouchTargetDp.toStringAsFixed(0)}x${TouchTargetCompliance.minTouchTargetDp.toStringAsFixed(0)}dp',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
