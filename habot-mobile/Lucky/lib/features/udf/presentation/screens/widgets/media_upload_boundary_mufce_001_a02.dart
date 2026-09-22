// MUFCE-001-A02 — Media Upload Boundary & Validation Widget.
// Implements drag-and-drop file containers with interactive warning states, 5MB size enforcement, local image compression, Material 3 stepper integration, and Snackbar alerts for verification failures.

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mock data representing atomic-level definition fields required by the system.
class MediaDefinitionMock {
  static const String definitionId = 'DEF-MUFCE-001-A02-001';
  static const String definitionName = 'Campaign Imagery Max Size Rule';
  static const String definitionType = 'MediaFileSizeLimit';
  static const Map<String, dynamic> definitionParameters = {
    'maxSizeMb': 5.0,
    'allowedTypes': ['image/jpeg', 'image/png', 'video/mp4', 'audio/mpeg'],
    'compressionEnabled': true,
  };
  static const String validationStatus = 'Approved';
}

enum MediaValidationState { idle, validating, valid, invalid }

class MediaUploadBoundaryWidget extends StatefulWidget {
  const MediaUploadBoundaryWidget({super.key});

  @override
  State<MediaUploadBoundaryWidget> createState() => _MediaUploadBoundaryWidgetState();
}

class _MediaUploadBoundaryWidgetState extends State<MediaUploadBoundaryWidget> {
  MediaValidationState _validationState = MediaValidationState.idle;
  double _uploadProgress = 0.0;
  bool _isHovering = false;
  int _currentStep = 0;

  static const double _maxFileSizeBytes = 5 * 1024 * 1024; // 5 Megabytes Poka-Yoke limit

  final FocusNode _dropZoneFocusNode = FocusNode();

  @override
  void dispose() {
    _dropZoneFocusNode.dispose();
    super.dispose();
  }

  /// Simulates local camera payload compression before upload to minimize network bills.
  Future<Uint8List> _compressImageLocally(Uint8List originalBytes) async {
    // In production, use flutter_image_compress or similar package.
    // Here we simulate a 40% reduction in payload size.
    final int compressedLength = (originalBytes.length * 0.6).toInt();
    return Uint8List.sublistView(originalBytes, 0, compressedLength.clamp(0, originalBytes.length));
  }

  Future<void> _handleFileSelection(int fileSizeBytes, String fileName) async {
    setState(() {
      _validationState = MediaValidationState.validating;
      _uploadProgress = 0.0;
    });

    await Future.delayed(const Duration(milliseconds: 800)); // Async processing indicator delay

    if (fileSizeBytes > _maxFileSizeBytes) {
      setState(() => _validationState = MediaValidationState.invalid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification Failure: "$fileName" exceeds the strict 5MB boundary limit.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'DISMISS',
              textColor: Theme.of(context).colorScheme.onError,
              onPressed: () {},
            ),
          ),
        );
      }
      return;
    }

    // Simulate compression
    final Uint8List dummyData = Uint8List(fileSizeBytes);
    await _compressImageLocally(dummyData);

    // Simulate chunked upload progress
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (mounted) {
        setState(() => _uploadProgress = i / 10.0);
      }
    }

    setState(() => _validationState = MediaValidationState.valid);

    // Auto-advance logic upon valid field completion
    if (_currentStep < 2) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _currentStep++);
      });
    }
  }

  Color _getBorderColor(BuildContext context) {
    switch (_validationState) {
      case MediaValidationState.valid:
        return Theme.of(context).colorScheme.primary;
      case MediaValidationState.invalid:
        return Theme.of(context).colorScheme.error;
      case MediaValidationState.validating:
        return Theme.of(context).colorScheme.tertiary;
      case MediaValidationState.idle:
        return _isHovering
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outlineVariant;
    }
  }

  IconData _getStateIcon() {
    switch (_validationState) {
      case MediaValidationState.valid:
        return Icons.check_circle_outline_rounded;
      case MediaValidationState.invalid:
        return Icons.error_outline_rounded;
      case MediaValidationState.validating:
        return Icons.hourglass_top_rounded;
      case MediaValidationState.idle:
        return Icons.cloud_upload_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Semantics(
      label: 'Media Upload Drop Zone',
      hint: 'Drag and drop files here or tap to select. Maximum file size is 5 megabytes.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Adaptive horizontal to vertical stepper transitions based on viewport
          Stepper(
            currentStep: _currentStep,
            type: isMobile ? StepperType.vertical : StepperType.horizontal,
            controlsBuilder: (context, details) => const SizedBox.shrink(), // Handled via auto-advance
            steps: [
              Step(
                title: const Text('Select Media'),
                content: const Text('Choose imagery or video assets.'),
                isActive: _currentStep >= 0,
                state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('Validation'),
                content: const Text('Automated boundary checks running.'),
                isActive: _currentStep >= 1,
                state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('Ingestion'),
                content: const Text('Asset securely uploaded to pipeline.'),
                isActive: _currentStep >= 2,
                state: _currentStep == 2 && _validationState == MediaValidationState.valid
                    ? StepState.complete
                    : StepState.indexed,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Drag-and-drop file container with interactive warning states
          KeyboardListener(
            focusNode: _dropZoneFocusNode,
            onKeyEvent: (KeyEvent event) {
              // Screen-reader / keyboard accessibility simulation
              if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                _handleFileSelection(2 * 1024 * 1024, 'keyboard_selected_asset.jpg');
              }
            },
            child: GestureDetector(
              onTap: _validationState != MediaValidationState.validating
                  ? () => _handleFileSelection(3 * 1024 * 1024, 'mock_camera_capture.jpg')
                  : null,
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovering = true),
                onExit: (_) => setState(() => _isHovering = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: _isHovering
                        ? colorScheme.primaryContainer.withOpacity(0.3)
                        : colorScheme.surfaceContainerHighest.withOpacity(0.1),
                    border: Border.all(
                      color: _getBorderColor(context),
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    // Consistent elevation and spacing mark the active state
                    boxShadow: _isHovering || _validationState == MediaValidationState.validating
                        ? [
                            BoxShadow(
                              color: colorScheme.shadow.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getStateIcon(),
                        size: 48,
                        color: _getBorderColor(context),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _validationState == MediaValidationState.idle
                            ? 'Drop assets here or tap to browse'
                            : _validationState == MediaValidationState.validating
                                ? 'Processing & Compressing...'
                                : _validationState == MediaValidationState.valid
                                    ? 'Asset Validated Successfully'
                                    : 'Boundary Breach Detected',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: _getBorderColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Max allowed size: ${(_maxFileSizeBytes / (1024 * 1024)).toStringAsFixed(0)} MB | Def ID: ${MediaDefinitionMock.definitionId}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Material Linear Progress models for async processing indicators
                      if (_validationState == MediaValidationState.validating)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _uploadProgress,
                            minHeight: 6,
                            backgroundColor: colorScheme.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                          ),
                        ),

                      // Mistake-Proofing (Poka-Yoke): Visually disable actions during processing
                      if (_validationState == MediaValidationState.invalid)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: ElevatedButton.icon(
                            onPressed: () => setState(() => _validationState = MediaValidationState.idle),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset Upload'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.errorContainer,
                              foregroundColor: colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Fluid flex wrapping structures rearrange upload thumbnails beautifully on mobile
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMockThumbnail(context, 'thumb_1.jpg', true),
              _buildMockThumbnail(context, 'thumb_2.mp4', true),
              _buildMockThumbnail(context, 'oversized_file.png', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMockThumbnail(BuildContext context, String name, bool isValid) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isValid ? colorScheme.primary : colorScheme.error,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isValid ? Icons.image_outlined : Icons.warning_amber_rounded,
            size: 24,
            color: isValid ? colorScheme.primary : colorScheme.error,
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
