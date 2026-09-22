// NSKFI-004-A04 — Right Ingress Form Keyboard Trigger Logic.
// Encapsulates form fields in controlled wrappers that manage mobile software keyboard actions, floating labels, 56dp min height, autocorrect disabling, and trailing clear buttons.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Configuration model for atomic-level data fields required by the layout engine.
class FormLayoutConfig {
  final String layoutType;
  final Size layoutGridDimensions;
  final EdgeInsets spacingRules;
  final Alignment alignmentSettings;
  final bool layoutValidationStatus;

  const FormLayoutConfig({
    required this.layoutType,
    required this.layoutGridDimensions,
    required this.spacingRules,
    required this.alignmentSettings,
    required this.layoutValidationStatus,
  });
}

/// Definition of a single field within the Right Ingress Form.
class IngressFieldDefinition {
  final String id;
  final String label;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool disableAutocorrect;
  final List<TextInputFormatter>? inputFormatters;
  final String? mockInitialValue;

  const IngressFieldDefinition({
    required this.id,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.disableAutocorrect = false,
    this.inputFormatters,
    this.mockInitialValue,
  });
}

/// The core layout engine optimized for native touch inputs.
/// Implements mistake-proofing (Poka-Yoke) by dismissing keyboards on neutral background taps.
class RightIngressKeyboardTriggerView extends StatelessWidget {
  final List<IngressFieldDefinition> fields;
  final FormLayoutConfig layoutConfig;
  final VoidCallback? onSubmit;

  const RightIngressKeyboardTriggerView({
    super.key,
    required this.fields,
    required this.layoutConfig,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    // Tapping neutral background zones drops virtual software keyboards automatically
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Align(
            alignment: layoutConfig.alignmentSettings,
            child: SingleChildScrollView(
              padding: layoutConfig.spacingRules,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...fields.map((field) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _IngressFormField(field: field),
                      )),
                  if (onSubmit != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: FilledButton(
                        onPressed: onSubmit,
                        child: const Text('Submit'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Controlled wrapper managing mobile software keyboard actions per field.
class _IngressFormField extends StatefulWidget {
  final IngressFieldDefinition field;

  const _IngressFormField({required this.field});

  @override
  State<_IngressFormField> createState() => _IngressFormFieldState();
}

class _IngressFormFieldState extends State<_IngressFormField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.field.mockInitialValue);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: widget.field.keyboardType,
      obscureText: widget.field.obscureText,
      enableSuggestions: !widget.field.disableAutocorrect,
      autocorrect: !widget.field.disableAutocorrect,
      inputFormatters: widget.field.inputFormatters,
      // Setting input container sizes to a minimum height of 56dp for reliable thumb accuracy
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        // Relying on floating placeholder text labels to maintain clarity inside compact forms
        labelText: widget.field.label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        constraints: const BoxConstraints(minHeight: 56.0),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
        ),
        // Adding explicit trailing wipe buttons to let users clear fields instantly
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  _controller.clear();
                  FocusScope.of(context).unfocus();
                },
                tooltip: 'Clear field',
              )
            : null,
      ),
    );
  }
}

/// Mock Data & Factory for demonstration and local testing without backend dependency.
class RightIngressMockFactory {
  static const FormLayoutConfig defaultLayoutConfig = FormLayoutConfig(
    layoutType: 'VerticalColumn',
    layoutGridDimensions: Size(double.infinity, double.infinity),
    spacingRules: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
    alignmentSettings: Alignment.topCenter,
    layoutValidationStatus: true,
  );

  static final List<IngressFieldDefinition> defaultFields = [
    const IngressFieldDefinition(
      id: 'unique_code_field',
      label: 'Unique Reference Code',
      keyboardType: TextInputType.visiblePassword,
      disableAutocorrect: true,
      mockInitialValue: '',
    ),
    const IngressFieldDefinition(
      id: 'full_name_field',
      label: 'Full Name',
      keyboardType: TextInputType.name,
      disableAutocorrect: false,
      mockInitialValue: '',
    ),
    const IngressFieldDefinition(
      id: 'phone_number_field',
      label: 'Mobile Number',
      keyboardType: TextInputType.phone,
      disableAutocorrect: true,
      mockInitialValue: '+971',
    ),
    const IngressFieldDefinition(
      id: 'email_field',
      label: 'Email Address',
      keyboardType: TextInputType.emailAddress,
      disableAutocorrect: true,
      mockInitialValue: '',
    ),
  ];

  static Widget buildMockRightIngressForm({VoidCallback? onSubmit}) {
    return RightIngressKeyboardTriggerView(
      fields: defaultFields,
      layoutConfig: defaultLayoutConfig,
      onSubmit: onSubmit,
    );
  }
}