// REF-242-A11 — Strict Input Masking Utilities and Widgets.
// Provides masked text input formatters, raw value stripping for API payloads, and a reusable masked text field component following Material 3 standards.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Strips all static formatting characters from a masked string,
/// returning only the raw alphanumeric payload suitable for backend submission.
String stripMaskToRawValue(String maskedValue) {
  final buffer = StringBuffer();
  for (final rune in maskedValue.runes) {
    final char = String.fromCharCode(rune);
    if (RegExp(r'[a-zA-Z0-9]').hasMatch(char)) {
      buffer.write(char);
    }
  }
  return buffer.toString();
}

/// A [TextInputFormatter] that enforces a strict mask pattern.
///
/// Supported mask characters:
/// - `#` : Numeric digit (0-9)
/// - `A` : Alphabetic character (a-z, A-Z)
/// - `*` : Alphanumeric character
/// - Any other character is treated as a static literal separator.
class StrictMaskInputFormatter extends TextInputFormatter {
  StrictMaskInputFormatter(this.mask);

  final String mask;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final rawNewText = stripMaskToRawValue(newValue.text);
    final buffer = StringBuffer();
    int rawIndex = 0;

    for (int i = 0; i < mask.length && rawIndex < rawNewText.length; i++) {
      final maskChar = mask[i];
      final inputChar = rawNewText[rawIndex];

      if (maskChar == '#') {
        if (RegExp(r'[0-9]').hasMatch(inputChar)) {
          buffer.write(inputChar);
          rawIndex++;
        } else {
          // Ignore invalid keystroke (Poka-Yoke)
          rawIndex++;
          i--; // Retry this mask position with next input char
        }
      } else if (maskChar == 'A') {
        if (RegExp(r'[a-zA-Z]').hasMatch(inputChar)) {
          buffer.write(inputChar);
          rawIndex++;
        } else {
          rawIndex++;
          i--;
        }
      } else if (maskChar == '*') {
        if (RegExp(r'[a-zA-Z0-9]').hasMatch(inputChar)) {
          buffer.write(inputChar);
          rawIndex++;
        } else {
          rawIndex++;
          i--;
        }
      } else {
        // Static formatting character
        buffer.write(maskChar);
        // Only advance rawIndex if the user typed the literal mask char
        if (inputChar == maskChar) {
          rawIndex++;
        }
      }
    }

    final formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

/// Determines the optimal [TextInputType] based on the mask pattern
/// to automatically trigger specific numeric or alphanumeric keyboards.
KeyboardType _resolveKeyboardType(String mask) {
  final hasAlpha = mask.contains('A') || mask.contains('*');
  final hasNumeric = mask.contains('#') || mask.contains('*');

  if (hasNumeric && !hasAlpha) {
    return TextInputType.number;
  }
  if (hasAlpha && !hasNumeric) {
    return TextInputType.text;
  }
  return TextInputType.visiblePassword;
}

/// A reusable, error-proof masked text field component.
///
/// Automatically applies strict input masking, configures the correct
/// mobile keyboard type, and strips formatting characters before
/// invoking the [onRawValueChanged] callback.
class StrictMaskedTextField extends StatefulWidget {
  const StrictMaskedTextField({
    super.key,
    required this.mask,
    required this.onRawValueChanged,
    this.labelText,
    this.hintText,
    this.controller,
  });

  /// The mask pattern (e.g., '###-AA-****').
  final String mask;

  /// Callback invoked with the stripped raw value whenever the input changes.
  final ValueChanged<String> onRawValueChanged;

  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;

  @override
  State<StrictMaskedTextField> createState() => _StrictMaskedTextFieldState();
}

class _StrictMaskedTextFieldState extends State<StrictMaskedTextField> {
  late final TextEditingController _controller;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _isInternalController = true;
    }
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final rawValue = stripMaskToRawValue(_controller.text);
    widget.onRawValueChanged(rawValue);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: _controller,
      keyboardType: _resolveKeyboardType(widget.mask),
      inputFormatters: [
        StrictMaskInputFormatter(widget.mask),
      ],
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText ?? widget.mask.replaceAll(RegExp(r'[^#A*]'), ''),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      ),
      style: theme.textTheme.bodyLarge,
    );
  }
}

// --- Mock Data & Example Usage for Testing ---

/// Mock API payload generator demonstrating that masked values are
/// correctly sent without mask characters.
class MockApiSubmissionService {
  static Future<bool> submitFormData({
    required String phoneRaw,
    required String licenseRaw,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final mockPayload = {
      'step_execution_id': 'EXEC-${DateTime.now().millisecondsSinceEpoch}',
      'execution_status': 'SUCCESS',
      'execution_timestamp': DateTime.now().toIso8601String(),
      'step_outcome': 'PASS',
      'user_id': 'USR-MOCK-001',
      'data': {
        'phone_number': phoneRaw,
        'license_plate': licenseRaw,
      },
    };

    debugPrint('[MockAPI] Payload submitted: $mockPayload');

    // Validate strip accuracy (Floor/Optimal/Ceiling Boundary = 100)
    final isClean = !phoneRaw.contains(RegExp(r'[^0-9]')) &&
        !licenseRaw.contains(RegExp(r'[^a-zA-Z0-9]'));

    return isClean;
  }
}

/// Example screen demonstrating the strict input masking architecture.
class MaskValidationDemoScreen extends StatelessWidget {
  const MaskValidationDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String phoneRaw = '';
    String licenseRaw = '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Strict Input Masking Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StrictMaskedTextField(
              mask: '+971-##-###-####',
              labelText: 'Phone Number',
              hintText: '+971-XX-XXX-XXXX',
              onRawValueChanged: (value) => phoneRaw = value,
            ),
            const SizedBox(height: 24),
            StrictMaskedTextField(
              mask: 'AA-#####',
              labelText: 'License Plate',
              hintText: 'AB-12345',
              onRawValueChanged: (value) => licenseRaw = value,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () async {
                final isValid = await MockApiSubmissionService.submitFormData(
                  phoneRaw: phoneRaw,
                  licenseRaw: licenseRaw,
                );

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isValid
                          ? 'Clean data payload submitted successfully.'
                          : 'Validation failed: malformed data detected.',
                    ),
                    backgroundColor: isValid
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                );
              },
              icon: const Icon(Icons.send_rounded),
              label: const Text('Submit Clean Payload'),
            ),
          ],
        ),
      ),
    );
  }
}