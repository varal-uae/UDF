// GEN-00982 — Automated Banned Terminology Code Linter & Compliance Guard UI.
// Displays M3 Elevated Card with status chips, alert notification delay metrics, and mock linter failure data for the engineering console.

import 'package:flutter/material.dart';

/// Mock data model representing a developer's linter compliance state.
class LinterComplianceRecord {
  final String traceId;
  final String developerId;
  final int dailyFailures;
  final double alertNotificationDelaySecs;
  final bool isPassing;
  final DateTime timestamp;

  const LinterComplianceRecord({
    required this.traceId,
    required this.developerId,
    required this.dailyFailures,
    required this.alertNotificationDelaySecs,
    required this.isPassing,
    required this.timestamp,
  });
}

/// Hardcoded mock data simulating backend/BigQuery telemetry.
const List<LinterComplianceRecord> kMockLinterRecords = [
  LinterComplianceRecord(
    traceId: 'trace-001-gen-00982',
    developerId: 'dev-adfa-01',
    dailyFailures: 2,
    alertNotificationDelaySecs: 0.8,
    isPassing: true,
    timestamp: DateTime(2026, 9, 17, 10, 0),
  ),
  LinterComplianceRecord(
    traceId: 'trace-002-gen-00982',
    developerId: 'dev-adfa-02',
    dailyFailures: 6,
    alertNotificationDelaySecs: 2.4,
    isPassing: false,
    timestamp: DateTime(2026, 9, 17, 10, 5),
  ),
  LinterComplianceRecord(
    traceId: 'trace-003-gen-00982',
    developerId: 'dev-adfa-03',
    dailyFailures: 5,
    alertNotificationDelaySecs: 1.1,
    isPassing: true,
    timestamp: DateTime(2026, 9, 17, 10, 10),
  ),
];

/// M3 Elevated Card (Level 2, 3dp) displaying linter compliance health.
/// Single-column on mobile (<600dp), multi-column capable via parent layout.
/// Includes 48x48dp touch targets and Material You dynamic color support.
class LinterComplianceCard extends StatelessWidget {
  final LinterComplianceRecord record;
  final VoidCallback? onDeepLinkDrillDown;

  const LinterComplianceCard({
    super.key,
    required this.record,
    this.onDeepLinkDrillDown,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 3.0, // M3 Elevated Card Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onDeepLinkDrillDown ?? () => _showBottomSheet(context),
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
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
                      'Linter Compliance Guard',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  _buildStatusChip(context, record.isPassing),
                ],
              ),
              const SizedBox(height: 12.0),
              _buildMetricRow(
                context,
                label: 'Developer ID',
                value: record.developerId,
              ),
              const SizedBox(height: 8.0),
              _buildMetricRow(
                context,
                label: 'Daily Failures',
                value: '${record.dailyFailures} times/day',
                isError: record.dailyFailures > 5,
              ),
              const SizedBox(height: 8.0),
              _buildMetricRow(
                context,
                label: 'Alert Notification Delay',
                value: '${record.alertNotificationDelaySecs.toStringAsFixed(2)} secs',
                isError: record.alertNotificationDelaySecs > 3.0,
              ),
              const SizedBox(height: 8.0),
              _buildMetricRow(
                context,
                label: 'Trace ID',
                value: record.traceId,
              ),
              const SizedBox(height: 16.0),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 48.0, // 48x48dp touch target
                  width: 48.0,
                  child: IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => _showBottomSheet(context),
                    tooltip: 'View Details',
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, bool isPassing) {
    return Chip(
      avatar: Icon(
        isPassing ? Icons.check_circle : Icons.error,
        size: 18.0,
        color: isPassing
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onErrorContainer,
      ),
      label: Text(isPassing ? 'Pass' : 'Fail'),
      backgroundColor: isPassing
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.errorContainer,
      labelStyle: TextStyle(
        color: isPassing
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onErrorContainer,
        fontWeight: FontWeight.bold,
      ),
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildMetricRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isError = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isError ? theme.colorScheme.error : theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: Theme.of(bottomSheetContext).colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Configuration & Details',
                style: Theme.of(bottomSheetContext).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16.0),
              Text(
                'Standard: Habot Shakti Safety Protocol',
                style: Theme.of(bottomSheetContext).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Floor Boundary: \u2264 3 secs | Optimal Target: \u2264 1 sec | Ceiling: 5 secs',
                style: Theme.of(bottomSheetContext).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Slack Alert Trigger: > 5 failures/day notifies DCDF Architect.',
                style: Theme.of(bottomSheetContext).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                height: 48.0, // 48x48dp touch target
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(bottomSheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Configuration acknowledged.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Acknowledge'),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
  }
}

/// Screen demonstrating background polling (mocked) and pull-to-refresh
/// for the Engineering Console Dashboard.
class LinterComplianceDashboardScreen extends StatefulWidget {
  const LinterComplianceDashboardScreen({super.key});

  @override
  State<LinterComplianceDashboardScreen> createState() => _LinterComplianceDashboardScreenState();
}

class _LinterComplianceDashboardScreenState extends State<LinterComplianceDashboardScreen> {
  late List<LinterComplianceRecord> _records;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _records = List.from(kMockLinterRecords);
    _startBackgroundPolling();
  }

  void _startBackgroundPolling() {
    // Mock background polling every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          // Simulate data refresh
          _records = List.from(kMockLinterRecords);
        });
        _startBackgroundPolling();
      }
    });
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    // Simulate manual sync network call
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _records = List.from(kMockLinterRecords);
        _isRefreshing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Manual sync completed successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering Console'),
        centerTitle: false,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp)
            final isMobile = constraints.maxWidth < 600;
            final crossAxisCount = isMobile ? 1 : (constraints.maxWidth >= 840 ? 2 : 1);

            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: isMobile ? 1.4 : 1.6,
              ),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                return LinterComplianceCard(
                  record: _records[index],
                  onDeepLinkDrillDown: () {
                    // Deep-link drill-down action placeholder
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
