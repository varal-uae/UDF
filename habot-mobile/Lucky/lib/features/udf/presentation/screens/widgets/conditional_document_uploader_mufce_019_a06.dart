// MUFCE-019-A06 — Conditional Document Uploader with Progressive Disclosure.
// Implements upload gates, DCYN verification toggles, and strict state management for document compliance validation.

import 'package:flutter/material.dart';

enum UploaderState { hidden, revealed, uploading, verifying, verified, failed }

class DcynVerification {
  final String id;
  final String label;
  bool isConfirmed;

  DcynVerification({
    required this.id,
    required this.label,
    this.isConfirmed = false,
  });
}

class MockDocumentMetadata {
  final String layoutType;
  final Size gridDimensions;
  final double spacing;
  final Alignment alignment;
  final bool isValidated;

  const MockDocumentMetadata({
    this.layoutType = 'Standard',
    this.gridDimensions = const Size(300, 400),
    this.spacing = 16.0,
    this.alignment = Alignment.center,
    this.isValidated = false,
  });
}

class ConditionalDocumentUploader extends StatefulWidget {
  final VoidCallback? onUploadSuccess;
  final ValueChanged<String>? onError;

  const ConditionalDocumentUploader({
    super.key,
    this.onUploadSuccess,
    this.onError,
  });

  @override
  State<ConditionalDocumentUploader> createState() => _ConditionalDocumentUploaderState();
}

class _ConditionalDocumentUploaderState extends State<ConditionalDocumentUploader> {
  UploaderState _state = UploaderState.revealed;
  final List<DcynVerification> _dcynChecks = [
    DcynVerification(id: 'dcyn_01', label: 'Document is legible and clear'),
    DcynVerification(id: 'dcyn_02', label: 'All edges of the document are visible'),
    DcynVerification(id: 'dcyn_03', label: 'No sensitive unrelated data exposed'),
  ];

  final MockDocumentMetadata _metadata = const MockDocumentMetadata(
    layoutType: 'SecureNative',
    gridDimensions: Size(double.infinity, 200),
    spacing: 16.0,
    alignment: Alignment.center,
    isValidated: true,
  );

  bool get _allDcynConfirmed => _dcynChecks.every((check) => check.isConfirmed);
  bool get _isSaveEnabled => _state == UploaderState.verified && _allDcynConfirmed;

  void _simulateFileSelection() {
    setState(() {
      _state = UploaderState.uploading;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _state = UploaderState.verifying;
      });
    });
  }

  void _onDcynToggle(int index, bool value) {
    setState(() {
      _dcynChecks[index].isConfirmed = value;
      if (value && _allDcynConfirmed) {
        _state = UploaderState.verified;
      } else if (_state == UploaderState.verified) {
        _state = UploaderState.verifying;
      }
    });
  }

  void _abortFlow() {
    setState(() {
      _state = UploaderState.failed;
      for (final check in _dcynChecks) {
        check.isConfirmed = false;
      }
    });
    widget.onError?.call('Upload aborted due to failed compliance checks.');

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _state = UploaderState.revealed;
      });
    });
  }

  void _saveDocument() {
    if (!_isSaveEnabled) return;
    widget.onUploadSuccess?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document saved and verified successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_state == UploaderState.hidden) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: EdgeInsets.all(_metadata.spacing),
      child: Padding(
        padding: EdgeInsets.all(_metadata.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Document Upload Compliance',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: _metadata.spacing),

            if (_state == UploaderState.revealed)
              _buildUploadTrigger(theme, colorScheme),

            if (_state == UploaderState.uploading)
              _buildProgressIndicator(theme, 'Uploading securely...'),

            if (_state == UploaderState.verifying || _state == UploaderState.verified)
              _buildDcynVerificationGates(theme, colorScheme),

            if (_state == UploaderState.failed)
              _buildErrorState(theme, colorScheme),

            SizedBox(height: _metadata.spacing),

            FilledButton(
              onPressed: _isSaveEnabled ? _saveDocument : null,
              style: FilledButton.styleFrom(
                backgroundColor: _isSaveEnabled
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                foregroundColor: _isSaveEnabled
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              child: const Text('Save Document'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadTrigger(ThemeData theme, ColorScheme colorScheme) {
    return OutlinedButton.icon(
      onPressed: _simulateFileSelection,
      icon: const Icon(Icons.cloud_upload_outlined),
      label: const Text('Select & Upload Document'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 24),
        side: BorderSide(color: colorScheme.primary),
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme, String message) {
    return Column(
      children: [
        const LinearProgressIndicator(),
        const SizedBox(height: 12),
        Text(message, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildDcynVerificationGates(ThemeData theme, ColorScheme colorScheme) {
    return AnimatedOpacity(
      opacity: _state == UploaderState.verifying || _state == UploaderState.verified ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Post-Upload Compliance Checks (DCYN)',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(_dcynChecks.length, (index) {
            final check = _dcynChecks[index];
            return SwitchListTile(
              title: Text(check.label),
              value: check.isConfirmed,
              activeColor: colorScheme.primary,
              onChanged: (val) {
                if (!val) {
                  _abortFlow();
                } else {
                  _onDcynToggle(index, val);
                }
              },
              contentPadding: EdgeInsets.zero,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Compliance check failed. Please upload a correct document.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
