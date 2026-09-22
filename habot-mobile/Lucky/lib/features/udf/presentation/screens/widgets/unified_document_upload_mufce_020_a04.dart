// MUFCE-020-A04 — Unified Document Ingestion & Cropping Upload Widget.
// Provides a touch-friendly, drag-and-drop upload container with client-side file size and extension validation, thumbnail preview pills, and inline error feedback banners adhering to Material 3 standards.

import 'package:flutter/material.dart';

/// Allowed file extensions whitelist (formalized master rules).
const List<String> kAllowedFileExtensions = ['pdf', 'jpg', 'jpeg', 'png', 'docx'];

/// Maximum allowed file size in bytes (10 MB).
const int kMaxFileSizeBytes = 10 * 1024 * 1024;

/// Minimum touch target dimension for mobile accessibility compliance.
const double kMinTouchTargetDp = 48.0;

/// Mock data model representing an uploaded file payload.
class MockUploadedFile {
  final String id;
  final String name;
  final int sizeBytes;
  final String extension;
  final DateTime timestamp;

  const MockUploadedFile({
    required this.id,
    required this.name,
    required this.sizeBytes,
    required this.extension,
    required this.timestamp,
  });
}

/// Centralized mock repository simulating backend ingestion events.
class MockUploadRepository {
  static final List<MockUploadedFile> uploadHistoryLedger = [
    const MockUploadedFile(
      id: 'trace-001',
      name: 'invoice_sept.pdf',
      sizeBytes: 204800,
      extension: 'pdf',
      timestamp: _mockNow,
    ),
  ];

  static const DateTime _mockNow = DateTime(2026, 9, 22, 10, 30);

  static void recordUpload(MockUploadedFile file) {
    uploadHistoryLedger.add(file);
    // Simulate Pub/Sub signal firing to BigQuery
    debugPrint('[Pub/Sub Mock] Fired upload event for trace ID: ${file.id}');
  }
}

/// Poka-Yoke: Strips illegal characters from the file string to secure naming taxonomy.
String sanitizeFileName(String rawName) {
  return rawName.replaceAll(RegExp(r'[^a-zA-Z0-9_.\-]'), '_');
}

/// Validates file size metrics right at the entry gate.
bool isFileSizeValid(int sizeBytes) => sizeBytes <= kMaxFileSizeBytes;

/// Validates file extension against the formalized whitelist.
bool isExtensionValid(String extension) {
  final normalizedExt = extension.toLowerCase().replaceAll('.', '');
  return kAllowedFileExtensions.contains(normalizedExt);
}

/// The unified upload gateway component serving as the absolute entry point
/// for 100% of uploaded files cross-entities.
class UnifiedDocumentUploadWidget extends StatefulWidget {
  final ValueChanged<MockUploadedFile>? onFileAccepted;
  final ValueChanged<String>? onError;

  const UnifiedDocumentUploadWidget({
    super.key,
    this.onFileAccepted,
    this.onError,
  });

  @override
  State<UnifiedDocumentUploadWidget> createState() => _UnifiedDocumentUploadWidgetState();
}

class _UnifiedDocumentUploadWidgetState extends State<UnifiedDocumentUploadWidget> {
  String? _errorMessage;
  MockUploadedFile? _previewFile;
  bool _categorizationChecked = false;

  void _simulateFileSelection(String rawName, int sizeBytes, String extension) {
    setState(() {
      _errorMessage = null;
      _previewFile = null;
    });

    final sanitizedName = sanitizeFileName(rawName);

    if (!isExtensionValid(extension)) {
      setState(() {
        _errorMessage = 'Invalid file format (.${extension.toLowerCase()}). Allowed: ${kAllowedFileExtensions.join(', ')}.';
      });
      widget.onError?.call(_errorMessage!);
      return;
    }

    if (!isFileSizeValid(sizeBytes)) {
      setState(() {
        _errorMessage = 'File exceeds maximum size limit of 10 MB.';
      });
      widget.onError?.call(_errorMessage!);
      return;
    }

    final newFile = MockUploadedFile(
      id: 'trace-${DateTime.now().millisecondsSinceEpoch}',
      name: sanitizedName,
      sizeBytes: sizeBytes,
      extension: extension,
      timestamp: DateTime.now(),
    );

    setState(() {
      _previewFile = newFile;
    });
  }

  void _commitUpload() {
    // Self-Chasing: Refuses to register until mandatory categorizations are checked.
    if (!_categorizationChecked) {
      setState(() {
        _errorMessage = 'You must explicitly check the categorization box before saving.';
      });
      widget.onError?.call(_errorMessage!);
      return;
    }

    if (_previewFile != null) {
      MockUploadRepository.recordUpload(_previewFile!);
      widget.onFileAccepted?.call(_previewFile!);
      setState(() {
        _previewFile = null;
        _categorizationChecked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Typographic visual weight guidelines applied to numeric summary headers
        Text(
          'Document Ingestion Gateway',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),

        // Non-disruptive feedback banner for improper file types
        if (_errorMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.error, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Clean, isolated drag-and-drop container featuring explicit format outline boundaries
        GestureDetector(
          onTap: () {
            // Simulate user picking a valid file via device camera or gallery
            _simulateFileSelection('field report #1!.pdf', 1024 * 500, 'pdf');
          },
          child: DragTarget<MockUploadedFile>(
            onAcceptWithDetails: (details) {
              // Handle actual drag/drop if implemented via desktop/web
            },
            builder: (context, candidateData, rejectedData) {
              final isHovering = candidateData.isNotEmpty;
              return Container(
                constraints: const BoxConstraints(
                  minHeight: kMinTouchTargetDp * 3,
                ),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  color: isHovering ? colorScheme.primaryContainer.withOpacity(0.3) : colorScheme.surfaceContainerHighest.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isHovering ? colorScheme.primary : colorScheme.outlineVariant,
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tap to upload or drag file here',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Allowed formats: ${kAllowedFileExtensions.map((e) => '.${e}').join(', ')} | Max size: 10MB',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Auto-render a clean thumbnail preview pill upon valid data payload reception
        if (_previewFile != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.insert_drive_file, color: colorScheme.onSecondaryContainer),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    _previewFile!.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(_previewFile!.sizeBytes / 1024).toStringAsFixed(1)} KB',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSecondaryContainer.withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => setState(() => _previewFile = null),
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Icons.close, size: 18, color: colorScheme.onSecondaryContainer),
                  ),
                ),
              ],
            ),
          ),

        if (_previewFile != null) const SizedBox(height: 16),

        // Self-Chasing: Mandatory categorization checkbox
        if (_previewFile != null)
          Row(
            children: [
              SizedBox(
                width: kMinTouchTargetDp,
                height: kMinTouchTargetDp,
                child: Checkbox(
                  value: _categorizationChecked,
                  onChanged: (val) {
                    setState(() {
                      _categorizationChecked = val ?? false;
                      if (_categorizationChecked) _errorMessage = null;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'I confirm the document categorization is accurate.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),

        if (_previewFile != null) const SizedBox(height: 16),

        // Commit action
        if (_previewFile != null)
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _commitUpload,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Confirm & Save Payload'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(kMinTouchTargetDp, kMinTouchTargetDp),
              ),
            ),
          ),

        const SizedBox(height: 24),

        // Simulation controls for testing invalid states
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: () => _simulateFileSelection('test.exe', 1024, 'exe'),
              child: const Text('Simulate Invalid Ext'),
            ),
            OutlinedButton(
              onPressed: () => _simulateFileSelection('huge.pdf', kMaxFileSizeBytes + 1, 'pdf'),
              child: const Text('Simulate Oversize'),
            ),
          ],
        ),
      ],
    );
  }
}
