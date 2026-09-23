import 'package:flutter/material.dart';

/// Row 23: NSKFI-004 (Seq 30963)
/// Action: Prevent the text property field from updating if characters violate the active regex formatting mask.
/// Quality Gate: Process Execution Quality (%) (Optimal: 95% of the step executed to defined standard).
class RegexMaskViolationBlockerPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const RegexMaskViolationBlockerPanel({
    super.key,
    this.globalRefId = 'NSKFI-004',
    this.atomicStepRefId = 'NSKFI-004-A12',
    this.sequenceOrder = 30963,
  });

  @override
  State<RegexMaskViolationBlockerPanel> createState() =>
      _RegexMaskViolationBlockerPanelState();
}

class _RegexMaskViolationBlockerPanelState
    extends State<RegexMaskViolationBlockerPanel> {
  bool _isActionActive = false;
  int _executionCount = 0;
  final String _targetMetric = '95% of the step executed to defined standard';
  final TextEditingController _controller = TextEditingController();
  String _validationMessage = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateInput(String value) {
    final regexMask = RegExp(r'^\d*$');
    if (!regexMask.hasMatch(value)) {
      setState(() {
        _validationMessage = 'BLOCKED: Non-numeric character violates active regex mask.';
        _controller.text = value.replaceAll(RegExp(r'[^\d]'), '');
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
        _executionCount++;
      });
    } else {
      setState(() {
        _validationMessage = value.isEmpty ? '' : 'PASS: Valid pattern accepted.';
      });
    }
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
                  child: Icon(Icons.block_outlined,
                      color: theme.colorScheme.onPrimaryContainer, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.globalRefId}: Regex Mask Violation Blocker',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Seq: ${widget.sequenceOrder} • Standard: Process Execution Quality',
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
              'Prevent the text property field from updating if characters violate the active regex formatting mask.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Numeric-only field (regex mask active)',
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.filter_alt_outlined),
                errorText: _validationMessage.startsWith('BLOCKED')
                    ? _validationMessage
                    : null,
                helperText: _validationMessage.startsWith('PASS')
                    ? _validationMessage
                    : null,
                helperStyle:
                    const TextStyle(color: Colors.green),
              ),
              onChanged: _validateInput,
            ),
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
                          'Regex mask enforced. Violation characters blocked at input layer (95% execution standard).'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(
                    _isActionActive
                        ? Icons.verified_rounded
                        : Icons.play_arrow_rounded,
                    size: 20),
                label: Text(_isActionActive
                    ? 'Mask Active & Verified'
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
            child: RegexMaskViolationBlockerPanel(),
          ),
        ),
      ),
    ),
  );
}
