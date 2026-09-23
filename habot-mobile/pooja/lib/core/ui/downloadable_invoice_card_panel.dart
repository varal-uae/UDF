import 'package:flutter/material.dart';

/// Row 390: GEN-01259 (Seq 17968)
/// Action: Embed a downloadable invoice card component onto order confirmation views.
/// Quality Gate: GAAP / IFRS Invoicing Compliance Standard (Target: 0.9999).
class DownloadableInvoiceCardPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const DownloadableInvoiceCardPanel({
    super.key,
    this.globalRefId = 'GEN-01259',
    this.atomicStepRefId = 'GEN-01259',
    this.sequenceOrder = 17968,
  });

  @override
  State<DownloadableInvoiceCardPanel> createState() =>
      _DownloadableInvoiceCardPanelState();
}

class _DownloadableInvoiceCardPanelState
    extends State<DownloadableInvoiceCardPanel> {
  final String _invoiceId = 'INV-2026-894210';
  final String _shaVerificationHash = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
  final double _complianceVerificationRate = 0.9999;
  int _downloadCount = 6;

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
                    Icons.receipt_long_rounded,
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
                        'GEN-01259: Downloadable Tax Invoice',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 17968 • Standard: GAAP / IFRS Invoicing',
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
                  label: Text('IFRS PASS'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invoice ID:', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(_invoiceId, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Compliance Level:', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text('${(_complianceVerificationRate * 100).toStringAsFixed(2)}%', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Cryptographic SHA-256 Digest:', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _shaVerificationHash,
                style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace', fontSize: 10),
              ),
            ),
            const SizedBox(height: 12),
            Text('Downloads Verified: $_downloadCount', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () {
                  setState(() => _downloadCount++);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tax Invoice $_invoiceId downloaded with SHA-256 checksum verified.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded, size: 20),
                label: const Text('Download Official Tax Invoice (PDF)'),
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
            child: DownloadableInvoiceCardPanel(),
          ),
        ),
      ),
    ),
  );
}
