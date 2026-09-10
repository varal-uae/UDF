// CSIVW-015-A05 — Token-Mapping Automated Text Compiler UI/UX Generation Engine Setup.
// Provides a Material 3 administrative message preview card that validates dynamic template tokens and blocks dispatch when unmapped bracket tokens remain.

import 'package:flutter/material.dart';

class Csivw015A05TokenMappingPreview extends StatefulWidget {
  const Csivw015A05TokenMappingPreview({
    super.key,
    required this.templateText,
    required this.mappedTokens,
    this.onDispatchBlocked,
    this.onDispatchAllowed,
  });

  final String templateText;
  final Map<String, String> mappedTokens;
  final ValueChanged<String>? onDispatchBlocked;
  final VoidCallback? onDispatchAllowed;

  @override
  State<Csivw015A05TokenMappingPreview> createState() => _Csivw015A05TokenMappingPreviewState();
}

class _Csivw015A05TokenMappingPreviewState extends State<Csivw015A05TokenMappingPreview> {
  static final RegExp _tokenPattern = RegExp(r'\{([^{}]+)\}');
  late final TextEditingController _previewController;
  bool _isValid = false;
  String? _validationMessage;
  List<String> _unmappedTokens = const [];

  @override
  void initState() {
    super.initState();
    _previewController = TextEditingController();
    _compilePreview();
  }

  @override
  void didUpdateWidget(covariant Csivw015A05TokenMappingPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.templateText != widget.templateText || oldWidget.mappedTokens != widget.mappedTokens) {
      _compilePreview();
    }
  }

  @override
  void dispose() {
    _previewController.dispose();
    super.dispose();
  }

  void _compilePreview() {
    final rawTokens = _tokenPattern.allMatches(widget.templateText).map((m) => m.group(1)!.trim()).toSet();
    final unmapped = rawTokens.where((token) => !widget.mappedTokens.containsKey(token)).toList()..sort();
    var rendered = widget.templateText;
    for (final entry in widget.mappedTokens.entries) {
      rendered = rendered.replaceAll('{${entry.key}}', entry.value);
    }
    final leaked = _tokenPattern.hasMatch(rendered);
    final valid = unmapped.isEmpty && !leaked;
    setState(() {
      _unmappedTokens = unmapped;
      _isValid = valid;
      _validationMessage = valid
          ? 'All template fields mapped one-to-one. Ready for dispatch.'
          : leaked
              ? 'Unmapped raw bracket tokens detected. Dispatch blocked.'
              : 'Missing token mappings: ${unmapped.join(', ')}';
      _previewController.text = rendered;
    });
  }

  Future<void> _handleDispatch() async {
    if (!_isValid) {
      widget.onDispatchBlocked?.call(_validationMessage ?? 'Dispatch blocked.');
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Dispatch blocked'),
          content: Text(_validationMessage ?? 'Resolve token mapping errors before sending.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Review mapping'),
            ),
          ],
        ),
      );
      return;
    }
    widget.onDispatchAllowed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Administrative message preview',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Validates dynamic template tokens against the data dictionary before dispatch.',
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _previewController,
              readOnly: true,
              maxLines: 6,
              minLines: 3,
              decoration: InputDecoration(
                labelText: 'Compiled communication text',
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.35),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _isValid ? Icons.verified_outlined : Icons.error_outline,
                  color: _isValid ? colorScheme.primary : colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _validationMessage ?? '',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: _isValid ? colorScheme.primary : colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
            if (_unmappedTokens.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _unmappedTokens
                    .map(
                      (token) => Chip(
                        label: Text(token),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(color: colorScheme.error),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _handleDispatch,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Dispatch preview'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
