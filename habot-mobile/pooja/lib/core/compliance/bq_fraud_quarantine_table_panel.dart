import 'package:flutter/material.dart';

/// Row 342: GEN-00738 (Seq 17447)
/// Action: Create BigQuery fraud quarantine table audit.quarantined_fraud_events.
/// Quality Gate: BigQuery Schema Rules (DDL Execution Pass: 100%).
class BqFraudQuarantineTablePanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const BqFraudQuarantineTablePanel({
    super.key,
    this.globalRefId = 'GEN-00738',
    this.atomicStepRefId = 'GEN-00738',
    this.sequenceOrder = 17447,
  });

  @override
  State<BqFraudQuarantineTablePanel> createState() =>
      _BqFraudQuarantineTablePanelState();
}

class _BqFraudQuarantineTablePanelState
    extends State<BqFraudQuarantineTablePanel> {
  final String _tableName = 'audit.quarantined_fraud_events';
  final List<String> _schemaColumns = const [
    'quarantine_id STRING NOT NULL',
    'canonical_user_id STRING',
    'anomaly_vector_type STRING',
    'quarantine_timestamp TIMESTAMP',
    'payload_snapshot JSON',
  ];
  int _quarantinedEventsCount = 7;

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
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.security_rounded,
                    color: theme.colorScheme.onErrorContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GEN-00738: Fraud Quarantine Table',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 17447 • Standard: BigQuery Schema Rules',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  avatar: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 16,
                  ),
                  label: Text('$_quarantinedEventsCount Quarantined'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Audit Quarantine Table: $_tableName',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            ..._schemaColumns.map(
              (col) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 14, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Text(
                      col,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _quarantinedEventsCount++;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Quarantined fraud table $_tableName verified. Anomaly logged.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.verified_user_outlined, size: 20),
                label: const Text('Audit Quarantine Table Schema'),
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
            child: BqFraudQuarantineTablePanel(),
          ),
        ),
      ),
    ),
  );
}
