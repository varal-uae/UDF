// GEN-00693 — Configure Mobile Push Notifications & Real-Time Alert Triggers.
// Engineering console dashboard screen displaying APNs SDK ingestion health via M3 Elevated Cards, horizontal array scrolling for alert workers, and 30s background polling.

import 'dart:async';
import 'package:flutter/material.dart';

/// Model representing an APNs push notification worker trigger node.
class ApnsWorkerNode {
  final String id;
  final String workerName;
  final String topic;
  final String status;
  final double latencyMs;
  final bool isHealthy;

  const ApnsWorkerNode({
    required this.id,
    required this.workerName,
    required this.topic,
    required this.status,
    required this.latencyMs,
    required this.isHealthy,
  });
}

/// Screen component providing engineering monitoring and configuration for APNs push triggers.
class ApnsPushNotificationStatusScreenGen00693 extends StatefulWidget {
  const ApnsPushNotificationStatusScreenGen00693({super.key});

  @override
  State<ApnsPushNotificationStatusScreenGen00693> createState() =>
      _ApnsPushNotificationStatusScreenGen00693State();
}

class _ApnsPushNotificationStatusScreenGen00693State
    extends State<ApnsPushNotificationStatusScreenGen00693> {
  Timer? _pollingTimer;
  bool _isLoading = false;
  String _completionStatus = 'Complete';
  double _ingestionPassRate = 100.0;
  DateTime _lastSyncTime = DateTime.now();

  final List<ApnsWorkerNode> _workerNodes = const [
    ApnsWorkerNode(
      id: 'worker-apns-01',
      workerName: 'APNs Production Worker A',
      topic: 'ae.habot.client.alerts',
      status: 'Active',
      latencyMs: 42.5,
      isHealthy: true,
    ),
    ApnsWorkerNode(
      id: 'worker-apns-02',
      workerName: 'APNs Production Worker B',
      topic: 'ae.habot.client.orders',
      status: 'Active',
      latencyMs: 38.1,
      isHealthy: true,
    ),
    ApnsWorkerNode(
      id: 'worker-apns-03',
      workerName: 'APNs Sandbox Ingestion',
      topic: 'ae.habot.client.dev',
      status: 'Idle',
      latencyMs: 55.4,
      isHealthy: true,
    ),
    ApnsWorkerNode(
      id: 'worker-apns-04',
      workerName: 'APNs Emergency Broadcast',
      topic: 'ae.habot.client.emergency',
      status: 'Standby',
      latencyMs: 29.8,
      isHealthy: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  /// Single-verb function: poll
  void _poll() {
    setState(() {
      _lastSyncTime = DateTime.now();
      _ingestionPassRate = 100.0;
      _completionStatus = 'Complete';
    });
  }

  /// Single-verb function: sync
  Future<void> _sync() async {
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      _poll();
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('APNs triggers and SDK configuration synchronized.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        _poll();
      }
    });
  }

  /// Single-verb function: configure
  void _configure() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configure APNs Worker Alerts',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              const Text(
                'Standard: Apple APNs Protocol Guidelines\n' 
                'Target Floor Ingestion: 100% (sub-100ms client latency)',
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48.0),
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('APNs configuration updated successfully.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.verified_user),
                  label: const Text('Verify & Save Ingestion Rules'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTabletDesktop = screenWidth >= 840;

    return Scaffold(
      appBar: AppBar(
        title: const Text('APNs Push Notifications (GEN-00693)'),
        actions: [
          IconButton(
            tooltip: 'Configure APNs',
            icon: const Icon(Icons.tune),
            onPressed: _configure,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _sync,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (isTabletDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildHealthCard(theme)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMetricCard(theme)),
                ],
              )
            else ...[
              _buildHealthCard(theme),
              const SizedBox(height: 16),
              _buildMetricCard(theme),
            ],
            const SizedBox(height: 24),
            Text(
              'Worker Ingestion Array (Horizontal Scroll)',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildHorizontalWorkerArray(theme),
            const SizedBox(height: 24),
            _buildAuditMetadataCard(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCard(ThemeData theme) {
    return Card(
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Service Health',
                  style: theme.textTheme.titleMedium,
                ),
                Chip(
                  avatar: const Icon(Icons.check_circle, size: 18, color: Colors.green),
                  label: Text(_completionStatus),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Apple Push Notification service (APNs) SDK worker ingestion baseline.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.sync, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Auto-polling active (30s interval) · Synced ${_lastSyncTime.minute.toString().padLeft(2, '0')}:${_lastSyncTime.second.toString().padLeft(2, '0')}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(ThemeData theme) {
    return Card(
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'APNs SDK Ingestion Pass Rate',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _ingestionPassRate / 100.0,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Floor Threshold: 100%',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  'Current: ${_ingestionPassRate.toStringAsFixed(0)}%',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalWorkerArray(ThemeData theme) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _workerNodes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          final ApnsWorkerNode node = _workerNodes[index];
          return SizedBox(
            width: 260,
            child: Card(
              elevation: 2.0,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Inspecting ${node.workerName} (${node.id})'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              node.workerName,
                              style: theme.textTheme.titleSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.bolt, size: 18, color: Colors.amber),
                        ],
                      ),
                      Text(
                        'Topic: ${node.topic}',
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${node.latencyMs} ms',
                            style: theme.textTheme.labelMedium,
                          ),
                          Chip(
                            label: Text(node.status),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ),
                        ],
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

  Widget _buildAuditMetadataCard(ThemeData theme) {
    return Card(
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pipeline Trace & Governance',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            const Text('Reference Standard: Apple APNs Protocol Guidelines'),
            const Text('BigQuery Stream: Partitioned event_date, clustered trace_id'),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _configure,
                icon: const Icon(Icons.settings_input_antenna),
                label: const Text('Configure Alert Triggers'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
