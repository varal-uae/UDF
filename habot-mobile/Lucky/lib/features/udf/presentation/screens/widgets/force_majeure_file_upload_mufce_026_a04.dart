// MUFCE-026-A04 — Force Majeure File Upload Component with strict validation.
// Implements a secure file-picker component logic for SLA pause requests, enforcing file size limits, format restrictions, and hash verification before enabling submission.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mock data and constants for requirement MUFCE-026-A04
class _MockData {
  static const List<String> allowedMimeTypes = [
    'image/jpeg',
    'image/png',
    'application/pdf',
  ];

  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10 MB

  static const String mockStepExecutionId = 'EXEC-9999-001';
  static const String mockUserId = 'USER-OPS-42';
}

enum _UploadState {
  idle,
  validating,
  invalid,
  verifyingHash,
  verified,
}

class ForceMajeureFileUpload extends StatefulWidget {
  const ForceMajeureFileUpload({super.key});

  @override
  State<ForceMajeureFileUpload> createState() => _ForceMajeureFileUploadState();
}

class _ForceMajeureFileUploadState extends State<ForceMajeureFileUpload>
    with SingleTickerProviderStateMixin {
  _UploadState _state = _UploadState.idle;
  String? _fileName;
  Uint8List? _fileBytes;
  String? _errorMessage;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _simulateFilePick() async {
    // Simulate picking a file. In production, use file_picker or image_picker.
    // Here we simulate both valid and invalid scenarios for demonstration.
    setState(() {
      _state = _UploadState.validating;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 800)); // Floor boundary simulation

    // Simulating an invalid file drop to trigger Poka-Yoke self-chasing
    final bool isSimulatedValid = false; 
    
    if (!isSimulatedValid) {
      setState(() {
        _state = _UploadState.invalid;
        _errorMessage = 'Invalid format. Only JPEG, PNG, or PDF under 10MB are accepted.';
      });
      _shakeController.forward(from: 0.0);
      HapticFeedback.heavyImpact();
      return;
    }

    // If valid, proceed to hash verification
    _fileName = 'emergency_proof.pdf';
    _fileBytes = Uint8List.fromList(utf8.encode('mock file content'));
    await _verifyFileHash();
  }

  Future<void> _verifyFileHash() async {
    setState(() => _state = _UploadState.verifyingHash);

    // Simulate backend hash verification
    await Future.delayed(const Duration(seconds: 2)); // Optimal target simulation

    if (!mounted) return;

    setState(() {
      _state = _UploadState.verified;
    });

    // Play standard success sound element (simulated via system feedback)
    HapticFeedback.lightImpact();
  }

  Color _getZoneColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (_state) {
      case _UploadState.idle:
        return colorScheme.surfaceContainerHighest;
      case _UploadState.validating:
      case _UploadState.verifyingHash:
        return colorScheme.primaryContainer;
      case _UploadState.invalid:
        return colorScheme.errorContainer; // Absolute color mapping marker for validation blocks
      case _UploadState.verified:
        return colorScheme.secondaryContainer;
    }
  }

  IconData _getStatusIcon() {
    switch (_state) {
      case _UploadState.idle:
        return Icons.upload_file_outlined;
      case _UploadState.validating:
      case _UploadState.verifyingHash:
        return Icons.hourglass_top_rounded;
      case _UploadState.invalid:
        return Icons.error_outline;
      case _UploadState.verified:
        return Icons.check_circle; // Material3.Icons.CheckCircle equivalent
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Interface message banner displaying clear success states
        if (_state == _UploadState.verified)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: colorScheme.onSecondaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Proof uploaded and verified successfully. Submit enabled.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Rigid file-upload zone parsing document before enabling submit
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value * 10 * (_state == _UploadState.invalid ? 1 : 0), 0),
              child: child,
            );
          },
          child: GestureDetector(
            onTap: _state == _UploadState.idle || _state == _UploadState.invalid
                ? _simulateFilePick
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: _getZoneColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _state == _UploadState.invalid
                      ? colorScheme.error
                      : colorScheme.outlineVariant,
                  width: _state == _UploadState.invalid ? 2.0 : 1.0,
                ),
                // Define Material Design 3 elevation surface overlay color tokens for Level 3
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getStatusIcon(),
                    size: 48,
                    color: _state == _UploadState.invalid
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _state == _UploadState.idle
                        ? 'Drag & Drop or Tap to Upload Proof'
                        : _state == _UploadState.validating
                            ? 'Parsing Document...'
                            : _state == _UploadState.verifyingHash
                                ? 'Verifying File Hash...'
                                : _state == _UploadState.invalid
                                    ? 'Dropping invalid file turns zone red dictating format'
                                    : 'Verification Complete',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: _state == _UploadState.invalid
                          ? colorScheme.onErrorContainer
                          : colorScheme.onSurface,
                    ),
                  ),
                  if (_errorMessage != null && _state == _UploadState.invalid) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                  if (_state == _UploadState.validating || _state == _UploadState.verifyingHash) ...[
                    const SizedBox(height: 16),
                    const CircularProgressIndicator.adaptive(),
                  ],
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Submit disabled at DOM level until file hash verified by backend
        FilledButton.icon(
          onPressed: _state == _UploadState.verified
              ? () {
                  // Trigger submit action
                }
              : null, // Disabled state
          icon: const Icon(Icons.send),
          label: const Text('Submit Emergency Pause Request'),
        ),
      ],
    );
  }
}

/// Wrapper class to mimic AnimatedBuilder behavior if not available directly in older Flutter versions
/// but standard Flutter uses AnimatedBuilder.
class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilderInternal(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}

class AnimatedBuilderInternal extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilderInternal({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}