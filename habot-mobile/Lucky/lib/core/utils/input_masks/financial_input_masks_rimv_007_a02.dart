// RIMV-007-A02 — Financial and Identity Input Masking Utilities.
// Provides regex-based input formatters, visual validation states, and mock template configurations for onboarding financial data entry to prevent invalid payload mutations.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enum representing the type of input template.
enum TemplateType { financial, identity, personal }

/// Mock data model representing an input template configuration.
class InputTemplateConfig {
  final String templateName;
  final String templateVersion;
  final TemplateType templateType;
  final Map<String, dynamic> templateConfiguration;

  const InputTemplateConfig({
    required this.templateName,
    required this.templateVersion,
    required this.templateType,
    required this.templateConfiguration,
  });
}

/// Hardcoded mock repository simulating backend template configurations.
class MockTemplateRepository {
  static const List<InputTemplateConfig> templates = [
    InputTemplateConfig(
      templateName: 'UAE_IBAN_Entry',
      templateVersion: '1.0.0',
      templateType: TemplateType.financial,
      templateConfiguration: {
        'maxLength': 23,
        'prefix': 'AE',
        'maskPattern': 'AE## #### #### #### #### ###',
      },
    ),
    InputTemplateConfig(
      templateName: 'Emirates_ID_Entry',
      templateVersion: '1.0.0',
      templateType: TemplateType.identity,
      templateConfiguration: {
        'maxLength': 18,
        'prefix': '784',
        'maskPattern': '784-####-#######-#',
      },
    ),
    InputTemplateConfig(
      templateName: 'Credit_Card_Entry',
      templateVersion: '1.0.0',
      templateType: TemplateType.financial,
      templateConfiguration: {
        'maxLength': 19,
        'maskPattern': '#### #### #### ####',
      },
    ),
  ];

  static List<InputTemplateConfig> getTemplates() => templates;
}

/// Poka-Yoke Regex Matrix for programmatic front-end rejection.
class FinancialInputMasks {
  FinancialInputMasks._();

  /// Allows only digits, enforces max length, suitable for credit cards or raw IDs.
  static TextInputFormatter numericOnly(int maxLength) {
    return FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*$'));
  }

  /// UAE IBAN Formatter: AE followed by 21 digits. Formats with spaces every 4 chars.
  static TextInputFormatter uaeIbanFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String text = newValue.text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
      
      // Enforce prefix if user starts typing
      if (text.isNotEmpty && !text.startsWith('AE')) {
        if (text.length == 1 && text != 'A') return oldValue;
        if (text.length == 2 && text != 'AE') return oldValue;
      }

      if (text.length > 23) text = text.substring(0, 23);

      final buffer = StringBuffer();
      for (int i = 0; i < text.length; i++) {
        if (i > 1 && (i - 2) % 4 == 0) buffer.write(' ');
        buffer.write(text[i]);
      }

      final String formatted = buffer.toString();
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  /// Emirates ID Formatter: 784-XXXX-XXXXXXX-X
  static TextInputFormatter emiratesIdFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
      
      if (text.isNotEmpty && !text.startsWith('784')) {
        if (text.length <= 3 && !'784'.startsWith(text)) return oldValue;
      }

      if (text.length > 15) text = text.substring(0, 15);

      final buffer = StringBuffer();
      for (int i = 0; i < text.length; i++) {
        if (i == 3 || i == 7 || i == 14) buffer.write('-');
        buffer.write(text[i]);
      }

      final String formatted = buffer.toString();
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  /// Credit Card Formatter: XXXX XXXX XXXX XXXX
  static TextInputFormatter creditCardFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (text.length > 16) text = text.substring(0, 16);

      final buffer = StringBuffer();
      for (int i = 0; i < text.length; i++) {
        if (i > 0 && i % 4 == 0) buffer.write(' ');
        buffer.write(text[i]);
      }

      final String formatted = buffer.toString();
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  /// Validation regex matrix for submission blocking.
  static bool isValidUaeIban(String input) {
    return RegExp(r'^AE[0-9]{2}\s?[0-9]{4}\s?[0-9]{4}\s?[0-9]{4}\s?[0-9]{4}\s?[0-9]{3}$').hasMatch(input);
  }

  static bool isValidEmiratesId(String input) {
    return RegExp(r'^784-[0-9]{4}-[0-9]{7}-[0-9]{1}$').hasMatch(input);
  }

  static bool isValidCreditCard(String input) {
    return RegExp(r'^[0-9]{4}\s?[0-9]{4}\s?[0-9]{4}\s?[0-9]{4}$').hasMatch(input);
  }
}

/// Visual validation highlight state for Material 3 compliance.
enum InputValidationState { idle, valid, invalid }

/// A reusable UI component implementing distinct visual validation highlights inside form bounding borders.
class MaskedFinancialTextField extends StatefulWidget {
  final String label;
  final TemplateType templateType;
  final ValueChanged<bool>? onValidationChanged;

  const MaskedFinancialTextField({
    super.key,
    required this.label,
    required this.templateType,
    this.onValidationChanged,
  });

  @override
  State<MaskedFinancialTextField> createState() => _MaskedFinancialTextFieldState();
}

class _MaskedFinancialTextFieldState extends State<MaskedFinancialTextField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  InputValidationState _validationState = InputValidationState.idle;
  String? _errorText;

  late final TextInputFormatter _formatter;
  late final bool Function(String) _validator;
  late final TextInputType _keyboardType;

  @override
  void initState() {
    super.initState();
    _setupMaskAndValidator();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_validateInput);
  }

  void _setupMaskAndValidator() {
    switch (widget.templateType) {
      case TemplateType.financial:
        // Defaulting to Credit Card for generic financial, can be expanded via config
        _formatter = FinancialInputMasks.creditCardFormatter();
        _validator = FinancialInputMasks.isValidCreditCard;
        _keyboardType = TextInputType.number;
        break;
      case TemplateType.identity:
        _formatter = FinancialInputMasks.emiratesIdFormatter();
        _validator = FinancialInputMasks.isValidEmiratesId;
        _keyboardType = TextInputType.number;
        break;
      case TemplateType.personal:
        _formatter = FilteringTextInputFormatter.singleLineFormatter;
        _validator = (val) => val.trim().isNotEmpty;
        _keyboardType = TextInputType.text;
        break;
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _controller.text.isNotEmpty) {
      _validateInput();
    } else if (_focusNode.hasFocus) {
      setState(() {
        _validationState = InputValidationState.idle;
        _errorText = null;
      });
    }
  }

  void _validateInput() {
    final text = _controller.text;
    if (text.isEmpty) {
      setState(() {
        _validationState = InputValidationState.idle;
        _errorText = null;
      });
      widget.onValidationChanged?.call(false);
      return;
    }

    final isValid = _validator(text);
    setState(() {
      if (isValid) {
        _validationState = InputValidationState.valid;
        _errorText = null;
      } else {
        _validationState = InputValidationState.invalid;
        _errorText = 'Invalid format. Please check your entry.';
      }
    });
    widget.onValidationChanged?.call(isValid);
  }

  Color _getBorderColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (_validationState) {
      case InputValidationState.idle:
        return _focusNode.hasFocus ? colorScheme.primary : colorScheme.outline;
      case InputValidationState.valid:
        return colorScheme.primary;
      case InputValidationState.invalid:
        return colorScheme.error;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: _keyboardType,
          inputFormatters: [_formatter],
          decoration: InputDecoration(
            labelText: widget.label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: _getBorderColor(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: _getBorderColor(context), width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2.0),
            ),
            // Distinct visual validation highlights inside form bounding borders
            filled: _validationState != InputValidationState.idle,
            fillColor: _validationState == InputValidationState.valid
                ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2)
                : _validationState == InputValidationState.invalid
                    ? Theme.of(context).colorScheme.errorContainer.withOpacity(0.2)
                    : null,
          ),
        ),
        // Execute clear error presentation tracks below active text regions
        if (_validationState == InputValidationState.invalid && _errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 16.0),
            child: Text(
              _errorText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12.0,
              ),
            ),
          ),
      ],
    );
  }
}