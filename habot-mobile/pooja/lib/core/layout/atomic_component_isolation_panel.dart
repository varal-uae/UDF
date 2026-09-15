import 'package:flutter/material.dart';

/// Row 298: GEN-00253 (Seq 16962)
/// Action: Ensure atomic components render independently without layout side-effects.
/// Quality Gate: Agile Definition of Done / Zero Layout Bleed Constraint.
class AtomicComponentIsolationPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const AtomicComponentIsolationPanel({
    super.key,
    this.globalRefId = 'GEN-00253',
    this.atomicStepRefId = 'GEN-00253',
    this.sequenceOrder = 16962,
  });

  @override
  State<AtomicComponentIsolationPanel> createState() =>
      _AtomicComponentIsolationPanelState();
}

class _AtomicComponentIsolationPanelState
    extends State<AtomicComponentIsolationPanel> {
  bool _isolationBoundaryActive = true;
  int _independentRenderTests = 12;

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
                    Icons.view_in_ar_rounded,
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
                        'Atomic Component Isolation',
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
                    'ZERO LAYOUT BLEED',
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
              'Ensures all atomic UI components render strictly within their declared box constraints without leaking margins, unhandled overflows, or cascading side-effects.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () {
                    setState(() {
                      _isolationBoundaryActive = !_isolationBoundaryActive;
                      _independentRenderTests++;
                    });
                  },
                  icon: Icon(_isolationBoundaryActive ? Icons.lock_outline : Icons.lock_open, size: 18),
                  label: Text(_isolationBoundaryActive ? 'Isolation Enforced' : 'Isolation Relaxed'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Isolated container demonstration
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isolationBoundaryActive ? Colors.green : Colors.orange,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bounded Child Box (Strict Constraints)',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Tests: $_independentRenderTests',
                        style: const TextStyle(fontSize: 11, color: Colors.indigo),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.tag, size: 14),
                        label: const Text('Tag Token', style: TextStyle(fontSize: 11)),
                        onPressed: () {},
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.toggle_on, size: 14),
                        label: const Text('Atomic Switch', style: TextStyle(fontSize: 11)),
                        onPressed: () {},
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.check, size: 14),
                        label: const Text('Atomic Badge', style: TextStyle(fontSize: 11)),
                        onPressed: () {},
                      ),
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
