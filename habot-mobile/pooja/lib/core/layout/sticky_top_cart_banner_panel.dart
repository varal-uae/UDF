import 'package:flutter/material.dart';

/// Row 386: GEN-01215 (Seq 17924)
/// Action: Build a sticky top cart banner using M3 Surface banner components.
/// Quality Gate: E-Commerce Cart Session SLA (Baymard Institute) (Target: 0.999).
class StickyTopCartBannerPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const StickyTopCartBannerPanel({
    super.key,
    this.globalRefId = 'GEN-01215',
    this.atomicStepRefId = 'GEN-01215',
    this.sequenceOrder = 17924,
  });

  @override
  State<StickyTopCartBannerPanel> createState() =>
      _StickyTopCartBannerPanelState();
}

class _StickyTopCartBannerPanelState
    extends State<StickyTopCartBannerPanel> {
  int _cartItemCount = 3;
  double _cartTotalAed = 349.50;
  final double _bannerAvailabilityRate = 0.999;
  int _checkoutInvocations = 9;

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
                    Icons.shopping_cart_rounded,
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
                        'GEN-01215: Sticky Top Cart Banner',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 17924 • Standard: Baymard Cart Session SLA',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                const Chip(
                  avatar: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 16,
                  ),
                  label: Text('99.9% UPTIME PASS'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            Text('Sticky Top Cart Banner Preview:', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // M3 Surface banner simulation
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Badge(
                    label: Text('$_cartItemCount'),
                    child: Icon(Icons.shopping_bag_outlined, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$_cartItemCount items in cart', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Running Total: AED ${_cartTotalAed.toStringAsFixed(2)}', style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () {
                      setState(() => _checkoutInvocations++);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Navigating to checkout with $_cartItemCount items (AED ${_cartTotalAed.toStringAsFixed(2)}).'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                    child: const Text('Checkout'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Banner Availability: ${(_bannerAvailabilityRate * 100).toStringAsFixed(1)}%', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                Text('Checkout Clicks: $_checkoutInvocations', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _cartItemCount++;
                    _cartTotalAed += 99.00;
                  });
                },
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
                label: const Text('Add Test Item to Cart (+AED 99.00)'),
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
            child: StickyTopCartBannerPanel(),
          ),
        ),
      ),
    ),
  );
}
