// ARCPE-008-05 — Generative Prompt Template Selectors.
// Renders constrained input text boxes for prompt variables, maps them into a hidden API payload string,
// and enforces minimum 48dp touch targets for Material 3 accessibility compliance.
import 'dart:convert';

import 'package:flutter/material.dart';

/// Describes a single variable slot in a generative prompt template.
class PromptTemplateVariable {
  const PromptTemplateVariable({
    required this.key,
    required this.label,
    this.initialValue = '',
    this.obscureText = false,
    this.keyboardType,
    this.helperText,
  });

  final String key;
  final String label;
  final String initialValue;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? helperText;
}

/// Renders individual, accessibility-compliant text boxes for each prompt variable.
/// Combines the entered values into a single hidden JSON payload string.
class GenerativePromptTemplateSelector extends StatefulWidget {
  const GenerativePromptTemplateSelector({
    super.key,
    required this.variables,
    this.layoutGridColumns = 1,
    this.spacing = 12.0,
    this.alignment = CrossAxisAlignment.stretch,
    this.minTouchTargetSize = 48.0,
    this.onPayloadChanged,
    this.onValidationChanged,
  });

  final List<PromptTemplateVariable> variables;
  final int layoutGridColumns;
  final double spacing;
  final CrossAxisAlignment alignment;
  final double minTouchTargetSize;
  final ValueChanged<String>? onPayloadChanged;
  final ValueChanged<bool>? onValidationChanged;

  @override
  State<GenerativePromptTemplateSelector> createState() =>
      _GenerativePromptTemplateSelectorState();
}

class _GenerativePromptTemplateSelectorState
    extends State<GenerativePromptTemplateSelector> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (final variable in widget.variables) {
      final controller = TextEditingController(text: variable.initialValue);
      controller.addListener(_handleInputChanged);
      _controllers[variable.key] = controller;
    }
    _emitState();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.removeListener(_handleInputChanged);
      controller.dispose();
    }
    super.dispose();
  }

  void _handleInputChanged() {
    setState(_emitState);
  }

  void _emitState() {
    final payloadMap = <String, dynamic>{};
    var complete = true;
    for (final variable in widget.variables) {
      final value = _controllers[variable.key]?.text.trim() ?? '';
      payloadMap[variable.key] = value;
      if (value.isEmpty) {
        complete = false;
      }
    }
    widget.onPayloadChanged?.call(jsonEncode(payloadMap));
    widget.onValidationChanged?.call(complete);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: widget.alignment,
      children: [
        for (var index = 0; index < widget.variables.length; index++) ...[
          if (index > 0) SizedBox(height: widget.spacing),
          _PromptVariableTextField(
            variable: widget.variables[index],
            controller: _controllers[widget.variables[index].key]!,
            minTouchTargetSize: widget.minTouchTargetSize,
          ),
        ],
      ],
    );
  }
}

class _PromptVariableTextField extends StatelessWidget {
  const _PromptVariableTextField({
    required this.variable,
    required this.controller,
    required this.minTouchTargetSize,
  });

  final PromptTemplateVariable variable;
  final TextEditingController controller;
  final double minTouchTargetSize;

  @override
  Widget build(BuildContext context) {
    final enabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: 2,
      ),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minTouchTargetSize),
      child: TextField(
        controller: controller,
        obscureText: variable.obscureText,
        keyboardType: variable.keyboardType,
        decoration: InputDecoration(
          labelText: variable.label,
          helperText: variable.helperText,
          alignLabelWithHint: true,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          enabledBorder: enabledBorder,
          focusedBorder: focusedBorder,
        ),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
