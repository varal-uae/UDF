// REF-167-A14 — Smart Form Input Component with Contextual Mobile Keyboard Hooks.
// Provides automatic keyboard type mapping based on field data constraints, Material 3 styling, full-width layout, and Poka-Yoke validation disabling submission until all fields pass.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enum defining the supported input types for automatic keyboard mapping.
enum SmartInputType {
  text,
  email,
  phone,
  number,
  password,
  multiline,
}

/// Mock telemetry data model for QA and analytics alignment.
class InputTelemetryEvent {
  final String testType;
  final String testResult;
  final double testCoverage;
  final DateTime testTimestamp;
  final String testLogPath;
  final String completionStatus;
  final String sessionId;

  const InputTelemetryEvent({
    required this.testType,
    required this.testResult,
    required this.testCoverage,
    required this.testTimestamp,
    required this.testLogPath,
    required this.completionStatus,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() => {
        'Test Type': testType,
        'Test Result': testResult,
        'Test Coverage': testCoverage,
        'Test Timestamp': testTimestamp.toIso8601String(),
        'Test Log Path': testLogPath,
        'Completion Status': completionStatus,
        'User/Session ID': sessionId,
      };
}

/// Core reusable smart form input widget that handles automatic system
/// keyboard mapping out of the box following Material Design standards.
class SmartFormInput extends StatefulWidget {
  final String label;
  final String? hintText;
  final SmartInputType inputType;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;

  const SmartFormInput({
    super.key,
    required this.label,
    this.hintText,
    this.inputType = SmartInputType.text,
    this.controller,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  State<SmartFormInput> createState() => _SmartFormInputState();
}

class _SmartFormInputState extends State<SmartFormInput> {
  late final TextEditingController _controller;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  TextInputType _resolveKeyboardType() {
    switch (widget.inputType) {
      case SmartInputType.email:
        return TextInputType.emailAddress;
      case SmartInputType.phone:
        return TextInputType.phone;
      case SmartInputType.number:
        return const TextInputType.numberWithOptions(decimal: false, signed: false);
      case SmartInputType.multiline:
        return TextInputType.multiline;
      case SmartInputType.password:
      case SmartInputType.text:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _resolveInputFormatters() {
    switch (widget.inputType) {
      case SmartInputType.phone:
        return [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]'))];
      case SmartInputType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      case SmartInputType.email:
      case SmartInputType.text:
      case SmartInputType.password:
      case SmartInputType.multiline:
        return [];
    }
  }

  bool _resolveObscureText() => widget.inputType == SmartInputType.password;

  int? _resolveMaxLines() => widget.inputType == SmartInputType.multiline ? 5 : 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _hasFocus = hasFocus;
        });
      },
      child: Padding(
        // Full-width box styling variables enforced onto child elements
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          width: double.infinity,
          child: TextFormField(
            controller: _controller,
            enabled: widget.enabled,
            keyboardType: _resolveKeyboardType(),
            inputFormatters: _resolveInputFormatters(),
            obscureText: _resolveObscureText(),
            maxLines: _resolveMaxLines(),
            onChanged: widget.onChanged,
            validator: widget.validator,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hintText,
              filled: true,
              fillColor: widget.enabled
                  ? colorScheme.surfaceContainerHighest.withOpacity(0.3)
                  : colorScheme.surfaceContainerHighest.withOpacity(0.1),
              // Clear focus outlines that remain visible when keyboard slides up
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 2.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: colorScheme.error,
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: colorScheme.error,
                  width: 2.0,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A wrapper form component that stacks input rows into a single vertical stream
/// on small screen breaks and enforces Poka-Yoke submission rules.
class SmartFormBlock extends StatefulWidget {
  final List<SmartFormInput> fields;
  final VoidCallback onSubmit;
  final String submitLabel;

  const SmartFormBlock({
    super.key,
    required this.fields,
    required this.onSubmit,
    this.submitLabel = 'Submit',
  });

  @override
  State<SmartFormBlock> createState() => _SmartFormBlockState();
}

class _SmartFormBlockState extends State<SmartFormBlock> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isValid = false;

  void _validateForm() {
    setState(() {
      _isValid = _formKey.currentState?.validate() ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      onChanged: _validateForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stacks input rows into a single vertical stream
          ...widget.fields,
          const SizedBox(height: 24.0),
          // Mistake-Proofing (Poka-Yoke): Submission disabled until validation passes
          FilledButton(
            onPressed: _isValid
                ? () {
                    if (_formKey.currentState!.validate()) {
                      widget.onSubmit();
                      _logTelemetry(true);
                    }
                  }
                : null,
            child: Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }

  void _logTelemetry(bool passed) {
    // Automated regression code checks & GCP / BigQuery Alignment mock
    final event = InputTelemetryEvent(
      testType: 'KeyboardMappingValidation',
      testResult: passed ? 'Pass' : 'Fail',
      testCoverage: 1.0,
      testTimestamp: DateTime.now(),
      testLogPath: '/logs/ref_167_a14_validation.log',
      completionStatus: passed ? 'Pass' : 'Fail',
      sessionId: 'mock-session-id-12345',
    );
    // In production, stream directly into analytics buckets
    debugPrint('Telemetry Event: ${event.toJson()}');
  }
}
