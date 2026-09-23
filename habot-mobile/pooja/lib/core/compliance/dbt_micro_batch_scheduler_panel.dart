import 'package:flutter/material.dart';

/// Row 334: GEN-00649 (Seq 17358)
/// Action: Schedule dbt execution runs on a 4-hour micro-batch schedule.
/// Quality Gate: Apache Airflow / dbt Cloud Rules (Schedule On-Time Execution: >= 99.9%).
class DbtMicroBatchSchedulerPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const DbtMicroBatchSchedulerPanel({
    super.key,
    this.globalRefId = 'GEN-00649',
    this.atomicStepRefId = 'GEN-00649',
    this.sequenceOrder = 17358,
  });

  @override
  State<DbtMicroBatchSchedulerPanel> createState() =>
      _DbtMicroBatchSchedulerPanelState();
}

class _DbtMicroBatchSchedulerPanelState
    extends State<DbtMicroBatchSchedulerPanel> {
  final String _scheduleCron = '0 */4 * * * (Every 4 Hours UTC)';
  final String _targetModel = 'dbt_transforms.core_marketing_roas_stream';
  bool _schedulerActive = true;
  final double _onTimeRate = 99.95;

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
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.schedule_rounded,
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
                        'GEN-00649: dbt 4h Micro-Batch Scheduler',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 17358 • Standard: Apache Airflow / dbt Cloud Rules',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  avatar: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 16,
                  ),
                  label: Text('$_onTimeRate% On-Time'),
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
                    Text(
                      'Schedule Cron Pattern:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _scheduleCron,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Target dbt Model:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _targetModel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _schedulerActive = !_schedulerActive;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'dbt 4-hour micro-batch scheduler is now ${_schedulerActive ? "Active" : "Paused"}.',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(
                  _schedulerActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 20,
                ),
                label: Text(
                  _schedulerActive
                      ? 'Pause dbt 4-Hour Cron'
                      : 'Resume dbt 4-Hour Cron',
                ),
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
            child: DbtMicroBatchSchedulerPanel(),
          ),
        ),
      ),
    ),
  );
}
