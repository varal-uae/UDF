// GEN-01037 — Post-Release Monitoring & Auto-Rollback Status Dashboard.
// Displays M3 status cards for Cloud Run auto-rollback health, KPI metrics, and completion state in a responsive single/multi-column layout.

import 'dart:async';
import 'package:flutter/material.dart';

enum RollbackStatus { pass, fail, pending }

class MockRollbackEvent {
  final String traceId;
  final String stepName;
  final RollbackStatus status;
  final double dispatchDelaySecs;
  final DateTime timestamp;

  const MockRollbackEvent({
    required this.traceId,
    required this.stepName,
    required this.status,
    required this.dispatchDelaySecs,
    required this.timestamp,
  });
}

final List<MockRollbackEvent> _mockEvents = [
  MockRollbackEvent(
    traceId: 'trace-001-gen-01037',
    stepName: 'Auto-revert Cloud Run to previous commit',
    status: RollbackStatus.pass,
    dispatchDelaySecs: 0.8,
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  MockRollbackEvent(
    traceId: 'trace-002-gen-01037',
    stepName: 'Failover mechanism sandbox test',
    status: RollbackStatus.fail,
    dispatchDelaySecs: 4.2,
    timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
  ),
  MockRollbackEvent(
    traceId: 'trace-003-gen-01037',
    stepName: 'Liveness Handshake Monitor',
    status: RollbackStatus.pending,
    dispatchDelaySecs: 1.5,
    timestamp: DateTime.now().subtract(const Duration(seconds: 30)),
  ),
];

class ReleaseMonitoringScreenGen01037 extends StatefulWidget {
  const ReleaseMonitoringScreenGen01037({super.key});

  @override
  State<ReleaseMonitoringScreenGen01037> createState() => _ReleaseMonitoringScreenStateGen01037();
}

class _ReleaseMonitoringScreenStateGen01037 extends State<ReleaseMonitoringScreenGen01037> {
  Timer? _pollingTimer;
  List<MockRollbackEvent> _events = [];
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadData());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _events = List.from(_mockEvents);
      _isRefreshing = false;
    });
  }

  Color _statusColor(RollbackStatus status, ThemeData theme) {
    switch (status) {
      case RollbackStatus.pass:
        return theme.colorScheme.primary;
      case RollbackStatus.fail:
        return theme.colorScheme.error;
      case RollbackStatus.pending:
        return theme.colorScheme.tertiary;
    }
  }

  String _statusLabel(RollbackStatus status) {
    switch (status) {
      case RollbackStatus.pass:
        return 'Pass';
      case RollbackStatus.fail:
        return 'Fail';
      case RollbackStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 840;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Release Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'SRE Auto-Rollback Spec',
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GEN-01037: End Document Lock Verification',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Auto-Rollback Dispatch Delay Target: \u2264 3 secs',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (_isRefreshing) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = isDesktop ? 2 : 1;
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: isDesktop ? 2.8 : 2.2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final event = _events[index];
                        return _buildStatusCard(event, theme);
                      },
                      childCount: _events.length,
                    ),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(MockRollbackEvent event, ThemeData theme) {
    final statusColor = _statusColor(event.status, theme);
    final meetsThreshold = event.dispatchDelaySecs <= 3.0;

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () => _showDetailSheet(event),
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
                      event.stepName,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Chip(
                    label: Text(
                      _statusLabel(event.status),
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: statusColor.withOpacity(0.12),
                    side: BorderSide.none,
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    meetsThreshold ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                    size: 20,
                    color: meetsThreshold ? theme.colorScheme.primary : theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Delay: ${event.dispatchDelaySecs.toStringAsFixed(1)}s',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: meetsThreshold ? theme.colorScheme.onSurface : theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Trace: ${event.traceId}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailSheet(MockRollbackEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
            left: 24,
            right: 24,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Step Details', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Action'),
                subtitle: Text(event.stepName),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Status'),
                subtitle: Text(_statusLabel(event.status)),
                trailing: Icon(
                  event.status == RollbackStatus.pass ? Icons.check_circle : Icons.cancel,
                  color: _statusColor(event.status, theme),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Dispatch Delay'),
                subtitle: Text('${event.dispatchDelaySecs.toStringAsFixed(2)} seconds'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Timestamp'),
                subtitle: Text(event.timestamp.toIso8601String()),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Configuration acknowledged.'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  },
                  child: const Text('Acknowledge & Close'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}