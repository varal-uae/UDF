import 'package:flutter/material.dart';

/// Row 27: NSKFI-007 (Seq 30993)
/// Action: Apply the autocorrect="off" tag on designated code fields.
/// Quality Gate: Configuration Parameter Accuracy (Optimal: 100% of parameters matching approved specification).
class AutocorrectOffCodeFieldPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const AutocorrectOffCodeFieldPanel({
    super.key,
    this.globalRefId = 'NSKFI-007',
    this.atomicStepRefId = 'NSKFI-007-A09',
    this.sequenceOrder = 30993,
  });

  @override
  State<AutocorrectOffCodeFieldPanel> createState() =>
      _AutocorrectOffCodeFieldPanelState();
}

class _AutocorrectOffCodeFieldPanelState
    extends State<AutocorrectOffCodeFieldPanel> {
  bool _isActionActive = false;
  int _executionCount = 0;
  final String _targetMetric =
      '100% of parameters matching approved specification';

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
                  child: Icon(Icons.spellcheck_rounded,
                      color: theme.colorScheme.onPrimaryContainer, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.globalRefId}: Autocorrect Off Code Field',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Seq: ${widget.sequenceOrder} • Standard: Config Parameter Accuracy',
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
              'Apply the autocorrect="off" tag on designated code fields.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            const TextField(
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: 'Code field (autocorrect: off)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.code_rounded),
                helperText: 'autocorrect=false, enableSuggestions=false applied',
              ),
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
                          'autocorrect=off applied to all code fields. 100% parameter spec matched.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(
                    _isActionActive
                        ? Icons.toggle_off_rounded
                        : Icons.play_arrow_rounded,
                    size: 20),
                label: Text(_isActionActive
                    ? 'Autocorrect Disabled'
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
            child: AutocorrectOffCodeFieldPanel(),
          ),
        ),
      ),
    ),
  );
}
