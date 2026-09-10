// CSIVW-002-A07 — Profile Field Constraint Schema & Mobile Form Validation UI.
// Centralized profile field rules, input masks, inline semantic warnings, and Material 3 demo-booking calendar selection.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ProfileFieldType { text, email, phone, number, date, url }

class ProfileFieldConstraint {
  final String id;
  final String label;
  final ProfileFieldType type;
  final bool required;
  final int? minLength;
  final int? maxLength;
  final RegExp? allowedPattern;
  final String? inputMask;
  final String? helpText;
  final String? hintText;
  final String? errorText;

  const ProfileFieldConstraint({
    required this.id,
    required this.label,
    required this.type,
    this.required = false,
    this.minLength,
    this.maxLength,
    this.allowedPattern,
    this.inputMask,
    this.helpText,
    this.hintText,
    this.errorText,
  });
}

class ProfileFieldConstraintSchema {
  final Map<String, ProfileFieldConstraint> _fields;

  const ProfileFieldConstraintSchema(this._fields);

  ProfileFieldConstraint? operator [](String id) => _fields[id];
  Iterable<ProfileFieldConstraint> get fields => _fields.values;
  Map<String, ProfileFieldConstraint> get asMap => Map.unmodifiable(_fields);
}

class ProfileFieldValidationResult {
  final bool isValid;
  final String? message;

  const ProfileFieldValidationResult(this.isValid, [this.message]);

  static const ProfileFieldValidationResult valid = ProfileFieldValidationResult(true);

  factory ProfileFieldValidationResult.invalid(String message) => ProfileFieldValidationResult(false, message);
}

class ProfileFieldValidator {
  static ProfileFieldValidationResult validate(ProfileFieldConstraint c, String? value) {
    final v = value?.trim() ?? '';
    if (c.required && v.isEmpty) return ProfileFieldValidationResult.invalid('${c.label} is required.');
    if (v.isEmpty) return ProfileFieldValidationResult.valid;
    if (c.minLength != null && v.length < c.minLength!) return ProfileFieldValidationResult.invalid('${c.label} must be at least ${c.minLength} characters.');
    if (c.maxLength != null && v.length > c.maxLength!) return ProfileFieldValidationResult.invalid('${c.label} must be at most ${c.maxLength} characters.');
    if (c.allowedPattern != null && !c.allowedPattern!.hasMatch(v)) return ProfileFieldValidationResult.invalid(c.errorText ?? '${c.label} format is invalid.');
    switch (c.type) {
      case ProfileFieldType.email:
        if (!RegExp('^[^@]+@[^@]+[.][^@]+').hasMatch(v)) return ProfileFieldValidationResult.invalid(c.errorText ?? 'Enter a valid email address.');
        break;
      case ProfileFieldType.phone:
        if (v.replaceAll(RegExp('[^0-9]'), '').length < 7) return ProfileFieldValidationResult.invalid(c.errorText ?? 'Enter a valid phone number.');
        break;
      case ProfileFieldType.number:
        if (num.tryParse(v) == null) return ProfileFieldValidationResult.invalid(c.errorText ?? 'Enter a valid number.');
        break;
      case ProfileFieldType.url:
        if (!RegExp('^https?://').hasMatch(v)) return ProfileFieldValidationResult.invalid(c.errorText ?? 'Enter a valid URL.');
        break;
      case ProfileFieldType.text:
      case ProfileFieldType.date:
        break;
    }
    return ProfileFieldValidationResult.valid;
  }

  static List<TextInputFormatter> formattersFor(ProfileFieldConstraint c) {
    final formatters = <TextInputFormatter>[];
    if (c.inputMask != null && c.inputMask!.isNotEmpty) {
      formatters.add(_ProfileInputMaskFormatter(c.inputMask!));
    } else if (c.allowedPattern != null) {
      formatters.add(FilteringTextInputFormatter.allow(c.allowedPattern!));
    } else {
      switch (c.type) {
        case ProfileFieldType.number:
          formatters.add(FilteringTextInputFormatter.digitsOnly);
          break;
        case ProfileFieldType.phone:
          formatters.add(FilteringTextInputFormatter.allow(RegExp('[0-9+() -]')));
          break;
        case ProfileFieldType.email:
          formatters.add(FilteringTextInputFormatter.deny(RegExp(' ')));
          break;
        case ProfileFieldType.url:
          formatters.add(FilteringTextInputFormatter.deny(RegExp(' ')));
          break;
        case ProfileFieldType.text:
        case ProfileFieldType.date:
          break;
      }
    }
    return formatters;
  }

  static TextInputType keyboardTypeFor(ProfileFieldType type) {
    switch (type) {
      case ProfileFieldType.email:
        return TextInputType.emailAddress;
      case ProfileFieldType.phone:
        return TextInputType.phone;
      case ProfileFieldType.number:
        return TextInputType.number;
      case ProfileFieldType.url:
        return TextInputType.url;
      case ProfileFieldType.date:
      case ProfileFieldType.text:
        return TextInputType.text;
    }
  }
}

class _ProfileInputMaskFormatter extends TextInputFormatter {
  _ProfileInputMaskFormatter(this.mask);

  final String mask;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text.replaceAll(RegExp('[^A-Za-z0-9]'), '');
    final buffer = StringBuffer();
    var rawIndex = 0;
    for (var i = 0; i < mask.length && rawIndex < raw.length; i++) {
      final token = mask[i];
      if (token == '#') {
        while (rawIndex < raw.length && !RegExp('[0-9]').hasMatch(raw[rawIndex])) {
          rawIndex++;
        }
        if (rawIndex < raw.length) {
          buffer.write(raw[rawIndex]);
          rawIndex++;
        }
      } else if (token == 'A') {
        while (rawIndex < raw.length && !RegExp('[A-Za-z]').hasMatch(raw[rawIndex])) {
          rawIndex++;
        }
        if (rawIndex < raw.length) {
          buffer.write(raw[rawIndex].toUpperCase());
          rawIndex++;
        }
      } else if (token == '*') {
        buffer.write(raw[rawIndex]);
        rawIndex++;
      } else {
        buffer.write(token);
      }
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class ProfileFieldConstraintForm extends StatefulWidget {
  final ProfileFieldConstraintSchema schema;
  final Map<String, String> initialValues;
  final ValueChanged<Map<String, String>>? onChanged;
  final ValueChanged<Map<String, ProfileFieldValidationResult>>? onValidationChanged;
  final bool showHelpOnPersistentFailure;

  const ProfileFieldConstraintForm({
    super.key,
    required this.schema,
    this.initialValues = const {},
    this.onChanged,
    this.onValidationChanged,
    this.showHelpOnPersistentFailure = true,
  });

  @override
  State<ProfileFieldConstraintForm> createState() => _ProfileFieldConstraintFormState();
}

class _ProfileFieldConstraintFormState extends State<ProfileFieldConstraintForm> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  final Map<String, int> _failureCounts = {};
  final Map<String, ProfileFieldValidationResult> _results = {};

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final field in widget.schema.fields)
        field.id: TextEditingController(text: widget.initialValues[field.id] ?? ''),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<String, String> get _values => {
        for (final entry in _controllers.entries) entry.key: entry.value.text,
      };

  void _validateField(ProfileFieldConstraint field, String? value) {
    final result = ProfileFieldValidator.validate(field, value);
    setState(() {
      _results[field.id] = result;
      if (!result.isValid && widget.showHelpOnPersistentFailure) {
        _failureCounts[field.id] = (_failureCounts[field.id] ?? 0) + 1;
        if (_failureCounts[field.id]! >= 3) {
          _failureCounts[field.id] = 0;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _showHelpDialog(field);
          });
        }
      } else if (result.isValid) {
        _failureCounts[field.id] = 0;
      }
    });
    widget.onValidationChanged?.call(Map.unmodifiable(_results));
  }

  void _showHelpDialog(ProfileFieldConstraint field) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${field.label} help'),
        content: Text(field.helpText ?? 'Please match the required field format.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          for (final field in widget.schema.fields)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: _controllers[field.id],
                keyboardType: ProfileFieldValidator.keyboardTypeFor(field.type),
                inputFormatters: ProfileFieldValidator.formattersFor(field),
                decoration: InputDecoration(
                  labelText: field.label,
                  hintText: field.hintText,
                  helperText: field.helpText,
                  errorText: _results[field.id]?.isValid == false ? _results[field.id]!.message : null,
                  errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onChanged: (value) {
                  _validateField(field, value);
                  widget.onChanged?.call(_values);
                },
                validator: (value) {
                  final result = ProfileFieldValidator.validate(field, value);
                  return result.isValid ? null : result.message;
                },
              ),
            ),
        ],
      ),
    );
  }
}

class DemoBookingCalendar extends StatefulWidget {
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<String>? onTimeSlotSelected;

  const DemoBookingCalendar({
    super.key,
    this.onDateSelected,
    this.onTimeSlotSelected,
  });

  @override
  State<DemoBookingCalendar> createState() => _DemoBookingCalendarState();
}

class _DemoBookingCalendarState extends State<DemoBookingCalendar> {
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  final List<String> _timeSlots = const ['09:00', '10:00', '11:00', '13:00', '14:00', '15:00'];

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          materialTapTargetSize: MaterialTapTargetSize.padded,
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      widget.onDateSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Demo booking', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_month),
              label: Text(
                _selectedDate == null
                    ? 'Select date'
                    : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
              ),
            ),
            const SizedBox(height: 16),
            Text('Time slot', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 360 ? 2 : 3;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.4,
                  ),
                  itemCount: _timeSlots.length,
                  itemBuilder: (context, index) {
                    final slot = _timeSlots[index];
                    final selected = slot == _selectedTimeSlot;
                    return ChoiceChip(
                      label: Text(slot),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _selectedTimeSlot = slot);
                        widget.onTimeSlotSelected?.call(slot);
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
