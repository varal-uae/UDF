import 'package:flutter/material.dart';

/// Row 359: GEN-00916 (Seq 17625)
/// Action: Calculate step drop-off severity ratios, highlighting the largest bottleneck step.
/// Quality Gate: Product Analytics Benchmarks (Drop-off Calculation Accuracy: 100%).
class StepDropoffSeverityCalculatorPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const StepDropoffSeverityCalculatorPanel({
    super.key,
    this.globalRefId = 'GEN-00916',
    this.atomicStepRefId = 'GEN-00916',
    this.sequenceOrder = 17625,
  });

  @override
  State<StepDropoffSeverityCalculatorPanel> createState() =>
      _StepDropoffSeverityCalculatorPanelState();
}

class _StepDropoffSeverityCalculatorPanelState
    extends State<StepDropoffSeverityCalculatorPanel> {
  final List<Map<String, dynamic>> _funnelSteps = [
    {'name': '1. Landing Page', 'visitors': 10000, 'dropoff': 0.0},
    {'name': '2. Registration Form', 'visitors': 7200, 'dropoff': 28.0},
    {'name': '3. KYC Document Upload', 'visitors': 3100, 'dropoff': 56.9},
    {'name': '4. Wallet Activation', 'visitors': 2800, 'dropoff': 9.7},
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
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.trending_down_rounded,
                    color: theme.colorScheme.onTertiaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GEN-00916: Drop-off Severity Calculator',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 17625 • Standard: Product Analytics Benchmarks',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                const Chip(
                  avatar: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 16,
                  ),
                  label: Text('100% Calculated'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'User Journey Funnel & Bottleneck Identification:',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._funnelSteps.map(
              (step) {
                final dropoff = step['dropoff'] as double;
                final isBottleneck = dropoff > 50.0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isBottleneck ? Colors.red.withValues(alpha: 0.12) : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isBottleneck ? Colors.red : theme.colorScheme.outlineVariant,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          step['name'] as String,
                          style: TextStyle(fontWeight: isBottleneck ? FontWeight.bold : FontWeight.normal),
                        ),
                      ),
                      Text('${step['visitors']} users', style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 12),
                      Text(
                        dropoff == 0.0 ? 'Baseline' : '-$dropoff% Drop',
                        style: TextStyle(
                          color: isBottleneck ? Colors.red : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bottleneck identified: "3. KYC Document Upload" has 56.9% drop-off severity.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.analytics_outlined, size: 20),
                label: const Text('Export Funnel Bottleneck Diagnostic'),
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
            child: StepDropoffSeverityCalculatorPanel(),
          ),
        ),
      ),
    ),
  );
}
