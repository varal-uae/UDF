// GEN-01026 — Unit Test Pass Rate M3 Status Card.
// Displays the automated unit test suite pass rate with M3 Elevated Card, status chips, and responsive layout. Includes mock data for local rendering without backend dependency.

import 'package:flutter/material.dart';

/// Mock data model representing the unit test execution result.
class UnitTestResult {
  final String metricName;
  final double passRate;
  final String status;
  final DateTime timestamp;
  final String sessionId;
  final String traceId;

  const UnitTestResult({
    required this.metricName,
    required this.passRate,
    required this.status,
    required this.timestamp,
    required this.sessionId,
    required this.traceId,
  });
}

/// Hardcoded mock repository simulating CI/CD pipeline output.
class MockUnitTestRepository {
  static const List<UnitTestResult> results = [
    UnitTestResult(
      metricName: 'Unit Test Pass Rate',
      passRate: 100.0,
      status: 'Pass',
      timestamp: DateTime(2026, 9, 17, 10, 30, 0),
      sessionId: 'sess_8a7b6c5d',
      traceId: 'trace_gen_01026_001',
    ),
  ];

  static UnitTestResult getLatest() => results.first;
}

/// M3 Elevated Card (Level 2, 3dp) displaying step completion state.
/// Responsive: single-column on mobile (<600dp), multi-column on desktop (≥840dp).
class UnitTestPassRateCard extends StatefulWidget {
  const UnitTestPassRateCard({super.key});

  @override
  State<UnitTestPassRateCard> createState() => _UnitTestPassRateCardState();
}

class _UnitTestPassRateCardState extends State<UnitTestPassRateCard> {
  late UnitTestResult _result;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _result = MockUnitTestRepository.getLatest();
    _startPolling();
  }

  void _startPolling() {
    // Background polling refreshes data every 30 seconds.
    Future.delayed(const Duration(seconds: 30), () {
      if (!mounted) return;
      _refreshData();
      _startPolling();
    });
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    // Simulate network delay for mock data fetch
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _result = MockUnitTestRepository.getLatest();
      _isRefreshing = false;
    });
  }

  Color _getStatusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_result.passRate >= 100.0 && _result.status == 'Pass') {
      return colorScheme.primary;
    }
    return colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 840;

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: isDesktop ? _buildDesktopLayout(textTheme, colorScheme) : _buildMobileLayout(textTheme, colorScheme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(textTheme, colorScheme),
        const SizedBox(height: 16),
        _buildMetricValue(textTheme, colorScheme),
        const SizedBox(height: 16),
        _buildStatusChip(colorScheme),
        const SizedBox(height: 16),
        _buildMetadata(textTheme, colorScheme),
        if (_isRefreshing) ...[
          const SizedBox(height: 16),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }

  Widget _buildDesktopLayout(TextTheme textTheme, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(textTheme, colorScheme),
              const SizedBox(height: 16),
              _buildMetricValue(textTheme, colorScheme),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatusChip(colorScheme),
              const SizedBox(height: 16),
              _buildMetadata(textTheme, colorScheme),
              if (_isRefreshing) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(TextTheme textTheme, ColorScheme colorScheme) {
    return Text(
      'GEN-01026: ${_result.metricName}',
      style: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildMetricValue(TextTheme textTheme, ColorScheme colorScheme) {
    return Text(
      '${_result.passRate.toStringAsFixed(1)}%',
      style: textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: _getStatusColor(context),
      ),
    );
  }

  Widget _buildStatusChip(ColorScheme colorScheme) {
    return Chip(
      avatar: Icon(
        _result.status == 'Pass' ? Icons.check_circle_outline : Icons.error_outline,
        size: 18,
        color: _getStatusColor(context),
      ),
      label: Text(
        _result.status.toUpperCase(),
        style: TextStyle(
          color: _getStatusColor(context),
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: _getStatusColor(context).withOpacity(0.12),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildMetadata(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trace ID: ${_result.traceId}',
          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          'Session: ${_result.sessionId}',
          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          'Last Checked: ${_result.timestamp.toLocal().toString().substring(0, 19)}',
          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}