import 'package:flutter/material.dart';

/// Row 338: GEN-00694 (Seq 17403)
/// Action: Configure budget threshold trigger logic inspecting live spend vs. caps every 15 minutes.
/// Quality Gate: Habot Budget Pacing Rules (Budget Inspection Cron Interval: 15 mins).
class BudgetThresholdTriggerPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const BudgetThresholdTriggerPanel({
    super.key,
    this.globalRefId = 'GEN-00694',
    this.atomicStepRefId = 'GEN-00694',
    this.sequenceOrder = 17403,
  });

  @override
  State<BudgetThresholdTriggerPanel> createState() =>
      _BudgetThresholdTriggerPanelState();
}

class _BudgetThresholdTriggerPanelState
    extends State<BudgetThresholdTriggerPanel> {
  final int _cronIntervalMinutes = 15;
  final double _spendCapUsd = 50000.0;
  final double _currentSpendUsd = 34820.0;
  bool _isAutoThrottleArmed = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spendRatio = (_currentSpendUsd / _spendCapUsd).clamp(0.0, 1.0);

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
                    Icons.trending_up_rounded,
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
                        'GEN-00694: Budget Threshold Trigger',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 17403 • Standard: Habot Budget Pacing Rules',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  avatar: const Icon(
                    Icons.timer_outlined,
                    color: Colors.indigo,
                    size: 16,
                  ),
                  label: Text('$_cronIntervalMinutes min Cron'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spend: \$${_currentSpendUsd.toStringAsFixed(0)} / \$${_spendCapUsd.toStringAsFixed(0)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(spendRatio * 100).toStringAsFixed(1)}% Allocated',
                  style: TextStyle(
                    color: spendRatio > 0.9 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: spendRatio,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                spendRatio > 0.9 ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _isAutoThrottleArmed = !_isAutoThrottleArmed;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Auto-throttle trigger guard ${_isAutoThrottleArmed ? "Armed" : "Disarmed"}. Next check in 15m.',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(
                  _isAutoThrottleArmed
                      ? Icons.shield_rounded
                      : Icons.shield_outlined,
                  size: 20,
                ),
                label: Text(
                  _isAutoThrottleArmed
                      ? 'Trigger Armed (Auto-Pacing Active)'
                      : 'Trigger Disarmed (Manual Mode)',
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
            child: BudgetThresholdTriggerPanel(),
          ),
        ),
      ),
    ),
  );
}
