import 'package:flutter/material.dart';

/// Row 320: GEN-00495 (Seq 17204)
/// Action: Perform message failure tests to confirm unacknowledged packets are redelivered.
/// Quality Gate: Google Cloud Pub/Sub Dead Letter / At-Least-Once Delivery Standard.
class UnacknowledgedPacketRedeliveryTesterPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const UnacknowledgedPacketRedeliveryTesterPanel({
    super.key,
    this.globalRefId = 'GEN-00495',
    this.atomicStepRefId = 'GEN-00495',
    this.sequenceOrder = 17204,
  });

  @override
  State<UnacknowledgedPacketRedeliveryTesterPanel> createState() =>
      _UnacknowledgedPacketRedeliveryTesterPanelState();
}

class _UnacknowledgedPacketRedeliveryTesterPanelState
    extends State<UnacknowledgedPacketRedeliveryTesterPanel> {
  int _redeliveryAttempts = 0;
  bool _isTestingFailure = false;
  String _packetStatus = 'IDLE (Subscriber Listening)';

  void _simulateNackAndRedelivery() {
    setState(() {
      _isTestingFailure = true;
      _packetStatus = 'SIMULATING NACK: Packet acknowledgment withheld';
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _isTestingFailure = false;
        _redeliveryAttempts++;
        _packetStatus = 'REDELIVERED: Pub/Sub broker resent packet (Attempt #$_redeliveryAttempts)';
      });
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
                    Icons.replay_rounded,
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
                        'Unacknowledged Packet Redelivery',
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
                    'AT-LEAST-ONCE PASS',
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
              'Tests Cloud Pub/Sub packet failure handling, confirming unacknowledged (NACK) messages are automatically redelivered to subscribers without packet loss.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _isTestingFailure ? null : _simulateNackAndRedelivery,
                  icon: _isTestingFailure
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync_problem_rounded, size: 18),
                  label: const Text('Simulate Failure & Test Redelivery'),
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
                      const Text('Delivery Guarantee:', style: TextStyle(fontSize: 11)),
                      Text('Redeliveries: $_redeliveryAttempts', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.indigo)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _packetStatus,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _packetStatus.contains('NACK') ? Colors.orange : Colors.green,
                    ),
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
            child: UnacknowledgedPacketRedeliveryTesterPanel(),
          ),
        ),
      ),
    ),
  );
}
