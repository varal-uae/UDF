// GEN-01875 — Real-Time SLA Countdown Hook with M3 Status Cards.
// Implements time limit boundary determination (5 mins vs 15 mins) based on task complexity, displayed via Material 3 Elevated Cards and Status Chips in a responsive single/multi-column layout.

import 'dart:async';
import 'package:flutter/material.dart';

enum TaskComplexity { low, medium, high }
enum CompletionStatus { complete, partial, notComplete }

class SlaTaskModel {
  final String traceId;
  final String title;
  final TaskComplexity complexity;
  final Duration timeLimit;
  final DateTime startedAt;
  final CompletionStatus status;

  const SlaTaskModel({
    required this.traceId,
    required this.title,
    required this.complexity,
    required this.timeLimit,
    required this.startedAt,
    required this.status,
  });

  Duration get remainingTime {
    final elapsed = DateTime.now().difference(startedAt);
    final remaining = timeLimit - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

class MockSlaRepository {
  static List<SlaTaskModel> fetchTasks() {
    final now = DateTime.now();
    return [
      SlaTaskModel(
        traceId: 'trace-001-gen-01875',
        title: 'Database Migration Validation',
        complexity: TaskComplexity.high,
        timeLimit: const Duration(minutes: 15),
        startedAt: now.subtract(const Duration(minutes: 2)),
        status: CompletionStatus.partial,
      ),
      SlaTaskModel(
        traceId: 'trace-002-gen-01875',
        title: 'API Endpoint Health Check',
        complexity: TaskComplexity.low,
        timeLimit: const Duration(minutes: 5),
        startedAt: now.subtract(const Duration(minutes: 4)),
        status: CompletionStatus.complete,
      ),
      SlaTaskModel(
        traceId: 'trace-003-gen-01875',
        title: 'Security Token Rotation',
        complexity: TaskComplexity.medium,
        timeLimit: const Duration(minutes: 10),
        startedAt: now.subtract(const Duration(minutes: 11)),
        status: CompletionStatus.notComplete,
      ),
    ];
  }
}

class SlaCountdownHookGen01875 extends StatefulWidget {
  const SlaCountdownHookGen01875({super.key});

  @override
  State<SlaCountdownHookGen01875> createState() => _SlaCountdownHookGen01875State();
}

class _SlaCountdownHookGen01875State extends State<SlaCountdownHookGen01875> {
  late List<SlaTaskModel> _tasks;
  Timer? _pollingTimer;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _tasks = MockSlaRepository.fetchTasks();
    // Background polling refreshes data every 30 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshData();
    });
    // UI countdown tick every second
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _refreshData() {
    if (mounted) {
      setState(() {
        _tasks = MockSlaRepository.fetchTasks();
      });
    }
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _refreshData();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Color _getStatusColor(BuildContext context, CompletionStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case CompletionStatus.complete:
        return colorScheme.primary;
      case CompletionStatus.partial:
        return colorScheme.tertiary;
      case CompletionStatus.notComplete:
        return colorScheme.error;
    }
  }

  String _getStatusLabel(CompletionStatus status) {
    switch (status) {
      case CompletionStatus.complete:
        return 'Complete';
      case CompletionStatus.partial:
        return 'Partial';
      case CompletionStatus.notComplete:
        return 'Not Complete';
    }
  }

  int _getComplexityMinutes(TaskComplexity c) {
    switch (c) {
      case TaskComplexity.low:
        return 5;
      case TaskComplexity.medium:
        return 10;
      case TaskComplexity.high:
        return 15;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SLA Countdown Dashboard'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp)
            final isDesktop = constraints.maxWidth >= 840;
            final isTablet = constraints.maxWidth >= 600 && !isDesktop;
            
            final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);

            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: isDesktop ? 1.8 : 2.2,
              ),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return _SlaTaskCard(
                  task: task,
                  formatDuration: _formatDuration,
                  getStatusColor: _getStatusColor,
                  getStatusLabel: _getStatusLabel,
                  getComplexityMinutes: _getComplexityMinutes,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SlaTaskCard extends StatelessWidget {
  final SlaTaskModel task;
  final String Function(Duration) formatDuration;
  final Color Function(BuildContext, CompletionStatus) getStatusColor;
  final String Function(CompletionStatus) getStatusLabel;
  final int Function(TaskComplexity) getComplexityMinutes;

  const _SlaTaskCard({
    required this.task,
    required this.formatDuration,
    required this.getStatusColor,
    required this.getStatusLabel,
    required this.getComplexityMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = getStatusColor(context, task.status);
    final remaining = task.remainingTime;
    final isExpired = remaining == Duration.zero && task.status != CompletionStatus.complete;

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Deep-link drill-down placeholder
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Drilling down into trace: ${task.traceId}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
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
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // M3 Status Chips for health indicators
                  Chip(
                    label: Text(
                      getStatusLabel(task.status),
                      style: TextStyle(color: statusColor, fontSize: 12),
                    ),
                    backgroundColor: statusColor.withOpacity(0.1),
                    side: BorderSide(color: statusColor.withOpacity(0.3)),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Trace ID: ${task.traceId}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Boundary Limit: ${getComplexityMinutes(task.complexity)} mins (${task.complexity.name.toUpperCase()} Complexity)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Remaining Time:',
                    style: theme.textTheme.labelLarge,
                  ),
                  Text(
                    isExpired ? 'EXPIRED' : formatDuration(remaining),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: isExpired ? colorScheme.error : colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: isExpired
                    ? 1.0
                    : 1.0 - (remaining.inSeconds / task.timeLimit.inSeconds).clamp(0.0, 1.0),
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isExpired ? colorScheme.error : colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}