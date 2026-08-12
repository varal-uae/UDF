import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mobile & Web Responsive Poka-Yoke Input Masking Form for numeric fields.
class NumericPokaYokeForm extends StatelessWidget {
  NumericPokaYokeForm({super.key});

  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _earningsController = TextEditingController();

  /// Validator for Child Age: Must be between 0 and 18.
  String? _validateChildAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Child age is required';
    }
    final age = int.tryParse(value);
    if (age == null || age < 0 || age > 18) {
      return 'Child age must be between 0 and 18';
    }
    return null;
  }

  /// Validator for Earnings: Must be a positive number (> 0).
  String? _validateEarnings(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Earnings amount is required';
    }
    final earnings = int.tryParse(value);
    if (earnings == null || earnings <= 0) {
      return 'Earnings must be a positive number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48.0),
                        child: TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: 'Child Age',
                            hintText: 'Enter age (0 - 18)',
                            helperText: 'Valid range: 0 to 18 years',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.child_care),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14.0,
                              horizontal: 16.0,
                            ),
                          ),
                          validator: _validateChildAge,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48.0),
                        child: TextFormField(
                          controller: _earningsController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: 'Earnings',
                            hintText: 'Enter positive earnings amount',
                            helperText: 'Must be greater than 0',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.attach_money),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14.0,
                              horizontal: 16.0,
                            ),
                          ),
                          validator: _validateEarnings,
                        ),
                      ),
                    ),
                  ],
                )
              else ...[
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48.0),
                  child: TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      labelText: 'Child Age',
                      hintText: 'Enter age (0 - 18)',
                      helperText: 'Valid range: 0 to 18 years',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.child_care),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14.0,
                        horizontal: 16.0,
                      ),
                    ),
                    validator: _validateChildAge,
                  ),
                ),
                const SizedBox(height: 20.0),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48.0),
                  child: TextFormField(
                    controller: _earningsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      labelText: 'Earnings',
                      hintText: 'Enter positive earnings amount',
                      helperText: 'Must be greater than 0',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.attach_money),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14.0,
                        horizontal: 16.0,
                      ),
                    ),
                    validator: _validateEarnings,
                  ),
                ),
              ],
              const SizedBox(height: 24.0),

              // Submit Action Button (minHeight 48.0)
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48.0),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Poka-Yoke inputs verified & validated successfully!',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text(
                    'Validate Inputs',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
