// GEN-03552 — Lineage Tracing Decorator Status Card.
// M3 Elevated Card displaying step completion state, decorator code coverage rate, and pass/fail status for the @trace_lineage component with 30-second polling and pull-to-refresh support.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data representing the backend lineage tracing decorator status.
class _LineageTracingMockData {
  static const String atomicId = 'GEN-03552';
  static const String globalRefId = 'GEN-03552';
  static const String stepName = 'Build @trace_lineage decorator';
  static const String assignedTeam = 'UDF';
  static const double floorBoundary = 0.95;
  static const double optimalTarget = 1.0;
  
  static Map<String, dynamic> fetchStatus() {
    return {
      'atomic_id': atomicId,
      'global_ref_id': globalRefId,
      'step_name': stepName,
      'assigned_team': assignedTeam,
      'decorator_code_coverage_rate': 0.98,
      'completion_status': 'Pass',
      'last_updated': DateTime.now().toIso8601String(),
      'ci_cd_pass_rate': 1.0,
      'validation_checks_passed': true,
    };
  }
}

class LineageTracingCardGen03552 extends StatefulWidget {
  const LineageTracingCardGen03552({super.key});

  @override
  State<LineageTracingCardGen03552> createState() => _LineageTracingCardGen03552State();
}

class _LineageTracingCardGen03552State extends State<LineageTracingCardGen03552> {
  late Map<String, dynamic> _mockData;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _mockData = _LineageTracingMockData.fetchStatus();
    // Background polling refreshes data every 30 seconds.
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    // Simulate network delay for mock data fetch
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _mockData = _LineageTracingMockData.fetchStatus();
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPass = _mockData['completion_status'] == 'Pass';
    final coverageRate = (_mockData['decorator_code_coverage_rate'] as num).toDouble();

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Engineering Console',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (≥840dp).
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 840;
                  final card = _buildElevatedCard(theme, colorScheme, isPass, coverageRate);
                  
                  if (isDesktop) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: card),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDetailsPanel(theme)),
                      ],
                    );
                  }
                  return card;
                },
              ),
              if (_isRefreshing) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElevatedCard(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isPass,
    double coverageRate,
  ) {
    // M3 Elevated Cards Level 2 (3dp)
    return Card(
      elevation: 3.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _mockData['step_name'] as String,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // M3 Status Chips for health indicators
                Chip(
                  avatar: Icon(
                    isPass ? Icons.check_circle : Icons.error,
                    size: 18,
                    color: isPass ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
                  ),
                  label: Text(
                    _mockData['completion_status'] as String,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isPass ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: isPass
                      ? colorScheme.primaryContainer
                      : colorScheme.errorContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildMetricRow(
              theme,
              'Atomic ID',
              _mockData['atomic_id'] as String,
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              theme,
              'Assigned Team',
              _mockData['assigned_team'] as String,
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              theme,
              'Decorator Code Coverage Rate',
              '${(coverageRate * 100).toStringAsFixed(1)}%',
              valueColor: coverageRate >= _LineageTracingMockData.floorBoundary
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              theme,
              'CI/CD Pass Rate',
              '${((_mockData['ci_cd_pass_rate'] as num) * 100).toStringAsFixed(0)}%',
            ),
            const SizedBox(height: 24),
            // 48x48dp touch targets
            SizedBox(
              width: double.infinity,
              height: 48.0,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    // M3 Snackbar for confirmations
                    SnackBar(
                      content: const Text('Deep-link drill-down initiated for GEN-03552'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.open_in_new, size: 20),
                label: const Text('View Runbook & Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    ThemeData theme,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsPanel(ThemeData theme) {
    return Card(
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Standard: Python/Node Software Design Patterns [cite: 4388]',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Floor Boundary: ${_LineageTracingMockData.floorBoundary}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Optimal Target: ${_LineageTracingMockData.optimalTarget}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Liveness Handshake: Every 30s',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            // M3 Bottom Sheet trigger for configuration inputs
            SizedBox(
              width: double.infinity,
              height: 48.0,
              child: OutlinedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                        left: 24,
                        right: 24,
                        top: 24,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configure Lineage Tracing',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Trace ID Filter',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48.0,
                            child: FilledButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Apply Configuration'),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.settings, size: 20),
                label: const Text('Open Configuration'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}