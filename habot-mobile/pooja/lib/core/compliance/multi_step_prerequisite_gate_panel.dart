import 'package:flutter/material.dart';

/// Row 306: GEN-00341 (Seq 17050)
/// Action: Confirm Steps 9, 15, and 24 are complete as prerequisites.
/// Quality Gate: ITIL v4 Change Enablement / PMI PMBOK Dependency Gating Standard.
class MultiStepPrerequisiteGatePanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const MultiStepPrerequisiteGatePanel({
    super.key,
    this.globalRefId = 'GEN-00341',
    this.atomicStepRefId = 'GEN-00341',
    this.sequenceOrder = 17050,
  });

  @override
  State<MultiStepPrerequisiteGatePanel> createState() =>
      _MultiStepPrerequisiteGatePanelState();
}

class _MultiStepPrerequisiteGatePanelState
    extends State<MultiStepPrerequisiteGatePanel> {
  bool _step9Complete = true;
  bool _step15Complete = true;
  bool _step24Complete = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allComplete = _step9Complete && _step15Complete && _step24Complete;

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
                    Icons.checklist_rtl_rounded,
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
                        'Multi-Step Prerequisite Gate',
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
                    color: allComplete
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: allComplete ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Text(
                    allComplete ? '100% GATED PASS' : 'PREREQUISITE BLOCKED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: allComplete ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Enforces milestone prerequisite checkpoints requiring Step 9 (Entity Schema), Step 15 (Security Policy), and Step 24 (Validation Baseline) to be verified complete before authorizing transition.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Step 9 (Schema)'),
                  selected: _step9Complete,
                  onSelected: (val) => setState(() => _step9Complete = val),
                ),
                FilterChip(
                  label: const Text('Step 15 (Security)'),
                  selected: _step15Complete,
                  onSelected: (val) => setState(() => _step15Complete = val),
                ),
                FilterChip(
                  label: const Text('Step 24 (Baseline)'),
                  selected: _step24Complete,
                  onSelected: (val) => setState(() => _step24Complete = val),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Dependency Gate', style: TextStyle(fontSize: 11)),
                      Text(
                        allComplete ? 'CLEARED' : 'LOCKED',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: allComplete ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const Column(
                    children: [
                      Text('Framework Standard', style: TextStyle(fontSize: 11)),
                      Text('ITIL v4 / PMBOK', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.indigo)),
                    ],
                  ),
                ],
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
            child: MultiStepPrerequisiteGatePanel(),
          ),
        ),
      ),
    ),
  );
}
