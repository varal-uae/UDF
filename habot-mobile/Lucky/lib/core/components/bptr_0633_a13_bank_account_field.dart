// BPTR-0633-A13 — Bank Account Input & Inline Validation Component.
// Enforces numeric mobile keyboard, input masking, anomaly alert panel, and disabled save until bank format is valid.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Bptr0633A13BankAccountField extends StatefulWidget {
  const Bptr0633A13BankAccountField({
    super.key,
    this.initialValue = '',
    this.minLength = 16,
    this.maxLength = 34,
    this.groupSize = 4,
    this.onSaved,
  });

  final String initialValue;
  final int minLength;
  final int maxLength;
  final int groupSize;
  final ValueChanged<String>? onSaved;

  @override
  State<Bptr0633A13BankAccountField> createState() => _Bptr0633A13BankAccountFieldState();
}

class _Bptr0633A13BankAccountFieldState extends State<Bptr0633A13BankAccountField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isValid = false;
  List<String> _anomalies = const [];

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController(text: _formatForDisplay(widget.initialValue));
    _controller.addListener(_validate);
    _validate();
  }

  @override
  void dispose() {
    _controller.removeListener(_validate);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'[^0-9]'), '');

  String _formatForDisplay(String value) {
    final digits = _digitsOnly(value);
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % widget.groupSize == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  void _validate() {
    if (!mounted) return;
    final raw = _controller.text.replaceAll(' ', '');
    final digits = _digitsOnly(raw);
    final anomalies = <String>[];
    if (digits.isEmpty) {
      anomalies.add('Bank account number is required.');
    }
    if (digits.isNotEmpty && digits.length < widget.minLength) {
      anomalies.add('Must be at least ${widget.minLength} digits.');
    }
    if (digits.length > widget.maxLength) {
      anomalies.add('Must not exceed ${widget.maxLength} digits.');
    }
    if (RegExp(r'[^0-9]').hasMatch(raw)) {
      anomalies.add('Only numeric characters are allowed.');
    }
    setState(() {
      _isValid = anomalies.isEmpty;
      _anomalies = anomalies;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_isValid && _anomalies.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.error),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: theme.colorScheme.onErrorContainer),
                    const SizedBox(width: 8),
                    Text(
                      'Formatting anomalies',
                      style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onErrorContainer),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ..._anomalies.map(
                  (anomaly) => Text(
                    '• $anomaly',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onErrorContainer),
                  ),
                ),
              ],
            ),
          ),
        Semantics(
          textField: true,
          label: 'Bank account number',
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _Bptr0633A13BankAccountFormatter(groupSize: widget.groupSize),
            ],
            decoration: InputDecoration(
              labelText: 'Bank account number',
              hintText: 'Enter numeric account number',
              prefixIcon: const Icon(Icons.account_balance),
              suffixIcon: _isValid ? const Icon(Icons.check_circle, color: Colors.green) : null,
              border: const OutlineInputBorder(),
              errorText: _isValid ? null : (_anomalies.isNotEmpty ? _anomalies.first : null),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isValid ? () => widget.onSaved?.call(_controller.text.replaceAll(' ', '')) : null,
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }
}

class _Bptr0633A13BankAccountFormatter extends TextInputFormatter {
  _Bptr0633A13BankAccountFormatter({required this.groupSize});

  final int groupSize;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % groupSize == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
