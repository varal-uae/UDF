// CSIVW-012-A03 — Bulk Action Guardrail Modal for high-risk deletion confirmation.
// Provides a text-validation confirmation overlay that locks the action until the user types the exact phrase. Renders full-screen on mobile and centered modal on desktop, lists high-priority row titles, and shows exact affected row count.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BulkActionGuardrailModal extends StatefulWidget {
  const BulkActionGuardrailModal({
    super.key,
    required this.affectedCount,
    required this.highPriorityTitles,
    required this.confirmationPhrase,
    required this.onConfirm,
    this.actionLabel = 'Delete',
  });

  final int affectedCount;
  final List<String> highPriorityTitles;
  final String confirmationPhrase;
  final VoidCallback onConfirm;
  final String actionLabel;

  static Future<bool?> show({
    required BuildContext context,
    required int affectedCount,
    required List<String> highPriorityTitles,
    String confirmationPhrase = 'DELETE',
    String actionLabel = 'Delete',
    required VoidCallback onConfirm,
  }) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    if (isMobile) {
      return Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          fullscreenDialog: true,
          builder: (_) => BulkActionGuardrailModal(
            affectedCount: affectedCount,
            highPriorityTitles: highPriorityTitles,
            confirmationPhrase: confirmationPhrase,
            actionLabel: actionLabel,
            onConfirm: onConfirm,
          ),
        ),
      );
    }
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BulkActionGuardrailModal(
        affectedCount: affectedCount,
        highPriorityTitles: highPriorityTitles,
        confirmationPhrase: confirmationPhrase,
        actionLabel: actionLabel,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<BulkActionGuardrailModal> createState() => _BulkActionGuardrailModalState();
}

class _BulkActionGuardrailModalState extends State<BulkActionGuardrailModal> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isConfirmed = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _controller.addListener(_validate);
  }

  @override
  void dispose() {
    _controller.removeListener(_validate);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validate() {
    final matches = _controller.text.trim() == widget.confirmationPhrase;
    if (matches != _isConfirmed) {
      setState(() => _isConfirmed = matches);
    }
  }

  Future<void> _handleConfirm() async {
    if (!_isConfirmed || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      widget.onConfirm();
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final content = _buildContent(context, theme, colorScheme, isMobile);
    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Confirm bulk action'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          ),
        ),
        body: SafeArea(child: content),
      );
    }
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: content,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, ColorScheme colorScheme, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WarningCallout(
            affectedCount: widget.affectedCount,
            actionLabel: widget.actionLabel,
          ),
          const SizedBox(height: 16),
          Text(
            'High-priority records affected',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (widget.highPriorityTitles.isEmpty)
            Text('No high-priority titles were provided.', style: theme.textTheme.bodyMedium)
          else
            ...widget.highPriorityTitles.take(5).map(
              (title) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 18, color: colorScheme.error),
                    const SizedBox(width: 8),
                    Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),
                  ],
                ),
              ),
            ),
          if (widget.highPriorityTitles.length > 5) ...[
            const SizedBox(height: 4),
            Text(
              '+${widget.highPriorityTitles.length - 5} more high-priority records',
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            'Type ${widget.confirmationPhrase} to confirm',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Semantics(
            textField: true,
            label: 'Confirmation phrase',
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: !_isSubmitting,
              autofocus: true,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
              decoration: InputDecoration(
                hintText: widget.confirmationPhrase,
                border: const OutlineInputBorder(),
                suffixIcon: _isConfirmed
                    ? Icon(Icons.check_circle, color: colorScheme.primary)
                    : null,
              ),
              onSubmitted: (_) => _handleConfirm(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _isConfirmed && !_isSubmitting ? _handleConfirm : null,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.actionLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WarningCallout extends StatelessWidget {
  const _WarningCallout({
    required this.affectedCount,
    required this.actionLabel,
  });

  final int affectedCount;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: colorScheme.onErrorContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$actionLabel $affectedCount records?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'This high-risk action cannot be undone. Review the affected records before confirming.',
            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onErrorContainer),
          ),
        ],
      ),
    );
  }
}
