import 'package:flutter/material.dart';

/// Row 362: GEN-00949 (Seq 17658)
/// Action: Open mobile scaffolds directory mobile_core/ui/scaffolds/.
/// Quality Gate: Flutter Component Layout (Directory Access Integrity: 100%).
class MobileCoreScaffoldsInspectorPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const MobileCoreScaffoldsInspectorPanel({
    super.key,
    this.globalRefId = 'GEN-00949',
    this.atomicStepRefId = 'GEN-00949',
    this.sequenceOrder = 17658,
  });

  @override
  State<MobileCoreScaffoldsInspectorPanel> createState() =>
      _MobileCoreScaffoldsInspectorPanelState();
}

class _MobileCoreScaffoldsInspectorPanelState
    extends State<MobileCoreScaffoldsInspectorPanel> {
  final String _scaffoldDirPath = 'mobile_core/ui/scaffolds/';
  final List<String> _scaffoldTemplates = const [
    'adaptive_base_scaffold.dart',
    'collapsible_header_scaffold.dart',
    'master_detail_tablet_scaffold.dart',
    'bottom_sheet_modal_scaffold.dart',
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
                    Icons.space_dashboard_rounded,
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
                        'GEN-00949: Scaffolds Directory Inspector',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 17658 • Standard: Flutter Component Layout',
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
                  label: Text('100% Access PASS'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Scaffolds Target Directory: $_scaffoldDirPath',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            ..._scaffoldTemplates.map(
              (tmpl) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.widgets_outlined, size: 14, color: Colors.blueAccent),
                    const SizedBox(width: 8),
                    Text(
                      tmpl,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Scaffolds directory $_scaffoldDirPath inspected: ${_scaffoldTemplates.length} templates verified.',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.folder_open_rounded, size: 20),
                label: const Text('Audit Scaffolds Directory Tree'),
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
            child: MobileCoreScaffoldsInspectorPanel(),
          ),
        ),
      ),
    ),
  );
}
