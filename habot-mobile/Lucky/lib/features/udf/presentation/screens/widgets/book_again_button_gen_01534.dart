// GEN-01534 — Book Again M3 Filled Tonal Button for completed order history cards.
// Embeds a Material 3 Filled Tonal Button with 48x48dp touch targets, responsive layout support, and local mock data.

import 'package:flutter/material.dart';

/// Mock model representing a completed order for local rendering.
class MockCompletedOrder {
  final String orderId;
  final String serviceName;
  final DateTime completedAt;
  final double amount;

  const MockCompletedOrder({
    required this.orderId,
    required this.serviceName,
    required this.completedAt,
    required this.amount,
  });
}

/// Static mock data simulating backend response for completed orders.
const List<MockCompletedOrder> kMockCompletedOrders = [
  MockCompletedOrder(
    orderId: 'ORD-99281',
    serviceName: 'Deep Cleaning Service',
    completedAt: DateTime(2026, 9, 15, 14, 30),
    amount: 350.00,
  ),
  MockCompletedOrder(
    orderId: 'ORD-99282',
    serviceName: 'AC Maintenance',
    completedAt: DateTime(2026, 9, 10, 10, 0),
    amount: 150.00,
  ),
];

/// A reusable widget that renders an M3 Elevated Card containing order details
/// and a "Book Again" Filled Tonal Button.
/// 
/// Enforces minimum 48x48dp touch targets as per M3 accessibility guidelines.
/// Adapts to single-column mobile (<600dp) and multi-column desktop (>=840dp) layouts.
class BookAgainOrderCard extends StatelessWidget {
  final MockCompletedOrder order;
  final VoidCallback? onBookAgainPressed;

  const BookAgainOrderCard({
    super.key,
    required this.order,
    this.onBookAgainPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.serviceName,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // M3 Status Chip for completion state
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'Completed',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              'Order ID: ${order.orderId}',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Completed on: ${_formatDate(order.completedAt)}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'AED ${order.amount.toStringAsFixed(2)}',
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: _BookAgainButton(
                onPressed: onBookAgainPressed ?? () => _handleBookAgain(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _handleBookAgain(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Re-booking initiated for ${order.serviceName}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Internal M3 Filled Tonal Button implementation enforcing 48x48dp touch targets.
class _BookAgainButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BookAgainButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 48.0,
        minWidth: 48.0,
      ),
      child: FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // M3 standard rounded shape
          ),
        ),
        child: const Text('Book Again'),
      ),
    );
  }
}

/// A sample screen demonstrating the responsive layout of [BookAgainOrderCard].
/// Single-column on mobile (<600dp), multi-column on desktop (>=840dp).
class OrderHistoryScreenGen01534 extends StatelessWidget {
  const OrderHistoryScreenGen01534({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 840;
    final crossAxisCount = isDesktop ? 2 : 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        centerTitle: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: isDesktop ? 2.5 : 1.8,
            ),
            itemCount: kMockCompletedOrders.length,
            itemBuilder: (context, index) {
              return BookAgainOrderCard(
                order: kMockCompletedOrders[index],
              );
            },
          );
        },
      ),
    );
  }
}