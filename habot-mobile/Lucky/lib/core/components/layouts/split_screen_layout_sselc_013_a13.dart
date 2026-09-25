// SSELC-013-A13 — Split-Screen Contextual Mirror UI Template Standardization.
// Enforces a rigid 50/50 split-screen layout on desktop/tablet that auto-stacks vertically on mobile, with Material 3 typography token adherence, touch swipe gesture recognizers, and interaction tracking listeners.

import 'package:flutter/material.dart';

/// Mock telemetry model for micro-interaction logs (GCP/BigQuery alignment).
class InteractionMetric {
  final String metricName;
  final double metricValue;
  final String monitoringStatus;
  final double alertThreshold;
  final DateTime monitoringTimestamp;

  const InteractionMetric({
    required this.metricName,
    required this.metricValue,
    required this.monitoringStatus,
    required this.alertThreshold,
    required this.monitoringTimestamp,
  });

  Map<String, dynamic> toJson() => {
        'Metric Name': metricName,
        'Metric Value': metricValue,
        'Monitoring Status': monitoringStatus,
        'Alert Threshold': alertThreshold,
        'Monitoring Timestamp': monitoringTimestamp.toIso8601String(),
      };
}

/// Hardcoded mock data simulating backend payload / JSON-driven form panels.
final List<InteractionMetric> mockMetrics = [
  InteractionMetric(
    metricName: 'Typography Token Scale Adherence (Material Design 3 Type Scale)',
    metricValue: 0.99,
    monitoringStatus: 'Active',
    alertThreshold: 0.9,
    monitoringTimestamp: DateTime.now(),
  ),
  InteractionMetric(
    metricName: 'Hover Duration Tracking',
    metricValue: 1.2,
    monitoringStatus: 'Active',
    alertThreshold: 5.0,
    monitoringTimestamp: DateTime.now(),
  ),
];

/// Core reusable split-screen layout enforcing rigid orientation.
/// Local overrides are programmatically ignored by core framework rules.
class SplitScreenLayout extends StatefulWidget {
  final Widget leftPanel;
  final Widget rightPanel;
  final Function(InteractionMetric)? onInteractionTracked;

  const SplitScreenLayout({
    super.key,
    required this.leftPanel,
    required this.rightPanel,
    this.onInteractionTracked,
  });

  @override
  State<SplitScreenLayout> createState() => _SplitScreenLayoutState();
}

class _SplitScreenLayoutState extends State<SplitScreenLayout> {
  late final PageController _mobilePageController;

  @override
  void initState() {
    super.initState();
    _mobilePageController = PageController();
  }

  @override
  void dispose() {
    _mobilePageController.dispose();
    super.dispose();
  }

  void _trackInteraction(String metricName, double value) {
    final metric = InteractionMetric(
      metricName: metricName,
      metricValue: value,
      monitoringStatus: 'Pass',
      alertThreshold: 0.9,
      monitoringTimestamp: DateTime.now(),
    );
    widget.onInteractionTracked?.call(metric);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          // Vertical orientation auto-activating on mobile width devices.
          // Touch swipe gesture recognizers mapped to standard list item cells.
          return PageView(
            controller: _mobilePageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              _trackInteraction('Mobile Panel Swipe', index.toDouble());
            },
            children: [
              _buildAdaptivePanel(widget.leftPanel, 'Left'),
              _buildAdaptivePanel(widget.rightPanel, 'Right'),
            ],
          );
        }

        // Precise 50/50 balance splitting seamlessly on tablet/desktop.
        return Row(
          children: [
            Expanded(
              child: _buildAdaptivePanel(widget.leftPanel, 'Left'),
            ),
            // High-density borders separating panels elegantly.
            const VerticalDivider(
              width: 2.0,
              thickness: 2.0,
              color: Colors.black87,
            ),
            Expanded(
              child: _buildAdaptivePanel(widget.rightPanel, 'Right'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAdaptivePanel(Widget child, String panelId) {
    // Attach interaction tracking listeners to monitor visual hover durations.
    return MouseRegion(
      onEnter: (_) => _trackInteraction('Hover Enter $panelId', 1.0),
      onExit: (_) => _trackInteraction('Hover Exit $panelId', 0.0),
      child: GestureDetector(
        onTap: () => _trackInteraction('Touch Tap $panelId', 1.0),
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );
  }
}

/// Example usage demonstrating Typography Token Scale Adherence (MD3).
class SplitScreenDemo extends StatelessWidget {
  const SplitScreenDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SSELC-013-A13 Split Screen',
          style: theme.textTheme.titleLarge, // MD3 Type Scale token
        ),
      ),
      body: SplitScreenLayout(
        onInteractionTracked: (metric) {
          // Micro-interaction logs delivered directly (mock GCP/BigQuery alignment)
          debugPrint('Telemetry Log: ${metric.toJson()}');
        },
        leftPanel: Container(
          color: theme.colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Primary Form Panel', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              // Modal block styling maps securely locking fields.
              TextField(
                decoration: InputDecoration(
                  labelText: 'Operator Input',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0), // Rigid template
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Button wrapper logic & Visual state shifts.
              FilledButton(
                onPressed: () {},
                child: const Text('Submit Verification'),
              ),
            ],
          ),
        ),
        rightPanel: Container(
          color: theme.colorScheme.surfaceContainerLow,
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: mockMetrics.length,
            itemBuilder: (context, index) {
              final metric = mockMetrics[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: ListTile(
                  title: Text(
                    metric.metricName,
                    style: theme.textTheme.bodyLarge, // MD3 adherence
                  ),
                  subtitle: Text(
                    'Value: ${metric.metricValue} | Status: ${metric.monitoringStatus}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  trailing: Icon(
                    metric.metricValue >= metric.alertThreshold
                        ? Icons.check_circle
                        : Icons.warning,
                    color: metric.metricValue >= metric.alertThreshold
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}