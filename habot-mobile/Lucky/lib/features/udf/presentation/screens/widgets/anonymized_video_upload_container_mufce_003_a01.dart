// MUFCE-003-A01 — AnonymizedVideoUploadContainer
// Secure data submission portal for micro video uploads with MIME type validation, offline persistence, and Material 3 card layout.

import 'dart:async';
import 'package:flutter/material.dart';

enum UploadValidationStatus { pending, valid, invalid, uploading, complete }

class VideoDefinition {
  final String definitionId;
  final String definitionName;
  final Map<String, dynamic> definitionParameters;
  final String definitionType;
  final UploadValidationStatus validationStatus;

  const VideoDefinition({
    required this.definitionId,
    required this.definitionName,
    required this.definitionParameters,
    required this.definitionType,
    required this.validationStatus,
  });
}

class MockVideoRepository {
  static const List<String> allowedMimeTypes = [
    'video/mp4',
    'video/quicktime',
    'video/webm',
  ];

  static const int maxFileSizeBytes = 50 * 1024 * 1024; // 50MB limit

  static Future<VideoDefinition> validateAndSubmit(String fileName, int fileSizeBytes, String mimeType) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network latency

    if (!allowedMimeTypes.contains(mimeType.toLowerCase())) {
      return VideoDefinition(
        definitionId: 'DEF-ERR-001',
        definitionName: fileName,
        definitionParameters: {'error': 'Invalid MIME type'},
        definitionType: mimeType,
        validationStatus: UploadValidationStatus.invalid,
      );
    }

    if (fileSizeBytes > maxFileSizeBytes) {
      return VideoDefinition(
        definitionId: 'DEF-ERR-002',
        definitionName: fileName,
        definitionParameters: {'error': 'File exceeds maximum size'},
        definitionType: mimeType,
        validationStatus: UploadValidationStatus.invalid,
      );
    }

    return VideoDefinition(
      definitionId: 'DEF-${DateTime.now().millisecondsSinceEpoch}',
      definitionName: fileName,
      definitionParameters: {'size': fileSizeBytes, 'mime': mimeType},
      definitionType: mimeType,
      validationStatus: UploadValidationStatus.complete,
    );
  }
}

class AnonymizedVideoUploadContainer extends StatefulWidget {
  const AnonymizedVideoUploadContainer({super.key});

  @override
  State<AnonymizedVideoUploadContainer> createState() => _AnonymizedVideoUploadContainerState();
}

class _AnonymizedVideoUploadContainerState extends State<AnonymizedVideoUploadContainer> {
  bool _isOnline = true;
  bool _isUploading = false;
  UploadValidationStatus _currentStatus = UploadValidationStatus.pending;
  VideoDefinition? _lastResult;

  void _simulateOfflineToggle() {
    setState(() {
      _isOnline = !_isOnline;
    });
  }

  Future<void> _handleMockUpload() async {
    if (!_isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot upload while offline. Please restore connectivity.'),
          duration: Duration(days: 1), // Persistent until connectivity restored
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _currentStatus = UploadValidationStatus.uploading;
    });

    // Mock file selection
    const String mockFileName = 'micro_video_sample.mp4';
    const int mockFileSize = 12 * 1024 * 1024; // 12MB
    const String mockMimeType = 'video/mp4';

    final result = await MockVideoRepository.validateAndSubmit(
      mockFileName,
      mockFileSize,
      mockMimeType,
    );

    if (!mounted) return;

    setState(() {
      _isUploading = false;
      _currentStatus = result.validationStatus;
      _lastResult = result;
    });

    if (result.validationStatus == UploadValidationStatus.invalid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload rejected: ${result.definitionParameters['error']}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        Card(
          elevation: 2.0,
          margin: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  _currentStatus == UploadValidationStatus.complete
                      ? Icons.check_circle_outline
                      : Icons.cloud_upload_outlined,
                  size: 64,
                  color: _currentStatus == UploadValidationStatus.invalid
                      ? colorScheme.error
                      : colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Micro Video Upload',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Supported formats: MP4, MOV, WebM. Max size: 50MB.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _isUploading ? null : _handleMockUpload,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.video_file_outlined),
                  label: Text(_isUploading ? 'Verifying & Uploading...' : 'Select & Upload Video'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                if (_lastResult != null && _currentStatus == UploadValidationStatus.complete) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Submission Progress', style: theme.textTheme.labelLarge),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: 1.0, borderRadius: BorderRadius.circular(4)),
                        const SizedBox(height: 8),
                        Text(
                          'Status: Complete | ID: ${_lastResult!.definitionId}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        // Offline persistent toast simulation
        if (!_isOnline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              elevation: 4,
              color: colorScheme.errorContainer,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off, color: colorScheme.onErrorContainer, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You are currently offline. Uploads are paused.',
                          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        // Debug toggle for testing offline state
        Positioned(
          bottom: 8,
          right: 8,
          child: IconButton(
            tooltip: 'Toggle Connectivity State (Debug)',
            icon: Icon(_isOnline ? Icons.wifi : Icons.wifi_off),
            onPressed: _simulateOfflineToggle,
          ),
        ),
      ],
    );
  }
}