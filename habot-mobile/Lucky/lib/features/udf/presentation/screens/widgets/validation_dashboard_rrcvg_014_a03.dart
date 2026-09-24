// RRCVG-014-A03 — Validation Progress Dashboard with Audit Summaries.
// Displays multi-column status charts on wide screens and a vertical progress dashboard on mobile, using Material 3 design tokens and smooth accordion expansions.

import 'package:flutter/material.dart';

/// Represents a single test verification record.
class TestRecord {
  final String testType;
  final String testResult;
  final double testCoverage;
  final DateTime testTimestamp;
  final String testLogPath;
  final bool isCompleted;

  const TestRecord({
    required this.testType,
    required this.testResult,
    required this.testCoverage,
    required this.testTimestamp,
    required this.testLogPath,
    required this.isCompleted,
  });
}

/// Mock data repository simulating backend load test results.
class MockTestRepository {
  static List<TestRecord> getMockRecords() {
    return [
      TestRecord(
        testType: 'Real-time Streaming Load Test',
        testResult: 'Passed',
        testCoverage: 98.5,
        testTimestamp: DateTime(2026, 9, 20, 10, 30),
        testLogPath: '/logs/streaming_load_01.log',
        isCompleted: true,
      ),
      TestRecord(
        testType: 'Network Connectivity Detection',
        testResult: 'Passed',
        testCoverage: 100.0,
        testTimestamp: DateTime(2026, 9, 21, 14, 15),
        testLogPath: '/logs/network_detect_02.log',
        isCompleted: true,
      ),
      TestRecord(
        testType: 'Data Integrity Automated Check',
        testResult: 'Pending',
        testCoverage: 75.0,
        testTimestamp: DateTime(2026, 9, 22, 9, 0),
        testLogPath: '/logs/integrity_check_03.log',
        isCompleted: false,
      ),
      TestRecord(
        testType: 'Release-Gating Verification',
        testResult: 'Failed',
        testCoverage: 60.0,
        testTimestamp: DateTime(2026, 9, 23, 16, 45),
        testLogPath: '/logs/release_gate_04.log',
        isCompleted: false,
      ),
    ];
  }
}

/// Main dashboard widget implementing responsive layout and MD3 styling.
class ValidationDashboardRrcvg014A03 extends StatefulWidget {
  const ValidationDashboardRrcvg014A03({super.key});

  @override
  State<ValidationDashboardRrcvg014A03> createState() => _ValidationDashboardRrcvg014A03State();
}

class _ValidationDashboardRrcvg014A03State extends State<ValidationDashboardRrcvg014A03> {
  late final List<TestRecord> _records;

  @override
  void initState() {
    super.initState();
    _records = MockTestRepository.getMockRecords();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isWideScreen = MediaQuery.sizeOf(context).width >= 840;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Audit Summary & Validation',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: !isWideScreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isWideScreen ? _buildMultiColumnLayout(context) : _buildMobileVerticalLayout(context),
      ),
    );
  }

  /// Multi-column status chart for wide workstation monitors.
  Widget _buildMultiColumnLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verification & Test Coverage Completeness',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Target: 95–100% of defined test cases passed pre-release (ISTQB / Six Sigma <3.4 DPMO)',
          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: _records.length,
            itemBuilder: (context, index) {
              return _buildStatusCard(context, _records[index]);
            },
          ),
        ),
      ],
    );
  }

  /// Clean vertical progress dashboard for mobile screen form factors.
  Widget _buildMobileVerticalLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Validation Progress',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to expand details',
          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: _records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _buildAccordionItem(context, _records[index], index);
            },
          ),
        ),
      ],
    );
  }

  /// Status card utilizing explicit token color options (md.sys.color.success).
  Widget _buildStatusCard(BuildContext context, TestRecord record) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Using tertiary or primary as a stand-in for md.sys.color.success if not explicitly defined in standard scheme
    final Color successColor = Colors.green.shade700;
    final Color statusColor = record.testResult == 'Passed'
        ? successColor
        : record.testResult == 'Pending'
            ? colorScheme.tertiary
            : colorScheme.error;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
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
                    record.testType,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStepIndicator(record.isCompleted, 0, statusColor),
              ],
            ),
            const Spacer(),
            Text(
              'Coverage: ${record.testCoverage.toStringAsFixed(1)}%',
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: record.testCoverage / 100.0,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  /// Smooth accordion expansion tile for dense validation lists.
  Widget _buildAccordionItem(BuildContext context, TestRecord record, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final Color successColor = Colors.green.shade700;
    final Color statusColor = record.testResult == 'Passed'
        ? successColor
        : record.testResult == 'Pending'
            ? colorScheme.tertiary
            : colorScheme.error;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: _buildStepIndicator(record.isCompleted, index + 1, statusColor),
        title: Text(
          record.testType,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${record.testCoverage.toStringAsFixed(1)}% Coverage • ${record.testResult}',
          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 24),
          _buildDetailRow('Test Result', record.testResult, theme),
          _buildDetailRow('Timestamp', record.testTimestamp.toIso8601String(), theme),
          _buildDetailRow('Log Path', record.testLogPath, theme),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: record.testCoverage / 100.0,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  /// Clear completed (checkmark) and pending (number) step indicators.
  Widget _buildStepIndicator(bool isCompleted, int stepNumber, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 2),
      ),
      alignment: Alignment.center,
      child: isCompleted
          ? Icon(Icons.check_rounded, size: 18, color: color)
          : Text(
              '$stepNumber',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
    );
  }

  /// Helper for bold titles and muted descriptions.
  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
