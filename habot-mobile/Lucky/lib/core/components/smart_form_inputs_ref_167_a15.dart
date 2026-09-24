// REF-167-A15 — Smart Form Input Architecture with Contextual Mobile Keyboard Hooks.
// Provides reusable Material 3 form field components that automatically map system keyboards to expected data types, enforce validation before submission, and stack into single-column vertical layouts on mobile screens.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enum defining the supported smart input types for automatic keyboard mapping.
enum SmartInputType {
  text,
  email,
  phone,
  number,
  decimal,
  password,
}

/// A reusable smart form input widget that handles automatic system keyboard
/// mapping, contextual input formatting, and strict validation out of the box.
class SmartFormInput extends StatefulWidget {
  final String label;
  final String? hint;
  final SmartInputType inputType;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final int? maxLines;
  final FocusNode? focusNode;

  const SmartFormInput({
    super.key,
    required this.label,
    this.hint,
    this.inputType = SmartInputType.text,
    this.controller,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.focusNode,
  });

  @override
  State<SmartFormInput> createState() => _SmartFormInputState();
}

class _SmartFormInputState extends State<SmartFormInput> {
  late final TextEditingController _internalController;
  late final FocusNode _internalFocusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _hasFocus = _internalFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    if (widget.focusNode == null) {
      _internalFocusNode.removeListener(_handleFocusChange);
      _internalFocusNode.dispose();
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
        return TextInputType.number;
      case SmartInputType.decimal:
        return const TextInputType.numberWithOptions(decimal: true);
      case SmartInputType.password:
        return TextInputType.visiblePassword;
      case SmartInputType.text:
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _resolveInputFormatters() {
    switch (widget.inputType) {
      case SmartInputType.phone:
        return [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]'))];
      case SmartInputType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      case SmartInputType.decimal:
        return [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))];
      case SmartInputType.email:
      case SmartInputType.text:
      case SmartInputType.password:
      default:
        return [];
    }
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '${widget.label} is required';
    }
    switch (widget.inputType) {
      case SmartInputType.email:
        final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
        if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
        break;
      case SmartInputType.phone:
        final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
        if (digits.length < 7 || digits.length > 15) {
          return 'Enter a valid phone number';
        }
        break;
      case SmartInputType.number:
        if (int.tryParse(value) == null) return 'Enter a valid whole number';
        break;
      case SmartInputType.decimal:
        if (double.tryParse(value) == null) return 'Enter a valid number';
        break;
      case SmartInputType.password:
        if (value.length < 8) return 'Password must be at least 8 characters';
        break;
      case SmartInputType.text:
        break;
    }
    return widget.validator?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _internalController,
        focusNode: _internalFocusNode,
        keyboardType: _resolveKeyboardType(),
        inputFormatters: _resolveInputFormatters(),
        obscureText: widget.inputType == SmartInputType.password,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        onChanged: widget.onChanged,
        validator: _defaultValidator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          filled: true,
          fillColor: widget.enabled
              ? colorScheme.surfaceContainerHighest.withOpacity(0.3)
              : colorScheme.surfaceContainerHighest.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: colorScheme.outline),
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
            borderSide: BorderSide(color: colorScheme.error),
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
            vertical: 14.0,
          ),
        ),
      ),
    );
  }
}

/// A form wrapper that stacks inputs into a single vertical stream on small
/// screen breakpoints and enforces full-width box styling variables.
/// Submission actions remain strictly disabled until internal validation passes.
class SmartFormLayout extends StatefulWidget {
  final List<Widget> children;
  final VoidCallback? onValidSubmit;
  final String submitLabel;

  const SmartFormLayout({
    super.key,
    required this.children,
    this.onValidSubmit,
    this.submitLabel = 'Submit',
  });

  @override
  State<SmartFormLayout> createState() => _SmartFormLayoutState();
}

class _SmartFormLayoutState extends State<SmartFormLayout> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isValid = false;

  void _onFormChanged() {
    // Defer validation check to after the current frame to allow fields to update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isValid = _formKey.currentState?.validate() ?? false;
      if (isValid != _isValid) {
        setState(() {
          _isValid = isValid;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      onChanged: _onFormChanged,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...widget.children,
          const SizedBox(height: 24.0),
          FilledButton(
            onPressed: _isValid
                ? () {
                    if (_formKey.currentState!.validate()) {
                      widget.onValidSubmit?.call();
                    }
                  }
                : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }
}

/// Mock telemetry service to simulate streaming validation failure frequencies
/// into analytics buckets to flag confusing input blocks (GCP / BigQuery Alignment).
class SmartFormTelemetryService {
  SmartFormTelemetryService._();
  static final SmartFormTelemetryService instance = SmartFormTelemetryService._();

  final Map<String, int> _validationFailureCounts = {};

  void recordValidationFailure(String fieldName) {
    _validationFailureCounts[fieldName] =
        (_validationFailureCounts[fieldName] ?? 0) + 1;
    debugPrint(
        '[REF-167-A15 Telemetry] Validation failure recorded for "$fieldName". Total: ${_validationFailureCounts[fieldName]}');
  }

  Map<String, int> getFailureMetrics() =>
      Map.unmodifiable(_validationFailureCounts);

  void reset() => _validationFailureCounts.clear();
}

/// Example usage demonstrating the atomic reusability across user data
/// submission and form collection workflows.
class SmartFormExampleScreen extends StatelessWidget {
  const SmartFormExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final quantityController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Form Inputs'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: SmartFormLayout(
            submitLabel: 'Submit Data',
            onValidSubmit: () {
              debugPrint('[REF-167-A15] Form submitted successfully.');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Form validated and submitted!')),
              );
            },
            children: [
              SmartFormInput(
                label: 'Full Name',
                hint: 'Enter your full name',
                inputType: SmartInputType.text,
                controller: nameController,
              ),
              SmartFormInput(
                label: 'Email Address',
                hint: 'example@domain.com',
                inputType: SmartInputType.email,
                controller: emailController,
              ),
              SmartFormInput(
                label: 'Phone Number',
                hint: '+971 50 123 4567',
                inputType: SmartInputType.phone,
                controller: phoneController,
              ),
              SmartFormInput(
                label: 'Quantity',
                hint: 'Enter quantity',
                inputType: SmartInputType.number,
                controller: quantityController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
