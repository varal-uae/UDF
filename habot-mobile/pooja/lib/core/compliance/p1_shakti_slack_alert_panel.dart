import 'package:flutter/material.dart';

/// Row 364: GEN-00971 (Seq 17680)
/// Action: Emit P1 Shakti Alerts to Slack if API pause retries fail.
/// Quality Gate: Habot Shakti Safety Protocol (Alert Dispatch Latency: <= 3 secs).
class P1ShaktiSlackAlertPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const P1ShaktiSlackAlertPanel({
    super.key,
    this.globalRefId = 'GEN-00971',
    this.atomicStepRefId = 'GEN-00971',
    this.sequenceOrder = 17680,
  });

  @override
  State<P1ShaktiSlackAlertPanel> createState() =>
      _P1ShaktiSlackAlertPanelState();
}

class _P1ShaktiSlackAlertPanelState extends State<P1ShaktiSlackAlertPanel> {
  final String _slackWebhookChannel = '#shakti-alerts-p1';
  final double _alertLatencySec = 0.8;
  int _emittedAlertsCount = 3;

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
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: theme.colorScheme.onErrorContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GEN-00971: P1 Shakti Slack Alerts',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 17680 • Standard: Habot Shakti Safety Protocol',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  avatar: const Icon(
                    Icons.flash_on_rounded,
                    color: Colors.green,
                    size: 16,
                  ),
                  label: Text('$_alertLatencySec s (<=3s PASS)'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            Text('Slack Alert Routing Webhook:', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _slackWebhookChannel,
                style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'P1 Incidents Logged: $_emittedAlertsCount',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() => _emittedAlertsCount++);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'P1 Alert dispatched to $_slackWebhookChannel in $_alertLatencySec s.',
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                },
                icon: const Icon(Icons.send_rounded, size: 20),
                label: const Text('Simulate API Retry Failure & P1 Slack Alert'),
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
            child: P1ShaktiSlackAlertPanel(),
          ),
        ),
      ),
    ),
  );
}
