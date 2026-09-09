// BCDLD-036 — Manager's DCYN Switch for Training Completion Validation.
// A Material 3 switch that locks all associated input fields until toggled to Yes, with visual state changes and lock/check icons.

import 'package:flutter/material.dart';

class Bcdld036DcynSwitch extends StatefulWidget {
  const Bcdld036DcynSwitch({super.key});

  @override
  State<Bcdld036DcynSwitch> createState() => _Bcdld036DcynSwitchState();
}

class _Bcdld036DcynSwitchState extends State<Bcdld036DcynSwitch> {
  bool _isTrainingComplete = false;

  void _onSwitchChanged(bool value) {
    setState(() {
      _isTrainingComplete = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isTrainingComplete ? Icons.check_circle : Icons.lock,
                  color: _isTrainingComplete ? Colors.green : theme.disabledColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Is Training Complete?',
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                Switch(
                  value: _isTrainingComplete,
                  onChanged: _onSwitchChanged,
                  activeColor: Colors.green,
                  inactiveThumbColor: theme.colorScheme.outline,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              enabled: _isTrainingComplete,
              decoration: InputDecoration(
                labelText: 'Manager Notes',
                border: const OutlineInputBorder(),
                suffixIcon: Icon(
                  _isTrainingComplete ? Icons.edit : Icons.lock_outline,
                  color: _isTrainingComplete ? null : theme.disabledColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isTrainingComplete ? () {} : null,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}