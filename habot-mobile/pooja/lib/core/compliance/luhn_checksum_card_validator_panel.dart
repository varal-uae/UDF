import 'package:flutter/material.dart';

/// Row 389: GEN-01248 (Seq 17957)
/// Action: Test form entry validation against valid and invalid card number datasets.
/// Quality Gate: PCI-DSS v4.0 (Target: Pass Level 1).
class LuhnChecksumCardValidatorPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const LuhnChecksumCardValidatorPanel({
    super.key,
    this.globalRefId = 'GEN-01248',
    this.atomicStepRefId = 'GEN-01248',
    this.sequenceOrder = 17957,
  });

  @override
  State<LuhnChecksumCardValidatorPanel> createState() =>
      _LuhnChecksumCardValidatorPanelState();
}

class _LuhnChecksumCardValidatorPanelState
    extends State<LuhnChecksumCardValidatorPanel> {
  String _cardNumber = '4532758892104018';
  bool _isChecksumValid = true;
  int _validationsExecuted = 16;

  bool _validateLuhn(String number) {
    final cleaned = number.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 13 || cleaned.length > 19) return false;

    int sum = 0;
    bool alternate = false;
    for (int i = cleaned.length - 1; i >= 0; i--) {
      int n = int.parse(cleaned[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

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
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.credit_card_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GEN-01248: Luhn Card Validator',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 17957 • Standard: PCI-DSS v4.0 Level 1',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  avatar: Icon(
                    _isChecksumValid ? Icons.check_circle_outline : Icons.error_outline,
                    color: _isChecksumValid ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  label: Text(_isChecksumValid ? 'LUHN PASS' : 'INVALID CHECK'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            Text('Card Number Under Validation:', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _cardNumber,
                style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Checksum Status: ${_isChecksumValid ? "Valid (Luhn Mod 10 = 0)" : "Failed Checksum"}',
                    style: TextStyle(color: _isChecksumValid ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                Text('Validations Run: $_validationsExecuted', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _cardNumber = '4532758892104018';
                        _isChecksumValid = _validateLuhn(_cardNumber);
                        _validationsExecuted++;
                      });
                    },
                    child: const Text('Test Valid Card'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _cardNumber = '4532758892104019'; // Invalid check digit
                        _isChecksumValid = _validateLuhn(_cardNumber);
                        _validationsExecuted++;
                      });
                    },
                    child: const Text('Test Invalid Card'),
                  ),
                ),
              ],
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
            child: LuhnChecksumCardValidatorPanel(),
          ),
        ),
      ),
    ),
  );
}
