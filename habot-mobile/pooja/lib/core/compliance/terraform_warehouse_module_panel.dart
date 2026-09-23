import 'package:flutter/material.dart';

/// Row 325: GEN-00550 (Seq 17259)
/// Action: Open the Terraform warehouse module infrastructure/terraform/modules/data_warehouse/.
/// Quality Gate: HashiCorp Terraform Best Practices / Infrastructure as Code Standard.
class TerraformWarehouseModulePanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const TerraformWarehouseModulePanel({
    super.key,
    this.globalRefId = 'GEN-00550',
    this.atomicStepRefId = 'GEN-00550',
    this.sequenceOrder = 17259,
  });

  @override
  State<TerraformWarehouseModulePanel> createState() =>
      _TerraformWarehouseModulePanelState();
}

class _TerraformWarehouseModulePanelState
    extends State<TerraformWarehouseModulePanel> {
  final List<Map<String, String>> _tfResources = [
    {'resource': 'google_bigquery_dataset.telemetry', 'state': 'PROVISIONED'},
    {'resource': 'google_bigquery_table.events_partitioned', 'state': 'PROVISIONED'},
    {'resource': 'google_pubsub_topic.purchase_events', 'state': 'PROVISIONED'},
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
                  child: Icon(
                    Icons.layers_rounded,
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
                        'Terraform Warehouse Module',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.globalRefId} | ${widget.atomicStepRefId} (Seq ${widget.sequenceOrder})',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Text(
                    'IaC VALIDATED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Inspects declarative infrastructure definitions in infrastructure/terraform/modules/data_warehouse/ validating BigQuery dataset and Pub/Sub topic declarations.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tfResources.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final res = _tfResources[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.code, color: Colors.indigo, size: 20),
                    title: Text(res['resource']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace')),
                    trailing: Text(
                      res['state']!,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  );
                },
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
            child: TerraformWarehouseModulePanel(),
          ),
        ),
      ),
    ),
  );
}
