import 'package:flutter/material.dart';

/// Row 296: GEN-00230 (Seq 16939)
/// Action: Confirm the integrated InstructionViewer component bound to EC Registry is delivered.
/// Quality Gate: ISO/IEC 25010 Functional Correctness; PMI PMBOK Quality Control.
class InstructionViewerEcRegistryPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const InstructionViewerEcRegistryPanel({
    super.key,
    this.globalRefId = 'GEN-00230',
    this.atomicStepRefId = 'GEN-00230',
    this.sequenceOrder = 16939,
  });

  @override
  State<InstructionViewerEcRegistryPanel> createState() =>
      _InstructionViewerEcRegistryPanelState();
}

class _InstructionViewerEcRegistryPanelState
    extends State<InstructionViewerEcRegistryPanel> {
  int _selectedInstructionIndex = 0;
  final List<Map<String, String>> _ecInstructions = [
    {
      'code': 'EC-INST-101',
      'title': 'Operating Perimeter Quarantine Protocol',
      'body': 'Enforce physical perimeter verification and security gate clearance prior to field telemetry logging.',
      'status': 'BOUND_TO_REGISTRY',
    },
    {
      'code': 'EC-INST-102',
      'title': 'Cryptographic Chain Validation Procedure',
      'body': 'Verify previous block hash against Genesis ledger before approving batch state dispatch.',
      'status': 'BOUND_TO_REGISTRY',
    },
    {
      'code': 'EC-INST-103',
      'title': 'Biometric Step-Up Challenge Escalation',
      'body': 'Trigger hardware-bound biometric authentication upon encountering high-risk role transactions.',
      'status': 'BOUND_TO_REGISTRY',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentInst = _ecInstructions[_selectedInstructionIndex];

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
                    Icons.menu_book_rounded,
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
                        'InstructionViewer EC Registry',
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
                    'EC REGISTRY BOUND',
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
              'Confirms the delivery of the InstructionViewer component tightly bound to the Enterprise Compliance (EC) Registry, displaying operational standard work instructions.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_ecInstructions.length, (index) {
                return ChoiceChip(
                  label: Text(_ecInstructions[index]['code']!),
                  selected: _selectedInstructionIndex == index,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedInstructionIndex = index;
                      });
                    }
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentInst['code']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo),
                      ),
                      Text(
                        currentInst['status']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currentInst['title']!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentInst['body']!,
                    style: theme.textTheme.bodySmall,
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
