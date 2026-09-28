// GEN-03706 — Automated Cash Forecasting Pipeline and Mobile Treasury Dashboard.
// Displays a read-only engineering console dashboard with M3 Elevated Cards, status chips,
// background polling every 30 seconds, pull-to-refresh, responsive single/multi-column layout,
// and Material You dynamic color using local mock data.

import 'dart:async';
import 'package:flutter/material.dart';

enum StepStatus { complete, notComplete, inProgress }

class MockForecastStep {
  final String id;
  final String title;
  final String description;
  final StepStatus status;
  final DateTime timestamp;

  const MockForecastStep({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.timestamp,
  });
}

final List<MockForecastStep> _mockSteps = [
  MockForecastStep(
    id: 'GEN-03705',
    title: 'Foundational Configuration',
    description: 'Baseline configuration for cash forecasting pipeline.',
    status: StepStatus.complete,
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  MockForecastStep(
    id: 'GEN-03706',
    title: 'Automated Cash Forecasting Pipeline',
    description: 'Produce the expected output: Automated Cash Forecasting Pipeline and Mobile Treasury Dashboard.',
    status: StepStatus.inProgress,
    timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
  ),
  MockForecastStep(
    id: 'GEN-03707',
    title: 'Mobile Treasury Dashboard Validation',
    description: 'CI/CD pass rate validation and runbook documentation.',
    status: StepStatus.notComplete,
    timestamp: DateTime.now(),
  ),
];

class CashForecastDashboardGen03706 extends StatefulWidget {
  const CashForecastDashboardGen03706({super.key});

  @override
  State<CashForecastDashboardGen03706> createState() => _CashForecastDashboardGen03706State();
}

class _CashForecastDashboardGen03706State extends State<CashForecastDashboardGen03706> {
  late List<MockForecastStep> _steps;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _steps = List.from(_mockSteps);
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    // Simulate network latency < 100ms
    await Future.delayed(const Duration(milliseconds: 80));
    if (mounted) {
      setState(() {
        _steps = List.from(_mockSteps);
        _isRefreshing = false;
      });
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Color _statusColor(StepStatus status, ColorScheme cs) {
    switch (status) {
      case StepStatus.complete:
        return cs.primary;
      case StepStatus.inProgress:
        return cs.tertiary;
      case StepStatus.notComplete:
        return cs.error;
    }
  }

  String _statusLabel(StepStatus status) {
    switch (status) {
      case StepStatus.complete:
        return 'Complete';
      case StepStatus.inProgress:
        return 'In Progress';
      case StepStatus.notComplete:
        return 'Not Complete';
    }
  }

  void _showConfigBottomSheet(BuildContext context, MockForecastStep step) {
    showModalBottomSheet(
      context: context,
      useMaterial3: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Configuration: ${step.id}', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              Text(step.description, style: Theme.of(ctx).textTheme.bodyMedium),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${step.id} configuration saved.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Apply Configuration'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, MockForecastStep step) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 3.0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showConfigBottomSheet(context, step),
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
                      step.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Chip(
                    avatar: Icon(
                      step.status == StepStatus.complete ? Icons.check_circle : Icons.info_outline,
                      size: 18,
                      color: _statusColor(step.status, cs),
                    ),
                    label: Text(_statusLabel(step.status)),
                    side: BorderSide(color: _statusColor(step.status, cs)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(step.description, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${step.timestamp.hour}:${step.timestamp.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const Spacer(),
                  Icon(Icons.link, size: 16, color: cs.primary),
                  const SizedBox(width: 4),
                  Text('Drill-down', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.primary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treasury Dashboard'),
        centerTitle: false,
        actions: [
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: _fetchData,
              tooltip: 'Manual Sync',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 840;
            if (isDesktop) {
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.8,
                ),
                itemCount: _steps.length,
                itemBuilder: (ctx, i) => _buildCard(ctx, _steps[i]),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _steps.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => _buildCard(ctx, _steps[i]),
            );
          },
        ),
      ),
    );
  }
}