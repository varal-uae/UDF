// FEBFL-001-A11 — Export Status Panels for Non-Blocking File Export Tasks.
// Provides a compact lower-corner panel that tracks background export jobs, supports per-item manual dismissal, preview/download actions, and progress/status metadata.

import 'package:flutter/material.dart';

enum ExportStatus { queued, processing, ready, failed }

class ExportStatusItem {
  const ExportStatusItem({
    required this.id,
    required this.exportFormat,
    required this.status,
    this.exportPath,
    this.exportTimestamp,
    this.fileSizeBytes,
    this.progress = 0,
  });

  final String id;
  final String exportFormat;
  final ExportStatus status;
  final String? exportPath;
  final DateTime? exportTimestamp;
  final int? fileSizeBytes;
  final double progress;

  String get fileSizeLabel {
    final bytes = fileSizeBytes;
    if (bytes == null || bytes <= 0) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get formattedTimestamp {
    final ts = exportTimestamp;
    if (ts == null) return '';
    final local = ts.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
  }
}

class ExportStatusPanel extends StatelessWidget {
  const ExportStatusPanel({
    super.key,
    required this.items,
    required this.onDismiss,
    this.onPreview,
    this.onDownload,
    this.alignment = Alignment.bottomRight,
    this.maxWidth = 360,
  });

  final List<ExportStatusItem> items;
  final ValueChanged<String> onDismiss;
  final ValueChanged<ExportStatusItem>? onPreview;
  final ValueChanged<ExportStatusItem>? onDownload;
  final Alignment alignment;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: alignment,
      child: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(18),
          color: scheme.surface,
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                  child: Row(
                    children: [
                      Icon(Icons.downloading_outlined, size: 18, color: scheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Exports',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Text(
                        '${items.length}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ExportStreamJobTracker(
                        item: item,
                        onDismiss: () => onDismiss(item.id),
                        onPreview: onPreview == null ? null : () => onPreview!(item),
                        onDownload: onDownload == null ? null : () => onDownload!(item),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExportStreamJobTracker extends StatelessWidget {
  const ExportStreamJobTracker({
    super.key,
    required this.item,
    required this.onDismiss,
    this.onPreview,
    this.onDownload,
  });

  final ExportStatusItem item;
  final VoidCallback onDismiss;
  final VoidCallback? onPreview;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.exportFormat,
                        style: Theme.of(context).textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(status: item.status),
                  ],
                ),
                const SizedBox(height: 8),
                if (item.status == ExportStatus.queued || item.status == ExportStatus.processing)
                  LinearProgressIndicator(
                    value: item.status == ExportStatus.queued ? null : item.progress.clamp(0.0, 1.0).toDouble(),
                    minHeight: 6,
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    if (item.fileSizeLabel.isNotEmpty)
                      _Meta(icon: Icons.data_usage, label: item.fileSizeLabel),
                    if (item.formattedTimestamp.isNotEmpty)
                      _Meta(icon: Icons.schedule, label: item.formattedTimestamp),
                    if (item.exportPath != null && item.exportPath!.isNotEmpty)
                      _Meta(icon: Icons.folder_outlined, label: item.exportPath!),
                  ],
                ),
                if (item.status == ExportStatus.ready &&
                    (onPreview != null || onDownload != null)) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (onPreview != null)
                        OutlinedButton.icon(
                          onPressed: onPreview,
                          icon: const Icon(Icons.visibility_outlined, size: 16),
                          label: const Text('Preview'),
                        ),
                      if (onDownload != null)
                        FilledButton.icon(
                          onPressed: onDownload,
                          icon: const Icon(Icons.download_outlined, size: 16),
                          label: const Text('Download'),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Dismiss export status',
            onPressed: onDismiss,
            icon: const Icon(Icons.close),
            color: scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ExportStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      ExportStatus.queued => ('Queued', scheme.tertiary),
      ExportStatus.processing => ('Processing', scheme.primary),
      ExportStatus.ready => ('Ready', scheme.secondary),
      ExportStatus.failed => ('Failed', scheme.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: scheme.onSurfaceVariant),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}
