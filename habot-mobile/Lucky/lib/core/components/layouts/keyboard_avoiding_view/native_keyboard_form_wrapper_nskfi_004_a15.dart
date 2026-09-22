// NSKFI-004-A15 — Native Keyboard Trigger Logic & Right Ingress Form Wrapper.
// Encapsulates form fields in controlled wrappers that manage mobile software keyboard actions, floating labels, 56dp min height, trailing clear buttons, and background tap-to-dismiss behavior.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A wrapper widget that manages native keyboard interactions for right ingress forms.
/// Implements Material 3 standards with floating labels, 56dp minimum input height,
/// autocorrect disabling for unique code fields, trailing wipe buttons, and
/// background tap-to-dismiss keyboard logic.
class NativeKeyboardFormWrapper extends StatelessWidget {
  const NativeKeyboardFormWrapper({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(16.0),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Mistake-Proofing (Poka-Yoke): Tapping neutral background zones drops
        // virtual software keyboards automatically, restoring split-screen visibility.
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

/// A standardized text field component adhering to NSKFI-004-A15 requirements.
/// Enforces 56dp minimum height, floating placeholder labels, optional trailing
/// wipe (clear) buttons, and configurable autocorrect/input mask behaviors.
class StandardizedFormField extends StatefulWidget {
  const StandardizedFormField({
    super.key,
    required this.labelText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isUniqueCodeField = false,
    this.showClearButton = true,
    this.inputFormatters,
    this.validator,
    this.onChanged,
  });

  final String labelText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool isUniqueCodeField;
  final bool showClearButton;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  @override
  State<StandardizedFormField> createState() => _StandardizedFormFieldState();
}

class _StandardizedFormFieldState extends State<StandardizedFormField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final bool hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    widget.onChanged?.call(_controller.text);
  }

  void _clearField() {
    _controller.clear();
    // Ensure keyboard remains visible after clearing if focused
    FocusManager.instance.primaryFocus?.requestFocus();
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mobile-First & Responsive UI: Setting input container sizes to a minimum
    // height of 56dp for reliable thumb accuracy.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56.0),
      child: TextFormField(
        controller: _controller,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        inputFormatters: widget.inputFormatters,
        // Mobile-First & Responsive UX: Disabling autocorrect features on unique
        // code fields to protect entry accuracy.
        autocorrect: !widget.isUniqueCodeField,
        enableSuggestions: !widget.isUniqueCodeField,
        // UX Translation: Floating placeholder text labels to maintain clarity
        // inside compact forms.
        decoration: InputDecoration(
          labelText: widget.labelText,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: const OutlineInputBorder(),
          // Mobile-First & Responsive UI: Adding explicit trailing wipe buttons
          // to let users clear fields instantly.
          suffixIcon: widget.showClearButton && _hasText
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear field',
                  onPressed: _clearField,
                )
              : null,
          // Ensures the 56dp constraint is respected internally by the InputDecorator
          isDense: false,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 16.0,
          ),
        ),
      ),
    );
  }
}

/// Mock data repository simulating backend transaction payload updates
/// securely through platform API endpoints (GCP / BigQuery Alignment).
class MockFormPayloadRepository {
  static const Map<String, dynamic> mockTransactionPayload = {
    'transactionId': 'TXN-99283746-MOCK',
    'timestamp': '2026-09-22T10:30:00Z',
    'formData': {
      'fullName': 'Jane Doe',
      'emiratesId': '784-1990-1234567-1',
      'phoneNumber': '+971501234567',
      'uniqueReferenceCode': 'UDF-REF-00415',
    },
    'validationStatus': 'PASS',
    'layoutValidation': {
      'layoutType': 'SingleColumnVertical',
      'gridDimensions': {'width': '100%', 'height': 'auto'},
      'spacingRules': '16dp standard margin',
      'alignmentSettings': 'stretch',
      'layoutValidationStatus': 'PASS',
    },
  };

  /// Simulates submitting validated form data to GCP/BigQuery via API.
  Future<bool> submitPayload(Map<String, dynamic> payload) async {
    // Simulate network latency
    await Future<void>.delayed(const Duration(milliseconds: 500));
    // AISS: Verify that the matching input mask strictly prevents malformed
    // user data input layout breaks.
    debugPrint('Mock Payload Submitted: $payload');
    return true;
  }
}
