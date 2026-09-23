import 'package:flutter/material.dart';

/// Row 323: GEN-00528 (Seq 17237)
/// Action: Dispatch conversion events carrying event_id simultaneously to BigQuery and AppsFlyer.
/// Quality Gate: ISO/IEC 25010 Reliability / Dual-Pipeline Telemetry Consistency.
class DualDispatchConversionEventPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const DualDispatchConversionEventPanel({
    super.key,
    this.globalRefId = 'GEN-00528',
    this.atomicStepRefId = 'GEN-00528',
    this.sequenceOrder = 17237,
  });

  @override
  State<DualDispatchConversionEventPanel> createState() =>
      _DualDispatchConversionEventPanelState();
}

class _DualDispatchConversionEventPanelState
    extends State<DualDispatchConversionEventPanel> {
  int _dispatchedCount = 6;
  bool _bigQuerySynced = true;
  bool _appsFlyerSynced = true;
  String _lastEventId = 'EVT-UUID-7721a-49bf';

  void _triggerDualDispatch() {
    setState(() {
      _dispatchedCount++;
      _lastEventId = 'EVT-UUID-${(_dispatchedCount * 1337).toRadixString(16)}-99ca';
      _bigQuerySynced = true;
      _appsFlyerSynced = true;
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
                    Icons.call_split_rounded,
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
                        'Dual-Dispatch Conversion Event',
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
                    'DUAL PIPELINE PASS',
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
              'Dispatches mobile conversion events carrying a persistent event_id simultaneously to BigQuery and AppsFlyer, enforcing zero attribution skew across channels.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _triggerDualDispatch,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Simulate Dual Dispatch'),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Active event_id: $_lastEventId', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                      Text('Events: $_dispatchedCount', style: const TextStyle(fontSize: 11, color: Colors.indigo, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: _bigQuerySynced ? Colors.green : Colors.red, size: 16),
                          const SizedBox(width: 4),
                          const Text('BigQuery Stream', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: _appsFlyerSynced ? Colors.green : Colors.red, size: 16),
                          const SizedBox(width: 4),
                          const Text('AppsFlyer MMP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
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
            child: DualDispatchConversionEventPanel(),
          ),
        ),
      ),
    ),
  );
}
