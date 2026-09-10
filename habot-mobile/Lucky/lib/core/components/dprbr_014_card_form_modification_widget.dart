// DPRBR-014 — Card Form Modification View with Clear Button Positioning.
// Provides a Material 3, accessible card modification form with stable clear-button placement, responsive spacing, and token-based styling.
import 'package:flutter/material.dart';

class Dprbr014CardFormModificationView extends StatefulWidget {
  const Dprbr014CardFormModificationView({super.key, this.onSubmit});

  final ValueChanged<Dprbr014CardFormData>? onSubmit;

  @override
  State<Dprbr014CardFormModificationView> createState() => _Dprbr014CardFormModificationViewState();
}

class Dprbr014CardFormData {
  const Dprbr014CardFormData({
    required this.cardholderName,
    required this.cardNumber,
    required this.expiry,
    required this.cvv,
  });

  final String cardholderName;
  final String cardNumber;
  final String expiry;
  final String cvv;
}

class _Dprbr014CardFormModificationViewState extends State<Dprbr014CardFormModificationView> {
  final _formKey = GlobalKey<FormState>();
  final _cardholderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardholderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _clear(TextEditingController controller) {
    controller.clear();
  }

  void _clearAll() {
    _cardholderController.clear();
    _cardNumberController.clear();
    _expiryController.clear();
    _cvvController.clear();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit?.call(
        Dprbr014CardFormData(
          cardholderName: _cardholderController.text.trim(),
          cardNumber: _cardNumberController.text.trim(),
          expiry: _expiryController.text.trim(),
          cvv: _cvvController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 600;
            final horizontalPadding = isCompact ? 16.0 : 24.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Modify card details',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Update your payment method. Clear actions stay aligned and accessible.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _cardholderController,
                    label: 'Cardholder name',
                    hint: 'Name as shown on card',
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Cardholder name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _cardNumberController,
                    label: 'Card number',
                    hint: '1234 5678 9012 3456',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final digits = value?.replaceAll(RegExp(r'\\D'), '') ?? '';
                      if (digits.length < 12) {
                        return 'Enter a valid card number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _expiryController,
                          label: 'Expiry',
                          hint: 'MM/YY',
                          keyboardType: TextInputType.datetime,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _cvvController,
                          label: 'CVV',
                          hint: '123',
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          obscureText: true,
                          validator: (value) {
                            final digits = value?.replaceAll(RegExp(r'\\D'), '') ?? '';
                            if (digits.length < 3) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clearAll,
                          child: const Text('Clear all'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _submit,
                          child: const Text('Save changes'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Semantics(
      textField: true,
      label: label,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                tooltip: 'Clear $label',
                onPressed: () => _clear(controller),
                icon: const Icon(Icons.clear),
              );
            },
          ),
        ),
      ),
    );
  }
}
