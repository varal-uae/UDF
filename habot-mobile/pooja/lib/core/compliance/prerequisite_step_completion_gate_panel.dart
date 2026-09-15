import 'package:flutter/material.dart';

/// Row 276: GEN-00017 (Seq 16726)
/// Action: Confirm Step 1 is complete as a prerequisite.
/// Quality Gate: ITIL v4 Change Enablement / PMI PMBOK 7th Ed. (100% prerequisite verification).
class PrerequisiteStepCompletionGatePanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const PrerequisiteStepCompletionGatePanel({
    super.key,
    this.globalRefId = 'GEN-00017',
    this.atomicStepRefId = 'GEN-00017',
    this.sequenceOrder = 16726,
  });

  @override
  State<PrerequisiteStepCompletionGatePanel> createState() =>
      _PrerequisiteStepCompletionGatePanelState();
}

class _PrerequisiteStepCompletionGatePanelState
    extends State<PrerequisiteStepCompletionGatePanel> {
  bool _isStep1Complete = true;
  final List<Map<String, dynamic>> _prerequisiteChecklist = [
    {
      'stepName': 'Step 1: Core Configuration Baseline',
      'owner': 'DevOps Gatekeeper',
      'isCleared': true,
      'clearedTimestamp': '2026-09-10T13:45:00Z',
    },
    {
      'stepName': 'Step 2: Architecture Compliance Linter',
      'owner': 'QA Automation',
      'isCleared': true,
      'clearedTimestamp': '2026-09-10T13:48:22Z',
    },
    {
      'stepName': 'Step 3: Cryptographic Token Provisioning',
      'owner': 'Security Authority',
      'isCleared': true,
      'clearedTimestamp': '2026-09-10T13:51:10Z',
    },
  ];

  void _toggleStep1Prerequisite() {
    setState(() {
      _isStep1Complete = !_isStep1Complete;
      _prerequisiteChecklist[0]['isCleared'] = _isStep1Complete;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allCleared = _prerequisiteChecklist.every((s) => s['isCleared'] == true);

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
                    color: allCleared
                        ? theme.colorScheme.primaryContainer
                        : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    allCleared ? Icons.playlist_add_check_circle_rounded : Icons.block_rounded,
                    color: allCleared ? theme.colorScheme.onPrimaryContainer : Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prerequisite Step Completion Gate',
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
                    color: allCleared
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: allCleared ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Text(
                    allCleared ? 'PREREQUISITES MET' : 'GATE BLOCKED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: allCleared ? Colors.green[800] : Colors.red[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Enforces strict ITIL v4 milestone sequencing by confirming that Step 1 is verified complete before allowing downstream deployments.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _toggleStep1Prerequisite,
                  icon: Icon(_isStep1Complete ? Icons.cancel_outlined : Icons.check_circle_outline, size: 18),
                  label: Text(_isStep1Complete ? 'Simulate Missing Step 1' : 'Clear Step 1 Prerequisite'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _prerequisiteChecklist.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _prerequisiteChecklist[index];
                final isCleared = item['isCleared'] as bool;
                final sName = item['stepName'] as String? ?? '';
                final sOwner = item['owner'] as String? ?? '';

                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isCleared ? Icons.check_circle_rounded : Icons.pending_rounded,
                    color: isCleared ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  title: Text(
                    sName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      decoration: isCleared ? null : TextDecoration.lineThrough,
                    ),
                  ),
                  subtitle: Text('Owner: $sOwner', style: const TextStyle(fontSize: 11)),
                  trailing: Text(
                    isCleared ? 'CLEARED' : 'BLOCKED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isCleared ? Colors.green : Colors.red,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
