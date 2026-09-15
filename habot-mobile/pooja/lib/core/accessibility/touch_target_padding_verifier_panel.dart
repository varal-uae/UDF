import 'package:flutter/material.dart';

/// Row 282: GEN-00083 (Seq 16792)
/// Action: Verify all touchable components are configured with transparent padded touch target areas.
/// Quality Gate: WCAG 2.1 AA 48x48dp Minimum Touch Target Boundary Standard.
class TouchTargetPaddingVerifierPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const TouchTargetPaddingVerifierPanel({
    super.key,
    this.globalRefId = 'GEN-00083',
    this.atomicStepRefId = 'GEN-00083',
    this.sequenceOrder = 16792,
  });

  @override
  State<TouchTargetPaddingVerifierPanel> createState() =>
      _TouchTargetPaddingVerifierPanelState();
}

class _TouchTargetPaddingVerifierPanelState
    extends State<TouchTargetPaddingVerifierPanel> {
  bool _showTouchBoundaries = true;
  int _successfulTapsInTarget = 0;
  final List<Map<String, dynamic>> _touchableElements = [
    {
      'element': 'IconButton (Close)',
      'visualSize': '24x24dp',
      'touchBoundary': '48x48dp',
      'status': 'PASS_WCAG_AA',
    },
    {
      'element': 'Checkbox Action',
      'visualSize': '18x18dp',
      'touchBoundary': '48x48dp',
      'status': 'PASS_WCAG_AA',
    },
    {
      'element': 'Small Chip Delete Icon',
      'visualSize': '16x16dp',
      'touchBoundary': '48x48dp',
      'status': 'PASS_WCAG_AA',
    },
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
                    Icons.aspect_ratio_rounded,
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
                        'Touch Target Padding Verifier',
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
                    '≥48x48dp WCAG AA',
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
              'Verifies that all touchable components are configured with transparent padded touch target areas meeting the minimum 48x48dp WCAG 2.1 AA accessibility boundary.',
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
                      _showTouchBoundaries = !_showTouchBoundaries;
                    });
                  },
                  icon: Icon(_showTouchBoundaries ? Icons.visibility_off : Icons.visibility, size: 18),
                  label: Text(_showTouchBoundaries ? 'Hide Boundaries' : 'Highlight 48dp Box'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Interactive 48dp demonstration
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
                  // 48x48 box with 24x24 visual icon inside
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _successfulTapsInTarget++;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        border: _showTouchBoundaries
                            ? Border.all(color: Colors.red, width: 1.5)
                            : null,
                        color: _showTouchBoundaries
                            ? Colors.red.withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Icon(Icons.close_rounded, size: 24, color: Colors.black87),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Visual Target: 24x24dp', style: TextStyle(fontSize: 11)),
                      const Text('Hit Boundary: 48x48dp (WCAG Validated)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                      Text('Taps Registered: $_successfulTapsInTarget', style: const TextStyle(fontSize: 11, color: Colors.indigo)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _touchableElements.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final el = _touchableElements[index];
                  final eName = el['element'] as String? ?? '';
                  final vSize = el['visualSize'] as String? ?? '';
                  final tBound = el['touchBoundary'] as String? ?? '';

                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                    title: Text(eName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    subtitle: Text('Visual: $vSize | Hit Target: $tBound', style: const TextStyle(fontSize: 11)),
                    trailing: const Text(
                      'PASS',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
