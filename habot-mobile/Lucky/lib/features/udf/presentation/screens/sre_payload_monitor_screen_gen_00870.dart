// GEN-00870 — SRE Payload Compression & Network Size Monitor Console
// Implements M3 single-column engineering console card and dashboard monitoring payload sizes against the 10KB SRE threshold.
// Features 30s background polling, pull-to-refresh manual sync, M3 bottom sheet configuration, and SRE alert triggers.

import 'dart:async';
import 'package:flutter/material.dart';

/// English Code (EC) Blueprint:
/// 1. Define SRE payload budget constants (Ceiling: 10KB, Optimal: <=5KB).
/// 2. Implement NetworkPayloadMetric model capturing payload size, timestamp, traceId, and Pass/Fail status.
/// 3. Implement SrePayloadMonitorController handling periodic 30s polling, alert triggering, and BigQuery telemetry simulation.
/// 4. Build M3 responsive UI adapting single-column for mobile (<600dp) and multi-panel for desktop (>=840dp).
/// 5. Provide 48x48dp interactive touch targets, M3 Elevated Card Level 2 (3dp), status chips, and M3 bottom sheet configuration.

/// SRE Network Payload Metric model.
class NetworkPayloadMetric {
  final String traceId;
  final String endpoint;
  final double payloadSizeBytes;
  final DateTime timestamp;
  final bool isGzipProtobufApplied;

  const NetworkPayloadMetric({
    required this.traceId,
    required this.endpoint,
    required this.payloadSizeBytes,
    required this.timestamp,
    required this.isGzipProtobufApplied,
  });

  double get payloadSizeKb => payloadSizeBytes / 1024.0;
  bool get isPassing => payloadSizeKb <= 10.0;
  bool get isOptimal => payloadSizeKb <= 5.0;
  String get statusText => isPassing ? 'Pass' : 'Fail';
}

/// Primary SRE Payload Monitor Screen widget.
class SrePayloadMonitorScreenGen00870 extends StatefulWidget {
  const SrePayloadMonitorScreenGen00870({super.key});

  @override
  State<SrePayloadMonitorScreenGen00870> createState() =>
      _SrePayloadMonitorScreenGen00870State();
}

class _SrePayloadMonitorScreenGen00870State
    extends State<SrePayloadMonitorScreenGen00870> {
  static const double _defaultThresholdKb = 10.0;
  double _maxPayloadThresholdKb = _defaultThresholdKb;
  Timer? _pollingTimer;
  bool _isSyncing = false;
  final List<NetworkPayloadMetric> _metricsHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeMetrics();
    _startPeriodicPolling();
  }

  @override
  void dispose() {
    _cancelPeriodicPolling();
    super.dispose();
  }

  /// Initialize baseline telemetry metrics.
  void _initializeMetrics() {
    _metricsHistory.addAll([
      NetworkPayloadMetric(
        traceId: 'tr-0982-ab',
        endpoint: '/api/v1/mobile/user-session',
        payloadSizeBytes: 4.2 * 1024,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isGzipProtobufApplied: true,
      ),
      NetworkPayloadMetric(
        traceId: 'tr-0983-bc',
        endpoint: '/api/v1/catalog/stream',
        payloadSizeBytes: 8.8 * 1024,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        isGzipProtobufApplied: true,
      ),
      NetworkPayloadMetric(
        traceId: 'tr-0984-cd',
        endpoint: '/api/v1/telemetry/bulk-events',
        payloadSizeBytes: 12.6 * 1024,
        timestamp: DateTime.now().subtract(const Duration(seconds: 45)),
        isGzipProtobufApplied: false,
      ),
    ]);
  }

  /// Start background polling every 30 seconds for live SRE telemetry sync.
  void _startPeriodicPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchLatestPayloadMetrics(showSnackbar: false);
    });
  }

  /// Cancel active timer polling.
  void _cancelPeriodicPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Fetch latest simulated payload metrics and trigger alert if threshold breached.
  Future<void> _fetchLatestPayloadMetrics({bool showSnackbar = true}) async {
    if (!mounted) return;
    setState(() => _isSyncing = true);

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final double simulatedKb = 3.5 + (DateTime.now().second % 9);
    final newMetric = NetworkPayloadMetric(
      traceId: 'tr-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      endpoint: '/api/v1/network/sync',
      payloadSizeBytes: simulatedKb * 1024,
      timestamp: DateTime.now(),
      isGzipProtobufApplied: simulatedKb <= _maxPayloadThresholdKb,
    );

    setState(() {
      _metricsHistory.insert(0, newMetric);
      _isSyncing = false;
    });

    _streamTelemetryToBigQuery(newMetric);

    if (newMetric.payloadSizeKb > _maxPayloadThresholdKb) {
      _triggerSreAlert(newMetric);
    } else if (showSnackbar) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Manual Sync Complete: Latest payload at ${newMetric.payloadSizeKb.toStringAsFixed(1)} KB (Pass)',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Trigger SRE alert notification for payload size limit breach.
  void _triggerSreAlert(NetworkPayloadMetric metric) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'SRE Alert: Payload size ${metric.payloadSizeKb.toStringAsFixed(1)} KB exceeds threshold (ceiling: ${_maxPayloadThresholdKb.toStringAsFixed(0)} KB)!',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// Stream audit telemetry to BigQuery pipeline simulation.
  void _streamTelemetryToBigQuery(NetworkPayloadMetric metric) {
    debugPrint(
      '[GCP-BigQuery] Ingesting step GEN-00870: trace_id=${metric.traceId}, size_kb=${metric.payloadSizeKb.toStringAsFixed(2)}, status=${metric.statusText}',
    );
  }

  /// Display M3 Bottom Sheet for SRE performance budget configuration.
  void _showConfigurationBottomSheet() {
    double tempThreshold = _maxPayloadThresholdKb;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tune,
                        color: Theme.of(sheetContext).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SRE Performance Budget Standard',
                        style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adjust Payload Size Alert Ceiling (Floor threshold: <= 10 KB, Optimal: <= 5 KB)',
                    style: Theme.of(sheetContext).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ceiling Threshold:'),
                      Text(
                        '${tempThreshold.toStringAsFixed(1)} KB',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Slider(
                    value: tempThreshold,
                    min: 2.0,
                    max: 20.0,
                    divisions: 18,
                    label: '${tempThreshold.toStringAsFixed(1)} KB',
                    onChanged: (val) {
                      setModalState(() => tempThreshold = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () {
                        setState(() => _maxPayloadThresholdKb = tempThreshold);
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'SRE threshold updated to ${tempThreshold.toStringAsFixed(1)} KB.',
                            ),
                          ),
                        );
                      },
                      child: const Text('Save & Apply Budget'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompact = MediaQuery.of(context).size.width < 600;

    final latestMetric = _metricsHistory.isNotEmpty ? _metricsHistory.first : null;
    final isPassing = latestMetric?.isPassing ?? true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GEN-00870 SRE Payload Health'),
        actions: [
          IconButton(
            tooltip: 'Configure Threshold',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: const Icon(Icons.settings_outlined),
            onPressed: _showConfigurationBottomSheet,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchLatestPayloadMetrics(showSnackbar: true),
        child: isCompact
            ? _buildSingleColumnLayout(colorScheme, latestMetric, isPassing)
            : _buildMultiPanelLayout(colorScheme, latestMetric, isPassing),
      ),
    );
  }

  /// Build M3 responsive single-column layout for mobile devices (<600dp).
  Widget _buildSingleColumnLayout(
    ColorScheme colorScheme,
    NetworkPayloadMetric? latestMetric,
    bool isPassing,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSummaryHeaderCard(colorScheme, latestMetric, isPassing),
        const SizedBox(height: 16),
        _buildKpiMetricsRow(colorScheme),
        const SizedBox(height: 16),
        _buildTelemetryHistoryList(colorScheme),
      ],
    );
  }

  /// Build responsive multi-column layout for desktop and tablet displays (>=840dp).
  Widget _buildMultiPanelLayout(
    ColorScheme colorScheme,
    NetworkPayloadMetric? latestMetric,
    bool isPassing,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  _buildSummaryHeaderCard(colorScheme, latestMetric, isPassing),
                  const SizedBox(height: 16),
                  _buildKpiMetricsRow(colorScheme),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 6,
              child: _buildTelemetryHistoryList(colorScheme),
            ),
          ],
        ),
      ],
    );
  }

  /// Build M3 Elevated Card Level 2 (3dp elevation) displaying live step health.
  Widget _buildSummaryHeaderCard(
    ColorScheme colorScheme,
    NetworkPayloadMetric? latestMetric,
    bool isPassing,
  ) {
    final chipBgColor = isPassing
        ? colorScheme.primaryContainer
        : colorScheme.errorContainer;
    final chipTextColor = isPassing
        ? colorScheme.onPrimaryContainer
        : colorScheme.onErrorContainer;

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step GEN-00870',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gzip & Protobuf Compression Budget',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    isPassing ? 'PASS' : 'FAIL',
                    style: TextStyle(
                      color: chipTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: chipBgColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Status: ${latestMetric != null ? "Last payload: ${latestMetric.payloadSizeKb.toStringAsFixed(2)} KB (Standard <= ${_maxPayloadThresholdKb.toStringAsFixed(0)} KB)" : "Awaiting metrics..."}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: latestMetric != null
                  ? (latestMetric.payloadSizeKb / _maxPayloadThresholdKb).clamp(0.0, 1.0)
                  : 0.0,
              color: isPassing ? colorScheme.primary : colorScheme.error,
              backgroundColor: colorScheme.surfaceVariant,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _isSyncing
                      ? null
                      : () => _fetchLatestPayloadMetrics(showSnackbar: true),
                  icon: _isSyncing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                  label: const Text('Sync Now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build KPI metrics cards detailing Floor, Optimal target, and Ceiling boundary.
  Widget _buildKpiMetricsRow(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            title: 'Ceiling',
            value: '<= ${_maxPayloadThresholdKb.toStringAsFixed(0)} KB',
            colorScheme: colorScheme,
            icon: Icons.security_update_warning,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            title: 'Optimal',
            value: '<= 5 KB',
            colorScheme: colorScheme,
            icon: Icons.bolt,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            title: 'Polling',
            value: '30s Liveness',
            colorScheme: colorScheme,
            icon: Icons.timer_outlined,
          ),
        ),
      ],
    );
  }

  /// Build individual KPI mini card with standard touch metrics.
  Widget _buildKpiCard({
    required String title,
    required String value,
    required ColorScheme colorScheme,
    required IconData icon,
  }) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: colorScheme.primary),
            const SizedBox(height: 6),
            Text(
              title,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build audit history section with deep-link drill-down capabilities.
  Widget _buildTelemetryHistoryList(ColorScheme colorScheme) {
    return Card(
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Execution Event Logs',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'BigQuery Stream Clustered',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.secondary,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _metricsHistory.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _metricsHistory[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  leading: Icon(
                    item.isPassing ? Icons.check_circle : Icons.error_outline,
                    color: item.isPassing ? Colors.green : colorScheme.error,
                  ),
                  title: Text(
                    item.endpoint,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  subtitle: Text(
                    'Trace: ${item.traceId} • ${item.timestamp.toIso8601String().substring(11, 19)}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Text(
                    '${item.payloadSizeKb.toStringAsFixed(1)} KB',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: item.isPassing ? Colors.green[700] : colorScheme.error,
                    ),
                  ),
                  onTap: () => _showMetricDrillDownDetails(item),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Drill down into selected telemetry event details via M3 dialog.
  void _showMetricDrillDownDetails(NetworkPayloadMetric metric) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Telemetry Trace: ${metric.traceId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
 [
            Text('Endpoint: ${metric.endpoint}'),
            const SizedBox(height: 6),
            Text('Payload Size: ${metric.payloadSizeKb.toStringAsFixed(2)} KB (${metric.payloadSizeBytes.toStringAsFixed(0)} bytes)'),
            const SizedBox(height: 6),
            Text('Protobuf & Gzip Enabled: ${metric.isGzipProtobufApplied ? "Yes" : "No"}'),
            const SizedBox(height: 6),
            Text('SRE Budget Standard: ${metric.isPassing ? "Pass (<= 10 KB)" : "FAIL (> 10 KB)"}'),
            const SizedBox(height: 6),
            Text('Timestamp: ${metric.timestamp}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
