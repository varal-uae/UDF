import 'package:flutter/material.dart';

/// Row 355: GEN-00882 (Seq 17591)
/// Action: Program visualizer to automatically highlight orphan nodes in bright flashing red.
/// Quality Gate: Habot DCDF Orphan Detection Rule (Orphan Visual Alert Precision: 100%).
class OrphanNodesHighlighterPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const OrphanNodesHighlighterPanel({
    super.key,
    this.globalRefId = 'GEN-00882',
    this.atomicStepRefId = 'GEN-00882',
    this.sequenceOrder = 17591,
  });

  @override
  State<OrphanNodesHighlighterPanel> createState() =>
      _OrphanNodesHighlighterPanelState();
}

class _OrphanNodesHighlighterPanelState
    extends State<OrphanNodesHighlighterPanel> {
  final List<Map<String, dynamic>> _nodes = [
    {'id': 'NODE_001', 'isOrphan': false, 'desc': 'Root Ingestion Gate'},
    {'id': 'NODE_002', 'isOrphan': true, 'desc': 'Detached Legacy Router (ORPHAN)'},
    {'id': 'NODE_003', 'isOrphan': false, 'desc': 'BigQuery Buffer Client'},
    {'id': 'NODE_004', 'isOrphan': true, 'desc': 'Unreferenced Transform Task (ORPHAN)'},
  ];
  bool _highlightOrphans = true;

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
                    Icons.warning_amber_rounded,
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
                        'GEN-00882: Orphan Node Visualizer',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 17591 • Standard: Habot DCDF Orphan Detection Rule',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  avatar: const Icon(
                    Icons.flourescent_rounded,
                    color: Colors.red,
                    size: 16,
                  ),
                  label: Text(_highlightOrphans ? 'Flashing Red ON' : 'Off'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'DAG Node Visualizer (Highlighted Orphan Nodes):',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._nodes.map(
              (node) {
                final isOrphan = node['isOrphan'] as bool;
                final shouldHighlight = isOrphan && _highlightOrphans;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: shouldHighlight ? Colors.red.withValues(alpha: 0.15) : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: shouldHighlight ? Colors.red : theme.colorScheme.outlineVariant,
                      width: shouldHighlight ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        shouldHighlight ? Icons.error_rounded : Icons.check_circle_outline,
                        color: shouldHighlight ? Colors.red : Colors.green,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(node['id'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                      const SizedBox(width: 8),
                      Expanded(child: Text(node['desc'] as String, style: const TextStyle(fontSize: 12))),
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
                  setState(() {
                    _highlightOrphans = !_highlightOrphans;
                  });
                },
                icon: Icon(_highlightOrphans ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20),
                label: Text(_highlightOrphans ? 'Toggle Flashing Highlight Off' : 'Highlight Orphan Nodes in Red'),
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
            child: OrphanNodesHighlighterPanel(),
          ),
        ),
      ),
    ),
  );
}
