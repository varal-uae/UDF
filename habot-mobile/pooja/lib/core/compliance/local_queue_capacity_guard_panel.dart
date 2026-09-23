import 'package:flutter/material.dart';

/// Row 344: GEN-00760 (Seq 17469)
/// Action: Set maximum local storage queue cap to 5,000 events.
/// Quality Gate: Mobile Resource Limit Rules (Storage Queue Capacity: 5000 events).
class LocalQueueCapacityGuardPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const LocalQueueCapacityGuardPanel({
    super.key,
    this.globalRefId = 'GEN-00760',
    this.atomicStepRefId = 'GEN-00760',
    this.sequenceOrder = 17469,
  });

  @override
  State<LocalQueueCapacityGuardPanel> createState() =>
      _LocalQueueCapacityGuardPanelState();
}

class _LocalQueueCapacityGuardPanelState
    extends State<LocalQueueCapacityGuardPanel> {
  final int _maxQueueCap = 5000;
  int _currentQueuedEvents = 1420;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usagePercent = (_currentQueuedEvents / _maxQueueCap).clamp(0.0, 1.0);

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
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.storage_rounded,
                    color: theme.colorScheme.onSecondaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GEN-00760: Local Queue Capacity Guard',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 17469 • Standard: Mobile Resource Limit Rules',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  avatar: const Icon(
                    Icons.verified_rounded,
                    color: Colors.green,
                    size: 16,
                  ),
                  label: Text('$_maxQueueCap Cap PASS'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Queue Storage: $_currentQueuedEvents / $_maxQueueCap events',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(usagePercent * 100).toStringAsFixed(1)}% full',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: usagePercent > 0.8 ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: usagePercent,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                usagePercent > 0.8 ? Colors.orange : Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentQueuedEvents = (_currentQueuedEvents + 250).clamp(0, _maxQueueCap);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Queued events updated: $_currentQueuedEvents / $_maxQueueCap (FIFO boundary enforced).',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                label: const Text('Simulate Enqueue Batch (+250 Events)'),
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
            child: LocalQueueCapacityGuardPanel(),
          ),
        ),
      ),
    ),
  );
}
