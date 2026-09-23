import 'package:flutter/material.dart';

/// Row 332 | Task: GEN-00627 | Seq: 17336
/// Action: Program form state logic to keep the "Submit" button disabled until all regex patterns evaluate to True.
/// Metric: Submit Lock Reliability (Target: 100%, Standard: Habot Self-Chasing UI Rule)
class SubmitButtonDisableGuardPanel extends StatefulWidget {
  const SubmitButtonDisableGuardPanel({super.key});

  @override
  State<SubmitButtonDisableGuardPanel> createState() =>
      _SubmitButtonDisableGuardPanelState();
}

class _SubmitButtonDisableGuardPanelState
    extends State<SubmitButtonDisableGuardPanel> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final RegExp _pinRegex = RegExp(r'^[0-9]{4,6}$');

  bool _isEmailValid = false;
  bool _isPinValid = false;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateInputs);
    _pinController.addListener(_validateInputs);
  }

  void _validateInputs() {
    final emailValid = _emailRegex.hasMatch(_emailController.text.trim());
    final pinValid = _pinRegex.hasMatch(_pinController.text.trim());
    if (emailValid != _isEmailValid || pinValid != _isPinValid) {
      setState(() {
        _isEmailValid = emailValid;
        _isPinValid = pinValid;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  bool get _isFormValid => _isEmailValid && _isPinValid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.lock_clock_outlined,
                    color: theme.colorScheme.onSecondaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GEN-00627: Submit Disable Guard',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 17336 • Standard: Habot Self-Chasing UI Rule',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  avatar: Icon(
                    _isFormValid ? Icons.lock_open : Icons.lock_outline,
                    color: _isFormValid ? Colors.green : Colors.orange,
                    size: 16,
                  ),
                  label: Text(_isFormValid ? 'Unlocked' : 'Guarded'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'User Email (Regex: valid email format)',
                isDense: true,
                border: const OutlineInputBorder(),
                suffixIcon: Icon(
                  _isEmailValid ? Icons.check_circle : Icons.cancel_outlined,
                  color: _isEmailValid ? Colors.green : Colors.grey,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Security PIN (Regex: 4-6 digits)',
                isDense: true,
                border: const OutlineInputBorder(),
                suffixIcon: Icon(
                  _isPinValid ? Icons.check_circle : Icons.cancel_outlined,
                  color: _isPinValid ? Colors.green : Colors.grey,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _isFormValid
                    ? () {
                        setState(() {
                          _isSubmitted = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Form passed all regex validations and submitted successfully!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.send_rounded, size: 20),
                label: Text(
                  _isSubmitted
                      ? 'Submitted Successfully'
                      : (_isFormValid ? 'Submit Validated Form' : 'Submit Locked (Regex Incomplete)'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: SubmitButtonDisableGuardPanel(),
          ),
        ),
      ),
    ),
  );
}
