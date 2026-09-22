// MUFCE-003-A14 — Anonymized Video Upload Container & Post-Upload Confirmation.
// Renders a Material 3 card layout for micro video uploads with strict client-side
// chunking validation, generous touch targets, and post-upload metadata confirmation.

import 'package:flutter/material.dart';

/// Mock data representing the execution step metadata required by the system.
class _MockUploadExecutionData {
  final String stepExecutionId;
  final String userId;
  final String sessionId;
  final DateTime actionTimestamp;

  const _MockUploadExecutionData({
    required this.stepExecutionId,
    required this.userId,
    required this.sessionId,
    required this.actionTimestamp,
  });
}

const _MockUploadExecutionData _mockExecution = _MockUploadExecutionData(
  stepExecutionId: 'STEP-EXEC-MUFCE-003-A14-001',
  userId: 'USR-MOCK-8829',
  sessionId: 'SESS-MOCK-112A',
  actionTimestamp: null as dynamic,
);

/// Represents an uploaded file's metadata for the confirmation view.
class UploadedFileMetadata {
  final String fileName;
  final int fileSizeBytes;
  final DateTime uploadTimestamp;
  final bool isCompliant;

  const UploadedFileMetadata({
    required this.fileName,
    required this.fileSizeBytes,
    required this.uploadTimestamp,
    required this.isCompliant,
  });
}

/// Bounding calculation constants (Poka-Yoke) to filter asset sizes automatically.
class _UploadConstraints {
  static const int maxFileSizeBytes = 50 * 1024 * 1024; // 50 MB limit
  static const double minTouchTargetSize = 48.0; // Material generous touch spacing
}

enum _UploadState { idle, uploading, success, rejected }

class AnonymizedVideoUploadContainer extends StatefulWidget {
  const AnonymizedVideoUploadContainer({super.key});

  @override
  State<AnonymizedVideoUploadContainer> createState() =>
      _AnonymizedVideoUploadContainerState();
}

class _AnonymizedVideoUploadContainerState
    extends State<AnonymizedVideoUploadContainer>
    with SingleTickerProviderStateMixin {
  _UploadState _state = _UploadState.idle;
  UploadedFileMetadata? _uploadedFile;
  late AnimationController _opacityController;

  @override
  void initState() {
    super.initState();
    // Anchor motion designs strictly to standardized core system transition keys.
    _opacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _opacityController.dispose();
    super.dispose();
  }

  /// Simulates selecting a file and validating it against constraints.
  Future<void> _simulateFileSelection() async {
    setState(() => _state = _UploadState.uploading);
    _opacityController.forward();

    await Future.delayed(const Duration(seconds: 2));

    // Mock payload redirect into localized secure cache queue
    const mockFileName = 'micro_video_chunk_001.mp4';
    const mockFileSize = 12 * 1024 * 1024; // 12 MB

    // Poka-Yoke: Bounding calculations filter asset sizes automatically
    if (mockFileSize > _UploadConstraints.maxFileSizeBytes) {
      setState(() => _state = _UploadState.rejected);
      return;
    }

    final metadata = UploadedFileMetadata(
      fileName: mockFileName,
      fileSizeBytes: mockFileSize,
      uploadTimestamp: DateTime.now(),
      isCompliant: true,
    );

    if (!mounted) return;
    setState(() {
      _uploadedFile = metadata;
      _state = _UploadState.success;
    });
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Secure Micro Video Upload',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8.0),
            // Render highly concise action helper descriptions near file rows.
            Text(
              'Select a video file to route through verification pipelines. '
              'Max size: ${_formatBytes(_UploadConstraints.maxFileSizeBytes)}.',
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24.0),

            // Lock container footprints to prevent vertical layout shifts when data arrives.
            SizedBox(
              height: 160.0,
              width: double.infinity,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildContent(theme),
              ),
            ),

            if (_state == _UploadState.success && _uploadedFile != null) ...[
              const SizedBox(height: 24.0),
              _PostUploadConfirmationCard(metadata: _uploadedFile!),
            ],

            const SizedBox(height: 24.0),

            // Use generous touch spacing guidelines around all upload elements.
            SizedBox(
              width: double.infinity,
              height: _UploadConstraints.minTouchTargetSize,
              child: FilledButton.icon(
                onPressed:
                    _state == _UploadState.idle || _state == _UploadState.rejected
                        ? _simulateFileSelection
                        : null,
                icon: const Icon(Icons.cloud_upload_outlined),
                label: Text(
                  _state == _UploadState.uploading
                      ? 'Processing...'
                      : 'Upload Video',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    switch (_state) {
      case _UploadState.idle:
      case _UploadState.rejected:
        return Container(
          key: const ValueKey('idle_drop_zone'),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              style: BorderStyle.solid,
              width: 1.0,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.video_file_outlined,
                  size: 48.0,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12.0),
                Text(
                  _state == _UploadState.rejected
                      ? 'File rejected. Non-compliant structure.'
                      : 'Tap below to select media',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      case _UploadState.uploading:
        return Container(
          key: const ValueKey('uploading_indicator'),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        );
      case _UploadState.success:
        return Container(
          key: const ValueKey('success_state'),
          alignment: Alignment.center,
          child: Icon(
            Icons.check_circle_outline,
            size: 64.0,
            color: theme.colorScheme.primary,
          ),
        );
    }
  }
}

/// Post-upload confirmation showing file name, size, and upload timestamp.
class _PostUploadConfirmationCard extends StatelessWidget {
  final UploadedFileMetadata metadata;

  const _PostUploadConfirmationCard({required this.metadata});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Limit opacity changes to strict baseline styling token values.
    return FadeTransition(
      opacity: const AlwaysStoppedAnimation(1.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.verified_user, color: theme.colorScheme.primary, size: 20.0),
                const SizedBox(width: 8.0),
                Text(
                  'Submission Confirmed',
                  style: textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24.0),
            _MetadataRow(label: 'File Name', value: metadata.fileName, theme: theme),
            const SizedBox(height: 8.0),
            _MetadataRow(
              label: 'File Size',
              value: _formatBytes(metadata.fileSizeBytes),
              theme: theme,
            ),
            const SizedBox(height: 8.0),
            _MetadataRow(
              label: 'Upload Time',
              value: TimeOfDay.fromDateTime(metadata.uploadTimestamp).format(context),
              theme: theme,
            ),
            const SizedBox(height: 8.0),
            _MetadataRow(
              label: 'Step Execution ID',
              value: _mockExecution.stepExecutionId,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

class _MetadataRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _MetadataRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}