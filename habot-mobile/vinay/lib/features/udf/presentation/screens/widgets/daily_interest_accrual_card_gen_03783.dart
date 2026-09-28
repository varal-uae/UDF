// GEN-03783 — Daily Interest Accrual Engineering Console Card.
// Displays M3 Elevated Card with status chips, KPI metrics, and mock GL journal streaming data for the engineering console dashboard.

import 'package:flutter/material.dart';

/// Mock data model representing a daily interest accrual journal entry streamed to GL.
class GlJournalEntry {
  final String traceId;
  final DateTime eventDate;
  final double accruedInterest;
  final String accountId;
  final String status;

  const GlJournalEntry({
    required this.traceId,
    required this.eventDate,
    required this.accruedInterest,
    required this.accountId,
    required this.status,
  });
}

/// Hardcoded mock repository simulating backend GAAP Interest Accrual data.
class MockAccrualRepository {
  static const double floorThreshold = 1.0;
  static const double optimalTarget = 1.0;
  static const double ceilingBoundary = 1.0;

  static List<GlJournalEntry> fetchMockJournals() {
    return [
      GlJournalEntry(
        traceId: 'TRC-99281-A',
        eventDate: DateTime(2026, 9, 28),
        accruedInterest: 145.32,
        accountId: 'ACC-GL-001',
        status: 'Pass',
      ),
      GlJournalEntry(
        traceId: 'TRC-99282-B',
        eventDate: DateTime(2026, 9, 28),
        accruedInterest: 89.10,
        accountId: 'ACC-GL-002',
        status: 'Pass',
      ),
      GlJournalEntry(
        traceId: 'TRC-99283-C',
        eventDate: DateTime(2026, 9, 27),
        accruedInterest: 0.50,
        accountId: 'ACC-GL-003',
        status: 'Fail',
      ),
    ];
  }
}

/// Primary UI widget for the Engineering Console Dashboard step health.
/// Implements M3 Elevated Card (Level 2, 3dp elevation) with responsive layout.
class DailyInterestAccrualCardGen03783 extends StatefulWidget {
  const DailyInterestAccrualCardGen03783({super.key});

  @override
  State<DailyInterestAccrualCardGen03783> createState() => _DailyInterestAccrualCardGen03783State();
}

class _DailyInterestAccrualCardGen03783State extends State<DailyInterestAccrualCardGen03783> {
  late List<GlJournalEntry> _journals;
  bool _isPolling = false;

  @override
  void initState() {
    super.initState();
    _journals = MockAccrualRepository.fetchMockJournals();
    _startBackgroundPolling();
  }

  /// Simulates background polling refresh every 30 seconds.
  void _startBackgroundPolling() {
    setState(() => _isPolling = true);
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _journals = MockAccrualRepository.fetchMockJournals();
        });
        _startBackgroundPolling();
      }
    });
  }

  /// Triggers manual sync via pull-to-refresh.
  Future<void> _handleManualRefresh() async {
    await Future.delayed(const Duration(milliseconds: 80)); // Sub-100ms simulation
    setState(() {
      _journals = MockAccrualRepository.fetchMockJournals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = MediaQuery.of(context).size.width >= 840;

    return RefreshIndicator(
      onRefresh: _handleManualRefresh,
      color: colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isDesktop ? _buildMultiColumnLayout(theme) : _buildSingleColumnLayout(theme),
        ),
      ),
    );
  }

  /// M3 responsive multi-column layout for desktop (>=840dp).
  Widget _buildMultiColumnLayout(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 1, child: _buildKpiSummaryCard(theme)),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _buildJournalStreamList(theme)),
      ],
    );
  }

  /// M3 responsive single-column layout for mobile (<600dp).
  Widget _buildSingleColumnLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildKpiSummaryCard(theme),
        const SizedBox(height: 16),
        _buildJournalStreamList(theme),
      ],
    );
  }

  /// M3 Elevated Card Level 2 (3dp) displaying step completion state and KPIs.
  Widget _buildKpiSummaryCard(ThemeData theme) {
    final passCount = _journals.where((j) => j.status == 'Pass').length;
    final failCount = _journals.where((j) => j.status == 'Fail').length;
    final overallStatus = failCount == 0 ? 'Pass' : 'Fail';

    return Card(
      elevation: 3.0,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Interest Accrual Precision',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatusChip(overallStatus, theme),
            const SizedBox(height: 24),
            _buildMetricRow('Floor Threshold', '${MockAccrualRepository.floorThreshold}', theme),
            _buildMetricRow('Optimal Target', '${MockAccrualRepository.optimalTarget}', theme),
            _buildMetricRow('Ceiling Boundary', '${MockAccrualRepository.ceilingBoundary}', theme),
            const Divider(height: 32),
            _buildMetricRow('Total Journals Streamed', '${_journals.length}', theme),
            _buildMetricRow('Passed Validations', '$passCount', theme),
            _buildMetricRow('Failed Validations', '$failCount', theme),
            const SizedBox(height: 16),
            Text(
              'Standard: GAAP Interest Accrual Rules',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              _isPolling ? 'Liveness Handshake: Active (30s)' : 'Liveness Handshake: Idle',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }

  /// M3 Status Chip for health indicators with 48x48dp touch target compliance.
  Widget _buildStatusChip(String status, ThemeData theme) {
    final isPass = status == 'Pass';
    return SizedBox(
      height: 48.0, // 48x48dp touch target minimum
      child: Chip(
        avatar: Icon(
          isPass ? Icons.check_circle_outline : Icons.error_outline,
          color: isPass ? theme.colorScheme.primary : theme.colorScheme.error,
        ),
        label: Text(
          status,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isPass ? theme.colorScheme.primary : theme.colorScheme.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isPass
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : theme.colorScheme.errorContainer.withOpacity(0.3),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  /// Read-only list of GL journal streams with deep-link drill-down capability.
  Widget _buildJournalStreamList(ThemeData theme) {
    return Card(
      elevation: 3.0,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GL Journal Stream',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _journals.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final journal = _journals[index];
                return _buildJournalTile(journal, theme);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Individual journal entry tile with 48dp min height for touch targets.
  Widget _buildJournalTile(GlJournalEntry journal, ThemeData theme) {
    final isPass = journal.status == 'Pass';
    return InkWell(
      onTap: () {
        // Deep-link drill-down action simulated via Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Drill-down: Trace ID ${journal.traceId}'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48.0), // 48x48dp touch target
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
          child: Row(
            children: [
              Icon(
                isPass ? Icons.task_alt : Icons.cancel_outlined,
                color: isPass ? theme.colorScheme.primary : theme.colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trace: ${journal.traceId}',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Account: ${journal.accountId} | Date: ${journal.eventDate.year}-${journal.eventDate.month.toString().padLeft(2, '0')}-${journal.eventDate.day.toString().padLeft(2, '0')}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${journal.accruedInterest.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}