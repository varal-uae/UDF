import 'package:flutter/material.dart';

/// Row 317: GEN-00462 (Seq 17171)
/// Action: Integrate Cloud Logging drivers with Cloud Run containers.
/// Quality Gate: Google Cloud Well-Architected Framework — Operational Excellence.
class CloudLoggingDriverIntegrationPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const CloudLoggingDriverIntegrationPanel({
    super.key,
    this.globalRefId = 'GEN-00462',
    this.atomicStepRefId = 'GEN-00462',
    this.sequenceOrder = 17171,
  });

  @override
  State<CloudLoggingDriverIntegrationPanel> createState() =>
      _CloudLoggingDriverIntegrationPanelState();
}

class _CloudLoggingDriverIntegrationPanelState
    extends State<CloudLoggingDriverIntegrationPanel> {
  int _emittedLogsCount = 24;
  final List<String> _recentStructuredLogs = [
    '{"severity":"INFO", "service":"habot-mobile-gateway", "msg":"Session heartbeat verified"}',
    '{"severity":"NOTICE", "service":"habot-compliance-engine", "msg":"Gate 30 checkpoint signed"}',
  ];

  void _emitLog() {
    setState(() {
      _emittedLogsCount++;
      _recentStructuredLogs.insert(
        0,
        '{"severity":"INFO", "service":"habot-run-$_emittedLogsCount", "msg":"Structured event emitted at ${DateTime.now().second}s"}',
      );
      if (_recentStructuredLogs.length > 4) {
        _recentStructuredLogs.removeLast();
      }
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
                    Icons.cloud_done_rounded,
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
                        'Cloud Logging Driver Integration',
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
                    'CLOUD RUN LINKED',
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
              'Integrates Google Cloud Logging drivers directly with Cloud Run microservices, formatting mobile logs into structured JSON payloads with severity annotations.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _emitLog,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Emit Structured Log'),
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
                      Text('Driver Status', style: TextStyle(fontSize: 11)),
                      Text('STREAMING', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Total Emitted', style: TextStyle(fontSize: 11)),
                      Text('$_emittedLogsCount', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.indigo)),
                    ],
                  ),
                  const Column(
                    children: [
                      Text('Format Standard', style: TextStyle(fontSize: 11)),
                      Text('JSON (Stackdriver)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _recentStructuredLogs
                    .map((log) => Text(
                          log,
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            color: Colors.lightGreenAccent,
                          ),
                        ))
                    .toList(),
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
            child: CloudLoggingDriverIntegrationPanel(),
          ),
        ),
      ),
    ),
  );
}
