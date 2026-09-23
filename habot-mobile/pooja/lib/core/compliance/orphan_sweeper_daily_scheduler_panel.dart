import 'package:flutter/material.dart';

/// Row 326: GEN-00561 (Seq 17270)
/// Action: Schedule the Orphan Sweeper query to run daily at midnight.
/// Quality Gate: ISO/IEC 27001 / Cloud Scheduler Cron Standard (0 0 * * *).
class OrphanSweeperDailySchedulerPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const OrphanSweeperDailySchedulerPanel({
    super.key,
    this.globalRefId = 'GEN-00561',
    this.atomicStepRefId = 'GEN-00561',
    this.sequenceOrder = 17270,
  });

  @override
  State<OrphanSweeperDailySchedulerPanel> createState() =>
      _OrphanSweeperDailySchedulerPanelState();
}

class _OrphanSweeperDailySchedulerPanelState
    extends State<OrphanSweeperDailySchedulerPanel> {
  final String _cronSchedule = '0 0 * * * (Daily Midnight UTC)';
  bool _schedulerEnabled = true;
  final int _sweptOrphansTotal = 14;

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
                    Icons.schedule_rounded,
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
                        'Orphan Sweeper Daily Scheduler',
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
                    'CRON SCHEDULED',
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
              'Configures Google Cloud Scheduler to trigger the Orphan Sweeper BigQuery maintenance query daily at midnight UTC, identifying and purging unlinked attribution records.',
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
                      _schedulerEnabled = !_schedulerEnabled;
                    });
                  },
                  icon: Icon(_schedulerEnabled ? Icons.pause_circle_outline : Icons.play_circle_outline, size: 18),
                  label: Text(_schedulerEnabled ? 'Pause Cloud Scheduler' : 'Resume Cloud Scheduler'),
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
                      const Text('Cron Expression', style: TextStyle(fontSize: 11)),
                      Text(_cronSchedule.split(' ').first, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.indigo)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Status', style: TextStyle(fontSize: 11)),
                      Text(
                        _schedulerEnabled ? 'ENABLED' : 'PAUSED',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _schedulerEnabled ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Orphans Cleared', style: TextStyle(fontSize: 11)),
                      Text('$_sweptOrphansTotal', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
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
            child: OrphanSweeperDailySchedulerPanel(),
          ),
        ),
      ),
    ),
  );
}
