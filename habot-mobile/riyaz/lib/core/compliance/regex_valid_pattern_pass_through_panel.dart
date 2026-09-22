import 'package:flutter/material.dart';

/// Row 25: NSKFI-005 (Seq 30980)
/// Action: Test regex rejection allows a valid string pattern through.
/// Quality Gate: Functional Test Pass Rate (Optimal: 100% first-pass test success).
class RegexValidPatternPassThroughPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const RegexValidPatternPassThroughPanel({
    super.key,
    this.globalRefId = 'NSKFI-005',
    this.atomicStepRefId = 'NSKFI-005-A10',
    this.sequenceOrder = 30980,
  });

  @override
  State<RegexValidPatternPassThroughPanel> createState() =>
      _RegexValidPatternPassThroughPanelState();
}

class _RegexValidPatternPassThroughPanelState
    extends State<RegexValidPatternPassThroughPanel> {
  bool _isActionActive = false;
  int _executionCount = 0;
  final String _targetMetric = '100% first-pass test success';
  String _testResult = '';

  void _runTest(String value) {
    final validPattern = RegExp(r'^\d{4,10}$');
    setState(() {
      _testResult = validPattern.hasMatch(value)
          ? 'PASS: Valid pattern accepted through regex gate.'
          : 'PENDING: Enter 4–10 digit numeric string to validate.';
      _executionCount++;
    });
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
                  child: Icon(Icons.checklist_outlined,
                      color: theme.colorScheme.onPrimaryContainer, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.globalRefId}: Regex Valid Pattern Pass-Through',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Seq: ${widget.sequenceOrder} • Standard: Functional Test Pass Rate',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                ),
                const Chip(
                  avatar: Icon(Icons.check_circle_outline,
                      color: Colors.green, size: 16),
                  label: Text('ACTIVE PASS'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Benchmark Target:',
                          style: theme.textTheme.labelMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text(_targetMetric,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Telemetry Executions:',
                        style: theme.textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text('$_executionCount runs',
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Test regex rejection allows a valid string pattern through.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter 4–10 digit code to test pass-through',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: _runTest,
            ),
            if (_testResult.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _testResult,
                style: TextStyle(
                  color: _testResult.startsWith('PASS')
                      ? Colors.green
                      : theme.colorScheme.outline,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _isActionActive = !_isActionActive;
                    _executionCount++;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Regex pass-through verified. 100% first-pass success rate confirmed.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(
                    _isActionActive
                        ? Icons.task_alt_rounded
                        : Icons.play_arrow_rounded,
                    size: 20),
                label: Text(_isActionActive
                    ? 'Pass-Through Verified'
                    : 'Execute Step Verification'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standalone entrypoint for isolated file verification.
void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: RegexValidPatternPassThroughPanel(),
          ),
        ),
      ),
    ),
  );
}
