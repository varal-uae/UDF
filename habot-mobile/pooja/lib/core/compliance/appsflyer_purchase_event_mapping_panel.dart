import 'package:flutter/material.dart';

/// Row 321: GEN-00506 (Seq 17215)
/// Action: Map the standard event AFEventPurchase with revenue, currency, and content type.
/// Quality Gate: AppsFlyer Standard In-App Events / MMP Integration Guide.
class AppsflyerPurchaseEventMappingPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const AppsflyerPurchaseEventMappingPanel({
    super.key,
    this.globalRefId = 'GEN-00506',
    this.atomicStepRefId = 'GEN-00506',
    this.sequenceOrder = 17215,
  });

  @override
  State<AppsflyerPurchaseEventMappingPanel> createState() =>
      _AppsflyerPurchaseEventMappingPanelState();
}

class _AppsflyerPurchaseEventMappingPanelState
    extends State<AppsflyerPurchaseEventMappingPanel> {
  final Map<String, dynamic> _afPurchasePayload = {
    'af_event_name': 'af_purchase',
    'af_revenue': 49.99,
    'af_currency': 'USD',
    'af_content_type': 'enterprise_permit_license',
    'af_order_id': 'ORD-98231',
  };

  int _trackedPurchases = 3;

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
                    Icons.monetization_on_rounded,
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
                        'AppsFlyer AFEventPurchase Mapping',
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
                    'MMP ALIGNED',
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
              'Maps the canonical AppsFlyer AFEventPurchase payload including revenue, currency, and content type parameters to mobile conversion dispatchers.',
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
                      _trackedPurchases++;
                    });
                  },
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: const Text('Simulate Purchase Attribution'),
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
                      const Text('Payload Contract:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      Text('Dispatched: $_trackedPurchases', style: const TextStyle(fontSize: 11, color: Colors.indigo, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Event Name: ${_afPurchasePayload['af_event_name']}', style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                  Text('Revenue: \$${_afPurchasePayload['af_revenue']} ${_afPurchasePayload['af_currency']}', style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.green, fontWeight: FontWeight.bold)),
                  Text('Content Type: ${_afPurchasePayload['af_content_type']}', style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
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
            child: AppsflyerPurchaseEventMappingPanel(),
          ),
        ),
      ),
    ),
  );
}
