// GEN-01600 — Activity History List Screen Layout using M3 Timeline List specifications.
// Constructs a responsive single-column (mobile <600dp) / multi-column (desktop >=840dp) activity history screen with M3 Elevated Cards, Status Chips, 48x48dp touch targets, pull-to-refresh, and 30-second background polling using local mock data.

import 'dart:async';
import 'package:flutter/material.dart';

enum ActivityStatus { complete, partial, notComplete }

class ActivityHistoryItem {
  final String id;
  final String traceId;
  final String title;
  final String description;
  final DateTime timestamp;
  final ActivityStatus status;
  final String userId;

  const ActivityHistoryItem({
    required this.id,
    required this.traceId,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.status,
    required this.userId,
  });
}

class MockActivityRepository {
  static const List<ActivityHistoryItem> _mockData = [
    ActivityHistoryItem(
      id: 'act-001',
      traceId: 'trace-99281',
      title: 'System Initialization',
      description: 'Core engine bootstrap sequence completed successfully.',
      timestamp: DateTime(2026, 9, 18, 8, 0),
      status: ActivityStatus.complete,
      userId: 'usr-eng-01',
    ),
    ActivityHistoryItem(
      id: 'act-002',
      traceId: 'trace-99282',
      title: 'Data Sync Partial',
      description: 'Background synchronization encountered minor latency threshold breach.',
      timestamp: DateTime(2026, 9, 18, 8, 15),
      status: ActivityStatus.partial,
      userId: 'usr-eng-01',
    ),
    ActivityHistoryItem(
      id: 'act-003',
      traceId: 'trace-99283',
      title: 'Authentication Handshake',
      description: 'Liveness handshake failed due to timeout. Automated rollback triggered.',
      timestamp: DateTime(2026, 9, 18, 8, 30),
      status: ActivityStatus.notComplete,
      userId: 'usr-sys-02',
    ),
    ActivityHistoryItem(
      id: 'act-004',
      traceId: 'trace-99284',
      title: 'CI/CD Pipeline Validation',
      description: 'All validation checks passed. Documentation committed to runbook.',
      timestamp: DateTime(2026, 9, 18, 9, 0),
      status: ActivityStatus.complete,
      userId: 'usr-eng-03',
    ),
    ActivityHistoryItem(
      id: 'act-005',
      traceId: 'trace-99285',
      title: 'BigQuery Stream Event',
      description: 'Step execution event streamed to partitioned dataset.',
      timestamp: DateTime(2026, 9, 18, 9, 45),
      status: ActivityStatus.complete,
      userId: 'usr-sys-01',
    ),
  ];

  Future<List<ActivityHistoryItem>> fetchActivities() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockData;
  }
}

class ActivityHistoryListScreen extends StatefulWidget {
  const ActivityHistoryListScreen({super.key});

  @override
  State<ActivityHistoryListScreen> createState() => _ActivityHistoryListScreenState();
}

class _ActivityHistoryListScreenState extends State<ActivityHistoryListScreen> {
  final MockActivityRepository _repository = MockActivityRepository();
  List<ActivityHistoryItem> _activities = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _repository.fetchActivities();
      if (mounted) {
        setState(() {
          _activities = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadData();
    });
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  void _showConfigBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Configuration Inputs', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Metric Threshold',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Configuration saved successfully.')),
                      );
                    }
                  },
                  child: const Text('Apply'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showConfigBottomSheet(context),
            tooltip: 'Configuration',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 840;
          if (_isLoading && _activities.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final content = RefreshIndicator(
            onRefresh: _onRefresh,
            child: _buildTimelineList(context, isDesktop),
          );
          if (isDesktop) {
            return Row(
              children: [
                Expanded(flex: 2, child: content),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildHealthCard(context),
                  ),
                ),
              ],
            );
          }
          return content;
        },
      ),
    );
  }

  Widget _buildTimelineList(BuildContext context, bool isDesktop) {
    if (_activities.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(child: Text('No activity logs available.')),
        ],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16, vertical: 16),
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final item = _activities[index];
        return _TimelineTile(item: item, isLast: index == _activities.length - 1);
      },
    );
  }

  Widget _buildHealthCard(BuildContext context) {
    final theme = Theme.of(context);
    final completeness = _activities.isEmpty ? 0.0 : _activities.where((e) => e.status == ActivityStatus.complete).length / _activities.length;
    final healthStatus = completeness >= 0.95 ? 'Optimal' : completeness >= 0.8 ? 'Partial' : 'Degraded';
    final chipColor = completeness >= 0.95 ? Colors.green : completeness >= 0.8 ? Colors.orange : Colors.red;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Step Health', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Data Completeness', style: theme.textTheme.bodyLarge),
                Chip(
                  label: Text(healthStatus, style: TextStyle(color: chipColor, fontWeight: FontWeight.bold)),
                  backgroundColor: chipColor.withOpacity(0.1),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: completeness,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text('${(completeness * 100).toStringAsFixed(1)}% (Floor: 95%)', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final ActivityHistoryItem item;
  final bool isLast;

  const _TimelineTile({required this.item, required this.isLast});

  Color _statusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.complete:
        return Colors.green;
      case ActivityStatus.partial:
        return Colors.orange;
      case ActivityStatus.notComplete:
        return Colors.red;
    }
  }

  IconData _statusIcon(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.complete:
        return Icons.check_circle;
      case ActivityStatus.partial:
        return Icons.warning_amber_rounded;
      case ActivityStatus.notComplete:
        return Icons.error_outline;
    }
  }

  String _statusLabel(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.complete:
        return 'Complete';
      case ActivityStatus.partial:
        return 'Partial';
      case ActivityStatus.notComplete:
        return 'Not Complete';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor(item.status);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 48,
            child: Column(
              children: [
                Icon(_statusIcon(item.status), color: color, size: 24),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(12),
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
                                item.title,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Chip(
                              label: Text(
                                _statusLabel(item.status),
                                style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: color.withOpacity(0.1),
                              side: BorderSide.none,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(item.description, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')} • ${item.timestamp.day}/${item.timestamp.month}/${item.timestamp.year}',
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                            const Spacer(),
                            Text(
                              'Trace: ${item.traceId}',
                              style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}