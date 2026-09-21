// GEN-01611 — Report an Issue CTA Button for Completed Order Detail Views.
// Adds a Material 3 ElevatedButton (48x48dp minimum touch target) to completed order screens, with mock data and telemetry hooks.

import 'package:flutter/material.dart';

/// Mock data representing a completed order for local development.
class _MockCompletedOrder {
  final String orderId;
  final String status;
  final DateTime completedAt;

  const _MockCompletedOrder({
    required this.orderId,
    required this.status,
    required this.completedAt,
  });
}

const _MockCompletedOrder _mockOrder = _MockCompletedOrder(
  orderId: 'ORD-2026-9921',
  status: 'COMPLETED',
  completedAt: null as dynamic, // replaced below
);

final _kMockOrder = _MockCompletedOrder(
  orderId: 'ORD-2026-9921',
  status: 'COMPLETED',
  completedAt: DateTime(2026, 9, 20, 14, 30),
);

/// A reusable M3-compliant CTA button widget that allows users to report
/// an issue on a completed order detail view.
///
/// Implements:
/// - 48x48dp minimum touch target (M3 standard)
/// - M3 Elevated styling
/// - Single-column mobile layout compatibility (<600dp)
/// - Telemetry-ready callback hook
class ReportIssueCtaButtonGen01611 extends StatelessWidget {
  final String orderId;
  final VoidCallback? onReportIssuePressed;

  const ReportIssueCtaButtonGen01611({
    super.key,
    required this.orderId,
    this.onReportIssuePressed,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 48.0,
        minWidth: 48.0,
      ),
      child: FilledButton.icon(
        onPressed: () => _handlePress(context),
        icon: const Icon(Icons.report_problem_outlined, size: 20.0),
        label: const Text('Report an Issue'),
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.errorContainer,
          foregroundColor: colorScheme.onErrorContainer,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 3.0, // M3 Elevated Card Level 2 equivalent
          minimumSize: const Size(48.0, 48.0),
        ),
      ),
    );
  }

  void _handlePress(BuildContext context) {
    // Telemetry / Analytics hook placeholder
    _logTelemetryEvent('report_issue_cta_tapped', orderId);

    if (onReportIssuePressed != null) {
      onReportIssuePressed!();
      return;
    }

    // Default behavior: show confirmation snackbar (M3 Snackbar)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening issue report for order $orderId...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            _logTelemetryEvent('report_issue_cta_undo', orderId);
          },
        ),
      ),
    );
  }

  /// Simulates streaming execution events to BigQuery partitioned by event_date.
  void _logTelemetryEvent(String eventName, String traceId) {
    // In production, this streams to the telemetry layer.
    // Mock implementation logs to console for validation.
    debugPrint('[GEN-01611 Telemetry] event=$eventName, trace_id=$traceId, timestamp=${DateTime.now().toIso8601String()}');
  }
}

/// Example usage within a completed order detail screen.
/// Demonstrates single-column mobile layout (<600dp) integration.
class CompletedOrderDetailScreenGen01611 extends StatelessWidget {
  const CompletedOrderDetailScreenGen01611({super.key});

  @override
  Widget build(BuildContext context) {
    final order = _kMockOrder;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // M3 Status Card displaying step completion state
              Card(
                elevation: 3.0,
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ${order.orderId}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Chip(
                            avatar: const Icon(Icons.check_circle, size: 16.0, color: Colors.green),
                            label: Text(order.status),
                          ),
                          const Spacer(),
                          Text(
                            'Completed: ${order.completedAt.toString().substring(0, 16)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // GEN-01611: Report an Issue CTA Button
              ReportIssueCtaButtonGen01611(
                orderId: order.orderId,
                onReportIssuePressed: () {
                  // Custom deep-link drill-down or bottom sheet trigger
                  showModalBottomSheet(
                    context: context,
                    builder: (ctx) => SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Report Issue for ${order.orderId}',
                              style: Theme.of(ctx).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16.0),
                            const TextField(
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelText: 'Describe the issue',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Submit Report'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
