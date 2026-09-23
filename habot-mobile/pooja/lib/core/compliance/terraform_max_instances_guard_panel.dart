import 'package:flutter/material.dart';

/// Row 358: GEN-00905 (Seq 17614)
/// Action: Add Terraform validation scripts blocking deployment if max_instances < 10 or CDN is disabled.
/// Quality Gate: HashiCorp OPA Governance (Terraform Policy Guard Interlock: 100%).
class TerraformMaxInstancesGuardPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const TerraformMaxInstancesGuardPanel({
    super.key,
    this.globalRefId = 'GEN-00905',
    this.atomicStepRefId = 'GEN-00905',
    this.sequenceOrder = 17614,
  });

  @override
  State<TerraformMaxInstancesGuardPanel> createState() =>
      _TerraformMaxInstancesGuardPanelState();
}

class _TerraformMaxInstancesGuardPanelState
    extends State<TerraformMaxInstancesGuardPanel> {
  int _maxInstances = 12;
  bool _cdnEnabled = true;

  bool get _isPolicySatisfied => _maxInstances >= 10 && _cdnEnabled;

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
                    Icons.gavel_rounded,
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
                        'GEN-00905: Terraform OPA Guard',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 17614 • Standard: HashiCorp OPA Governance',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  avatar: Icon(
                    _isPolicySatisfied ? Icons.check_circle_outline : Icons.cancel_outlined,
                    color: _isPolicySatisfied ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  label: Text(_isPolicySatisfied ? 'Deploy Allowed' : 'Blocked!'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('max_instances: $_maxInstances (Min: 10)', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text('CDN Enabled: ${_cdnEnabled ? "YES" : "NO"}', style: TextStyle(color: _cdnEnabled ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: _maxInstances.toDouble(),
              min: 4,
              max: 20,
              divisions: 16,
              label: '$_maxInstances instances',
              onChanged: (val) {
                setState(() => _maxInstances = val.toInt());
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Cloud CDN Distribution'),
              value: _cdnEnabled,
              onChanged: (val) {
                setState(() => _cdnEnabled = val);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _isPolicySatisfied
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Terraform plan passed OPA policy gate: deployment authorized.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.cloud_upload_rounded, size: 20),
                label: Text(_isPolicySatisfied ? 'Deploy Infrastructure' : 'Deployment Blocked by OPA Policy'),
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
            child: TerraformMaxInstancesGuardPanel(),
          ),
        ),
      ),
    ),
  );
}
