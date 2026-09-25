// SSELC-011-A01 — ContextMirrorInputPanel: Split-pane correction entry widget.
// Provides a responsive split-screen layout for reference context and text correction input, enforcing minimum word-count validation before submission.

import 'package:flutter/material.dart';

/// Mock data representing repository metadata required by the panel.
class _MockRepositoryData {
  static const String repositoryUrl = 'https://github.com/habot/ui-components-core.git';
  static const String repositoryBranch = 'main';
  static const String accessRights = 'read-write';
  static const String commitHistory = 'abc1234 - Initial setup\ndef5678 - Added tokens';
  static const String repositoryVersion = '1.0.4';
  static const String cloneStatus = 'Cloned';
}

/// A reusable split-pane input panel for manual text corrections.
/// Adapts from vertical single-column on mobile to balanced double-column on wide screens (>1024dp).
class ContextMirrorInputPanel extends StatefulWidget {
  final VoidCallback? onSubmit;

  const ContextMirrorInputPanel({super.key, this.onSubmit});

  @override
  State<ContextMirrorInputPanel> createState() => _ContextMirrorInputPanelState();
}

class _ContextMirrorInputPanelState extends State<ContextMirrorInputPanel> {
  final TextEditingController _correctionController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  String? _validationError;

  // Minimum word count threshold for submission (Poka-Yoke)
  static const int _minWordCount = 3;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _correctionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int _getWordCount(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  void _handleSubmit() {
    final wordCount = _getWordCount(_correctionController.text);
    if (wordCount < _minWordCount) {
      setState(() {
        _validationError = 'Submission blocked: Minimum $_minWordCount words required. Current: $wordCount.';
      });
      return;
    }

    setState(() {
      _validationError = null;
    });

    widget.onSubmit?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1024;

    // Reference Material Pane (Upper/Left)
    final referencePane = Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reference Context', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _buildMetaRow('Repository URL:', _MockRepositoryData.repositoryUrl, theme),
          _buildMetaRow('Branch:', _MockRepositoryData.repositoryBranch, theme),
          _buildMetaRow('Access Rights:', _MockRepositoryData.accessRights, theme),
          _buildMetaRow('Version:', _MockRepositoryData.repositoryVersion, theme),
          _buildMetaRow('Clone Status:', _MockRepositoryData.cloneStatus, theme),
          const SizedBox(height: 12),
          Text('Commit History:', style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            _MockRepositoryData.commitHistory,
            style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
          ),
        ],
      ),
    );

    // Correction Entry Pane (Lower/Right)
    final entryPane = Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: _isFocused ? colorScheme.primary : colorScheme.outlineVariant,
          width: _isFocused ? 2.0 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Text Correction Entry', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _correctionController,
            focusNode: _focusNode,
            minLines: 4,
            maxLines: 8,
            onChanged: (_) {
              if (_validationError != null) {
                setState(() => _validationError = null);
              }
            },
            decoration: InputDecoration(
              hintText: 'Enter corrected text here...',
              filled: true,
              fillColor: _isFocused
                  ? colorScheme.primaryContainer.withOpacity(0.3)
                  : colorScheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              // Enforce minimum touch height of 48dp
              constraints: const BoxConstraints(minHeight: 48.0),
            ),
          ),
          if (_validationError != null) ...[
            const SizedBox(height: 8),
            Text(
              _validationError!,
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.error),
            ),
          ],
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _handleSubmit,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Submit Correction'),
            ),
          ),
        ],
      ),
    );

    // Scroll container that adjusts for on-screen keyboards
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isWideScreen
            // Balanced double columns for wide screens (>1024dp)
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: referencePane),
                  const SizedBox(width: 16),
                  Expanded(child: entryPane),
                ],
              )
            // Vertical single column for mobile
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  referencePane,
                  const SizedBox(height: 16),
                  entryPane,
                ],
              ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Keep row labels clearly visible above masked indicators
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
