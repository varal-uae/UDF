// GEN-01776 — OPS Task Deconstruction Status Card.
// M3 Elevated Card displaying step completion state for image cropping task deconstruction with mock data, background polling simulation, and responsive layout.

import 'dart:async';
import 'package:flutter/material.dart';

enum StepCompletionStatus { complete, partial, notComplete }

class OpsTaskDeconstructionModel {
  final String atomicId;
  final String stepName;
  final StepCompletionStatus status;
  final double completionRate;
  final DateTime lastUpdated;
  final String traceId;

  const OpsTaskDeconstructionModel({
    required this.atomicId,
    required this.stepName,
    required this.status,
    required this.completionRate,
    required this.lastUpdated,
    required this.traceId,
  });
}

class MockOpsRepository {
  static const List<OpsTaskDeconstructionModel> mockTasks = [
    OpsTaskDeconstructionModel(
      atomicId: 'GEN-01776',
      stepName: 'Force OPS to further deconstruct tasks if image cropping fails',
      status: StepCompletionStatus.complete,
      completionRate: 98.5,
      lastUpdated: null as dynamic,
      traceId: 'trace-001-gen-01776',
    ),
  ];

  static Future<List<OpsTaskDeconstructionModel>> fetchTasks() async {
    await Future.delayed(const Duration(milliseconds: 80));
    return [
      OpsTaskDeconstructionModel(
        atomicId: 'GEN-01776',
        stepName: 'Force OPS to further deconstruct tasks if image cropping fails',
        status: StepCompletionStatus.complete,
        completionRate: 98.5,
        lastUpdated: DateTime.now(),
        traceId: 'trace-001-gen-01776',
      ),
    ];
  }
}

class OpsTaskDeconstructionCard extends StatefulWidget {
  const OpsTaskDeconstructionCard({super.key});

  @override
  State<OpsTaskDeconstructionCard> createState() => _OpsTaskDeconstructionCardState();
}

class _OpsTaskDeconstructionCardState extends State<OpsTaskDeconstructionCard> {
  List<OpsTaskDeconstructionModel> _tasks = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

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
    setState(() => _isLoading = true);
    try {
      final data = await MockOpsRepository.fetchTasks();
      if (mounted) {
        setState(() {
          _tasks = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(BuildContext context, StepCompletionStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case StepCompletionStatus.complete:
        return colorScheme.primary;
      case StepCompletionStatus.partial:
        return colorScheme.tertiary;
      case StepCompletionStatus.notComplete:
        return colorScheme.error;
    }
  }

  String _getStatusLabel(StepCompletionStatus status) {
    switch (status) {
      case StepCompletionStatus.complete:
        return 'Complete';
      case StepCompletionStatus.partial:
        return 'Partial';
      case StepCompletionStatus.notComplete:
        return 'Not Complete';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 840;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = isDesktop ? 2 : 1;

          if (_isLoading && _tasks.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (_tasks.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('No task data available.'),
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: isDesktop ? 2.5 : 2.0,
            ),
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              final task = _tasks[index];
              return _buildElevatedCard(context, task);
            },
          );
        },
      ),
    );
  }

  Widget _buildElevatedCard(BuildContext context, OpsTaskDeconstructionModel task) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _getStatusColor(context, task.status);

    return Card(
      elevation: 3.0,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Drill-down for ${task.atomicId}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.atomicId,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      _getStatusLabel(task.status),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    backgroundColor: statusColor,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                task.stepName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Completion Rate',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${task.completionRate.toStringAsFixed(1)}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: task.completionRate >= 90
                          ? colorScheme.primary
                          : colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: task.completionRate / 100.0,
                minHeight: 4.0,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}