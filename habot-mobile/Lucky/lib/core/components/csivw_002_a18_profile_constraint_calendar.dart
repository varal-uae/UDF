// CSIVW-002-A18 — Profile Field Constraint Configuration & Material Date Picker Calendar.
// Provides strict profile input masks, inline semantic validation, and responsive date/time slot selection.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileConstraintCalendar extends StatefulWidget {
  const ProfileConstraintCalendar({super.key});

  @override
  State<ProfileConstraintCalendar> createState() => _ProfileConstraintCalendarState();
}

class _ProfileConstraintCalendarState extends State<ProfileConstraintCalendar> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTimeSlot;

  final List<String> _timeSlots = const <String>[
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          datePickerTheme: const DatePickerThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final required = _requiredValidator(value);
    if (required != null) return required;
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value!.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    final required = _requiredValidator(value);
    if (required != null) return required;
    if (value!.replaceAll(RegExp(r'\D'), '').length < 10) {
      return 'Enter at least 10 digits.';
    }
    return null;
  }

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a demo date.')),
      );
      return;
    }
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Confirm a time slot.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile constraints satisfied. Demo request ready.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Demo Booking')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Profile field constraints',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Strict masks reject invalid characters before submission.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  hintText: 'Letters, spaces, hyphens only',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s\-]')),
                  LengthLimitingTextInputFormatter(80),
                ],
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  LengthLimitingTextInputFormatter(120),
                ],
                validator: _emailValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  hintText: 'Digits, spaces, parentheses, hyphens',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\s\(\)\-]')),
                  LengthLimitingTextInputFormatter(20),
                ],
                validator: _phoneValidator,
              ),
              const SizedBox(height: 24),
              Text(
                'Demo date',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  _selectedDate == null
                      ? 'Select date'
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Time slot',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth < 360
                      ? 2
                      : constraints.maxWidth < 600
                          ? 3
                          : 4;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _timeSlots.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.2,
                    ),
                    itemBuilder: (context, index) {
                      final slot = _timeSlots[index];
                      final selected = _selectedTimeSlot == slot;
                      return ChoiceChip(
                        label: Text(slot),
                        selected: selected,
                        onSelected: (_) {
                          setState(() => _selectedTimeSlot = slot);
                        },
                        labelStyle: theme.textTheme.labelLarge,
                        selectedColor: theme.colorScheme.primaryContainer,
                        showCheckmark: false,
                        side: BorderSide(
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirm 1-tap demo booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
