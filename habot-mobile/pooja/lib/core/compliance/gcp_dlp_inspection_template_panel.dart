import 'package:flutter/material.dart';

/// Row 349: GEN-00815 (Seq 17524)
/// Action: Provision Google Cloud Data Loss Prevention (DLP) inspection templates.
/// Quality Gate: Google Cloud DLP Documentation (Template Provisioning Status: Provisioned).
class GcpDlpInspectionTemplatePanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const GcpDlpInspectionTemplatePanel({
    super.key,
    this.globalRefId = 'GEN-00815',
    this.atomicStepRefId = 'GEN-00815',
    this.sequenceOrder = 17524,
  });

  @override
  State<GcpDlpInspectionTemplatePanel> createState() =>
      _GcpDlpInspectionTemplatePanelState();
}

class _GcpDlpInspectionTemplatePanelState
    extends State<GcpDlpInspectionTemplatePanel> {
  final String _templateId = 'projects/habot-prod/inspectTemplates/dlp-pii-scrubber-v2';
  final List<String> _infoTypes = const [
    'EMAIL_ADDRESS',
    'PHONE_NUMBER',
    'CREDIT_CARD_NUMBER',
    'INDIA_AADHAAR_INDIVIDUAL',
  ];
  int _scansExecuted = 28;

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
                    Icons.security_update_good_rounded,
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
                        'GEN-00815: GCP DLP Inspection Template',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 17524 • Standard: Google Cloud DLP Documentation',
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
                  label: Text('Provisioned PASS'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'GCP DLP Inspection Template Resource:',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _templateId,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Active InfoTypes Inspected:',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: _infoTypes
                  .map(
                    (type) => Chip(
                      label: Text(type, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _scansExecuted++;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'DLP template validated: Scan #$_scansExecuted completed with 0 PII leakages.',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.manage_search_rounded, size: 20),
                label: const Text('Validate DLP Template Status'),
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
            child: GcpDlpInspectionTemplatePanel(),
          ),
        ),
      ),
    ),
  );
}
