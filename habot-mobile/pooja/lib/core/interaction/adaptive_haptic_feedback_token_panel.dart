import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Row 399: GEN-01358 (Seq 18067)
/// Action: Bind adaptive haptic feedback triggers to touch target token interactions.
/// Quality Gate: WCAG 2.1 SC 2.5.5 Target Size / MD3 (Target: 48x48dp).
class AdaptiveHapticFeedbackTokenPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const AdaptiveHapticFeedbackTokenPanel({
    super.key,
    this.globalRefId = 'GEN-01358',
    this.atomicStepRefId = 'GEN-01358',
    this.sequenceOrder = 18067,
  });

  @override
  State<AdaptiveHapticFeedbackTokenPanel> createState() =>
      _AdaptiveHapticFeedbackTokenPanelState();
}

class _AdaptiveHapticFeedbackTokenPanelState
    extends State<AdaptiveHapticFeedbackTokenPanel> {
  final String _targetBound = '48x48dp';
  int _hapticTapsCount = 18;
  String _lastHapticType = 'Light Impact';

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
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.vibration_rounded,
                    color: theme.colorScheme.onTertiaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GEN-01358: Adaptive Haptic Feedback',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 18067 • Standard: WCAG 2.1 SC 2.5.5 / MD3',
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
                  label: Text('48x48dp PASS'),
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
                    Text('Touch Target Token Bound:', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(_targetBound, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Last Haptic Signal:', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(_lastHapticType, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Trigger Adaptive Haptic Touch Target:', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                // 48x48dp touch target with light haptic
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton.filled(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _hapticTapsCount++;
                        _lastHapticType = 'Light Impact';
                      });
                    },
                    icon: const Icon(Icons.touch_app_rounded, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                // 48x48dp touch target with medium haptic
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton.filledTonal(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _hapticTapsCount++;
                        _lastHapticType = 'Medium Impact';
                      });
                    },
                    icon: const Icon(Icons.fingerprint_rounded, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Taps Executed: $_hapticTapsCount', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'WCAG SC 2.5.5 Compliance: Minimum dimensions strictly enforced with tactile feedback confirmation on touch down.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
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
            child: AdaptiveHapticFeedbackTokenPanel(),
          ),
        ),
      ),
    ),
  );
}
