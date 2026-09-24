// GEN-02193 — Micro-Training (5-Min Video SOPs) Delivery Checklist Widget.
// Mobile-first single-column checklist with M3 components, 48x48dp touch targets, progress indicator, and local mock data for onboarding tasks.

import 'package:flutter/material.dart';

enum TaskCompletionStatus { complete, partial, notComplete }

class TrainingTask {
  final String id;
  final String title;
  final String description;
  final TaskCompletionStatus status;
  final bool isCurrent;

  const TrainingTask({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.isCurrent = false,
  });
}

const List<TrainingTask> _mockTrainingTasks = [
  TrainingTask(
    id: 'task_001',
    title: 'Company Culture & Values',
    description: 'Watch the 5-min intro video on our core values.',
    status: TaskCompletionStatus.complete,
  ),
  TrainingTask(
    id: 'task_002',
    title: 'Security & Compliance SOP',
    description: 'Review data handling policies and sign acknowledgment.',
    status: TaskCompletionStatus.complete,
  ),
  TrainingTask(
    id: 'task_003',
    title: 'Tools & Systems Setup',
    description: 'Configure your workstation and login credentials.',
    status: TaskCompletionStatus.partial,
    isCurrent: true,
  ),
  TrainingTask(
    id: 'task_004',
    title: 'Team Introduction',
    description: 'Join the virtual meet-and-greet session.',
    status: TaskCompletionStatus.notComplete,
  ),
  TrainingTask(
    id: 'task_005',
    title: 'Role-Specific Training',
    description: 'Complete the assigned micro-learning modules.',
    status: TaskCompletionStatus.notComplete,
  ),
];

class MicroTrainingChecklistGen02193 extends StatefulWidget {
  const MicroTrainingChecklistGen02193({super.key});

  @override
  State<MicroTrainingChecklistGen02193> createState() =>
      _MicroTrainingChecklistGen02193State();
}

class _MicroTrainingChecklistGen02193State
    extends State<MicroTrainingChecklistGen02193> {
  late List<TrainingTask> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = List.from(_mockTrainingTasks);
  }

  double get _completionRate {
    if (_tasks.isEmpty) return 0.0;
    final completed =
        _tasks.where((t) => t.status == TaskCompletionStatus.complete).length;
    return completed / _tasks.length;
  }

  int get _currentStepIndex {
    final idx = _tasks.indexWhere((t) => t.isCurrent);
    return idx == -1 ? 0 : idx;
  }

  void _advanceTask(int index) {
    setState(() {
      final task = _tasks[index];
      final newStatus = task.status == TaskCompletionStatus.notComplete
          ? TaskCompletionStatus.partial
          : TaskCompletionStatus.complete;

      _tasks[index] = TrainingTask(
        id: task.id,
        title: task.title,
        description: task.description,
        status: newStatus,
        isCurrent: false,
      );

      if (newStatus == TaskCompletionStatus.complete &&
          index + 1 < _tasks.length) {
        final next = _tasks[index + 1];
        _tasks[index + 1] = TrainingTask(
          id: next.id,
          title: next.title,
          description: next.description,
          status: next.status,
          isCurrent: true,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task updated successfully.'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _statusColor(TaskCompletionStatus status, ThemeData theme) {
    switch (status) {
      case TaskCompletionStatus.complete:
        return theme.colorScheme.primary;
      case TaskCompletionStatus.partial:
        return theme.colorScheme.tertiary;
      case TaskCompletionStatus.notComplete:
        return theme.colorScheme.outlineVariant;
    }
  }

  IconData _statusIcon(TaskCompletionStatus status) {
    switch (status) {
      case TaskCompletionStatus.complete:
        return Icons.check_circle_rounded;
      case TaskCompletionStatus.partial:
        return Icons.pending_actions_rounded;
      case TaskCompletionStatus.notComplete:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Day 1 Onboarding'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(_completionRate * 100).toStringAsFixed(0)}%',
                  style: textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Completed',
                  style: textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: LinearProgressIndicator(
              value: _completionRate,
              minHeight: 8.0,
              borderRadius: BorderRadius.circular(4.0),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: _tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12.0),
              itemBuilder: (context, index) {
                final task = _tasks[index];
                final isCurrent = task.isCurrent ||
                    (index == _currentStepIndex &&
                        task.status != TaskCompletionStatus.complete);

                return Card(
                  elevation: isCurrent ? 2.0 : 0.0,
                  color: isCurrent
                      ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                      : theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    side: BorderSide(
                      color: isCurrent
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                      width: isCurrent ? 2.0 : 1.0,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _advanceTask(index),
                    borderRadius: BorderRadius.circular(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _statusIcon(task.status),
                            size: 28.0,
                            color: _statusColor(task.status, theme),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: isCurrent
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: task.status ==
                                            TaskCompletionStatus.complete
                                        ? theme.colorScheme.onSurface
                                            .withOpacity(0.6)
                                        : theme.colorScheme.onSurface,
                                    decoration: task.status ==
                                            TaskCompletionStatus.complete
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  task.description,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color:
                                        theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (isCurrent) ...[
                                  const SizedBox(height: 8.0),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 4.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius:
                                          BorderRadius.circular(12.0),
                                    ),
                                    child: Text(
                                      'Current Task',
                                      style:
                                          textTheme.labelSmall?.copyWith(
                                        color:
                                            theme.colorScheme.onPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (task.status != TaskCompletionStatus.complete)
                            SizedBox(
                              width: 48.0,
                              height: 48.0,
                              child: IconButton(
                                onPressed: () => _advanceTask(index),
                                icon: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 20.0,
                                  color: theme.colorScheme.primary,
                                ),
                                tooltip: 'Advance task',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _currentStepIndex < _tasks.length &&
              _tasks[_currentStepIndex].status !=
                  TaskCompletionStatus.complete
          ? FloatingActionButton(
              onPressed: () => _advanceTask(_currentStepIndex),
              tooltip: 'Complete current task',
              child: const Icon(Icons.check_rounded),
            )
          : null,
    );
  }
}