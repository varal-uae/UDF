// CSIVW-002-A15 — Profile Field Constraint Configuration UI.
// Provides masked, validated profile inputs with inline semantic warnings, Material date picker,
// one-tap time slot confirmation, and responsive calendar grid behavior.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileConstraintForm extends StatefulWidget {
  const ProfileConstraintForm({super.key});

  @override
  State<ProfileConstraintForm> createState() => _ProfileConstraintFormState();
}

class _ProfileConstraintFormState extends State<ProfileConstraintForm> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _employeeIdController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTimeSlot;

  static const _timeSlots = <String>[
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
  ];

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile constraints satisfied.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Profile Field Constraint Configuration',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _displayNameController,
            decoration: const InputDecoration(
              labelText: 'Display Name',
              hintText: 'Letters and spaces only',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
              LengthLimitingTextInputFormatter(40),
            ],
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Display name is required';
              if (text.length < 2) return 'Use at least 2 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'name@example.com',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r' ')),
              LengthLimitingTextInputFormatter(120),
            ],
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Email is required';
              final regex = RegExp(r'^[^@ ]+@[^@ ]+[.][^@ ]+$');
              if (!regex.hasMatch(text)) return 'Enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _employeeIdController,
            decoration: const InputDecoration(
              labelText: 'Employee ID',
              hintText: 'AB-1234',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
              LengthLimitingTextInputFormatter(12),
              _MaskedTextInputFormatter(mask: 'XX-9999'),
            ],
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Employee ID is required';
              if (!RegExp(r'^[A-Z]{2}-[0-9]{4}$').hasMatch(text)) {
                return 'Use format AB-1234';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Demo Booking',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month),
            label: Text(
              _selectedDate == null
                  ? 'Select date'
                  : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, _) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _timeSlots.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 120,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.5,
                ),
                itemBuilder: (_, index) {
                  final slot = _timeSlots[index];
                  final selected = _selectedTimeSlot == slot;
                  return ChoiceChip(
                    label: Text(slot),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedTimeSlot = slot);
                    },
                    selectedColor: colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: selected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.check_circle),
            label: const Text('Confirm constraints'),
          ),
        ],
      ),
    );
  }
}

class _MaskedTextInputFormatter extends TextInputFormatter {
  _MaskedTextInputFormatter({required this.mask});

  final String mask;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    final buffer = StringBuffer();
    var digitIndex = 0;
    for (var i = 0; i < mask.length && digitIndex < digits.length; i++) {
      final maskChar = mask[i];
      if (maskChar == 'X') {
        final char = digits[digitIndex].toUpperCase();
        if (RegExp(r'[A-Z]').hasMatch(char)) {
          buffer.write(char);
          digitIndex++;
        } else {
          break;
        }
      } else if (maskChar == '9') {
        final char = digits[digitIndex];
        if (RegExp(r'[0-9]').hasMatch(char)) {
          buffer.write(char);
          digitIndex++;
        } else {
          break;
        }
      } else {
        buffer.write(maskChar);
      }
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
