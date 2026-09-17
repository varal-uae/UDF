// GEN-00926 — Bank Statement Reconciliation Status Card.
// M3 Elevated Card displaying automated financial reconciliation and BigQuery raw.bank_statements feed status for the mobile engineering console.

import 'package:flutter/material.dart';

enum _ReconciliationStatus { complete, notComplete }

class _MockBankStatementFeed {
  final String traceId;
  final String sessionId;
  final DateTime timestamp;
  final double insertDelaySeconds;
  final _ReconciliationStatus status;

  const _MockBankStatementFeed({
    required this.traceId,
    required this.sessionId,
    required this.timestamp,
    required this.insertDelaySeconds,
    required this.status,
  });
}

const List<_MockBankStatementFeed> _mockFeeds = [
  _MockBankStatementFeed(
    traceId: 'trace-001-gen-00926',
    sessionId: 'session-eng-01',
    timestamp: DateTime(2026, 9, 17, 10, 0, 0),
    insertDelaySeconds: 0.45,
    status: _ReconciliationStatus.complete,
  ),
  _MockBankStatementFeed(
    traceId: 'trace-002-gen-00926',
    sessionId: 'session-eng-02',
    timestamp: DateTime(2026, 9, 17, 10, 0, 30),
    insertDelaySeconds: 1.12,
    status: _ReconciliationStatus.notComplete,
  ),
  _MockBankStatementFeed(
    traceId: 'trace-003-gen-00926',
    sessionId: 'session-eng-01',
    timestamp: DateTime(2026, 9, 17, 10, 1, 0),
    insertDelaySeconds: 0.22,
    status: _ReconciliationStatus.complete,
  ),
];

class BankStatementReconciliationCardGen00926 extends StatefulWidget {
  const BankStatementReconciliationCardGen00926({super.key});

  @override
  State<BankStatementReconciliationCardGen00926> createState() =>
      _BankStatementReconciliationCardGen00926State();
}

class _BankStatementReconciliationCardGen00926State
    extends State<BankStatementReconciliationCardGen00926> {
  late List<_MockBankStatementFeed> _feeds;
  bool _isPolling = false;

  @override
  void initState() {
    super.initState();
    _feeds = List.from(_mockFeeds);
    _startPolling();
  }

  void _startPolling() {
    _isPolling = true;
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isPolling) {
        _refreshData();
        _startPolling();
      }
    });
  }

  @override
  void dispose() {
    _isPolling = false;
    super.dispose();
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _feeds = List.from(_mockFeeds);
    });
  }

  bool get _isAllComplete =>
      _feeds.every((f) => f.status == _ReconciliationStatus.complete);

  double get _maxDelay => _feeds.isEmpty
      ? 0.0
      : _feeds.map((f) => f.insertDelaySeconds).reduce(
            (a, b) => a > b ? a : b,
          );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Automated Financial Reconciliation',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'BigQuery raw.bank_statements Feed Health',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              _buildKpiCard(theme, colorScheme, isMobile),
              const SizedBox(height: 24),
              Text(
                'Recent Execution Events',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ..._feeds.map((feed) => _buildFeedTile(theme, feed, isMobile)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isMobile,
  ) {
    final overallStatus = _isAllComplete ? 'Complete' : 'Not Complete';
    final statusColor =
        _isAllComplete ? colorScheme.primary : colorScheme.error;
    final delayMeetsFloor = _maxDelay <= 1.0;

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kpiRow('Overall Status', overallStatus, statusColor, theme),
                  const SizedBox(height: 16),
                  _kpiRow(
                    'Max Insert Delay',
                    '${_maxDelay.toStringAsFixed(2)}s',
                    delayMeetsFloor ? colorScheme.primary : colorScheme.error,
                    theme,
                  ),
                  const SizedBox(height: 16),
                  _kpiRow(
                    'Floor Threshold',
                    '\u2264 1 sec',
                    colorScheme.onSurfaceVariant,
                    theme,
                  ),
                  const SizedBox(height: 16),
                  _kpiRow(
                    'Events Tracked',
                    '${_feeds.length}',
                    colorScheme.onSurfaceVariant,
                    theme,
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _kpiColumn(
                      'Overall Status', overallStatus, statusColor, theme),
                  _kpiColumn(
                    'Max Insert Delay',
                    '${_maxDelay.toStringAsFixed(2)}s',
                    delayMeetsFloor ? colorScheme.primary : colorScheme.error,
                    theme,
                  ),
                  _kpiColumn(
                    'Floor Threshold',
                    '\u2264 1 sec',
                    colorScheme.onSurfaceVariant,
                    theme,
                  ),
                  _kpiColumn(
                    'Events Tracked',
                    '${_feeds.length}',
                    colorScheme.onSurfaceVariant,
                    theme,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _kpiRow(
    String label,
    String value,
    Color valueColor,
    ThemeData theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _kpiColumn(
    String label,
    String value,
    Color valueColor,
    ThemeData theme,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedTile(
    ThemeData theme,
    _MockBankStatementFeed feed,
    bool isMobile,
  ) {
    final isComplete = feed.status == _ReconciliationStatus.complete;
    final chipColor =
        isComplete ? theme.colorScheme.primary : theme.colorScheme.error;
    final chipLabel = isComplete ? 'Complete' : 'Not Complete';

    return Card(
      elevation: 1.0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDetailSheet(theme, feed),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            feed.traceId,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(chipLabel),
                          backgroundColor: chipColor.withValues(alpha: 0.12),
                          labelStyle: TextStyle(
                            color: chipColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide.none,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Delay: ${feed.insertDelaySeconds.toStringAsFixed(2)}s | Session: ${feed.sessionId}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Timestamp: ${feed.timestamp.toIso8601String()}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        feed.traceId,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${feed.insertDelaySeconds.toStringAsFixed(2)}s',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        feed.sessionId,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Chip(
                      label: Text(chipLabel),
                      backgroundColor: chipColor.withValues(alpha: 0.12),
                      labelStyle: TextStyle(
                        color: chipColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide.none,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _showDetailSheet(ThemeData theme, _MockBankStatementFeed feed) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Event Details',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _detailRow('Trace ID', feed.traceId, theme),
                _detailRow('Session ID', feed.sessionId, theme),
                _detailRow(
                  'Insert Delay',
                  '${feed.insertDelaySeconds.toStringAsFixed(2)} sec',
                  theme,
                ),
                _detailRow(
                  'Status',
                  feed.status == _ReconciliationStatus.complete
                      ? 'Complete'
                      : 'Not Complete',
                  theme,
                ),
                _detailRow(
                  'Timestamp',
                  feed.timestamp.toIso8601String(),
                  theme,
                ),
                _detailRow(
                  'Standard',
                  'BigQuery Raw Zone Standards',
                  theme,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Deep-link drill-down acknowledged.',
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          action: SnackBarAction(
                            label: 'OK',
                            onPressed: () {},
                          ),
                        ),
                      );
                    },
                    child: const Text('Drill Down'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}