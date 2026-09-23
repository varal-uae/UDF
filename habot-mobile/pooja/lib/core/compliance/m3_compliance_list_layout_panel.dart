import 'package:flutter/material.dart';

/// Row 403: GEN-01402 (Seq 18111)
/// Action: Construct a compliance screen layout using an M3 List view structure.
/// Quality Gate: ISO/IEC 27001 Annex A (Target: 1.0).
class M3ComplianceListLayoutPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const M3ComplianceListLayoutPanel({
    super.key,
    this.globalRefId = 'GEN-01402',
    this.atomicStepRefId = 'GEN-01402',
    this.sequenceOrder = 18111,
  });

  @override
  State<M3ComplianceListLayoutPanel> createState() =>
      _M3ComplianceListLayoutPanelState();
}

class _M3ComplianceListLayoutPanelState
    extends State<M3ComplianceListLayoutPanel> {
  final double _complianceFidelity = 1.0;
  final List<Map<String, dynamic>> _complianceItems = const [
    {
      'title': 'A.9.2 User Access Management',
      'subtitle': 'Role-based access control & biometric step-up active',
      'icon': Icons.lock_person_rounded,
      'isCompliant': true,
    },
    {
      'title': 'A.10.1 Cryptographic Controls',
      'subtitle': 'AES-256 local storage encryption & TLS 1.3 transit',
      'icon': Icons.vpn_key_rounded,
      'isCompliant': true,
    },
    {
      'title': 'A.12.4 Logging and Monitoring',
      'subtitle': 'Immutable audit trail with Pub/Sub streaming',
      'icon': Icons.receipt_long_rounded,
      'isCompliant': true,
    },
  ];
  int _auditRuns = 14;

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
                    Icons.security_rounded,
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
                        'GEN-01402: Compliance List Layout',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 18111 • Standard: ISO/IEC 27001 Annex A',
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
                  label: Text('ISO 27001 PASS'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            Text('M3 Compliance Policy Registry:', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._complianceItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(item['icon'] as IconData, size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Text(item['subtitle'] as String, style: TextStyle(color: theme.colorScheme.outline, fontSize: 10)),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Compliance Rate: ${(_complianceFidelity * 100).toInt()}%', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                Text('Audit Audits Run: $_auditRuns', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () {
                  setState(() => _auditRuns++);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ISO/IEC 27001 Annex A controls verified compliant across all active stations.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.verified_user_rounded, size: 20),
                label: const Text('Execute ISO 27001 Compliance Audit'),
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
            child: M3ComplianceListLayoutPanel(),
          ),
        ),
      ),
    ),
  );
}
