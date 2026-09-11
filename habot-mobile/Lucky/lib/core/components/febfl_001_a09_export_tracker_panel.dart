// FEBFL-001-A09 — Non-blocking export task tracker with concurrent status panels.
// Provides a floating badge on mobile, an expandable lower-corner panel, and a desktop sidebar panel.

import 'package:flutter/material.dart';

enum ExportStatus { queued, running, completed, failed, paused }

class ExportTask {
  final String id;
  final String fileName;
  final String format;
  final ExportStatus status;
  final double progress;
  final String? downloadUrl;
  final String? exportPath;
  final DateTime? timestamp;
  final int? fileSizeBytes;
  final bool previewAvailable;
  final List<Map<String, dynamic>>? previewRows;

  const ExportTask({
    required this.id,
    required this.fileName,
    required this.format,
    required this.status,
    this.progress = 0,
    this.downloadUrl,
    this.exportPath,
    this.timestamp,
    this.fileSizeBytes,
    this.previewAvailable = false,
    this.previewRows,
  });

  bool get isActive => status == ExportStatus.queued || status == ExportStatus.running;
  bool get isComplete => status == ExportStatus.completed;
}

class ExportTrackerHost extends StatefulWidget {
  final Widget child;
  final List<ExportTask> tasks;
  final ValueChanged<ExportTask>? onPreview;
  final ValueChanged<ExportTask>? onRetry;
  final ValueChanged<ExportTask>? onDismiss;

  const ExportTrackerHost({
    super.key,
    required this.child,
    required this.tasks,
    this.onPreview,
    this.onRetry,
    this.onDismiss,
  });

  @override
  State<ExportTrackerHost> createState() => _ExportTrackerHostState();
}

class _ExportTrackerHostState extends State<ExportTrackerHost> {
  bool _minimized = true;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 900;
    final activeCount = widget.tasks.where((t) => t.isActive).length;

    if (widget.tasks.isEmpty) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned(
          right: 16,
          bottom: 16,
          top: isDesktop && !_minimized ? 88 : null,
          child: SafeArea(
            child: _minimized
                ? _FloatingExportBadge(
                    count: activeCount == 0 ? widget.tasks.length : activeCount,
                    onTap: () => setState(() => _minimized = false),
                  )
                : _ExpandedExportPanel(
                    tasks: widget.tasks,
                    isDesktop: isDesktop,
                    onMinimize: () => setState(() => _minimized = true),
                    onPreview: widget.onPreview,
                    onRetry: widget.onRetry,
                    onDismiss: widget.onDismiss,
                  ),
          ),
        ),
      ],
    );
  }
}

class _FloatingExportBadge extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _FloatingExportBadge({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(999),
      color: cs.primaryContainer,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.downloading, size: 20, color: cs.onPrimaryContainer),
              const SizedBox(width: 8),
              Text(
                '$count',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpandedExportPanel extends StatelessWidget {
  final List<ExportTask> tasks;
  final bool isDesktop;
  final VoidCallback onMinimize;
  final ValueChanged<ExportTask>? onPreview;
  final ValueChanged<ExportTask>? onRetry;
  final ValueChanged<ExportTask>? onDismiss;

  const _ExpandedExportPanel({
    required this.tasks,
    required this.isDesktop,
    required this.onMinimize,
    this.onPreview,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      color: cs.surface,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 360 : 420,
          maxHeight: isDesktop ? double.infinity : 420,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                children: [
                  Icon(Icons.cloud_download_outlined, color: cs.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Export tasks',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Minimize',
                    onPressed: onMinimize,
                    icon: const Icon(Icons.minimize),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: tasks.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return _ExportTaskTile(
                    task: task,
                    onPreview: onPreview,
                    onRetry: onRetry,
                    onDismiss: onDismiss,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportTaskTile extends StatelessWidget {
  final ExportTask task;
  final ValueChanged<ExportTask>? onPreview;
  final ValueChanged<ExportTask>? onRetry;
  final ValueChanged<ExportTask>? onDismiss;

  const _ExportTaskTile({
    required this.task,
    this.onPreview,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = _statusColor(context, task.status);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(_statusIcon(task.status), color: statusColor),
      title: Text(task.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text('${task.format} • ${task.status.name}'),
          if (task.isActive) ...[
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: task.progress.clamp(0, 1).toDouble(),
              backgroundColor: cs.surfaceContainerHighest,
            ),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (task.isComplete && task.previewAvailable)
            IconButton(
              tooltip: 'Preview',
              onPressed: () {
                if (onPreview != null) {
                  onPreview!(task);
                } else {
                  _showPreviewDialog(context, task);
                }
              },
              icon: const Icon(Icons.preview_outlined),
            ),
          if (task.status == ExportStatus.failed)
            IconButton(
              tooltip: 'Retry',
              onPressed: onRetry == null ? null : () => onRetry!(task),
              icon: const Icon(Icons.refresh),
            ),
          if (!task.isActive)
            IconButton(
              tooltip: 'Dismiss',
              onPressed: onDismiss == null ? null : () => onDismiss!(task),
              icon: const Icon(Icons.close),
            ),
        ],
      ),
    );
  }

  Color _statusColor(BuildContext context, ExportStatus status) {
    final cs = Theme.of(context).colorScheme;
    switch (status) {
      case ExportStatus.completed:
        return cs.primary;
      case ExportStatus.failed:
        return cs.error;
      case ExportStatus.paused:
        return cs.tertiary;
      case ExportStatus.queued:
      case ExportStatus.running:
        return cs.secondary;
    }
  }

  IconData _statusIcon(ExportStatus status) {
    switch (status) {
      case ExportStatus.completed:
        return Icons.check_circle_outline;
      case ExportStatus.failed:
        return Icons.error_outline;
      case ExportStatus.paused:
        return Icons.pause_circle_outline;
      case ExportStatus.queued:
        return Icons.schedule;
      case ExportStatus.running:
        return Icons.downloading;
    }
  }

  Future<void> _showPreviewDialog(BuildContext context, ExportTask task) async {
    final rows = task.previewRows ?? const <Map<String, dynamic>>[];
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Preview ${task.fileName}'),
        content: SizedBox(
          width: double.maxFinite,
          child: rows.isEmpty
              ? const Text('No preview rows available.')
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: rows.first.keys
                        .map((key) => DataColumn(label: Text(key)))
                        .toList(),
                    rows: rows
                        .map(
                          (row) => DataRow(
                            cells: row.values
                                .map((value) => DataCell(Text('$value')))
                                .toList(),
                          ),
                        )
                        .toList(),
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
