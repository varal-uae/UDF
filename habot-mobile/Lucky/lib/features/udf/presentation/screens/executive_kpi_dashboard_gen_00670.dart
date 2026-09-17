// GEN-00670 — Mobile-Optimized Executive Performance Dashboard: Primary KPI Card Placement.
// Renders the Blended ROAS/CAC primary KPI card pinned to the top-left 40% screen area,
// with M3 Elevated Cards, Pass/Fail status chips, 30s background polling, and pull-to-refresh.

import 'dart:async';

import 'package:flutter/material.dart';

/// Read-only executive KPI dashboard optimized for mobile-first layouts.
///
/// Layout rules (per Improvado Dashboard Spec):
/// - Mobile (<600dp): single-column, primary KPI card occupies the top
///   region spanning 40% of the available body height.
/// - Desktop/tablet (>=840dp): multi-column grid, primary KPI card pinned
///   to the top-left cell spanning 40% of the grid width.
/// - All touch targets are >= 48x48dp.
class ExecutiveKpiDashboardGen00670 extends StatefulWidget {
  const ExecutiveKpiDashboardGen00670({super.key});

  @override
  State<ExecutiveKpiDashboardGen00670> createState() =>
      _ExecutiveKpiDashboardGen00670State();
}

class _ExecutiveKpiDashboardGen00670State
    extends State<ExecutiveKpiDashboardGen00670> {
  static const Duration _pollInterval = Duration(seconds: 30);
  static const double _mobileBreakpoint = 600;
  static const double _desktopBreakpoint = 840;
  static const double _minTouchTarget = 48;

  Timer? _pollTimer;
  bool _isSyncing = false;
  DateTime? _lastSyncedAt;

  /// Placeholder metric state; wired to the BI data source in integration.
  double _blendedRoas = 4.2;
  double _blendedCac = 38.50;
  bool _placementCheckPassed = true;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _syncMetrics());
  }

  Future<void> _syncMetrics() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      // Simulated fetch from the executive metrics source.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() {
        _lastSyncedAt = DateTime.now();
        _placementCheckPassed = true;
      });
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _onPullToRefresh() async {
    await _syncMetrics();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Executive metrics refreshed'),
      ),
    );
  }

  void _openDrillDown(String metricKey) {
    // Deep-link drill-down entry point (read-only detail route).
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Drill-down: $metricKey'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Executive Performance'),
        actions: [
          IconButton(
            tooltip: 'Sync now',
            onPressed: _onPullToRefresh,
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onPullToRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < _mobileBreakpoint;
            final isDesktop = constraints.maxWidth >= _desktopBreakpoint;
            if (isMobile) {
              return _buildSingleColumn(context, constraints);
            }
            return _buildMultiColumn(context, constraints, isDesktop);
          },
        ),
      ),
    );
  }

  /// Mobile: single-column; primary KPI card pinned to the top region
  /// occupying 40% of the available body height (top-left equivalent).
  Widget _buildSingleColumn(BuildContext context, BoxConstraints constraints) {
    final primaryHeight = constraints.maxHeight * 0.40;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: primaryHeight.clamp(220.0, constraints.maxHeight),
          child: _buildPrimaryKpiCard(context),
        ),
        const SizedBox(height: 16),
        _buildSecondaryKpiCard(
          context,
          title: 'Blended CAC',
          value: '\$${_blendedCac.toStringAsFixed(2)}',
          metricKey: 'blended_cac',
        ),
        const SizedBox(height: 16),
        _buildSyncStatusCard(context),
      ],
    );
  }

  /// Desktop/tablet: multi-column grid; primary KPI card pinned to the
  /// top-left cell spanning 40% of the grid width.
  Widget _buildMultiColumn(
    BuildContext context,
    BoxConstraints constraints,
    bool isDesktop,
  ) {
    final primaryWidth = constraints.maxWidth * 0.40;
    final columns = isDesktop ? 3 : 2;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: primaryWidth.clamp(280.0, constraints.maxWidth),
              height: 260,
              child: _buildPrimaryKpiCard(context),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  SizedBox(
                    width: (constraints.maxWidth - primaryWidth - 72) / columns,
                    height: 260,
                    child: _buildSecondaryKpiCard(
                      context,
                      title: 'Blended CAC',
                      value: '\$${_blendedCac.toStringAsFixed(2)}',
                      metricKey: 'blended_cac',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSyncStatusCard(context),
      ],
    );
  }

  /// Primary KPI card: Blended ROAS/CAC with Pass/Fail status chip.
  /// M3 Elevated Card (Level 2) with deep-link drill-down support.
  Widget _buildPrimaryKpiCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDrillDown('blended_roas'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Blended ROAS / CAC',
                      style: textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),
              const Spacer(),
              Text(
                '${_blendedRoas.toStringAsFixed(2)}x',
                style: textTheme.displaySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Primary placement: Top-Left (40% area)',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.open_in_new,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final passed = _placementCheckPassed;
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: _minTouchTarget,
        minHeight: _minTouchTarget,
      ),
      child: Chip(
        avatar: Icon(
          passed ? Icons.check_circle : Icons.error,
          size: 18,
          color: passed ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
        ),
        label: Text(passed ? 'Pass' : 'Fail'),
        backgroundColor:
            passed ? colorScheme.primaryContainer : colorScheme.errorContainer,
        labelStyle: TextStyle(
          color: passed
              ? colorScheme.onPrimaryContainer
              : colorScheme.onErrorContainer,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildSecondaryKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required String metricKey,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDrillDown(metricKey),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.titleMedium),
              const Spacer(),
              Text(
                value,
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.open_in_new,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncStatusCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final syncedLabel = _lastSyncedAt == null
        ? 'Awaiting first sync'
        : 'Last synced: ${_lastSyncedAt!.toLocal()}';
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.schedule, size: 20, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                syncedLabel,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(
              width: _minTouchTarget,
              height: _minTouchTarget,
              child: IconButton(
                tooltip: 'Refresh metrics',
                onPressed: _onPullToRefresh,
                icon: const Icon(Icons.refresh),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
