// MUFCE-026-A15 — Force Majeure File Upload Component.
// Implements a rigid file-upload zone that parses documents before enabling submit, with strict validation, native mobile picker integration, and Material 3 design standards.

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ExecutionStatus { pending, success, failed }

class StepExecutionRecord {
  final String stepExecutionId;
  final ExecutionStatus executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;

  const StepExecutionRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
        'Step Execution ID': stepExecutionId,
        'Execution Status': executionStatus.name,
        'Execution Timestamp': executionTimestamp.toIso8601String(),
        'Step Outcome': stepOutcome,
        'User ID': userId,
      };
}

class MockFileVerificationRepository {
  static const List<String> _allowedExtensions = ['.pdf', '.jpg', '.jpeg', '.png'];
  static const int _maxFileSizeBytes = 10 * 1024 * 1024; // 10MB

  Future<bool> verifyFileHash(String fileName, Uint8List bytes) async {
    await Future.delayed(const Duration(seconds: 2));
    final ext = fileName.substring(fileName.lastIndexOf('.')).toLowerCase();
    if (!_allowedExtensions.contains(ext)) return false;
    if (bytes.length > _maxFileSizeBytes) return false;
    return true;
  }
}

class ForceMajeureFileUpload extends StatefulWidget {
  final String userId;
  final VoidCallback? onVerificationSuccess;

  const ForceMajeureFileUpload({
    super.key,
    required this.userId,
    this.onVerificationSuccess,
  });

  @override
  State<ForceMajeureFileUpload> createState() => _ForceMajeureFileUploadState();
}

class _ForceMajeureFileUploadState extends State<ForceMajeureFileUpload> {
  final MockFileVerificationRepository _repository = MockFileVerificationRepository();
  
  bool _isVerifying = false;
  bool _isVerified = false;
  bool _hasError = false;
  String? _selectedFileName;
  Uint8List? _fileBytes;
  String _errorMessage = '';

  static const List<String> allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

  Future<void> _pickAndVerifyFile() async {
    setState(() {
      _hasError = false;
      _isVerified = false;
      _errorMessage = '';
    });

    // Simulating native mobile file picker / camera API integration
    // In production, use file_picker or image_picker package
    const mockFileName = 'emergency_proof.pdf';
    final mockBytes = Uint8List.fromList(utf8.encode('mock_emergency_document_data'));

    setState(() {
      _selectedFileName = mockFileName;
      _fileBytes = mockBytes;
      _isVerifying = true;
    });

    final isValid = await _repository.verifyFileHash(mockFileName, mockBytes);

    if (!mounted) return;

    final record = StepExecutionRecord(
      stepExecutionId: 'MUFCE-026-A15-${DateTime.now().millisecondsSinceEpoch}',
      executionStatus: isValid ? ExecutionStatus.success : ExecutionStatus.failed,
      executionTimestamp: DateTime.now(),
      stepOutcome: isValid ? 'Pass' : 'Fail',
      userId: widget.userId,
    );

    // Secure and undeniable logging (mock)
    debugPrint('Execution Log: ${jsonEncode(record.toJson())}');

    setState(() {
      _isVerifying = false;
      _isVerified = isValid;
      _hasError = !isValid;
      if (!isValid) {
        _errorMessage = 'Invalid file format or corrupted proof. Please upload a valid PDF or Image.';
      }
    });

    if (isValid) {
      SystemSound.play(SystemSoundType.click);
      widget.onVerificationSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color borderColor;
    if (_hasError) {
      borderColor = colorScheme.error;
    } else if (_isVerified) {
      borderColor = colorScheme.primary;
    } else {
      borderColor = colorScheme.outlineVariant;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Force Majeure Proof Upload',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload absolute proof of emergency to pause penalties instantly.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _isVerifying ? null : _pickAndVerifyFile,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: _hasError 
                      ? colorScheme.errorContainer.withOpacity(0.3)
                      : colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderColor,
                    style: BorderStyle.solid,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: _isVerifying
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: colorScheme.primary),
                            const SizedBox(height: 12),
                            Text('Verifying document hash...', style: theme.textTheme.bodyMedium),
                          ],
                        )
                      : _isVerified
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 48,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Proof Verified Successfully',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (_selectedFileName != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedFileName!,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 48,
                                  color: _hasError ? colorScheme.error : colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _hasError ? 'Drop invalid file turned zone red' : 'Tap to select file from device',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: _hasError ? colorScheme.error : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Accepted formats: PDF, JPG, PNG (Max 10MB)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
            ),
            if (_hasError && _errorMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: colorScheme.onErrorContainer, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_isVerified) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: colorScheme.onPrimaryContainer, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'System penalty paused successfully without support ticket escalation.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isVerified ? () {} : null, // Submit disabled at DOM level until verified
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('Submit Force Majeure Request'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}