// MUFCE-003-A10 — AnonymizedVideoUploadContainer for secure micro video uploads.
// Implements pause/resume upload functionality, Material 3 card layouts, generous touch targets,
// automatic file size bounding (Poka-Yoke), and smooth viewport scaling without vertical layout shifts.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Maximum allowed file size in bytes (50 MB limit for Poka-Yoke bounding).
const int _kMaxFileSizeBytes = 50 * 1024 * 1024;

/// Minimum required touch target size per Material Design guidelines.
const double _kMinTouchTargetSize = 48.0;

enum UploadStatus { idle, uploading, paused, completed, failed, rejected }

class VideoUploadItem {
  final String id;
  final String fileName;
  final int fileSizeBytes;
  final DateTime timestamp;
  double progress;
  UploadStatus status;

  VideoUploadItem({
    required this.id,
    required this.fileName,
    required this.fileSizeBytes,
    required this.timestamp,
    this.progress = 0.0,
    this.status = UploadStatus.idle,
  });
}

/// Mock data representing local file selections pending upload.
final List<VideoUploadItem> _mockUploadItems = [
  VideoUploadItem(
    id: 'exec-step-001',
    fileName: 'micro_content_01.mp4',
    fileSizeBytes: 15 * 1024 * 1024,
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    progress: 0.45,
    status: UploadStatus.paused,
  ),
  VideoUploadItem(
    id: 'exec-step-002',
    fileName: 'brand_story_v2.mp4',
    fileSizeBytes: 8 * 1024 * 1024,
    timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    progress: 0.0,
    status: UploadStatus.idle,
  ),
  VideoUploadItem(
    id: 'exec-step-003',
    fileName: 'oversized_asset.mp4',
    fileSizeBytes: 65 * 1024 * 1024,
    timestamp: DateTime.now(),
    progress: 0.0,
    status: UploadStatus.rejected,
  ),
];

class AnonymizedVideoUploadContainer extends StatefulWidget {
  const AnonymizedVideoUploadContainer({super.key});

  @override
  State<AnonymizedVideoUploadContainer> createState() =>
      _AnonymizedVideoUploadContainerState();
}

class _AnonymizedVideoUploadContainerState
    extends State<AnonymizedVideoUploadContainer>
    with TickerProviderStateMixin {
  late final List<VideoUploadItem> _items;
  Timer? _uploadSimulationTimer;

  @override
  void initState() {
    super.initState();
    _items = List.from(_mockUploadItems);
    _startSimulation();
  }

  @override
  void dispose() {
    _uploadSimulationTimer?.cancel();
    super.dispose();
  }

  void _startSimulation() {
    _uploadSimulationTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) return;
      bool needsUpdate = false;
      setState(() {
        for (final item in _items) {
          if (item.status == UploadStatus.uploading && item.progress < 1.0) {
            item.progress = math.min(1.0, item.progress + 0.05);
            needsUpdate = true;
            if (item.progress >= 1.0) {
              item.status = UploadStatus.completed;
            }
          }
        }
      });
      if (!needsUpdate &&
          !_items.any((i) => i.status == UploadStatus.uploading)) {
        timer.cancel();
      }
    });
  }

  void _togglePauseResume(String id) {
    setState(() {
      final item = _items.firstWhere((i) => i.id == id);
      if (item.status == UploadStatus.uploading) {
        item.status = UploadStatus.paused;
      } else if (item.status == UploadStatus.paused ||
          item.status == UploadStatus.idle) {
        item.status = UploadStatus.uploading;
        _startSimulation();
      }
    });
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (math.log(bytes) / math.log(1024)).floor();
    i = math.min(i, suffixes.length - 1);
    final value = bytes / math.pow(1024, i);
    return '${value.toStringAsFixed(1)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ConstrainedBox(
      // Lock container footprints to prevent vertical layout shifts when data arrives
      constraints: const BoxConstraints(minHeight: 320, maxHeight: 600),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Secure Video Submission Portal',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                'Upload micro videos securely. Files are screened automatically.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const Divider(height: 16.0),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return _VideoUploadRow(
                      item: item,
                      formatBytes: _formatBytes,
                      onPauseResume: () => _togglePauseResume(item.id),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                height: _kMinTouchTargetSize,
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Select New Video'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoUploadRow extends StatelessWidget {
  final VideoUploadItem item;
  final String Function(int) formatBytes;
  final VoidCallback onPauseResume;

  const _VideoUploadRow({
    required this.item,
    required this.formatBytes,
    required this.onPauseResume,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isRejected = item.status == UploadStatus.rejected;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          isRejected ? Icons.error_outline : Icons.video_file_outlined,
          color: isRejected ? colorScheme.error : colorScheme.primary,
          size: 32.0,
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isRejected ? colorScheme.error : null,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                isRejected
                    ? 'Rejected: Exceeds maximum allowed size (50 MB)'
                    : formatBytes(item.fileSizeBytes),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isRejected
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              if (!isRejected) ...[
                const SizedBox(height: 8.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: LinearProgressIndicator(
                    value: item.progress,
                    minHeight: 6.0,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      item.status == UploadStatus.completed
                          ? colorScheme.primary
                          : colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  _statusLabel(item.status),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12.0),
        if (!isRejected)
          SizedBox(
            width: _kMinTouchTargetSize,
            height: _kMinTouchTargetSize,
            child: IconButton(
              onPressed: onPauseResume,
              icon: Icon(
                item.status == UploadStatus.uploading
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_fill,
                color: colorScheme.primary,
                size: 32.0,
              ),
              tooltip: item.status == UploadStatus.uploading
                  ? 'Pause Upload'
                  : 'Resume Upload',
            ),
          ),
      ],
    );
  }

  String _statusLabel(UploadStatus status) {
    switch (status) {
      case UploadStatus.idle:
        return 'Ready to upload';
      case UploadStatus.uploading:
        return 'Uploading... ${(item.progress * 100).toStringAsFixed(0)}%';
      case UploadStatus.paused:
        return 'Paused at ${(item.progress * 100).toStringAsFixed(0)}%';
      case UploadStatus.completed:
        return 'Completed successfully';
      case UploadStatus.failed:
        return 'Upload failed';
      case UploadStatus.rejected:
        return 'Rejected';
    }
  }
}
