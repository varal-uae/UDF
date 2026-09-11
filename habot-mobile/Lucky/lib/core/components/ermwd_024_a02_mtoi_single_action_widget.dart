// ERMWD-024-A02 — MTOI Single-Action Mobile Interface.
// Centered Card with 8dp elevation, cropped image, masked input, and full-width primary submit button.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MtoiSingleActionWidget extends StatefulWidget {
  const MtoiSingleActionWidget({
    super.key,
    required this.imageAssetPath,
    required this.inputMask,
    required this.onSubmit,
    this.inputLabel = 'Enter value',
    this.submitLabel = 'Submit',
  });

  final String imageAssetPath;
  final String inputMask;
  final ValueChanged<String> onSubmit;
  final String inputLabel;
  final String submitLabel;

  @override
  State<MtoiSingleActionWidget> createState() => _MtoiSingleActionWidgetState();
}

class _MtoiSingleActionWidgetState extends State<MtoiSingleActionWidget> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isValid = false;

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
    final text = _controller.text;
    final valid = text.isNotEmpty && _matchesMask(text, widget.inputMask);
    if (valid != _isValid) {
      setState(() => _isValid = valid);
    }
  }

  bool _matchesMask(String value, String mask) {
    if (mask.isEmpty) return value.isNotEmpty;
    if (value.length != mask.length) return false;
    for (var i = 0; i < mask.length; i++) {
      final m = mask[i];
      final c = value[i];
      if (m == '#') {
        if (!RegExp(r'\d').hasMatch(c)) return false;
      } else if (m == 'A') {
        if (!RegExp(r'[A-Za-z]').hasMatch(c)) return false;
      } else if (m == '*') {
        if (!RegExp(r'[A-Za-z0-9]').hasMatch(c)) return false;
      } else if (m != c) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          widget.imageAssetPath,
                          fit: BoxFit.contain,
                          semanticLabel: 'Cropped task image',
                          errorBuilder: (_, __, ___) => Container(
                            height: 180,
                            color: theme.colorScheme.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_not_supported_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Semantics(
                        textField: true,
                        label: widget.inputLabel,
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.text,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(widget.inputMask.length),
                          ],
                          decoration: InputDecoration(
                            labelText: widget.inputLabel,
                            border: const OutlineInputBorder(),
                            errorText: _controller.text.isEmpty || _isValid ? null : 'Value does not match required mask',
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) {
                            if (_isValid) widget.onSubmit(_controller.text);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _isValid ? () => widget.onSubmit(_controller.text) : null,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          textStyle: theme.textTheme.titleMedium,
                        ),
                        child: Text(widget.submitLabel),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
