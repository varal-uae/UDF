// FEBFL-001-A03 — Export Stream Job Tracker.
// Bottom-right non-blocking status panel for file export tasks with animated entry/exit,
// mobile minimize-to-badge behavior, progress tracking, preview, download, and dismiss actions.

import 'package:flutter/material.dart';

enum ExportTaskState { queued, running, ready, failed, cancelled }

@immutable
class ExportTaskStatus {
  const ExportTaskStatus({
    required this.id,
    required this.fileName,
    required this.state,
    this.progress = 0.0,
    this.previewRows = const <String>[],
    this.downloadUrl,
    this.errorMessage,
  });

  final String id;
  final String fileName;
  final ExportTaskState state;
  final double progress;
  final List<String> previewRows;
  final String? downloadUrl;
  final String? errorMessage;

  bool get isReady => state == ExportTaskState.ready && downloadUrl != null;
  bool get isActive => state == ExportTaskState.queued || state == ExportTaskState.running;
  double get clampedProgress => progress.clamp(0.0, 1.0);
}

class ExportStreamJobTracker extends StatefulWidget {
  const ExportStreamJobTracker({
    super.key,
    required this.tasks,
    this.onPreview,
    this.onDownload,
    this.onDismiss,
    this.initiallyMinimized = false,
  });

  final List<ExportTaskStatus> tasks;
  final ValueChanged<ExportTaskStatus>? onPreview;
  final ValueChanged<ExportTaskStatus>? onDownload;
  final ValueChanged<String>? onDismiss;
  final bool initiallyMinimized;

  @override
  State<ExportStreamJobTracker> createState() => _ExportStreamJobTrackerState();
}

class _ExportStreamJobTrackerState extends State<ExportStreamJobTracker> {
  bool _minimized = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final isMobile = MediaQuery.sizeOf(context).width < 600;
      _minimized = widget.initiallyMinimized || (isMobile && widget.tasks.length > 1);
      _initialized = true;
    }
  }

  void _toggleMinimized() {
    setState(() => _minimized = !_minimized);
  }

  void _showPreview(ExportTaskStatus task) {
    if (widget.onPreview != null) {
      widget.onPreview!(task);
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.fileName),
        content: task.previewRows.isEmpty
            ? const Text('No preview rows available.')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: task.previewRows.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      task.previewRows[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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

  @override
  Widget build(BuildContext context) {
    final hasTasks = widget.tasks.isNotEmpty;
    final activeCount = widget.tasks.where((task) => task.isActive).length;
    final readyCount = widget.tasks.where((task) => task.isReady).length;

    return Align(
      alignment: Alignment.bottomRight,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        offset: hasTasks ? Offset.zero : const Offset(1.2, 1.2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: hasTasks ? 1 : 0,
          child: IgnorePointer(
            ignoring: !hasTasks,
            child: Semantics(
              label: 'Export task status panel',
              container: true,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: _minimized
                        ? _ExportBadge(
                            key: const ValueKey('export-badge'),
                            activeCount: activeCount,
                            readyCount: readyCount,
                            onTap: _toggleMinimized,
                          )
                        : _ExportPanel(
                            key: const ValueKey('export-panel'),
                            tasks: widget.tasks,
                            onMinimize: _toggleMinimized,
                            onPreview: _showPreview,
                            onDownload: widget.onDownload,
                            onDismiss: widget.onDismiss,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExportBadge extends StatelessWidget {
  const _ExportBadge({
    super.key,
    required this.activeCount,
    required this.readyCount,
    required this.onTap,
  });

  final int activeCount;
  final int readyCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = activeCount + readyCount;
    return Material(
      color: theme.colorScheme.primaryContainer,
      shape: const CircleBorder(),
      elevation: 6,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.file_download_outlined,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              if (count > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Text(
                      '$count',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onError,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportPanel extends StatelessWidget {
  const _ExportPanel({
    super.key,
    required this.tasks,
    required this.onMinimize,
    required this.onPreview,
    required this.onDownload,
    required this.onDismiss,
  });

  final List<ExportTaskStatus> tasks;
  final VoidCallback onMinimize;
  final ValueChanged<ExportTaskStatus> onPreview;
  final ValueChanged<ExportTaskStatus>? onDownload;
  final ValueChanged<String>? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(20),
      color: theme.colorScheme.surface,
      child: Container(
        width: 360,
        constraints: const BoxConstraints(maxHeight: 420),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.file_download_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Exports',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: 'Minimize export panel',
                  onPressed: onMinimize,
                  icon: const Icon(Icons.minimize),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: tasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return _ExportTaskTile(
                    task: task,
                    onPreview: () => onPreview(task),
                    onDownload: task.isReady && onDownload != null ? () => onDownload!(task) : null,
                    onDismiss: onDismiss == null ? null : () => onDismiss!(task.id),
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
  const _ExportTaskTile({
    required this.task,
    required this.onPreview,
    this.onDownload,
    this.onDismiss,
  });

  final ExportTaskStatus task;
  final VoidCallback onPreview;
  final VoidCallback? onDownload;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = switch (task.state) {
      ExportTaskState.queued => theme.colorScheme.secondary,
      ExportTaskState.running => theme.colorScheme.primary,
      ExportTaskState.ready => Colors.green,
      ExportTaskState.failed => theme.colorScheme.error,
      ExportTaskState.cancelled => theme.colorScheme.outline,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  tooltip: 'Dismiss export',
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close, size: 18),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  task.state.name.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              if (task.isActive)
                Text(
                  '${(task.clampedProgress * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.labelMedium,
                ),
            ],
          ),
          if (task.isActive) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: task.clampedProgress,
              minHeight: 6,
              borderRadius: BorderRadius.circular(999),
            ),
          ],
          if (task.state == ExportTaskState.failed && task.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              task.errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onPreview,
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('Preview'),
              ),
              if (task.isReady) ...[
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onDownload,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Download'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
