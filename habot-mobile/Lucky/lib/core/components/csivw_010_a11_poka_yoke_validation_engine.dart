// CSIVW-010-A11 — Poka-Yoke Interface-Level Cast-Validation Engine.
// Provides local field validation, input masks, warning chips, auto-focus, haptic feedback, and submit locking.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Csivw010A11PokaYokeValidationEngine extends StatefulWidget {
  const Csivw010A11PokaYokeValidationEngine({
    super.key,
    required this.fields,
    required this.onSubmit,
    this.submitLabel = 'Submit',
  });

  final List<Csivw010A11FieldConfig> fields;
  final ValueChanged<Map<String, String>> onSubmit;
  final String submitLabel;

  @override
  State<Csivw010A11PokaYokeValidationEngine> createState() => _Csivw010A11PokaYokeValidationEngineState();
}

class _Csivw010A11PokaYokeValidationEngineState extends State<Csivw010A11PokaYokeValidationEngine> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};
  final _focusNodes = <String, FocusNode>{};
  final _errors = <String, String?>{};

  @override
  void initState() {
    super.initState();
    for (final field in widget.fields) {
      _controllers[field.id] = TextEditingController();
      _focusNodes[field.id] = FocusNode();
      _errors[field.id] = null;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.fields.isNotEmpty) {
        _focusNodes[widget.fields.first.id]?.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final f in _focusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  bool get _isValid => widget.fields.every((field) {
        final value = _controllers[field.id]?.text ?? '';
        return field.validator(value) == null;
      });

  void _validateField(Csivw010A11FieldConfig field) {
    final value = _controllers[field.id]?.text ?? '';
    final error = field.validator(value);
    if (error != _errors[field.id]) {
      setState(() => _errors[field.id] = error);
      if (error != null) {
        HapticFeedback.mediumImpact();
      }
    }
  }

  void _submit() {
    var valid = true;
    for (final field in widget.fields) {
      _validateField(field);
      if (_errors[field.id] != null) valid = false;
    }
    if (!valid) {
      HapticFeedback.heavyImpact();
      return;
    }
    final data = {
      for (final field in widget.fields) field.id: _controllers[field.id]!.text,
    };
    widget.onSubmit(data);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final field in widget.fields) ...[
            TextFormField(
              key: ValueKey(field.id),
              controller: _controllers[field.id],
              focusNode: _focusNodes[field.id],
              decoration: InputDecoration(
                labelText: field.label,
                helperText: field.helpText,
                errorText: _errors[field.id],
                border: const OutlineInputBorder(),
              ),
              keyboardType: field.keyboardType,
              inputFormatters: field.inputFormatters,
              onChanged: (_) => _validateField(field),
              validator: (value) => field.validator(value ?? ''),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _isValid ? _submit : null,
            child: Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }
}

class Csivw010A11FieldConfig {
  const Csivw010A11FieldConfig({
    required this.id,
    required this.label,
    required this.validator,
    this.helpText,
    this.keyboardType,
    this.inputFormatters = const [],
  });

  final String id;
  final String label;
  final String? helpText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final String? Function(String value) validator;
}
