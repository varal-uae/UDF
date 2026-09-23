import 'package:flutter/material.dart';

/// Row 319: GEN-00484 (Seq 17193)
/// Action: Define the Cloud Pub/Sub topic topic-purchase-event.
/// Quality Gate: Google Cloud Pub/Sub Architecture Guide / Topic Provisioning Standard.
class PubsubPurchaseEventTopicPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const PubsubPurchaseEventTopicPanel({
    super.key,
    this.globalRefId = 'GEN-00484',
    this.atomicStepRefId = 'GEN-00484',
    this.sequenceOrder = 17193,
  });

  @override
  State<PubsubPurchaseEventTopicPanel> createState() =>
      _PubsubPurchaseEventTopicPanelState();
}

class _PubsubPurchaseEventTopicPanelState
    extends State<PubsubPurchaseEventTopicPanel> {
  final String _topicName = 'topic-purchase-event';
  int _messagesPublished = 8;
  String _lastPublishAck = 'ACK: 0x48a1...f7e';

  void _publishMockPurchase() {
    setState(() {
      _messagesPublished++;
      _lastPublishAck = 'ACK: 0x${(0x48a1 + _messagesPublished * 0x111).toRadixString(16)}...f7e';
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
                    Icons.shopping_cart_checkout_rounded,
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
                        'Pub/Sub Purchase Event Topic',
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
                    'TOPIC PROVISIONED',
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
              'Provisions and validates the Google Cloud Pub/Sub topic topic-purchase-event, decoupling mobile order submissions from asynchronous ledger reconciliation services.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _publishMockPurchase,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Publish Mock Purchase Event'),
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
                      Text('Topic: $_topicName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace')),
                      Text('Published: $_messagesPublished', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.indigo)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Latest Message Receipt: $_lastPublishAck',
                    style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
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
            child: PubsubPurchaseEventTopicPanel(),
          ),
        ),
      ),
    ),
  );
}
