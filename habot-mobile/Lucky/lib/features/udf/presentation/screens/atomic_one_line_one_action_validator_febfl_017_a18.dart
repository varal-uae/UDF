// FEBFL-017-A18 — Atomic One-Line-One-Action validation screen for mobile job posting.
// Provides a focused single-question input with inline isFiscalValid feedback, 8dp spacing, and Material 3 card selection.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AtomicOneLineOneActionValidator extends StatefulWidget {
  const AtomicOneLineOneActionValidator({super.key});

  @override
  State<AtomicOneLineOneActionValidator> createState() =>
      _AtomicOneLineOneActionValidatorState();
}

class _AtomicOneLineOneActionValidatorState
    extends State<AtomicOneLineOneActionValidator> {
  static final RegExp _fiscalPattern = RegExp(r'^[A-Z]{3}[0-9]{4}$');

  final TextEditingController _fiscalController = TextEditingController();
  bool _isFiscalValid = false;
  String? _selectedEmploymentType;

  @override
  void dispose() {
    _fiscalController.dispose();
    super.dispose();
  }

  void _validateFiscal(String value) {
    setState(() {
      _isFiscalValid = _fiscalPattern.hasMatch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atomic Job Posting'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Fiscal code',
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _fiscalController,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                  LengthLimitingTextInputFormatter(7),
                ],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Enter fiscal code',
                  hintText: 'ABC1234',
                  suffixIcon: _isFiscalValid
                      ? Icon(Icons.check_circle, color: colorScheme.primary)
                      : Icon(Icons.warning_amber_rounded,
                          color: colorScheme.error),
                  helperText: _isFiscalValid
                      ? null
                      : 'Use 3 letters followed by 4 digits.',
                ),
                onChanged: _validateFiscal,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Employment type',
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 8.0),
              _CardSelector<String>(
                options: const <String>['Full-time', 'Part-time', 'Contract'],
                selectedValue: _selectedEmploymentType,
                onSelected: (String value) {
                  setState(() {
                    _selectedEmploymentType = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardSelector<T> extends StatelessWidget {
  const _CardSelector({
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  final List<T> options;
  final T? selectedValue;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: options.map((T option) {
        final bool isSelected = option == selectedValue;
        return Card(
          elevation: 0.0,
          color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(
              color: isSelected ? colorScheme.primary : colorScheme.outline,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8.0),
            onTap: () => onSelected(option),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Text(
                option.toString(),
                style: TextStyle(
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
