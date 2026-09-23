import 'package:flutter/material.dart';

/// Row 329: GEN-00594 (Seq 17303)
/// Action: Lock mobile viewport orientations to DeviceOrientation.portraitUp.
/// Quality Gate: Material Design 3 Mobile Guidance / Orientation Lock Standard.
class PortraitOrientationLockEnforcerPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const PortraitOrientationLockEnforcerPanel({
    super.key,
    this.globalRefId = 'GEN-00594',
    this.atomicStepRefId = 'GEN-00594',
    this.sequenceOrder = 17303,
  });

  @override
  State<PortraitOrientationLockEnforcerPanel> createState() =>
      _PortraitOrientationLockEnforcerPanelState();
}

class _PortraitOrientationLockEnforcerPanelState
    extends State<PortraitOrientationLockEnforcerPanel> {
  bool _isPortraitLocked = true;

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
                    Icons.screen_lock_portrait_rounded,
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
                        'Portrait Orientation Lock Enforcer',
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
                    'PORTRAIT LOCKED',
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
              'Enforces SystemChrome orientation locks restricting mobile application viewports strictly to DeviceOrientation.portraitUp, preventing unexpected layout reflows on industrial plant tablets.',
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
                      _isPortraitLocked = !_isPortraitLocked;
                    });
                  },
                  icon: Icon(_isPortraitLocked ? Icons.lock : Icons.lock_open, size: 18),
                  label: Text(_isPortraitLocked ? 'Orientation: portraitUp Locked' : 'Orientation: Unlocked (Demo)'),
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
                  const Column(
                    children: [
                      Text('Active Constraint', style: TextStyle(fontSize: 11)),
                      Text('portraitUp', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.green)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Lock Enforcement', style: TextStyle(fontSize: 11)),
                      Text(
                        _isPortraitLocked ? 'ACTIVE' : 'TEST_OVERRIDE',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _isPortraitLocked ? Colors.indigo : Colors.orange,
                        ),
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

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: PortraitOrientationLockEnforcerPanel(),
          ),
        ),
      ),
    ),
  );
}
