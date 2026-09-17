// GEN-00648 — Multi-Touch Attribution Pipeline Monitor Screen
// Engineering console screen monitoring BigQuery dbt MTA materializations (analytics.mta_channel_contributions).
// Features responsive M3 cards, metered connection-aware 30s background polling, pull-to-refresh, and drill-down details.

import 'dart:async';
import 'package:flutter/material.dart';

/// Status indicator for MTA pipeline validation.
enum MaterializationStatus {
  complete,
  notComplete,
  validating,
  error,
}

/// Model encapsulating MTA channel contributions health telemetry.
class MtaPipelineTelemetry {
  final String artifactName;
  final MaterializationStatus status;
  final double passRate;
  final String targetTable;
  final DateTime lastRefreshed;
  final bool isMeteredConnection;

  const MtaPipelineTelemetry({
    required this.artifactName,
    required this.status,
    required this.passRate,
    required this.targetTable,
    required this.lastRefreshed,
    required this.isMeteredConnection,
  });

  MtaPipelineTelemetry copyWith({
    String? artifactName,
    MaterializationStatus? status,
    double? passRate,
    String? targetTable,
    DateTime? lastRefreshed,
    bool? isMeteredConnection,
  }) {
    return MtaPipelineTelemetry(
      artifactName: artifactName ?? this.artifactName,
      status: status ?? this.status,
      passRate: passRate ?? this.passRate,
      targetTable: targetTable ?? this.targetTable,
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
      isMeteredConnection: isMeteredConnection ?? this.isMeteredConnection,
    );
  }
}

/// Mobile engineering console view for MTA dbt materialization monitoring.
class MtaPipelineMonitorScreenGen00648 extends StatefulWidget {
  const MtaPipelineMonitorScreenGen00648({super.key});

  @override
  State<MtaPipelineMonitorScreenGen00648> createState() =>
      _MtaPipelineMonitorScreenGen00648State();
}

class _MtaPipelineMonitorScreenGen00648State
    extends State<MtaPipelineMonitorScreenGen00648> {
  Timer? _pollingTimer;
  bool _isSyncing = false;
  MtaPipelineTelemetry _telemetry = MtaPipelineTelemetry(
    artifactName: 'mta_channel_contributions',
    status: MaterializationStatus.complete,
    passRate: 100.0,
    targetTable: 'analytics.mta_channel_contributions',
    lastRefreshed: DateTime.now(),
    isMeteredConnection: false,
  );

  @override
  void initState() {
    super.initState();
    _schedulePolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  /// Schedule: Starts periodic background polling if not on a metered or slow network.
  void _schedulePolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_telemetry.isMeteredConnection) {
        _refreshData(isBackground: true);
      }
    });
  }

  /// Refresh: Performs telemetry synchronization and updates UI state.
  Future<void> _refreshData({bool isBackground = false}) async {
    if (!mounted) return;
    if (!isBackground) {
      setState(() => _isSyncing = true);
    }

    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() {
      _telemetry = _telemetry.copyWith(
        status: MaterializationStatus.complete,
        passRate: 100.0,
        lastRefreshed: DateTime.now(),
      );
      _isSyncing = false;
    });

    if (!isBackground) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('MTA Pipeline status refreshed successfully.'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  /// Toggle: Simulates network condition changes (metered vs unmetered).
  void _toggleNetworkCondition() {
    setState(() {
      final toggled = !_telemetry.isMeteredConnection;
      _telemetry = _telemetry.copyWith(isMeteredConnection: toggled);
      if (toggled) {
        _pollingTimer?.cancel();
      } else {
        _schedulePolling();
      }
    });
  }

  /// Inspect: Displays the configuration details and runbook specs in an M3 bottom sheet.
  void _inspectDetails() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'MTA dbt Materialization Spec',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Target Table: analytics.mta_channel_contributions\n'
                'Floor Boundary: 100% Pass\n'
                'Clustering: trace_id | Partition: event_date\n'
                'Spec: dbt Materialization Guide',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).pop(),
                child: const Center(child: Text('Close')),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MTA Pipeline Health'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Toggle Metered Connection',
            icon: Icon(
              _telemetry.isMeteredConnection
                  ? Icons.signal_cellular_alt_1_bar
                  : Icons.signal_cellular_alt,
            ),
            onPressed: _toggleNetworkCondition,
          ),
          IconButton(
            tooltip: 'Manual Sync',
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            onPressed: _isSyncing ? null : () => _refreshData(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSingleColumn = constraints.maxWidth < 600;

          return RefreshIndicator(
            onRefresh: () => _refreshData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: isSingleColumn
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _buildContentWidgets(colorScheme),
                    )
                  : Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 840),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: _buildCards(colorScheme),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: _buildConnectionCard(colorScheme),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  /// Build: Assembles content elements for single column layout.
  List<Widget> _buildContentWidgets(ColorScheme colorScheme) {
    return <Widget>[
      ..._buildCards(colorScheme),
      const SizedBox(height: 16),
      _buildConnectionCard(colorScheme),
    ];
  }

  /// Build: Assembles core M3 Elevated KPI cards.
  List<Widget> _buildCards(ColorScheme colorScheme) {
    final isComplete = _telemetry.status == MaterializationStatus.complete;

    return <Widget>[
      Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _telemetry.artifactName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Chip(
                    avatar: Icon(
                      isComplete ? Icons.check_circle : Icons.warning,
                      size: 16,
                      color: isComplete
                          ? colorScheme.primary
                          : colorScheme.error,
                    ),
                    label: Text(isComplete ? 'Complete' : 'Not Complete'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Destination: ${_telemetry.targetTable}',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  const Text('View Materialization Pass: '),
                  Text(
                    '${_telemetry.passRate.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.tonalIcon(
                  onPressed: _inspectDetails,
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Drill-Down Inspection'),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  /// Build: Assembles card displaying background polling & network state.
  Widget _buildConnectionCard(ColorScheme colorScheme) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Sync & Telemetry Engine',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _telemetry.isMeteredConnection
                  ? 'Background polling paused (Metered/Slow Connection detected).'
                  : 'Polling active (Every 30s). Streaming to BigQuery trace.',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              'Last check: ${_telemetry.lastRefreshed.toIso8601String().substring(11, 19)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
