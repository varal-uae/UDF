// FEBFL-001-A08 — Non-blocking export task status panel with failed-state retry and dismiss actions.
// Provides compact Material 3 panels for background file export tracking, including error, retry, and dismiss controls.

import 'package:flutter/material.dart';

enum ExportTaskStatus { running, succeeded, failed }

class ExportTaskState {
  const ExportTaskState({
    required this.id,
    required this.fileName,
    required this.status,
    this.progress,
    this.errorMessage,
  });

  final String id;
  final String fileName;
  final ExportTaskStatus status;
  final double? progress;
  final String? errorMessage;
}

class Febfl001A08ExportStatusPanel extends StatelessWidget {
  const Febfl001A08ExportStatusPanel({
    super.key,
    required this.task,
    this.onRetry,
    this.onDismiss,
    this.onPreview,
  });

  final ExportTaskState task;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFailed = task.status == ExportTaskStatus.failed;

    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_iconFor(task.status), color: _colorFor(task.status, colorScheme)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (onDismiss != null)
                    IconButton(
                      tooltip: 'Dismiss',
                      icon: const Icon(Icons.close),
                      onPressed: onDismiss,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (task.status == ExportTaskStatus.running) ...[
                LinearProgressIndicator(value: task.progress),
                const SizedBox(height: 8),
                Text('Export in progress', style: Theme.of(context).textTheme.bodySmall),
              ] else if (task.status == ExportTaskStatus.succeeded) ...[
                Text('Export ready', style: Theme.of(context).textTheme.bodyMedium),
                if (onPreview != null) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: onPreview,
                    icon: const Icon(Icons.preview_outlined),
                    label: const Text('Preview'),
                  ),
                ],
              ] else if (isFailed) ...[
                Text(
                  task.errorMessage ?? 'Export failed. Please try again.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.error),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: onDismiss,
                      child: const Text('Dismiss'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(ExportTaskStatus status) {
    switch (status) {
      case ExportTaskStatus.running:
        return Icons.downloading;
      case ExportTaskStatus.succeeded:
        return Icons.check_circle_outline;
      case ExportTaskStatus.failed:
        return Icons.error_outline;
    }
  }

  Color _colorFor(ExportTaskStatus status, ColorScheme scheme) {
    switch (status) {
      case ExportTaskStatus.running:
        return scheme.primary;
      case ExportTaskStatus.succeeded:
        return scheme.primary;
      case ExportTaskStatus.failed:
        return scheme.error;
    }
  }
}
