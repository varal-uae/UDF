// ============================================================================
// TELEMETRY METADATA BLOCK
// Mobile Platform: Flutter Universal Framework
// OS Version: Cross-Platform Universal Runtime
// Device Type: Web / Tablet / Mobile Responsive Form
// Screen Dimensions: Fluid LayoutBuilder Container (maxWidth: 600px)
// Mobile Configuration: Keystroke Filtering & Dynamic Masking Poka-Yoke
// Completion Status: Target: Complete - Requirement & Asset Discovery Coverage
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// SCTSS-008: Interactive Masked Input Form
///
/// Filters keystrokes at the widget level, dynamically formats inputs for downstream
/// BigQuery pipelines, and enforces a Poka-Yoke save button lock until all fields pass validation.
class InteractiveMaskedInputForm extends StatefulWidget {
  const InteractiveMaskedInputForm({super.key});

  @override
  State<InteractiveMaskedInputForm> createState() =>
      _InteractiveMaskedInputFormState();
}

class _InteractiveMaskedInputFormState
    extends State<InteractiveMaskedInputForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();

  bool _isFormValid = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    // Check extra field length constraints for BigQuery pipeline safety
    final phoneDigits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final currencyDigits = _currencyController.text.replaceAll(RegExp(r'\D'), '');

    final phoneValid = phoneDigits.length == 10;
    final currencyValid = currencyDigits.isNotEmpty && double.tryParse(currencyDigits) != null;

    final overallValid = isValid && phoneValid && currencyValid;

    if (overallValid != _isFormValid) {
      setState(() {
        _isFormValid = overallValid;
      });
    }
  }

  void _handleSave() {
    if (_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "BigQuery Payload Prepared: Phone=${_phoneController.text}, Currency=${_currencyController.text}",
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Interactive Masked Input Form (SCTSS-008)"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth <= 600;

                Widget formFieldsWidget = Form(
                  key: _formKey,
                  onChanged: _validateForm,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "BigQuery Ingestion Form",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Keystroke filtering and real-time masking active.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Phone Number Field
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        // Physical Keystroke Rejection
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _PhoneNumberMaskFormatter(),
                        ],
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          hintText: "(555) 000-0000",
                          prefixIcon: const Icon(Icons.phone),
                          border: const OutlineInputBorder(),
                          helperText: "Format: (XXX) XXX-XXXX",
                        ),
                        validator: (value) {
                          final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
                          if (digits.length != 10) {
                            return "Phone number must be exactly 10 digits.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Currency Amount Field
                      TextFormField(
                        controller: _currencyController,
                        keyboardType: TextInputType.number,
                        // Physical Keystroke Rejection
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _CurrencyMaskFormatter(),
                        ],
                        decoration: InputDecoration(
                          labelText: "Transaction Currency",
                          hintText: "\$0.00",
                          prefixIcon: const Icon(Icons.attach_money),
                          border: const OutlineInputBorder(),
                          helperText: "Real-time currency formatting",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty || value == "\$0.00") {
                            return "Please enter a valid currency amount.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // The "Save" Button Chaser (Poka-Yoke): onPressed set to null if form invalid
                      SizedBox(
                        width: double.infinity,
                        height: 48.0,
                        child: FilledButton.icon(
                          onPressed: _isFormValid ? _handleSave : null,
                          icon: const Icon(Icons.cloud_upload),
                          label: Text(_isFormValid ? "Save to BigQuery" : "Fix Typos to Save"),
                        ),
                      ),
                    ],
                  ),
                );

                if (!isMobile) {
                  // Web/Tablet View (> 600px): Constrain max width 600px
                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: formFieldsWidget,
                      ),
                    ),
                  );
                }

                return formFieldsWidget;
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom Masking Formatter for Phone Numbers (XXX) XXX-XXXX
class _PhoneNumberMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    if (newText.isEmpty) return newValue;

    final digits = newText.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length && i < 10; i++) {
      if (i == 0) buffer.write('(');
      if (i == 3) buffer.write(') ');
      if (i == 6) buffer.write('-');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Custom Masking Formatter for Currency Formatting ($X,XXX.XX)
class _CurrencyMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    if (newText.isEmpty) return newValue;

    final digits = newText.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');

    final double val = double.parse(digits) / 100.0;
    final formatted = "\$${val.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}";

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
