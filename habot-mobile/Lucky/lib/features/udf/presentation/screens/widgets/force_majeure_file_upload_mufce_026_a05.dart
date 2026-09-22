// MUFCE-026-A05 — Force Majeure File Upload Zone with strict validation and hash verification.
// Implements a rigid file-upload component that parses input documents, enforces minimum 48dp touch targets,
// disables submission until backend hash verification completes, and provides clear visual feedback using Material 3.

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Allowed MIME types for the rigid upload zone.
const List<String> _kAllowedMimeTypes = [
  'application/pdf',
  'image/jpeg',
  'image/png',
];

/// Maximum allowed file size (10 MB).
const int _kMaxFileSizeBytes = 10 * 1024 * 1024;

enum _UploadState {
  idle,
  parsing,
  verifying,
  success,
  error,
}

class ForceMajeureFileUploadZone extends StatefulWidget {
  const ForceMajeureFileUploadZone({
    super.key,
    required this.onVerificationChanged,
  });

  /// Callback triggered when the file verification status changes.
  final ValueChanged<bool> onVerificationChanged;

  @override
  State<ForceMajeureFileUploadZone> createState() => _ForceMajeureFileUploadZoneState();
}

class _ForceMajeureFileUploadZoneState extends State<ForceMajeureFileUploadZone>
    with TickerProviderStateMixin {
  _UploadState _state = _UploadState.idle;
  String? _fileName;
  String? _errorMessage;
  late final AnimationController _pulseController;

  // Mock data representing parsed file artifacts
  static const Map<String, dynamic> _mockBuildArtifacts = {
    'buildStatus': 'PENDING_VERIFICATION',
    'buildTimestamp': '2026-09-22T10:00:00Z',
    'buildArtifactsPath': '/mock/artifacts/proof_doc.pdf',
    'buildLogs': 'File parsed successfully. Awaiting hash check.',
    'buildDuration': '850ms',
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    widget.onVerificationChanged(false);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleFileSelection() async {
    if (_state == _UploadState.parsing || _state == _UploadState.verifying) return;

    setState(() {
      _state = _UploadState.parsing;
      _errorMessage = null;
      _fileName = null;
      widget.onVerificationChanged(false);
    });

    try {
      // Simulate native mobile file picker integration / drag-and-drop
      await Future<void>.delayed(const Duration(milliseconds: 600));

      // Mock selected file data
      const String mockFileName = 'emergency_proof_document.pdf';
      const int mockFileSize = 2 * 1024 * 1024; // 2MB
      const String mockMimeType = 'application/pdf';

      // Strict validation: Size
      if (mockFileSize > _kMaxFileSizeBytes) {
        throw Exception('File exceeds maximum size of 10MB.');
      }

      // Strict validation: Type
      if (!_kAllowedMimeTypes.contains(mockMimeType)) {
        throw Exception('Unauthorized file format. Only PDF, JPEG, PNG allowed.');
      }

      setState(() {
        _fileName = mockFileName;
        _state = _UploadState.verifying;
      });

      // Submit disabled at DOM level until file hash verified by backend
      await _simulateBackendHashVerification(mockFileName);

      if (!mounted) return;
      setState(() {
        _state = _UploadState.success;
      });
      widget.onVerificationChanged(true);

      // Standardize clean success sound elements following design criteria
      SystemSound.play(SystemSoundType.click);

      // Build interface message banners displaying clear success states
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Proof uploaded and verified successfully.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      // Dropping invalid file turns zone red dictating format
      setState(() {
        _state = _UploadState.error;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      widget.onVerificationChanged(false);
    }
  }

  Future<void> _simulateBackendHashVerification(String fileName) async {
    // Simulating network latency within Floor (800ms) to Optimal (2000ms) boundary
    final int simulatedLatency = 800 + Random().nextInt(1200);
    await Future<void>.delayed(Duration(milliseconds: simulatedLatency));

    // Mocking SHA-256 hash generation and backend verification
    final String mockHash = base64Encode(utf8.encode(fileName + DateTime.now().toIso8601String()));
    
    // Simulate occasional failure for demonstration (10% chance)
    if (Random().nextDouble() < 0.1) {
      throw Exception('Backend hash verification failed. Please try again.');
    }

    debugPrint('[MUFCE-026-A05] Hash $mockHash verified for $fileName');
    debugPrint('[MUFCE-026-A05] Artifacts: ${jsonEncode(_mockBuildArtifacts)}');
  }

  Color _getZoneColor(ColorScheme colorScheme) {
    switch (_state) {
      case _UploadState.error:
        return colorScheme.errorContainer;
      case _UploadState.success:
        return colorScheme.primaryContainer;
      case _UploadState.parsing:
      case _UploadState.verifying:
        return colorScheme.secondaryContainer;
      case _UploadState.idle:
        return colorScheme.surfaceVariant;
    }
  }

  Color _getBorderColor(ColorScheme colorScheme) {
    switch (_state) {
      case _UploadState.error:
        return colorScheme.error;
      case _UploadState.success:
        return colorScheme.primary;
      case _UploadState.parsing:
      case _UploadState.verifying:
        return colorScheme.secondary;
      case _UploadState.idle:
        return colorScheme.outline;
    }
  }

  IconData _getStateIcon() {
    switch (_state) {
      case _UploadState.error:
        return Icons.error_outline_rounded;
      case _UploadState.success:
        // Apply standard icon components for processing updates (Material3.Icons.CheckCircle)
        return Icons.check_circle_rounded;
      case _UploadState.parsing:
      case _UploadState.verifying:
        return Icons.hourglass_top_rounded;
      case _UploadState.idle:
        return Icons.cloud_upload_outlined;
    }
  }

  String _getStateText() {
    switch (_state) {
      case _UploadState.error:
        return _errorMessage ?? 'Invalid file provided.';
      case _UploadState.success:
        return 'Verified: $_fileName';
      case _UploadState.parsing:
        return 'Parsing document...';
      case _UploadState.verifying:
        return 'Verifying file hash...';
      case _UploadState.idle:
        return 'Tap to upload absolute proof of emergency';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isProcessing = _state == _UploadState.parsing || _state == _UploadState.verifying;

    if (isProcessing && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!isProcessing && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }

    return Semantics(
      label: 'Force Majeure File Upload Zone',
      hint: _getStateText(),
      button: true,
      enabled: !isProcessing,
      child: GestureDetector(
        onTap: _handleFileSelection,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          // Configure UI linters to flag components possessing touch targets smaller than 48dp
          constraints: const BoxConstraints(minHeight: 144, minWidth: 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: _getZoneColor(colorScheme),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getBorderColor(colorScheme),
              width: 2.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isProcessing ? 1.0 + (_pulseController.value * 0.15) : 1.0,
                    child: child,
                  );
                },
                child: Icon(
                  _getStateIcon(),
                  size: 48,
                  color: _getBorderColor(colorScheme),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _getStateText(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: _state == _UploadState.error ? colorScheme.onErrorContainer : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_state == _UploadState.idle) ...[
                const SizedBox(height: 8),
                Text(
                  'Accepted formats: PDF, JPEG, PNG (Max 10MB)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ],
              if (isProcessing) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  backgroundColor: colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Wrapper widget to demonstrate submit disabling logic based on verification state.
class ForceMajeureUploadForm extends StatefulWidget {
  const ForceMajeureUploadForm({super.key});

  @override
  State<ForceMajeureUploadForm> createState() => _ForceMajeureUploadFormState();
}

class _ForceMajeureUploadFormState extends State<ForceMajeureUploadForm> {
  bool _isFileVerified = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Force Majeure SLA Pause Request',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Provide undeniable proof to pause penalties instantly.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ForceMajeureFileUploadZone(
            onVerificationChanged: (bool isVerified) {
              setState(() {
                _isFileVerified = isVerified;
              });
            },
          ),
          const SizedBox(height: 32),
          // Submit disabled at DOM level until file hash verified by backend
          FilledButton.icon(
            onPressed: _isFileVerified
                ? () {
                    // Trigger SLA pause logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('SLA Paused Successfully.')),
                    );
                  }
                : null,
            icon: const Icon(Icons.pause_circle_outline_rounded),
            label: const Text('Submit & Pause SLA'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56), // Ensures >= 48dp touch target
              textStyle: theme.textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}