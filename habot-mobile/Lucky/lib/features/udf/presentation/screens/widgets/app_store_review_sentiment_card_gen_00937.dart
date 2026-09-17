// GEN-00937 — App Store Review Sentiment Attribution Engine Status Card.
// M3 Elevated Card displaying API Ingestion Success Rate, completion state, and liveness handshake status for Apple App Store Connect API workers. Single-column mobile layout with 48x48dp touch targets and 30-second background polling simulation.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data model representing the ingestion worker status.
class _IngestionWorkerStatus {
  final String workerId;
  final String apiSpec;
  final double successRate;
  final bool isComplete;
  final DateTime lastHandshake;
  final String traceId;

  const _IngestionWorkerStatus({
    required this.workerId,
    required this.apiSpec,
    required this.successRate,
    required this.isComplete,
    required this.lastHandshake,
    required this.traceId,
  });
}

/// Realistic local mock data simulating Apple App Store Connect API ingestion workers.
const List<_IngestionWorkerStatus> _mockWorkerData = [
  _IngestionWorkerStatus(
    workerId: 'worker-appstore-connect-01',
    apiSpec: 'Apple App Store Connect API Spec v2.3',
    successRate: 1.0,
    isComplete: true,
    lastHandshake: null as dynamic, // Replaced in build
    traceId: 'trace-8a7b6c5d-0001',
  ),
  _IngestionWorkerStatus(
    workerId: 'worker-appstore-connect-02',
    apiSpec: 'Apple App Store Connect API Spec v2.3',
    successRate: 0.9995,
    isComplete: true,
    lastHandshake: null as dynamic,
    traceId: 'trace-8a7b6c5d-0002',
  ),
];

class AppStoreReviewSentimentCardGen00937 extends StatefulWidget {
  const AppStoreReviewSentimentCardGen00937({super.key});

  @override
  State<AppStoreReviewSentimentCardGen00937> createState() => _AppStoreReviewSentimentCardGen00937State();
}

class _AppStoreReviewSentimentCardGen00937State extends State<AppStoreReviewSentimentCardGen00937> {
  Timer? _pollingTimer;
  late List<_IngestionWorkerStatus> _currentData;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _currentData = _generateMockDataWithTimestamps();
    // Background polling refreshes data every 30 seconds.
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _simulateBackgroundPolling();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  List<_IngestionWorkerStatus> _generateMockDataWithTimestamps() {
    final now = DateTime.now();
    return _mockWorkerData.map((w) => _IngestionWorkerStatus(
      workerId: w.workerId,
      apiSpec: w.apiSpec,
      successRate: w.successRate,
      isComplete: w.isComplete,
      lastHandshake: now.subtract(const Duration(seconds: 12)),
      traceId: w.traceId,
    )).toList();
  }

  Future<void> _simulateBackgroundPolling() async {
    if (!mounted) return;
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _currentData = _generateMockDataWithTimestamps();
      _isSyncing = false;
    });
  }

  Future<void> _handlePullToRefresh() async {
    await _simulateBackgroundPolling();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Manual sync complete. All gates passing.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openConfigurationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configuration Inputs', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'API Key ID',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Issuer ID',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48, // 48x48dp touch target
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Configuration saved successfully.')),
                  );
                },
                child: const Text('Apply Configuration'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: _handlePullToRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp).
          final isDesktop = constraints.maxWidth >= 840;
          final crossAxisCount = isDesktop ? 2 : 1;

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: isDesktop ? 2.5 : 1.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final worker = _currentData[index];
                      return _buildWorkerCard(context, worker, theme, colorScheme);
                    },
                    childCount: _currentData.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWorkerCard(
    BuildContext context,
    _IngestionWorkerStatus worker,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final meetsFloorBoundary = worker.successRate >= 0.999;
    final statusColor = meetsFloorBoundary ? colorScheme.primary : colorScheme.error;
    final statusLabel = worker.isComplete ? 'Complete' : 'Not Complete';

    return Card(
      elevation: 3, // M3 Elevated Cards Level 2 (3dp)
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openConfigurationSheet(context),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Sentiment Engine',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_isSyncing)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
                    )
                  else
                    // M3 Status Chips for health indicators
                    Chip(
                      avatar: Icon(Icons.circle, size: 12, color: statusColor),
                      label: Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                      backgroundColor: statusColor.withOpacity(0.1),
                      side: BorderSide.none,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'API Ingestion Success Rate:',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(worker.successRate * 100).toStringAsFixed(2)}%',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Target: \u2265 99.9% | Optimal: 100%',
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const Spacer(),
              Divider(color: colorScheme.outlineVariant, thickness: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Trace: ${worker.traceId}',
                      style: theme.textTheme.labelSmall?.copyWith(fontFamily: 'monospace'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 48x48dp touch target for deep-link drill-down
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      icon: const Icon(Icons.open_in_new_rounded),
                      tooltip: 'Drill-down details',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Deep-linking to BigQuery trace: ${worker.traceId}')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
