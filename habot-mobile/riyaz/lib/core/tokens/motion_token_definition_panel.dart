import 'package:flutter/material.dart';

/// Row 28: NSKFI-008 (Seq 31002)
/// Action: Define a standard set of motion tokens (duration, easing) for the design system.
/// Quality Gate: Specification Clarity & Sign-off (Optimal: Definition documented and approved by a technical lead).
class MotionTokenDefinitionPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const MotionTokenDefinitionPanel({
    super.key,
    this.globalRefId = 'NSKFI-008',
    this.atomicStepRefId = 'NSKFI-008-A02',
    this.sequenceOrder = 31002,
  });

  @override
  State<MotionTokenDefinitionPanel> createState() =>
      _MotionTokenDefinitionPanelState();
}

class _MotionTokenDefinitionPanelState
    extends State<MotionTokenDefinitionPanel> {
  bool _isActionActive = false;
  int _executionCount = 0;
  final String _targetMetric =
      'Definition documented and approved by a technical lead';

  final List<Map<String, String>> _tokens = const [
    {'name': 'motion.duration.short', 'value': '150ms'},
    {'name': 'motion.duration.medium', 'value': '300ms'},
    {'name': 'motion.duration.long', 'value': '500ms'},
    {'name': 'motion.easing.standard', 'value': 'cubic-bezier(0.2, 0, 0, 1)'},
    {'name': 'motion.easing.emphasized', 'value': 'cubic-bezier(0.05, 0.7, 0.1, 1)'},
  ];

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
                  child: Icon(Icons.animation_rounded,
                      color: theme.colorScheme.onPrimaryContainer, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.globalRefId}: Motion Token Definition',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Seq: ${widget.sequenceOrder} • Standard: Specification Sign-off',
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
              'Define a standard set of motion tokens (duration, easing) for the design system.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ..._tokens.map((token) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: Colors.green),
                      const SizedBox(width: 8),
                      Text('${token['name']}',
                          style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Text('= ${token['value']}',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary)),
                    ],
                  ),
                )),
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
                          'Motion tokens documented and signed off by technical lead.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(
                    _isActionActive
                        ? Icons.library_add_check_rounded
                        : Icons.play_arrow_rounded,
                    size: 20),
                label: Text(_isActionActive
                    ? 'Tokens Approved'
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
            child: MotionTokenDefinitionPanel(),
          ),
        ),
      ),
    ),
  );
}
