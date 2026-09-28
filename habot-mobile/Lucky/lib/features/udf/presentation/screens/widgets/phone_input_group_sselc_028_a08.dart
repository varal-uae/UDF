// SSELC-028-A08 — PhoneInputGroup Split-Field Format Enforcer Widget.
// Implements a touch-friendly country code dropdown prefix attached to a numeric-only phone input field with real-time regex masking, length validation, and Poka-Yoke form submission control.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mock data representing country codes and their expected phone number lengths/formats.
class _CountryCodeEntry {
  final String name;
  final String dialCode;
  final int expectedLength;
  final String regexPattern;

  const _CountryCodeEntry({
    required this.name,
    required this.dialCode,
    required this.expectedLength,
    required this.regexPattern,
  });
}

const List<_CountryCodeEntry> _mockCountryCodes = [
  _CountryCodeEntry(name: 'United Arab Emirates', dialCode: '+971', expectedLength: 9, regexPattern: r'^[0-9]{9}$'),
  _CountryCodeEntry(name: 'United States', dialCode: '+1', expectedLength: 10, regexPattern: r'^[0-9]{10}$'),
  _CountryCodeEntry(name: 'United Kingdom', dialCode: '+44', expectedLength: 10, regexPattern: r'^[0-9]{10}$'),
  _CountryCodeEntry(name: 'India', dialCode: '+91', expectedLength: 10, regexPattern: r'^[0-9]{10}$'),
  _CountryCodeEntry(name: 'Saudi Arabia', dialCode: '+966', expectedLength: 9, regexPattern: r'^[0-9]{9}$'),
];

/// A split-field interactive component for phone number input.
/// Enforces alphanumeric constraints dynamically based on the selected country code.
class PhoneInputGroup extends StatefulWidget {
  final ValueChanged<String>? onValidNumberChanged;
  final ValueChanged<bool>? onValidationStateChanged;

  const PhoneInputGroup({
    super.key,
    this.onValidNumberChanged,
    this.onValidationStateChanged,
  });

  @override
  State<PhoneInputGroup> createState() => _PhoneInputGroupState();
}

class _PhoneInputGroupState extends State<PhoneInputGroup> {
  late _CountryCodeEntry _selectedCountry;
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  bool _isTouched = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _selectedCountry = _mockCountryCodes.first;
    _phoneController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validateInput);
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _validateInput() {
    final text = _phoneController.text;
    // Real-time inline feedback: reject non-conforming input
    final regExp = RegExp(r'^[0-9]*$');
    if (!regExp.hasMatch(text)) {
      _phoneController.text = text.replaceAll(RegExp(r'[^0-9]'), '');
      _phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: _phoneController.text.length),
      );
      return;
    }

    final isLengthValid = text.length == _selectedCountry.expectedLength;
    final matchesRegex = RegExp(_selectedCountry.regexPattern).hasMatch(text);
    
    setState(() {
      _isValid = isLengthValid && matchesRegex;
    });

    widget.onValidationStateChanged?.call(_isValid);
    if (_isValid) {
      widget.onValidNumberChanged?.call('${_selectedCountry.dialCode}$text');
    }
  }

  void _onCountrySelected(_CountryCodeEntry? entry) {
    if (entry == null) return;
    setState(() {
      _selectedCountry = entry;
      _phoneController.clear();
      _isTouched = false;
      _isValid = false;
    });
    widget.onValidationStateChanged?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final bool showError = _isTouched && !_isValid && _phoneController.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Clear text annotations highlighting field constraints
        Text(
          'Emergency Contact Number',
          style: textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Touch-friendly dropdown prefix attached to the input field
            // Clear visual separation between code and number
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                border: Border.all(
                  color: showError ? colorScheme.error : colorScheme.outline,
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<_CountryCodeEntry>(
                  value: _selectedCountry,
                  items: _mockCountryCodes.map((entry) {
                    return DropdownMenuItem<_CountryCodeEntry>(
                      value: entry,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '${entry.dialCode} (${entry.name})',
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: _onCountrySelected,
                  borderRadius: BorderRadius.circular(12),
                  icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurface),
                ),
              ),
            ),
            const SizedBox(width: 1), // Visual separation line
            Expanded(
              child: TextField(
                controller: _phoneController,
                focusNode: _phoneFocusNode,
                keyboardType: TextInputType.number,
                // Numeric keypad exclusively
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(_selectedCountry.expectedLength),
                ],
                style: textTheme.bodyLarge?.copyWith(
                  letterSpacing: 1.2,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter ${_selectedCountry.expectedLength} digits',
                  hintStyle: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    borderSide: BorderSide(color: colorScheme.outline, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    borderSide: BorderSide(
                      color: showError ? colorScheme.error : colorScheme.outline,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    borderSide: BorderSide(
                      color: showError ? colorScheme.error : colorScheme.primary,
                      width: 2.0,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    borderSide: BorderSide(color: colorScheme.error, width: 1.5),
                  ),
                ),
                onTap: () {
                  if (!_isTouched) {
                    setState(() => _isTouched = true);
                  }
                },
                onChanged: (_) => _validateInput(),
              ),
            ),
          ],
        ),
        // Red helper text indicating required format length / Invalid inputs are physically blocked
        if (showError)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              'Invalid format. Exactly ${_selectedCountry.expectedLength} digits required for ${_selectedCountry.name}.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        else if (_isValid)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              'Valid phone number format.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

/// Poka-Yoke wrapper: Form submission disabled if inputted number length
/// does not mathematically match selected country code format.
class PhoneInputFormWrapper extends StatefulWidget {
  final VoidCallback onSubmit;

  const PhoneInputFormWrapper({
    super.key,
    required this.onSubmit,
  });

  @override
  State<PhoneInputFormWrapper> createState() => _PhoneInputFormWrapperState();
}

class _PhoneInputFormWrapperState extends State<PhoneInputFormWrapper> {
  bool _isFormValid = false;
  String? _formattedNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PhoneInputGroup(
          onValidationStateChanged: (isValid) {
            setState(() => _isFormValid = isValid);
          },
          onValidNumberChanged: (number) {
            _formattedNumber = number;
          },
        ),
        const SizedBox(height: 24),
        // Mistake-Proofing (Poka-Yoke): Form submission disabled if invalid
        FilledButton(
          onPressed: _isFormValid
              ? () {
                  // Reset the failure counter to zero if the test packet registers successful arrival.
                  debugPrint('Submitting valid number: $_formattedNumber');
                  widget.onSubmit();
                }
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: _isFormValid ? colorScheme.primary : colorScheme.surfaceContainerHighest,
            foregroundColor: _isFormValid ? colorScheme.onPrimary : colorScheme.onSurfaceVariant.withOpacity(0.5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Verify Emergency Contact'),
        ),
      ],
    );
  }
}
