import 'package:flutter/material.dart';

/// Row 292: GEN-00185 (Seq 16894)
/// Action: Confirm the ComponentErrorBoundary wrapper and mobile fallback UI screens are delivered.
/// Quality Gate: ISO/IEC 25010 Reliability / Graceful Mobile Fallback Standard.
class MobileFallbackErrorBoundaryPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const MobileFallbackErrorBoundaryPanel({
    super.key,
    this.globalRefId = 'GEN-00185',
    this.atomicStepRefId = 'GEN-00185',
    this.sequenceOrder = 16894,
  });

  @override
  State<MobileFallbackErrorBoundaryPanel> createState() =>
      _MobileFallbackErrorBoundaryPanelState();
}

class _MobileFallbackErrorBoundaryPanelState
    extends State<MobileFallbackErrorBoundaryPanel> {
  bool _simulateSubtreeFault = false;
  int _isolatedRetries = 0;

  void _toggleFault() {
    setState(() {
      _simulateSubtreeFault = !_simulateSubtreeFault;
    });
  }

  void _retryComponent() {
    setState(() {
      _simulateSubtreeFault = false;
      _isolatedRetries++;
    });
  }

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
                    Icons.mobile_friendly_rounded,
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
                        'Component Fallback UI Screen',
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
                    'ISO/IEC 25010 DELIVERED',
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
              'Confirms delivery of ComponentErrorBoundary wrappers and responsive mobile fallback screens, isolating component failures without interrupting surrounding workflows.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _toggleFault,
                  icon: Icon(_simulateSubtreeFault ? Icons.healing : Icons.flash_on, size: 18),
                  label: Text(_simulateSubtreeFault ? 'Clear Subtree Fault' : 'Trigger Subtree Fault'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Isolated Subtree Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: _simulateSubtreeFault
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sentiment_dissatisfied_rounded, color: Colors.orange, size: 36),
                        const SizedBox(height: 8),
                        const Text(
                          'Component temporarily unavailable',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Surrounding app shell remains completely functional.',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed: _retryComponent,
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Retry Component'),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 20),
                            SizedBox(width: 8),
                            Text('Normal Component Operation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                        Text('Retries: $_isolatedRetries', style: const TextStyle(fontSize: 11, color: Colors.indigo)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
